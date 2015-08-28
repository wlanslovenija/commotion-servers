docker:
  containers:
    tokumx:
      image: wlanslovenija/tokumx
      environment:
        TOKUMX_ARGS: --cacheSize 2G --directio
      sysfs:
        kernel.mm.transparent_hugepage.enabled: never
      volumes:
        /srv/storage/tokumx:
          bind: /var/lib/tokumx
          user: 102
          group: 105
        /srv/log/tokumx:
          bind: /var/log/tokumx
          user: nobody
          group: nogroup
          logrotate: True
