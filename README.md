
Create dependencies
```sh
helm install my-redis \
  --set password=redis \
    stable/redis

helm install my-psql \
  --set postgresqlPassword=collector,postgresqlUsername=collector,postgresqlDatabase=collector \
    stable/postgresql

helm install k-psql \
  --set postgresqlPassword=kong,postgresqlUsername=kong,postgresqlDatabase=kong \
    stable/postgresql

helm install my-kong stable/kong -f kong-values.yaml

helm install collector .
```