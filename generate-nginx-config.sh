#!/bin/bash

AZURE_IPS_URL="https://www.microsoft.com/en-us/download/confirmation.aspx?id=56519"
ACTUAL_URL=$(curl -sL "$AZURE_IPS_URL" | grep -Eo 'https://download\.microsoft\.com/download/[^"]*\.json' | head -1)

if [ -z "$ACTUAL_URL" ]; then
    echo "Error: Could not find Azure IP ranges download URL"
    exit 1
fi

curl -s "$ACTUAL_URL" | jq -r '
.values[] |
select(.name | test("AzureFrontDoor.Backend"; "i")) |
.properties.addressPrefixes[]' | sort -u > azure_frontdoor_ips.txt

IP_COUNT=$(wc -l < ./azure_frontdoor_ips.txt)
echo "Retrieved $IP_COUNT Azure Front Door IP ranges"

while read ip; do
    echo "    set_real_ip_from $ip;"
done < azure_frontdoor_ips.txt > azure_directives.txt

sed -e '/{{AZURE_IPS}}/ {
    r azure_directives.txt
    d
}' /tmp/nginx.conf.template > /etc/nginx/nginx.conf
