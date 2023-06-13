# Heroku Buildpack: Nginx

Nginx-buildpack installs & runs the powerful [Nginx web server](https://nginx.org/) inside a Heroku app.

## Features

* writes [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) & server timing to access logs
* complete control of [Nginx config](https://nginx.org/en/docs/) in `config/nginx.erb.conf`
	- see [Nginx docs](https://nginx.org/en/docs/)

## Versions

These are auto-selected based on the app's stack at build time.

### Heroku 18
* Nginx Version: 1.20.2
### Heroku 20
* Nginx Version: 1.20.2
### Heroku 22
* Nginx Version: 1.20.2

## Modes

With Nginx's flexibility, it can be configured & used for many different purposes. See the documentation for the mode you wish to use.

### [Static mode](static.md)

HTTP server for websites and single page apps. [[docs](static.md)]

### [Proxy mode](proxy.md)

HTTP proxy to an app server running in the same dyno, via UNIX domain sockets. [[docs](proxy.md)]

_Proxy is the original buildpack mode that is enabled by default, if the `config/nginx.conf.erb` file is not added to app source._

### Solo mode (deprecated)

This mode has been superceeded by [Static mode](static.md).

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
