# Heroku Buildpack: Nginx

Nginx-buildpack installs & runs the [Nginx web server](https://nginx.org/) inside a Heroku app.

## Features

* Presets for specific use-cases
	- [Static sites](static.md)
	- [Local proxy to app servers](proxy.md)
* Complete control of Nginx config in `config/nginx.erb.conf`
	- [`erb` template](https://github.com/ruby/erb) supports dynamic config at start-up
	- see [Nginx docs](https://nginx.org/en/docs/)
* writes [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) & server timing to access logs


### Nginx versions

These are auto-selected based on the app's stack at build time.

| Heroku Stack | Nginx Version |
|--------------|--------------:|
| `Heroku-18` | `1.25.1` |
| `Heroku-20` | `1.25.1` |
| `Heroku-22` | `1.25.1` |

## Presets

With Nginx's flexibility, it can be configured & used for many different purposes. See the documentation for the mode you wish to use.

### [Static sites](static.md)

HTTP server for websites and single page apps. [[docs](static.md)]

### [Local proxy](proxy.md)

HTTP proxy to an app server running in the same dyno, via UNIX domain sockets. [[docs](proxy.md)]

_Proxy is the original buildpack mode that is enabled by default, if the `config/nginx.conf.erb` file is not added to app source._

### Solo mode (deprecated)

This mode has been superceeded by [Static mode](static.md). 

## Custom Nginx usage

Have a use for Nginx that does not fit one of the above presets?

Add this buildpack to an app, as the last buildpack:
```bash
heroku buildpacks:add --app APP_NAME heroku-community/nginx
```

…and then setup `config/nginx.conf.erb` & `Procfile` in the app's source repo.

## General configuration

### Setting the Worker Processes and Connections

You can configure Nginx's `worker_processes` directive via the
`NGINX_WORKERS` environment variable.

For example, to set your `NGINX_WORKERS` to 8 on a PX dyno:

```bash
$ heroku config:set NGINX_WORKERS=8
```

Similarly, the `NGINX_WORKER_CONNECTIONS` environment variable can configure the `worker_connections` directive:

```bash
$ heroku config:set NGINX_WORKER_CONNECTIONS=2048
```

### Customizable Nginx Compile Options

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

## Upgrading dependencies

Process docs for buildpack maintainers.

### Upgrading Nginx, PCRE, zlib

_Please use only stable, even-numbered [Nginx releases](https://nginx.org/en/download.html)._

Revise the version variables in `scripts/build_nginx`, and then run the builds in a container (requires Docker) via:

```
$ make build
```

Then, commit & pull-request the resulting changes.

### Upgrading Ruby

_Ruby versions are downloaded from heroku-buildpack-ruby's distribution site. Only Heroku's [supported Ruby versions](https://devcenter.heroku.com/articles/ruby-support#ruby-versions) are available._

Revise the `ruby_version` variable in `bin/compile`.

Then, commit & pull-request the resulting changes.
