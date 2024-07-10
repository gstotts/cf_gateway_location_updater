# Start from a small base image with Go support
FROM golang:1.22.5-alpine AS builder

# Set the current working directory inside the container
WORKDIR /app

# Copy go.mod and go.sum to download dependencies
COPY go.mod go.sum ./

# Download dependencies
RUN go mod download

# Copy the source code into the container
COPY . .

# Build the Go app
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

# Run cron daemon in the foreground
CMD ["crond", "-f"]
