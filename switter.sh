#!/bin/bash

# Start Web driver and init browser session
./chromedriver &

#GLOBAL VARS
log=/dev/null
sid=$(curl -# -d '{"desiredCapabilities":{"browserName":"chrome"}}' http://localhost:9515/session | jq '.sessionId' | cut -d'"' -f 2) > $log
echo -e "session id: $sid"
base_url="-# http://localhost:9515/session/$sid"

# request twitter login
source ./login.sh

echo -n -e "\nLogging you in."
timeout=0
correct_login="https://twitter.com/home"
incorrect_login="https://twitter.com/login"
while [[ true ]]; do
	get_url=$(curl -s -g http://localhost:9515/session/$sid/url | jq '.value' | cut -d'"' -f 2) > $log
	if [[ $get_url == $correct_login ]]; then
		break
	elif [[ $get_url =~ $incorrect_login.* ]]; then
		echo -e "\nINCORRECT LOGIN!"
		read null
		source ./login.sh
	elif [[ $timeout -ge 5 ]]; then
		echo -e "/nTimeout exceeded."
		source ./kill.sh
	fi
	echo -n .
	((timeout++))
	sleep 1
done

# goto bookmarks
echo -e "\nGoing to bookmarks"
curl -d '{"url":"https://twitter.com/i/bookmarks"}' $base_url/url | jq > $log

#get file name to write
echo -e "\nFile name to write: "
read fileName

# get to bottom of page
curl -d '{"script":"window.scrollTo(0, document.body.scrollHeight)","args":[]}' $base_url/execute/sync > $log

# get each tweet link element
tweets=$(curl -d '{"using":"xpath","value":"//div/div/article"}' $base_url/elements | jq '.value' | jq 'length')
tlink_string=$(curl -d '{"using":"xpath","value":"//div/div/article/div/div/div/div[2]/div[2]/div[1]/div/div/div[1]/a"}' $base_url/elements | jq '.value' | jq '.[]' | jq '.ELEMENT' | cut -d'"' -f 2)
tname_string=$(curl -d '{"using":"xpath","value":"//div/div/article/div/div/div/div[2]/div[2]/div[1]/div/div/div[1]/div[1]/a/div/div[1]/div[1]/span/span"}' $base_url/elements |  jq '.value' | jq '.[]' | jq '.ELEMENT' | cut -d'"' -f 2)
echo -e "\n$tweets number of tweets found"

tname_list=($tname_string)
tlink_list=($tlink_string)
# for t in ${tlink_string[@]}
# do
# 	tlink_list+=($t)
# done

# # get name of each tweeter
# for t in ${tname_string[@]}
# do
# 	tname_list+=($t)
# done

i=0
while [[ $i < $tweets ]]; do
	echo "---" >> $fileName.md
	curl -g $base_url/element/${tname_list[$i]}/text | jq '.value' | cut -d'"' -f 2 >> $fileName.md
	curl -g $base_url/element/${tlink_list[$i]}/attribute/href | jq '.value' | cut -d'"' -f 2 >> $fileName.md
	((i++))
done

#quit session
source ./kill.sh
