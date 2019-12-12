
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

### TODO

- use ingress in testing environment
- fix hardcoded admin_api ip address in kong-values.yaml
- remove unnecessarily exposed env vars in collector deployments
- remove license and regcred secrets