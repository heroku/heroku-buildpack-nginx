## v1.1

2018-09-13

Update NGINX config

* add support for Heroku-18, running nginx 1.14 (stable version)
* update "headers-more-nginx" module to 0.33
* update PCRE dependency to 8.42
* update compile flags to include `--with-http_realip_module`
* update compile flags to include `--with-http_gzip_static_module` and compile with zlib support

## v0.4

2012-05-13

Update NGINX config

* enabled gzip compression
* using epoll and increasing workers to 4

## v0.3

2012-05-11

* Improve process managment using a fifo.

## v0.2

2012-05-10

* Improve the handling of app server failures

## v0.1

2012-05-09

* NGINX 1.4.1
* inital release
