# OAuth2

Reverse proxy

Will just add images into registry for using later

## Using oauth2-proxy with keycloak

Need to edit coredns configmap and add keycloak.hostname and auth.hostname to hosts
```sh
kubectl edit cm/coredns -n kube-system
```
Kill coredns pod to refresh

## HOME CONFIG

```
│                                                                       Autoscroll:On      FullScreen:Off     Timestamps:Off     Wrap:Off                                                                       ││ [2023/08/21 15:42:32] [provider.go:55] Performing OIDC Discovery...                                                                                                                                           ││ [2023/08/21 15:42:33] [providers.go:145] Warning: Your provider supports PKCE methods ["plain" "S256"], but you have not enabled one with --code-challenge-method                                             ││ [2023/08/21 15:42:33] [proxy.go:77] mapping path "/" => static response 202                                                                                                                                   ││ [2023/08/21 15:42:33] [oauthproxy.go:162] OAuthProxy configured for OpenID Connect Client ID: oauth2-proxy                                                                                                    ││ [2023/08/21 15:42:33] [oauthproxy.go:168] Cookie settings: name:_oauth2_proxy secure(https):false httponly:true expiry:168h0m0s domains:*.swk3s path:/ samesite: refresh:disabled                             ││ 10.42.0.1 - c8eaeb83-e189-4dfa-aa19-877b140ca756 - eikendram@gmail.com [2023/08/21 15:43:17] auth.swk3s GET static://202 "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, l ││ 10.42.0.1 - c3ac91db-1f1e-45be-91c2-f3b4a5711107 - eikendram@gmail.com [2023/08/21 15:43:25] auth.swk3s GET static://202 "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, l ││ [2023/08/21 15:43:49] [oauthproxy.go:959] No valid authentication in request. Initiating login.                                                                                                               ││ 10.42.0.1 - 3f5a982f-4b65-482d-a32a-a81fc30ccaa3 - - [2023/08/21 15:43:49] auth.swk3s GET - "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 S ││ [2023/08/21 15:43:50] [oauthproxy.go:959] No valid authentication in request. Initiating login.                                                                                                               ││ 10.42.0.1 - 6d8c4eb0-1f31-4316-9c2b-a4920dee153e - - [2023/08/21 15:43:50] auth.swk3s GET - "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 S ││ [2023/08/21 15:43:50] [oauthproxy.go:959] No valid authentication in request. Initiating login.                                                                                                               ││ 10.42.0.1 - 25dcdf63-9034-4665-8740-0ef1a9d4f73c - - [2023/08/21 15:43:50] auth.swk3s GET - "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 S ││ [2023/08/21 15:43:54] [cookies.go:21] Warning: request host "whoami.swk3s" did not match any of the specific cookie domains of "*.swk3s"                                                                      ││ [2023/08/21 15:43:54] [cookies.go:84] Warning: request host is "whoami.swk3s" but using configured cookie domain of "*.swk3s"                                                                                 ││ 2023/08/21 15:43:54 net/http: invalid Cookie.Domain "*.swk3s"; dropping domain attribute                                                                                                                      ││ 10.42.0.1 - c2c806a0-a68a-4c33-8115-23fcc81b0d9a - - [2023/08/21 15:43:54] whoami.swk3s GET - "/oauth2/start?rd=%2F" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Geck ││ [2023/08/21 15:43:59] [cookies.go:21] Warning: request host "whoami.swk3s" did not match any of the specific cookie domains of "*.swk3s"                                                                      ││ [2023/08/21 15:43:59] [cookies.go:84] Warning: request host is "whoami.swk3s" but using configured cookie domain of "*.swk3s"                                                                                 ││ 2023/08/21 15:43:59 net/http: invalid Cookie.Domain "*.swk3s"; dropping domain attribute                                                                                                                      ││ [2023/08/21 15:43:59] [cookies.go:21] Warning: request host "whoami.swk3s" did not match any of the specific cookie domains of "*.swk3s"                                                                      ││ [2023/08/21 15:43:59] [cookies.go:84] Warning: request host is "whoami.swk3s" but using configured cookie domain of "*.swk3s"                                                                                 ││ 2023/08/21 15:43:59 net/http: invalid Cookie.Domain "*.swk3s"; dropping domain attribute                                                                                                                      ││ 2023/08/21 15:43:59 net/http: invalid Cookie.Domain "*.swk3s"; dropping domain attribute                                                                                                                      ││ 10.42.0.1 - 322f233f-4375-40e0-a4a7-acee3673d216 - eikendram@gmail.com [2023/08/21 15:43:59] [AuthSuccess] Authenticated via OAuth2: Session{email:eikendram@gmail.com user:0210adac-6d62-41f4-8c42-70e97cc76 ││ 10.42.0.1 - 322f233f-4375-40e0-a4a7-acee3673d216 - - [2023/08/21 15:43:59] whoami.swk3s GET - "/oauth2/callback?state=bxHcM7deXFB8rfHOvNvI1ywvAcAJUglAMZMCTqRmy_8%3A%2F&session_state=6eab3ee9-44f0-420b-917c ││ 10.42.0.1 - 3a4dee5d-df1b-4a3a-bf3a-c0c64a631e24 - eikendram@gmail.com [2023/08/21 15:43:59] auth.swk3s GET static://202 "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, l ││ 10.42.0.1 - 06792624-2666-42ff-983e-c135975623d4 - eikendram@gmail.com [2023/08/21 15:44:00] auth.swk3s GET static://202 "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, l ││ 10.42.0.1 - b8704ca4-1dbb-4fd1-b725-7c3dcca49da4 - eikendram@gmail.com [2023/08/21 15:44:21] auth.swk3s GET static://202 "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, l ││ 10.42.0.1 - 906b1bb6-6858-48f3-b2b6-8e937591c757 - eikendram@gmail.com [2023/08/21 15:44:21] auth.swk3s GET static://202 "/" HTTP/1.1 "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, l ││                                                                                                                                                                                                               ││                              
```

```yaml
spec:
  automountServiceAccountToken: true
  containers:
  - args:
    - --http-address=0.0.0.0:4180
    - --https-address=0.0.0.0:4443
    - --metrics-address=0.0.0.0:44180
    - --config=/etc/oauth2_proxy/oauth2_proxy.cfg
    env:
    - name: OAUTH2_PROXY_CLIENT_ID
      valueFrom:
        secretKeyRef:
          key: client-id
          name: keycloak-oauth2-proxy
    - name: OAUTH2_PROXY_CLIENT_SECRET
      valueFrom:
        secretKeyRef:
          key: client-secret
          name: keycloak-oauth2-proxy
    - name: OAUTH2_PROXY_COOKIE_SECRET
      valueFrom:
        secretKeyRef:
          key: cookie-secret
          name: keycloak-oauth2-proxy
    image: quay.io/oauth2-proxy/oauth2-proxy:v7.4.0
```

```yaml
apiVersion: v1
data:
  oauth2_proxy.cfg: |-
    provider = "oidc"
    oidc_issuer_url = "http://keycloak.swk3s/realms/cluster"
    ssl_insecure_skip_verify="true"
    scope="openid email profile groups"
    reverse_proxy = "true"
    cookie_secure = "false"
    email_domains = [ "*" ]
    cookie_domains = ["*.swk3s" ]
    upstreams = [ "static://202" ]
    silence_ping_logging = "true"
```

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
spec:
  routes:
  - kind: Rule
    match: Host(`auth.swk3s`)
    middlewares:
    - name: oauth2-proxy-headers
    services:
    - name: keycloak-oauth2-proxy
      port: 80
```

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
spec:
  routes:
  - kind: Rule
    match: Host(`whoami.swk3s`)
    middlewares:
    - name: auth-proxy
      namespace: default
    services:
    - name: whoami
      port: 80
```

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
spec:
  routes:
  - kind: Rule
    match: Host(`whoami.swk3s`) && PathPrefix(`/oauth2/`)
    middlewares:
    - name: oauth2-proxy-headers
    services:
    - name: keycloak-oauth2-proxy
      port: 80
```


```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: auth-proxy
  namespace: default
spec:
  forwardAuth:
    address: http://auth.swk3s/
    authResponseHeaders:
    - X-Auth-Request-Access-Token
    - Authorization
    trustForwardHeader: true
```


```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: Middleware
metadata:
  name: oauth2-proxy-headers
  namespace: default
spec:
  headers:
    browserXssFilter: true
    contentTypeNosniff: true
    forceSTSHeader: true
    frameDeny: true
    sslRedirect: false
    stsIncludeSubdomains: true
    stsPreload: true
    stsSeconds: 315360000
```