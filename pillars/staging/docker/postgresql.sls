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
      environment:
        - postgresql
  environments:
    postgresql:
      PGSQL_ROLE_1_USERNAME: nodewatcher
      PGSQL_ROLE_1_PASSWORD: |
        -----BEGIN PGP MESSAGE-----
        Version: GnuPG v1

        hQEMA4LktP2+6CAcAQf/XeceFFtxGzGrH3L4Yp079Ltln+9JnF9KqveH68tzo6HY
        +gRkXfslBwZL0XlO5ef63RWZBa2V8NL+c7K2ShGVEdXIhS+qRp3hAj0EiRbJnL/v
        9trHVv1BH8/Fktx7gU2Wknxy4eXW9VPId/4T2bLrHiKjbqjNf2ZAA9PqqIEnMJA2
        CgD0aRj81blNGUD0935DXDQUcQ/ey0Xypc6N9Rtpq+irqLC2aW5xB/xNhANQwKB0
        tBymekDdmyP1q+KnDagLFiJoJFWfJhlJW8RRu7YS+Nz7PRQ3Jjb1CwnWYI7v+LCE
        64myyadRyLKsZZewy0c/r77qJ1PilxnZcR6BIUqXj9JjAcJhEf4WmSjYVhgELJs9
        cLo2LVTsZsoftK0NQA2sNgoWPz7JWs7QmZkaAUEnbk8BP0joqGVbjJ7E9mvvPcNw
        wuK1RapsdL5e/oSJ3smy2usDw5KHhnNzlkcg4/UPxCTE6j9L
        =/IGe
        -----END PGP MESSAGE-----
      PGSQL_ROLE_1_FLAGS: LOGIN
      PGSQL_DB_1_NAME: nodewatcher
      PGSQL_DB_1_OWNER: nodewatcher
      PGSQL_DB_1_ENCODING: UNICODE
