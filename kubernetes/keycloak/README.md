# Keycloak

This is access manager for cluster resources using singe sign-on policy

## Images

```
docker.io/bitnami/postgresql:15.3.0-debian-11-r17
docker.io/bitnami/keycloak:21.1.2-debian-11-r5
```

## Install

Install from helm:
```sh
helm install keycloak gitea/keycloak -f manifest/keycloak/values.yaml -n keycloak --create-namespace
```

## Batch update password

In order to provide admin-cli secret need to switch client auth on and copy the token here

Now we need to generate access token for `admin-cli`:
```sh
export access_token=$(curl --insecure -X POST http://keycloak.k3s.local/realms/master/protocol/openid-connect/token --user admin-cli:DBUfVLsd7iSDe1XD96dpr8Vz4cuPJiD3 -H 'content-type: application/x-www-form-urlencoded' -d 'username=admin&password=coreos&grant_type=password' | jq --raw-output '.access_token' )
```

Or with username and password:
```sh
curl --location --request POST 'http://localhost:8080/auth/realms/master/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'username=admin2' \
--data-urlencode 'password=admin2' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'client_id=admin-cli'
```

Or with access token:
```sh
curl --location --request POST 'http://localhost:8080/auth/realms/master/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=client_credentials' \
--data-urlencode 'client_id=admin-cli' \
--data-urlencode 'client_secret=7fb49e15-2a86-4b7c-a648-27746c67895b'
```

Duration is 1 minute, can be changed in settings

List all users:
```sh
curl -k -X GET http://keycloak.k3s.local/admin/realms/master/users -H "Authorization: Bearer "$access_token | jq
```

Change password for user:
```sh
curl -k -X POST http://keycloak.k3s.local/admin/realms/master/users/b910fa62-8c74-4ea5-95de-129814155d5b/reset-password -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" --data '{ "value": "newpassword" }'
```

To add user execute a POST http://<host>/admin/realms/<realm>/users with a JSON Payload which contains details about the User
```sh
curl -k -X POST http://keycloak.k3s.local/admin/realms/master/users/ -H "Content-Type: application/json" -H "Authorization: Bearer $access_token" --data '{ "value": "newpassword" }'
```

Or:
```sh
curl --location --request POST 'http://keycloak.k3s.local/auth/admin/realms/master/users' \
--header 'Content-Type: application/json' \
--header 'Authorization: Bearer $access_token' \
--data-raw '{"firstName":"Aiken","lastName":"Dram", "email":"test@test.com", "enabled":"true", "username":"app-user"}'
```

Alright this works, can later write some sort of console tool (maybe in go) to bulk update user passwords from a file

## Reverse proxy a resource inside kubernetes cluster

<2D>