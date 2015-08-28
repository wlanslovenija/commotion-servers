#!yaml|gpg
docker:
  containers:
    postgresql:
      image: wlanslovenija/postgis
      volumes:
        /srv/storage/postgresql:
          bind: /var/lib/postgresql/9.3/main
          user: 102
          group: 106
        /srv/log/postgresql:
          bind: /var/log/postgresql
          user: nobody
          group: nogroup
          logrotate: True
      environment:
        - postgresql
  environments:
    postgresql:
      PGSQL_ROLE_1_USERNAME: nodewatcher
      PGSQL_ROLE_1_PASSWORD: dS9ZZKqmdfNoXsjptMy4va0c1ZwSVcrdrFcF39Dt
      PGSQL_ROLE_1_FLAGS: LOGIN
      PGSQL_DB_1_NAME: nodewatcher
      PGSQL_DB_1_OWNER: nodewatcher
      PGSQL_DB_1_ENCODING: UNICODE
