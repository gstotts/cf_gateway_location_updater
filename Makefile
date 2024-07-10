.PHONY: build run

build:
	docker build -t cf_gateway_location .

run: build
	docker run -d --restart always --name cf_gateway_location cf_gateway_location:latest
