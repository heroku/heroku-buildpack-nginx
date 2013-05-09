# Heroku Buildpack: NGINX

Nginx-buildpack vendors NGINX inside a dyno and connects NGINX to an app server via UNIX domain sockets. Both the app server and NGINX logs are printed to stdout. NGINX is configured to use [l2met](https://github.com/ryandotsmith/l2met) conventions & heroku request ids.

* NGINX Version: 1.4.1
* NGINX Buildpack Version: 0.1

## Features

* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX logs.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Crashes dyno if NGINX or App server crashes. Safety first.
* Works with any app server.
* Customize NGINX config.

## Requirements

* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You touch `/tmp/app-initialized` when you are ready for traffic.
* You can start your web server with a shell command.

## Procfile & The Web Process

Nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get NGINX and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

## Custom NGINX Config

You can provide your own NGINX config by create a file named `nginx.conf.erb` in the config direcotry of your app. You can start by copying the buildpack's [default config file](https://github.com/ryandotsmith/nginx-buildpack/blob/master/config/nginx.conf.erb).

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
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
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
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```
```bash
$ git add Procfile
$ git commit -m 'Update procfile for NGINX buildpack'
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
$ git commit -m 'Update unicorn config to listen on NGINX socket.'
```

Deploy Changes
```bash
$ git push heroku master
```

## License

Copyright (c) 2013 Ryan R. Smith

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
