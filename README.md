# Heroku Buildpack: Nginx

Nginx-buildpack installs & runs the [Nginx web server](https://nginx.org/) inside a Heroku app.

## Features

* Presets for specific use-cases
	- [Static sites](STATIC.md)
	- [Local proxy to app servers](PROXY.md)
* Complete control of Nginx config in `config/nginx.conf.erb`
	- [`erb` template](https://github.com/ruby/erb) supports dynamic config at start-up
	- see [Nginx docs](https://nginx.org/en/docs/)
* writes [Heroku request ids](https://devcenter.heroku.com/articles/http-request-id) & server timing to access logs


### Nginx versions

These are auto-selected based on the app's stack at build time.

| [Heroku Stack](https://devcenter.heroku.com/articles/stack) | Nginx Version | PCRE version |
|--------------|--------------:|-------------:|
| [Heroku-22](https://devcenter.heroku.com/articles/heroku-22-stack) | 1.28.0 | PCRE1 (8.x) |
| [Heroku-24](https://devcenter.heroku.com/articles/heroku-24-stack) | 1.28.0 | PCRE2 (10.x) |

## Presets

With Nginx's flexibility, it can be configured & used for many different purposes. See the documentation for the mode you wish to use.

### [Static sites](STATIC.md)

HTTP server for websites and single page apps. [[docs](STATIC.md)]

### [Local proxy](PROXY.md)

HTTP proxy to an app server running in the same dyno, via UNIX domain sockets. [[docs](PROXY.md)]

_Proxy is the original buildpack mode that is enabled by default, if the `config/nginx.conf.erb` file is not added to app source._

### Solo mode (deprecated)

This mode has been superceeded by [Static mode](STATIC.md).

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

## Releasing a New Version

_Only maintainers of this buildpack can make releases._

_Replace "X.X" with the new version number._

1. Update `CHANGELOG.md`, moving the **[unreleased] - YYYY-MM-DD** section contents into a new version section for version X.X
2. Create a branch `preparing-release-X.X` with PR **Preparing release X.X**
3. Get the PR approved
4. Merge the approved PR
5. Create a new [GitHub release](https://github.com/heroku/heroku-buildpack-nginx/releases) for the new version, targetting `main`, with name and tag of form `vX.Y`.
6. Publish a new release in the Heroku Buildpack Registry, using either [plugin-buildpack-registry](https://github.com/heroku/plugin-buildpack-registry) and `heroku buildpacks:publish heroku-community/nginx <git_tag>`, or else the [buildpacks dashboard](https://addons-next.heroku.com/buildpacks/cf2713a5-65d0-4bc8-8dd2-b00d8d4f03f4/publish).

