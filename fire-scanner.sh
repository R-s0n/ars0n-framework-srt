#!/bin/bash

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Invalid number of command line arguments. Please provide a single URL argument or a URL argument with one of the flags: --sql, --xss, --dom, --inj."
    exit 1
fi

url="$1"
flag="$2"

if [ "$#" -eq 1 ]; then
    flag=""
fi

if [ "$flag" != "--sql" ] && [ "$flag" != "--xss" ] && [ "$flag" != "--dom" ] && [ "$flag" != "--inj" ] && [ "$flag" != "" ]; then
    echo "Invalid flag. Please provide one of the following flags: --sql, --xss, --dom, --inj."
    exit 1
fi

tld=$(echo "$url" | awk -F/ '{print $3}' | awk -F. '{print $(NF-1)"."$NF}')

json_data="{\"urls\": [\"$url\"], \"scope\":{\"host_or_ip_range\":\"$tld\"},\"scan_configurations\":[]}"

if [ "$flag" != "" ]; then
    config_file=""
    case "$flag" in
        --sql)
            config_file="./burp-configs/SQLi Audit.json"
            ;;
        --xss)
            config_file="./burp-configs/XSS Audit.json"
            ;;
        --dom)
            config_file="./burp-configs/DOM Audit.json"
            ;;
        --inj)
            config_file="./burp-configs/Injection Audit.json"
            ;;
    esac

    if [ ! -f "$config_file" ]; then
        echo "Configuration file not found: $config_file"
        exit 1
    fi

    config=$(cat "$config_file")

    json_data=$(echo "$json_data" | jq --argjson cfg "$config" '.scan_configurations[0] |= . + {"config": $cfg | tostring, "type": "CustomConfiguration"}')
fi

if [ -z "$flag" ]; then    
    default_config='{"name":"Crawl and Audit - Deep","type":"NamedConfiguration"}'
    json_data=$(echo "$json_data" | jq --argjson def_cfg "$default_config" '.scan_configurations = [$def_cfg]')
fi

curl -X POST -H "Content-Type: application/json" -d "$json_data" "http://localhost:1337/v0.1/scan"

