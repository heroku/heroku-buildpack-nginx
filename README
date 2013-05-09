# Heroku Buildpack: NGINX/Unicorn

## Synopsis

This buildpack starts NGINX 1.4.1 and proxies requests to /tmp/nginx.socket and expects Unicorn to handle requests on that socket.

## Prerequisites

* Unicorn listens on /tmp/nginx.socket
* Unicorn configuration located at RAILS_ROOT/config/unicorn.rb

Sample Unicorn Configuration:

```ruby
preload_app true
timeout 5
worker_processes 4
listen '/tmp/nginx.socket', backlog: 8
```

## Setup

New Heroku Apps:

```bash
$ heroku create --buildpack https://github.com/ddollar/heroku-buildpack-multi.git
$ echo 'https://github.com/ryandotsmith/buildpack-nginx-unicorn.git' >> .buildpacks
$ echo 'https://github.com/heroku/heroku-buildpack-ruby.git' >> .buildpacks
```
