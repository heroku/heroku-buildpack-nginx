# Heroku Buildpack: nginx/unicorn

Nginx-unicorn-buildpack vendors nginx inside a dyno and connects unicorn to nginx over a UNIX domain socket. Both unicorn and nginx logs are printed to stdout using [l2met](https://github.com/ryandotsmith/l2met) conventions.

## Procfile & The Web Process

Nginx-unicorn-buildpack provides a command named `bin/start-nginx` this command takes another command as an argument. You must pass your unicorn command to `start-nginx` to get NGINX and Unicorn running properly. For example:

```bash
$ cat Procfile
web: bin/start-nginx 'bundle exec unicorn -c config/unicorn.rb'
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
preload_app true
timeout 5
worker_processes 4
listen '/tmp/nginx.socket', backlog: 8
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
$ echo 'https://github.com/ryandotsmith/nginx-unicorn-buildpack.git' >> .buildpacks
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
$ echo 'https://github.com/ryandotsmith/nginx-unicorn-buildpack.git' >> .buildpacks
$ git add .buildpacks
$ git commit -m 'Add multi-buildpack'
```

Update Procfile
```
web: bundle exec unicorn -c config/unicorn.rb
```
**Becomes:**
```
web: bin/start-nginx 'bundle exec unicorn -c config/unicorn.rb'
```
```bash
$ git add Procfile
$ git commit -m 'Update procfile for nginx buildpack'
```

Update Unicorn Config

```ruby
#The only important thing to change:
listen ENV['PORT']
```
**Becomes:**
```ruby
#The only important thing to change:
listen '/tmp/nginx.socket'
```

Deploy Changes
```bash
$ git push heroku master
```
