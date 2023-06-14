# Heroku Buildpack: Nginx for static sites

Operates as an HTTP server for websites and single page apps.

## Usage

### 1. Add Buildpack

Add this buildpack branch to an app, as the last buildpack:
```bash
heroku buildpacks:add --app APP_NAME heroku-community/nginx
```

### 2. Create Procfile

Create the `Procfile` in the root of your app, containing,
```
web: bin/start-nginx-static
```

### 3. Create config file

1. Copy the [static config](config/nginx-static.conf.erb) into your app as `config/nginx.conf.erb`.
2. Set the [document root](#document-root) for your app (default is `/app/dist`, this varies by framework/build system).

## Configuration

Everything is set-up in `config/nginx.conf.erb`.

See [nginx docs](https://nginx.org/en/docs/) to further customize.

### Logging

Sends error & access loglines directly into logplex, for combined logging in the Heroku app.

### HTTPS Only

Forces secure HTTP for all requests, by sending 301 redirect responses from `http` to `https`.

### Document root

The default server document root is `/app/dist`.

To change it, edit the existing `root` entry.

### Clean URLs

Honor requests for static files without their file extension.

Enable the sample `try_files` directive:

```
try_files $uri $uri/ $uri.html =404;
```

### Client-side routing

Respond with `index.html` for all unknown request paths, so that the client-side app may perform its own routing.

Enable the sample `error_page` directive:
```
error_page 404 = /index.html;
```

### Specific behaviors for sub-directories, other locations

Nginx supports overriding the top-level `/` server configuration with more specific blocks, such as for the sample assets caching rules:
```
location /assets {
	expires 7d;
}
```

### Custom error pages

Unique error pages for your app may be set, such as sample:
```
error_page 404 /404.html;
```

### Canonical host

Support for redirecting visitors to a standardized hostname, such as the sample:
```
server { 
	server_name some-other-name.example.com;
	return 301 https://canonical-name.example.com$request_uri;
}
```


