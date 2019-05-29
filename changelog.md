# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2] - 2019-05-29
 ### Added
 - [heroku-18] update nginx to 1.17.0
 - add uuid4 module from https://github.com/cybozu/nginx-uuid4-module
 - add nginx solo support, see [sample config for nginx solo mode](config/nginx-solo.conf.erb) and [README](README.md)

## [1.1.0] - 2018-09-13
### Added
- [heroku-18] support new Heroku stack (heroku-18)
- [all] Real IP support, adding compile flag `--with-http_realip_module`
- [all] Static GZIP support, adding compile flag `--with-http_gzip_static_module`
- [all] compile with zlib support

### Changed
- [heroku-18] PCRE updated from 8.37 to 8.42
- [heroku-18] "headers-more-nginx" module updated from 0.261 to 0.33
- [heroku-18] PCRE updated from 8.37 to 8.42


## [0.4] - 2012-05-13
### Added
- [all] enabled gzip compression

### Changed
- [all] include most recent nginx config
- [all] using epoll and increasing workers to 4

## [0.3] - 2012-05-11
### Changed
- [all] Improve process managment using a fifo.

## [0.2] - 2012-05-10
### Changed
- [all] Improve the handling of app server failures

## [0.1] - 2012-05-09
### Added
- [all] initial release with NGINX 1.4.1
