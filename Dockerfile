FROM golang:1.22.5-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN go build -o cf_gateway_location

# Start a new stage from scratch
FROM alpine:latest

# Install necessary packages (e.g., cron)
RUN apk --no-cache add ca-certificates

# Copy the built executable from the builder stage
COPY --from=builder /app/cf_gateway_location /usr/local/bin/
COPY .env /usr/local/bin

# Copy your cron job file into the container
COPY cronjob /etc/crontabs/root

RUN mkdir -p /var/log/cf_gateway_location && \
    touch /var/log/cf_gateway_location/cf_gateway_location.log && \
    chmod 777 /var/log/cf_gateway_location/cf_gateway_location.log

# Run cron daemon in the foreground
CMD ["crond", "-f"]
