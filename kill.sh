#!/bin/bash

base_url="-# http://localhost:9515/session/$sid"
log=/dev/null

echo -e "\nExiting..."
pid=$(netstat -tulpn | grep -e "LISTEN.*chromedrive" -o | cut -d'N' -f2 | cut -d'/' -f 1 | uniq | xargs)
curl -X DELETE $base_url > $log
kill $pid
exit