# Heroku Buildpack: Nginx local proxy to backend app servers

Operates as an HTTP proxy to an app server running in the same dyno, via UNIX domain sockets.

Add this buildpack to an app, as the last buildpack:
```bash
heroku buildpacks:add --app APP_NAME heroku-community/nginx
```

Create the `Procfile` in the root of your app, containing,
```
web: bin/start-nginx <backend server command>
```
Example with backend server command: `bin/start-nginx bundle exec unicorn -c config/unicorn.rb`

Backend server must:
* Listen to the socket at `/tmp/nginx.socket`.
* Touch `/tmp/app-initialized` when the backend is ready for traffic.

The [default config `config/nginx.conf.erb`](config/nginx.conf.erb) will be loaded automatically. To customize, copy the default config to your app source code at `config/nginx.conf.erb`

## Logging

**Proxy mode writes logs to files, which is not the Heroku way. They should go to stdout.**

Nginx will output the following style of logs:

```
measure.nginx.service=0.007 request_id=e2c79e86b3260b9c703756ec93f8a66d
```

You can correlate this id with your Heroku router logs:

```
at=info method=GET path=/ host=salty-earth-7125.herokuapp.com request_id=e2c79e86b3260b9c703756ec93f8a66d fwd="67.180.77.184" dyno=web.1 connect=1ms service=8ms status=200 bytes=21
```
### Setting custom log paths

You can configure custom log paths using the environment variables `NGINX_ACCESS_LOG_PATH` and `NGINX_ERROR_LOG_PATH`.

For example, if you wanted to stop nginx from logging your access logs you could set `NGINX_ACCESS_LOG_PATH` to `/dev/null`:
```bash
$ heroku config:set NGINX_ACCESS_LOG_PATH="/dev/null"
```

## Language/App Server Agnostic

nginx-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your app server's startup command to `start-nginx`.

For example, to get Nginx and Unicorn up and running:

```bash
$ cat Procfile
web: bin/start-nginx bundle exec unicorn -c config/unicorn.rb
```

### Proxy mode nginx-debug
```bash
$ cat Procfile
web: bin/start-nginx-debug bundle exec unicorn -c config/unicorn.rb
```

## Application/Dyno coordination

Proxy mode will not start Nginx until a file has been written to `/tmp/app-initialized`. Since Nginx binds to the dyno's `$PORT` and since the `$PORT` determines if the app can receive traffic, you can delay Nginx accepting traffic until your application is ready to handle it. The [examples below](#example-proxy-setup) show how/when you should write the file when working with Unicorn.

## Force SSL

You can add a redirect/force SSL based on Heroku headers. Full, commented example in the [default config file](config/nginx.conf.erb) or in the [nextjs with forceSSL config file](config/nginx-nextjs-with-forcessl.conf.erb).

```
if ($http_x_forwarded_proto != "https") {
  return 301 https://$host$request_uri;
}
```


## Example Proxy Setup

Here are 2 setup examples. One example for a new app, another for an existing app. In both cases, we are working with ruby & unicorn. Keep in mind that this buildpack is not ruby specific. However if your app does happen to use Ruby, make sure to add the Nginx buildpack **after** the Ruby buildpack, so the Nginx buildpack doesn't have to install its own redundant copy of Ruby for the ERB templating feature.

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
$ git commit -m 'Update procfile for Nginx buildpack'
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
$ git commit -m 'Update unicorn config to listen on Nginx socket.'
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
$ heroku buildpacks:add heroku-community/nginx
$ git add .
$ git commit -am "init"
$ git push heroku main
$ heroku logs -t
```
Visit App
```
$ heroku open
```

## Original Motivation

Some application servers (e.g. Ruby's Unicorn) halt progress when dealing with network I/O. Heroku's routing stack [buffers only the headers](https://devcenter.heroku.com/articles/http-routing#request-buffering) of inbound requests. (The router will buffer the headers and body of a response up to 1MB) Thus, the Heroku router engages the dyno during the entire body transfer –from the client to dyno. For applications servers with blocking I/O, the latency per request will be degraded by the content transfer. By using Nginx in front of the application server, we can eliminate a great deal of transfer time from the application server. In addition to making request body transfers more efficient, all other I/O should be improved since the application server need only communicate with a UNIX socket on localhost. Basically, for webservers that are not designed for efficient, non-blocking I/O, we will benefit from having Nginx to handle all I/O operations.

## License
Copyright (c) 2013 Ryan R. Smith
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
