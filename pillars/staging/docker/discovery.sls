docker:
  containers:
    discovery:
      image: tozd/docker-hosts
      volumes:
        /var/run/docker.sock:
          bind: /var/run/docker.sock
          type: socket
        /srv/storage/discovery/hosts:
          bind: /hosts
          type: file
          user: nobody
          group: nogroup
