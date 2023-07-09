#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Invalid number of command line arguments. Please provide a single URL argument."
    exit 1
fi

url="$1"
tld=$(echo "$url" | awk -F/ '{print $3}' | awk -F. '{print $(NF-1)"."$NF}')
json_data="{\"urls\": [\"$url\"], \"scope\":{\"host_or_ip_range\":\"$tld\"},\"scan_configurations\":[{\"name\":\"Crawl and Audit - Deep\",\"type\":\"NamedConfiguration\"}],\"resource_pool\":\"Low and Slow\",\"protocol_option\":\"httpAndHttps\"}"

curl -X POST -H "Content-Type: application/json" -d "$json_data" "http://localhost:1337/v0.1/scan"

