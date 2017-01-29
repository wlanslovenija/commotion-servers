docker:
  containers:
    nginx-proxy:
      image: wlanslovenija/nginx-proxy
      ports:
        80/tcp:
          ip: 192.168.12.26
          port: 80
        443/tcp:
          ip: 192.168.12.26
          port: 443
      volumes:
        /srv/storage/ssl:
          bind: /ssl
          user: root
          group: root
          mode: 701
        /var/run/docker.sock:
          bind: /var/run/docker.sock
          type: socket
        /srv/log/nginx-proxy:
          bind: /var/log/nginx
          user: nobody
          group: nogroup
