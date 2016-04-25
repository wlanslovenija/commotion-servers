#!yaml|gpg
docker:
  containers:
    nodewatcher-frontend:
      image: wlanslovenija/nodewatcher-frontend
      environment:
        # We use a different virtual host for pushing monitoring data as we configure
        # TLS client authentication there.
        - VIRTUAL_HOST: nodewatcher.commotionwireless.net,push.nodewatcher.commotionwireless.net
          VIRTUAL_URL: /
        - nodewatcher
        - postgresql
      config:
        nodewatcher: /code/nodewatcher/settings_production.py
      files:
        /srv/storage/ssl/push.nodewatcher.commotionwireless.net_nonssl.conf: |
          # Allow push without SSL (needed for simple sensors). There is still a
          # per-node configuration that determines whether this should be allowed.
          location /push/http/ {
            proxy_pass http://push.nodewatcher.commotionwireless.net-u;
          }
        /srv/storage/ssl/push.nodewatcher.commotionwireless.net_ssl.conf: |
          # Setup client authentication. Allow authentication with any certificate
          # as all verification is done by the nodewatcher modules.
          ssl_verify_client optional_no_ca;

          # Accept push requests.
          location ~ ^/push/http[/$] {
            proxy_pass http://push.nodewatcher.commotionwireless.net-u;
          }

          # Redirect all other requests to the main site.
          location ~ / {
            return 301 https://nodewatcher.commotionwireless.net$request_uri;
          }
        /srv/storage/ssl/nodewatcher.commotionwireless.net_ssl.conf: |
          # Redirect push requests to its proper virtual host.
          location /push/http/ {
            return 301 https://push.nodewatcher.commotionwireless.net$request_uri;
          }
      volumes:
        /srv/storage/discovery/hosts:
          bind: /etc/hosts
          type: container
          container: discovery
          readonly: True
        /srv/storage/nodewatcher/media:
          bind: /media
          user: www-data
          group: www-data
          mode: 755
        /srv/storage/nodewatcher/static:
          bind: /static
        /srv/log/nodewatcher/uwsgi:
          bind: /var/log/uwsgi
          user: nobody
          group: nogroup
    nodewatcher-generator:
      image: wlanslovenija/nodewatcher-generator
      environment:
        - nodewatcher
        - postgresql
      config:
        nodewatcher: /code/nodewatcher/settings_production.py
      volumes:
        /srv/storage/discovery/hosts:
          bind: /etc/hosts
          type: container
          container: discovery
          readonly: True
        /srv/storage/nodewatcher/media:
          bind: /media
          user: www-data
          group: www-data
          mode: 755
        /srv/log/nodewatcher/generator:
          bind: /var/log/celery
          user: nobody
          group: nogroup
    nodewatcher-monitor:
      image: wlanslovenija/nodewatcher-monitor
      environment:
        - nodewatcher
        - postgresql
      config:
        nodewatcher: /code/nodewatcher/settings_production.py
      volumes:
        /srv/storage/discovery/hosts:
          bind: /etc/hosts
          type: container
          container: discovery
          readonly: True
        /srv/storage/nodewatcher/media:
          bind: /media
          user: www-data
          group: www-data
          mode: 755
        /srv/log/nodewatcher/monitor:
          bind: /var/log/monitor
          user: nobody
          group: nogroup
    nodewatcher-monitorq:
      image: wlanslovenija/nodewatcher-monitorq
      environment:
        - nodewatcher
        - postgresql
      config:
        nodewatcher: /code/nodewatcher/settings_production.py
      volumes:
        /srv/storage/discovery/hosts:
          bind: /etc/hosts
          type: container
          container: discovery
          readonly: True
        /srv/storage/nodewatcher/media:
          bind: /media
          user: www-data
          group: www-data
          mode: 755
        /srv/log/nodewatcher/monitorq:
          bind: /var/log/celery
          user: nobody
          group: nogroup
  environments:
    nodewatcher:
      DJANGO_SETTINGS_MODULE: nodewatcher.settings_production
      SECRET_KEY: |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v1

        hQEMA4LktP2+6CAcAQf+KRmE/nENsirZDIX8vV3pgLXIwzg141iNKMgXKQUSBmOZ
        so4KhdijdVb59yOZ/NYG3Y9dgv9R3pW0EI3b3xMdBs+YWHw2nyVqyu2vlL2eJYMh
        NQddHa8a7y4rZ7KOXYwmbAttBbW7gJFYoQ0xTwFQKY1TmBpaJcsd2BNJBWhwRRtN
        D1fzdO8l7uuloQylOYbSR/H4Zmk6QAy+JNRP0QIZd1wRIxQJE7mBcKTfRILxQm8t
        amx92KrLtTsueR9/J4+ygXWXYorzK4f0ISUTROdKHyf0rp6hafKdH7XHx5M0Pj9w
        D2/z1HbF0cRPNfQZ2fY+QWBneJyOWYdA89UU6NtndtJjAWWUx4jQIL1i4u5EwM+f
        fXcQLcPVm6tEKb/HTjqZqEY4icBGbiS4clbRIdfkCQiMa/354gg02p6nIm1utgNf
        Y0gKMduVCStas8IjUMtCSRqtJtNUG97MyjJY1u5uOc4uyLwe
        =hi5m
        -----END PGP MESSAGE-----
  configs:
    nodewatcher: |
      from .settings import *

      DEBUG = False
      TEMPLATE_DEBUG = False
      TEMPLATE_URL_RESOLVERS_DEBUG = False

      SECRET_KEY = os.environ.get('SECRET_KEY')

      DATABASES = {
          'default': {
              'ENGINE': 'django.contrib.gis.db.backends.postgis',
              'NAME': 'nodewatcher',
              'USER': 'nodewatcher',
              'PASSWORD': os.environ.get('PGSQL_ROLE_1_PASSWORD', ''),
              'HOST': 'postgresql',
              'PORT': '5432',
          }
      }

      MEDIA_ROOT = '/media'
      STATIC_ROOT = '/static'

      EMAIL_HOST = ''
      DEFAULT_FROM_EMAIL = 'notifications@nodewatcher.commotionwireless.net'

      CELERY_RESULT_BACKEND = 'mongodb'
      CELERY_MONGODB_BACKEND_SETTINGS = {
        'host': 'tokumx',
        'port': '27017',
        'database': 'nodewatcher_celery',
        'taskmeta_collection': 'celery_taskmeta',
        'options': {
          'tz_aware': USE_TZ,
        }
      }

      BROKER_URL = 'mongodb://tokumx:27017/nodewatcher_celery'

      DATASTREAM_BACKEND = 'datastream.backends.mongodb.Backend'
      DATASTREAM_BACKEND_SETTINGS = {
        'database_name': 'nodewatcher_ds',
        'host': 'tokumx',
        'port': 27017,
        'tz_aware': USE_TZ,
      }

      INSTALLED_APPS = (
        # Common frontend libraries before nodewatcher.core.frontend.
        # Uses "prepend_data" to assure libraries are loaded first.
        'nodewatcher.extra.jquery',
        'nodewatcher.extra.normalize',

        # Extend the default frontend with skyline banner
        'nodewatcher.modules.frontend.skyline',

        # Ours are at the beginning so that we can override default templates in 3rd party Django apps.
        'nodewatcher.core',
        'nodewatcher.core.allocation',
        'nodewatcher.core.allocation.ip',
        'nodewatcher.core.events',
        'nodewatcher.core.frontend',
        'nodewatcher.core.generator.cgm',
        'nodewatcher.core.generator',
        'nodewatcher.core.monitor',
        'nodewatcher.core.registry',

        # Modules.
        'nodewatcher.modules.administration.types',
        'nodewatcher.modules.administration.projects',
        'nodewatcher.modules.administration.location',
        'nodewatcher.modules.administration.description',
        'nodewatcher.modules.administration.status',
        'nodewatcher.modules.equipment.antennas',
        'nodewatcher.modules.platforms.openwrt',
        'nodewatcher.modules.devices',
        'nodewatcher.modules.identity.base',
        'nodewatcher.modules.identity.public_key',
        'nodewatcher.modules.monitor.sources.http',
        'nodewatcher.modules.monitor.datastream',
        'nodewatcher.modules.monitor.http.resources',
        'nodewatcher.modules.monitor.http.interfaces',
        'nodewatcher.modules.monitor.http.clients',
        'nodewatcher.modules.monitor.topology',
        'nodewatcher.modules.monitor.validation.reboot',
        'nodewatcher.modules.monitor.validation.version',
        'nodewatcher.modules.monitor.validation.interfaces',
        'nodewatcher.modules.services.nodeupgrade',
        'nodewatcher.modules.routing.olsr',
        'nodewatcher.modules.authentication.public_key',
        'nodewatcher.modules.events.sinks.db_sink',
        'nodewatcher.modules.frontend.display',
        'nodewatcher.modules.frontend.editor',
        'nodewatcher.modules.frontend.list',
        'nodewatcher.modules.frontend.mynodes',
        'nodewatcher.modules.frontend.statistics',
        'nodewatcher.modules.frontend.topology',
        'nodewatcher.modules.frontend.generator',
        'nodewatcher.modules.frontend.map',
        'nodewatcher.modules.administration.banner',

        # Defaults for commotion network.
        'nodewatcher.extra.commotion',

        # Accounts support.
        'nodewatcher.extra.accounts',

        'django.contrib.auth',
        'django.contrib.contenttypes',
        'django.contrib.sessions',
        'django.contrib.sites',
        'django.contrib.messages',
        'django.contrib.sitemaps',
        'django.contrib.admin',
        'django.contrib.gis',

        # We override staticfiles runserver with default Django runserver in
        # nodewatcher.core.frontend, which is loaded before for this to work.
        'django.contrib.staticfiles',

        'polymorphic',
        'tastypie',
        'django_datastream',
        'guardian',
        'sekizai',
        'missing',
        'timezone_field',
        'overextends',
        'json_field',
        'leaflet',
        'django_countries',
        'timedelta',
        'registration',
      )

      TELEMETRY_PROCESSOR_PIPELINE = (
        # Validators should start here in order to obtain previous state.
        'nodewatcher.modules.monitor.validation.reboot.processors.RebootValidator',
        'nodewatcher.modules.monitor.validation.version.processors.VersionValidator',
        'nodewatcher.modules.monitor.validation.interfaces.processors.InterfaceValidator',
        # Telemetry processors should be below this point.
        'nodewatcher.modules.monitor.sources.http.processors.HTTPTelemetry',
        'nodewatcher.modules.monitor.http.general.processors.GeneralInfo',
        'nodewatcher.modules.monitor.http.resources.processors.SystemStatus',
        'nodewatcher.modules.monitor.http.interfaces.processors.DatastreamInterfaces',
        'nodewatcher.modules.monitor.http.clients.processors.ClientInfo',
        'nodewatcher.modules.routing.olsr.processors.NodeTopology',
        'nodewatcher.modules.administration.status.processors.NodeStatus',
        'nodewatcher.modules.monitor.datastream.processors.NodeDatastream',
      )

      MONITOR_RUNS = {
        'telemetry-push': {
            # This run does not define any scheduling or worker information, so it will only be
            # executed on demand.
            'processors': (
                'nodewatcher.modules.monitor.sources.http.processors.HTTPGetPushedNode',
                'nodewatcher.modules.identity.public_key.processors.VerifyNodePublicKey',
                'nodewatcher.modules.monitor.datastream.processors.TrackRegistryModels',
                TELEMETRY_PROCESSOR_PIPELINE,
            ),
        },

        'datastream': {
            'workers': 2,
            'interval': 700,
            'max_tasks_per_child': 1,
            'processors': (
                'nodewatcher.modules.monitor.datastream.processors.MaintenanceBackprocess',
                'nodewatcher.modules.monitor.datastream.processors.MaintenanceDownsample',
            ),
        },
      }

      MONITOR_HTTP_PUSH_HOST = 'push.nodewatcher.commotionwireless.net'

      MEASUREMENT_SOURCE_NODE = ''

      USE_HTTPS = True

      HTTPS_PUBLIC_KEY = """
      -----BEGIN PUBLIC KEY-----
      MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAppNNz/YB9MmM1EBw3ajF
      ZWZ6y8q/3Vui3ZBJveRIYvnbO2Okn3/clJxRLAQhhHn86YrtIgpMrhirgvZDIdTv
      rHz+CT4WntjlEX/sxaJ3lnbzTX+S0dR99gB8ysmByKba3Y2H9syZ123qt/rfSfWM
      thy+zrMjuJcspf9XSbFrsopN9XZRGynuFkr1HmP0NKqxucP7MdoL4nI8CB2euphB
      nsUeEifBJoQfTFkE4ryLe96AjDpENnOx5MJhvoIuHSPw3NNeGcYtvverQQ+0PTZa
      QHrv+k9rCTdn+wN0CxpusBGj/zny6/D5A18K/U5clVpmJfGGyl4utMCDe47ifEa2
      +wIDAQAB
      -----END PUBLIC KEY-----
      """

      NETWORK = {
        'NAME': 'Commotion Wireless',
        'HOME': 'https://commotionwireless.net',
        'CONTACT': 'support@commotionwireless.net',
        'CONTACT_PAGE': 'https://commotionwireless.net/contact',
        'DESCRIPTION': 'open wireless network in your neighborhood',
        'FAVICON_FILE': None,
        'LOGO_FILE': None,
        'DEFAULT_PROJECT': None,
      }

      ALLOWED_HOSTS = os.environ.get('VIRTUAL_HOST', '127.0.0.1').split(',')
