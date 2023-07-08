#!/bin/bash

folder="./temp"

if [ ! -w "$folder" ]; then
    echo "[!] Fire-Starter does not have write permissions for $folder"
    echo "[-] Changing permissions..."
    chmod +w "$folder"
    echo "[+] Permissions changed. Fire-Starter now has write permissions for $folder"
else
    echo "[+] Fire-Starter has write permissions for $folder"
fi

file_one="./temp/amass.tmp"

if [ -f "$file_one" ]; then
    echo "[!] File $file_one exists. Deleting..."
    rm "$file_one"
else
    echo "[+] File $file_one not found."
fi
if [ -z "$1" ]; then
    echo "Usage: ./fire-starter.sh [DOMAIN]"
    exit 1
fi

file_two="./temp/amass.full.tmp"

if [ -f "$file_two" ]; then
    echo "[!] File $file_two exists. Deleting..."
    rm "$file_two"
else
    echo "[+] File $file_two not found."
fi
if [ -z "$1" ]; then
    echo "Usage: ./fire-starter.sh [DOMAIN]"
    exit 1
fi

fqdn="$1"
regex="{1,3}"

config_test=$(ls config/amass_config.ini 2>/dev/null)
if [ $? -eq 0 ]; then
    echo "[+] Amass config file detected! Scanning with custom settings..."
    amass_command="sudo amass enum -src -ip -brute -ipv4 -min-for-recursive 2 -timeout 60 -config config/amass_config.ini -d $fqdn -o ./temp/amass.tmp"
else
    echo "[!] Amass config file NOT detected! Scanning with default settings..."
    amass_command="sudo amass enum -src -ip -brute -ipv4 -min-for-recursive 2 -timeout 60 -d $fqdn -o ./temp/amass.tmp"
fi

eval $amass_command

cp ./temp/amass.tmp ./temp/amass.full.tmp >/dev/null

sed -i -E 's/\[(.*?)\] +//g' ./temp/amass.tmp >/dev/null

sed -i -E "s/ ([0-9]{$regex}\.)[0-9].*//g" ./temp/amass.tmp >/dev/null 2>/dev/null

amass_file="./temp/amass.tmp"
new_lines=()
while IFS= read -r line; do
    if [[ "$line" == *" "* ]]; then
        subdomain=$(echo "$line" | awk '{print $1}')
        new_lines+=("$subdomain")
    else
        new_lines+=("$line")
    fi
done < "$amass_file"

dash="-"
clean_fqdn="${fqdn//./$dash}"
amass_file="./$clean_fqdn.txt"

rm -rf $amass_file >/dev/null 2>/dev/null

printf "%s\n" "${new_lines[@]}" >"$amass_file"

rm -rf ./temp/amass.tmp >/dev/null 2>/dev/null
rm -rf ./temp/amass.full.tmp >/dev/null 2>/dev/null

proxy="http://localhost:8080"

http_verbs=("GET" "HEAD" "OPTIONS" "POST" "PUT" "PATCH" "UPDATE")

url_form_data="rs0n=rs0n"
json_data='{"rs0n":"rs0n"}'

if [ ! -f "$amass_file" ]; then
    exit 1
fi

urls=()
while IFS= read -r line; do
    urls+=("$line")
done < "$amass_file"

for url in "${urls[@]}"; do
    verb="GET"
    curl -X "$verb" -sS -o /dev/null -w "%{http_code}\n" -x "$proxy" "$url"
done

for verb in "${http_verbs[@]:1}"; do
    for url in "${urls[@]}"; do
        if [[ "$verb" == "GET" || "$verb" == "HEAD" || "$verb" == "OPTIONS" ]]; then
            continue
        fi

        curl -X "$verb" -sS -o /dev/null -w "%{http_code}\n" -x "$proxy" --data "$url_form_data" "$url"
        curl -X "$verb" -sS -o /dev/null -w "%{http_code}\n" -x "$proxy" --insecure --data "$url_form_data" "$url"
        
        curl -X "$verb" -sS -o /dev/null -w "%{http_code}\n" -H "Content-Type: application/json" -x "$proxy" --data "$json_data" "$url"
        curl -X "$verb" -sS -o /dev/null -w "%{http_code}\n" -H "Content-Type: application/json" -x "$proxy" --insecure --data "$json_data" "$url"
    done
done
