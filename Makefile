build: build-heroku-18 build-vouch-heroku-18

build-heroku-18:
	@echo "Building nginx in Docker for heroku-18..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-18" -e "NGINX_VERSION=1.16.0" -e "PCRE_VERSION=8.43" -e "HEADERS_MORE_VERSION=0.33" -w /buildpack heroku/heroku:18-build scripts/build_nginx /buildpack/bin/nginx-heroku-18

build-vouch-heroku-18:
	@echo "Building vouch-proxy in Docker for heroku-18..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-18" -w /buildpack heroku/heroku:18-build scripts/build_vouch /buildpack/bin/vouch-proxy

shell-build:
	@echo "Opening heroku-18 build shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-18" -e "PORT=5000" -w /buildpack heroku/heroku:18-build bash
