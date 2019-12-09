
Create dependencies
```sh
helm install my-redis \
  --set password=redis \
    stable/redis
helm install my-psql \
  --set postgresqlPassword=collector,postgresqlUsername=collector,postgresqlDatabase=collector \
    stable/postgresql
helm install collector .
```