# cloudflare_gateway_location

Simple container build that runs a job to update the Gateway location for your Cloudflare Zero Trust instance.  

###  Requirements
- Cloudflare API Token with with the following permissions:
    - `Zero Trust:Edit`
    - `Account Settings:Read`
- Docker

#### Usage
1. Add a `.env` file that contains your Cloudflare API Token (or modify to set an ENV for your container)/

2. Update any desired timing for checkins via the file `cronjob`.

3. `make run`
