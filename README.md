static
======

An nginx caching proxy (mostly) for serving static sites from Azure Blob Storage.

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

Test the default - [first server block](https://github.com/zooniverse/static/blob/1572db64aaeb38d904e1a60de00e9f06871414df/nginx.conf#L69)

``` bash
# provide an unkonwn host to test the defaul server block.
# making sure it matches path in the upstream proxy
curl -v -H "Host: talk.sunspotter.org" http://localhost:8080/users/%E7%8E%8B%E5%8F%AF%E8%90%B1/index.html
```

Note: You must provide a host when testing locally or the implicit `localhost` host header will be used.

Read more at the [Nginx request processing docs](http://nginx.org/en/docs/http/request_processing.html)

#### Simulate the jenkins test step

Use the `test-http` image to replicate the jenkins `Test HTTP response` stage. Uncomment the `test-http` conatiner in the docker-compose yaml.

``` bash
docker-compose run --rm test-http
# in the alpine conatiner install curl
apk add --no-cache curl
# and test a request to nginx static image
curl -vk http://nginx/index.html
```
