# Heroku Buildpack: NGINX

Nginx-buildpack vendors nginx inside a dyno and connects NGINX to an app server via UNIX domain sockets. Both the app server and nginx logs are printed to stdout. NGINX is configured to use [l2met](https://github.com/ryandotsmith/l2met) conventions & heroku request ids.

## Requirements

* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You touch `/tmp/app-initialized` when you are ready for traffic.

## Procfile & The Web Process

Nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get NGINX and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

## Setup A New Heroku App

```bash
$ mkdir myapp; cd myapp
$ git init
```

**Gemfile**
```ruby
source 'https://rubygems.org'
gem 'unicorn'
```

**config.ru**
```ruby
run Proc.new {[200,{'Content-Type' => 'text/plain'}, ["hello world"]]}
```

**config/unicorn.rb**
```ruby
require 'fileutils'
preload_app true
timeout 5
worker_processes 4
listen '/tmp/nginx.socket', backlog: 8

before_fork do |server,worker|
	FileUtils.touch('/tmp/app-initialized')
end
```

Install Gems
```bash
$ bundle install
```

Create Procfile
```
web: bin/start-nginx 'bundle exec unicorn -c config/unicorn.rb'
```

Create & Push Heroku App:
```bash
$ heroku create --buildpack https://github.com/ddollar/heroku-buildpack-multi.git
$ echo 'https://github.com/heroku/heroku-buildpack-ruby.git' >> .buildpacks
$ echo 'https://github.com/ryandotsmith/nginx-buildpack.git' >> .buildpacks
$ git add .
$ git commit -am "init"
$ git push heroku master
$ heroku logs -t
```

Visit App
```
$ heroku open
```

## Setup on Existing Apps

You will need to update your buildpack URL and setup the multi buildpacks. Be sure to test on staging first.

Update Buildpacks
```bash
$ heroku config:set BUILDPACK_URL=https://github.com/ddollar/heroku-buildpack-multi.git
$ echo 'https://github.com/heroku/heroku-buildpack-ruby.git' >> .buildpacks
$ echo 'https://github.com/ryandotsmith/nginx-buildpack.git' >> .buildpacks
$ git add .buildpacks
$ git commit -m 'Add multi-buildpack'
```

Update Procfile
```
web: bundle exec unicorn -c config/unicorn.rb -p $PORT
```
Becomes:
```
web: bin/start-nginx 'bundle exec unicorn -c config/unicorn.rb'
```
```bash
$ git add Procfile
$ git commit -m 'Update procfile for nginx buildpack'
```

Update Unicorn Config

```ruby
listen ENV['PORT']
```
Becomes:
```ruby
require 'fileutils'
listen '/tmp/nginx.socket'
before_fork do |server,worker|
	FileUtils.touch('/tmp/app-initialized')
end
```
```bash
$ git add config/unicorn.rb
$ git commit -m 'Update unicorn config to listen on nginx socket.'
```

Deploy Changes
```bash
$ git push heroku master
```
