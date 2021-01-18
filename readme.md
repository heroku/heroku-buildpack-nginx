# Heroku Buildpack: NGINX

Nginx-buildpack vendors NGINX inside a dyno and connects NGINX to an app server via UNIX domain sockets.

## Motivation

Some application servers (e.g. Ruby's Unicorn) halt progress when dealing with network I/O. Heroku's routing stack [buffers only the headers](https://devcenter.heroku.com/articles/http-routing#request-buffering) of inbound requests. (The router will buffer the headers and body of a response up to 1MB) Thus, the Heroku router engages the dyno during the entire body transfer –from the client to dyno. For applications servers with blocking I/O, the latency per request will be degraded by the content transfer. By using NGINX in front of the application server, we can eliminate a great deal of transfer time from the application server. In addition to making request body transfers more efficient, all other I/O should be improved since the application server need only communicate with a UNIX socket on localhost. Basically, for webservers that are not designed for efficient, non-blocking I/O, we will benefit from having NGINX to handle all I/O operations.

## Versions

### Heroku 16
* NGINX Version: 1.9.5
### Heroku 18
* NGINX Version: 1.18.0
### Heroku 20
* NGINX Version: 1.18.0

## Requirements (Proxy Mode)

* Your webserver listens to the socket at `/tmp/nginx.socket`.
* You touch `/tmp/app-initialized` when you are ready for traffic.
* You can start your web server with a shell command.

## Requirements (Solo Mode)

* Add a custom nginx config to your app source code at `config/nginx.conf.erb`. You can start by copying the [sample config for nginx solo mode](config/nginx-solo-sample.conf.erb).

## Features

* Unified NXNG/App Server logs.
* [L2met](https://github.com/ryandotsmith/l2met) friendly NGINX log format.
* [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) embedded in NGINX logs.
* Crashes dyno if NGINX or App server crashes. Safety first.
* Language/App Server agnostic.
* Customizable NGINX config.
* Application coordinated dyno starts.

### Logging

NGINX will output the following style of logs:

```
measure.nginx.service=0.007 request_id=e2c79e86b3260b9c703756ec93f8a66d
```

You can correlate this id with your Heroku router logs:

```
at=info method=GET path=/ host=salty-earth-7125.herokuapp.com request_id=e2c79e86b3260b9c703756ec93f8a66d fwd="67.180.77.184" dyno=web.1 connect=1ms service=8ms status=200 bytes=21
```
#### Setting custom log paths

You can configure custom log paths using the environment variables `NGINX_ACCESS_LOG_PATH` and `NGINX_ERROR_LOG_PATH`.

For example, if you wanted to stop nginx from logging your access logs you could set `NGINX_ACCESS_LOG_PATH` to `/dev/null`:
```bash
$ heroku config:set NGINX_ACCESS_LOG_PATH="/dev/null"
```

### Language/App Server Agnostic

nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get NGINX and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

#### nginx debug mode
```bash
$ cat Procfile
web: bin/start-nginx-debug bundle exec unicorn -c config/unicorn.rb
```

### nginx Solo Mode

nginx-buildpack provides a command named `bin/start-nginx-solo`. This is for you if you don't want to run an additional app server on the Dyno.
This mode requires you to put a `config/nginx.conf.erb` in your app code. You can start by coping the [sample config for nginx solo mode](config/nginx-solo-sample.conf.erb).
For example, to get NGINX and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx-solo
```

### Setting the Worker Processes and Connections

You can configure NGINX's `worker_processes` directive via the
`NGINX_WORKERS` environment variable.

For example, to set your `NGINX_WORKERS` to 8 on a PX dyno:

```bash
$ heroku config:set NGINX_WORKERS=8
```

Similarly, the `NGINX_WORKER_CONNECTIONS` environment variable can configure the `worker_connections` directive:

```bash
$ heroku config:set NGINX_WORKER_CONNECTIONS=2048
```

### Customizable NGINX Config

You can provide your own NGINX config by creating a file named `nginx.conf.erb` in the config directory of your app. Start by copying the buildpack's [default config file](config/nginx.conf.erb).

### Force SSL

You can add a redirect/force SSL based on Heroku headers. Full, commented example in the [default config file](config/nginx.conf.erb) or in the [nextjs with forceSSL config file](config/nginx-nextjs-with-forcessl.conf.erb).

```
if ($http_x_forwarded_proto != "https") {
  return 301 https://$host$request_uri;
}
```

### Customizable NGINX Compile Options

This requires a clone of this repository and [Docker](https://www.docker.com/). All you need to do is have Docker setup and running on your machine. The [`Makefile`](Makefile) will take care of the rest.

Configuring is as easy as changing the options passed to `./configure` in [scripts/build_nginx](scripts/build_nginx).

Run the builds in a container via:

```
$ make build
```

The binaries will be packed into `tar` files and placed in the repository's root directory. Commit the changes and push your repository.

Finally update your app to use your custom buildpack on Heroku either at https://dashboard.heroku.com/apps/#{YOUR_APP_NAME}/settings or via the Heroku CLI via:

```
heroku buildpacks:set #{YOUR_GIT_REPO_CLONE}
```

To test the builds locally:

```
$ make shell
$ cp bin/nginx-$STACK bin/nginx
$ FORCE=1 bin/start-nginx
```

### Application/Dyno coordination

The buildpack will not start NGINX until a file has been written to `/tmp/app-initialized`. Since NGINX binds to the dyno's $PORT and since the $PORT determines if the app can receive traffic, you can delay NGINX accepting traffic until your application is ready to handle it. The examples below show how/when you should write the file when working with Unicorn.

## Setup

Here are 2 setup examples. One example for a new app, another for an existing app. In both cases, we are working with ruby & unicorn. Keep in mind that this buildpack is not ruby specific.

### Existing App

Update Buildpacks to use the latest stable version of this buildpack:
```bash
$ heroku buildpacks:add heroku-community/nginx
```
Alternatively, you can use the Github URL of this repo if you want to edge version.

Update Procfile:
```
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```
```bash
$ git add Procfile
$ git commit -m 'Update procfile for NGINX buildpack'
```
Update Unicorn Config
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
$ git push heroku main
```

### New App

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
listen '/tmp/nginx.socket', backlog: 1024

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
$ heroku create
$ heroku buildpacks:add heroku/ruby
$ heroku buildpacks:add https://github.com/heroku/heroku-buildpack-nginx
$ git add .
$ git commit -am "init"
$ git push heroku main
$ heroku logs -t
```
Visit App
```
$ heroku open
```

## License
Copyright (c) 2013 Ryan R. Smith
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
