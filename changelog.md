# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.10] - 2023-06-13
### Changes
- New "Static site" preset config
- New `bin/start-nginx-static` to simply start Nginx, its process attached and sending logs to stdout
- [all stacks] updated nginx to 1.25.1, zlib to 1.2.13, headers-more-nginx-module to 0.34, ruby to 3.2.2

## [1.9] - 2022-06-21
### Changes
- If a Ruby installation is not found (required for the ERB templating feature), this buildpack will now install its own, to ensure it works on Heroku-22.

## [1.8] - 2022-05-19
### Changes
- [heroku-18] updated nginx to 1.20.2, bump zlib to 1.2.12, updated PCRE to 8.45
- [heroku-20] updated nginx to 1.20.2, bump zlib to 1.2.12, updated PCRE to 8.45
- [heroku-22] add support for Heroku-22

## [1.7] - 2021-06-04
### Changes
- [heroku-18] updated nginx to 1.20.1
- [heroku-20] updated nginx to 1.20.1
- [heroku-16] Removed

## [1.6] - 2021-05-27
### Changes
- [heroku-18] updated nginx to 1.20.0
- [heroku-20] updated nginx to 1.20.0
- [cedar-14] Removed
- rename master branch to main

## [1.5.1] - 2020-08-22
### Changes
- [readme.md] Updated custom build instructions
- [scripts/build_nginx] Updated outdated comments

## [1.5] - 2020-07-20
### Added
- [all] move to tgz to distribute binaries
- [all] update mime.types to reflect the version that is included in the nginx distrubition

## [1.4] - 2020-05-05
### Added
- [all] add nginx-debug binary
- [heroku-20] add support for Heroku-20

### Changed
- [heroku-18] update nginx to 1.18
- [heroku-18] update PCRE to 8.44

## [1.3] - 2020-01-06
### Added
- [heroku-18] update nginx to 1.16.1

## [1.2] - 2019-05-29
### Added
- [heroku-18] update nginx to 1.16.0
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
