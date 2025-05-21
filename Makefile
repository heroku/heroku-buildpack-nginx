build: build-heroku-20 build-heroku-22 build-heroku-24-amd64 build-heroku-24-arm64

build-heroku-20:
	@echo "Building nginx in Docker for heroku-20..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-20" -w /buildpack heroku/heroku:20-build scripts/build_nginx /buildpack/nginx-heroku-20.tgz

build-heroku-22:
	@echo "Building nginx in Docker for heroku-22..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-22" -w /buildpack heroku/heroku:22-build scripts/build_nginx /buildpack/nginx-heroku-22.tgz

build-heroku-24-amd64:
	@echo "Building nginx in Docker for heroku-24 (amd64)..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-24" -w /buildpack --platform linux/amd64 heroku/heroku:24-build scripts/build_nginx /buildpack/nginx-heroku-24-amd64.tgz

build-heroku-24-arm64:
	@echo "Building nginx in Docker for heroku-24 (arm64)..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-24" -w /buildpack --platform linux/arm64 heroku/heroku:24-build scripts/build_nginx /buildpack/nginx-heroku-24-arm64.tgz

shell:
	@echo "Opening heroku-22 shell..."
	@docker run -v $(shell pwd):/buildpack --rm -it -e "STACK=heroku-22" -e "PORT=5000" -w /buildpack heroku/heroku:22-build bash
