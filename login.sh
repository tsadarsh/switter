#!/bin/bash

# navigate to twitter login page
curl -d '{"url":"https://twitter.com/login"}' $base_url/url | jq > $log

# enter credentials
echo -n -e "\nUsername: "
read uname
unameJSON='{"value":["'$uname'"]}'

echo -n -e "\nPassword: "
read pwd
pwdJSON='{"value":["'$pwd'"]}'

username_elem_id=$(curl -d '{"using":"name","value":"session[username_or_email]"}' $base_url/element | jq ".value.ELEMENT" | cut -d'"' -f 2) > $log
curl -d $unameJSON $base_url/element/$username_elem_id/value | jq > $log

password_elem_id=$(curl -d '{"using":"name","value":"session[password]"}' $base_url/element | jq ".value.ELEMENT" | cut -d'"' -f 2) > $log
curl -d $pwdJSON $base_url/element/$password_elem_id/value | jq > $log

# click Log in
echo -n -e "\nLog in? [y/n]: "
read logIn
if [ $logIn == "y" ]
then
	login_element_id=$(curl -d '{"using":"xpath","value":"/html/body/div/div/div/div[2]/main/div/div/div[2]/form/div/div[3]/div"}' $base_url/element | jq ".value.ELEMENT" | cut -d'"' -f 2) > $log
	curl -d '{}' $base_url/element/$login_element_id/click | jq > $log
elif [ $logIn == 'n' ]
then
	source ./kill.sh
else
	echo -e "\nI'm taking that as an Yes."
fi