package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"

	"github.com/cloudflare/cloudflare-go"
)

type IPResult struct {
	IP string `json:"ip"`
}

func getMyIP() (string, error) {
	resp, err := http.Get("https://api.ipify.org?format=json")
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	var ip IPResult
	if err := json.Unmarshal(body, &ip); err != nil {
		return "", err
	}

	return fmt.Sprintf("%s/32", ip.IP), nil
}

func main() {
	// Get External IP
	ip, err := getMyIP()
	if err != nil {
		log.Fatal(err)
	}

	// Create Cloudflare client
	api, err := cloudflare.NewWithAPIToken(os.Getenv("CLOUDFLARE_API_TOKEN"))
	if err != nil {
		log.Fatal(err)
	}

	ctx := context.Background()

	// Get Account ID
	accounts, _, err := api.Accounts(ctx, cloudflare.AccountsListParams{})
	if err != nil {
		log.Fatal(err)
	}

	// Get Current Location
	locations, _, err := api.TeamsLocations(ctx, accounts[0].ID)
	if err != nil {
		log.Fatal(err)
	}

	// If Current Location is not same as External IP, Update
	if locations[0].Networks[0].Network != ip {
		log.Printf("Change in IP Detected. Current IP: %s  Cloudflare IP: %s\n", ip, locations[0].Networks[0].Network)
		locations[0].Networks[0].Network = ip
		_, err := api.UpdateTeamsLocation(ctx, accounts[0].ID, locations[0])
		if err != nil {
			log.Fatal(err)
		}
	} else {
		log.Printf("IP Address Matches Cloudflare IP: %s\n", ip)
	}
}
