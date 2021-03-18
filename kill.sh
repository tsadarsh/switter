#!/bin/bash

echo -e "\nExiting..."
pid=$(netstat -tulpn | grep -e "LISTEN.*chromedrive" -o | cut -d'N' -f2 | cut -d'/' -f 1 | uniq | xargs)
curl -X DELETE $base_url
kill $pid
exit