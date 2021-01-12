build: build-heroku-16 build-heroku-18 build-heroku-20

build-heroku-16:
	@echo "Building nginx in Docker for heroku-16..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-16" -e "NGINX_VERSION=1.9.5" -e "PCRE_VERSION=8.37" -e "HEADERS_MORE_VERSION=0.261" -w /buildpack heroku/heroku:16-build scripts/build_nginx /buildpack/nginx-heroku-16.tgz

build-heroku-18:
	@echo "Building nginx in Docker for heroku-18..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-18" -w /buildpack heroku/heroku:18-build scripts/build_nginx /buildpack/nginx-heroku-18.tgz

build-heroku-20:
	@echo "Building nginx in Docker for heroku-20..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-20" -w /buildpack heroku/heroku:20-build scripts/build_nginx /buildpack/nginx-heroku-20.tgz

shell:
	@echo "Opening heroku-18 shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-18" -e "PORT=5000" -w /buildpack heroku/heroku:18-build bash
