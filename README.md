static
======

An nginx caching proxy for routing traffic throughout the Zooniverse backend infrastructure.

Run it locally with Docker:

``` bash
docker-compose build
docker-compose up
```

And access it at http://localhost:8080/.

#### Testing your changes locally

Use curl to test the behaviour of your target or default server block:

``` bash
curl -v -H "Host: www.zooniverse.org" http://localhost:8080/main-54f00afe77a81c4ff6b88b1e0bee34bc.css
```

Test routing directives by checking the response headers

``` bash
curl -LI -H "Host: www.zooniverse.org" http://localhost:8080/projects/project-user/specific-routing-rule
HTTP/1.1 200 OK
...
X-Powered-By: Next.js # Routed to FEM

curl -LI -H "Host: alice.zooniverse.org" http://localhost:8080/
HTTP/1.1 200 OK
...
x-ms-request-id: 7d36afce-401e-000b-6b24-80c33b000000 # Routed to az blob storage
```

Test the default - [first server block](https://github.com/zooniverse/static/blob/1572db64aaeb38d904e1a60de00e9f06871414df/nginx.conf#L69)

``` bash
# provide an unknown host to test the default server block.
# making sure it matches path in the upstream proxy
curl -v -H "Host: talk.sunspotter.org" http://localhost:8080/users/%E7%8E%8B%E5%8F%AF%E8%90%B1/index.html
```

Note: You must provide a host when testing locally or the implicit `localhost` host header will be used.

Read more at the [Nginx request processing docs](http://nginx.org/en/docs/http/request_processing.html)

## Deployment
The nginx proxy portion of this repo is deployed to staging on pushes to the master branch via a Github Action. Deploys to production occur on pushes to the `production-release` tag and can be initiated via chatops in Slack with `lita deploy static`.

Ingress application also managed via a `production-ingresses` tag, which triggers the Apply Ingresses workflow. This workflow checks the diff between the hash tagged by the `production-ingress-release` tag and the current head and applies the templates that have changed. It then updates the latter tag to indicate the updates have been made. The `production-ingreses` tag can be pushed manually or via chatops with the `lita apply ingresses` command.

The hash of the current deployment is available by sending a request with the host header `proxy-version`:

``` bash
curl -v -H "Host: proxy-version" http://localhost:8080
asdf1234
```

This can be used to compare the deployed versions against the head of the master branch.