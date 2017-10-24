build: build-cedar-14

build-cedar-14:
	@echo "Building Nginx in docker for cedar-14..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=cedar-14" -w /buildpack heroku/cedar:14 scripts/build_nginx /buildpack/bin/nginx-cedar-14

shell:
	@echo "Opening cedar-14 shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=cedar-14" -e "PORT=5000" -w /buildpack heroku/cedar:14 bash
