.PHONY: build run

build:
	docker build -t cf_gateway_location_updater .

run: build
	docker run -d --restart always --name cf_gateway_location_updater cf_gateway_location_updater:latest
