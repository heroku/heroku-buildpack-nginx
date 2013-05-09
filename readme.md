# Heroku Buildpack: nginx/unicorn

Nginx-unicorn-buildpack vendors nginx inside a dyno and connects unicorn to nginx over a UNIX domain socket. Both unicorn and nginx logs are printed to stdout using [l2met](https://github.com/ryandotsmith/l2met) conventions.

## Procfile & The Web Process

Nginx-unicorn-buildpack provides a web process type for Heroku. This means that the web process type defined in your app's Procfile will be ignored. After starting nginx, this buildpack's web process type will start unicorn with the following command:

```bash
bundle exec unicorn -c config/unicorn.rb
```

## Setup

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
