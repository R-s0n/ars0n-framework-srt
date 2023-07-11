#!/bin/bash

urls_file="$1"
proxy_host="localhost"
proxy_port="8080"
timeout_seconds=10

if [ -z "$urls_file" ]; then
  echo "Please provide the file name containing URLs as the first command line argument."
  exit 1
fi

if [ ! -f "$urls_file" ]; then
  echo "File not found: $urls_file"
  exit 1
fi

filtered_file="$(pwd)/urls.filtered.txt"

touch "$filtered_file"

while IFS= read -r url; do
  base_url=$(echo "$url" | awk -F '/' '{print $1 "//" $3}')
  if ! grep -q "$base_url" "$filtered_file"; then
    echo "$base_url" >> "$filtered_file"
  fi
done < "$urls_file"

while IFS= read -r url; do
  echo "Sending GET request to: $url"
  curl -x "$proxy_host:$proxy_port" -k --max-time "$timeout_seconds" "$url"
  echo "-----------------------------------"
done < "$filtered_file"

rm "$filtered_file"

