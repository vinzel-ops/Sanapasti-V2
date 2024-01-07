#!/bin/bash

SANAPASTI_PATH="$HOME/.sanapasti"
key="$(jq -r '.appliance_key?' "$SANAPASTI_PATH/sanapasti.json")"
app_name="$(jq -r '.appliance_name?' "$SANAPASTI_PATH/sanapasti.json")"
url="$(jq -r '.appliance_url?' "$SANAPASTI_PATH/sanapasti.json")"

function appliances() {
	curl -s "$url/heartbeats/$key" | jq
}

appliance_ip() {
	name="$1"

	appliances | jq -r ".[] | select(.name==\"$name\") | .lan_ip"
}

appliance_list() {
	appliances | jq -r '.[].name'
}

function pretty_appliances()  {
	data="$(appliances)"

	(echo "Instance,External IP,Last Seen,Connected,Authenticated,City,Region,ISP,Link" && echo $data | jq -r 'reverse' | jq  -r '.[] | [.name?,.external_ip?,.heartbeat_last_seen?,.connected?,.authenticated?,.geoip?.city?,.geoip?.region?,.geoip.company?.name?,.geoip.asn.type?] | @csv')| sed 's/"//g' | column -t -s, | perl -pe '$_ = "\033[0;37m$_\033[0;34m" if($. % 2)'
	

}

function gen_app_sshconfig() {
	echo "" >> "$SANAPASTI_PATH/.sshconfig"

	for appliance in $(appliance_list)
	do
		ip=$(appliance_ip "$appliance")
		jump="$app_name"

		echo -e "Host $appliance\n\tHostName $ip\n\tUser op\n\tPort 22\n\tProxyJump $jump\n" >> "$SANAPASTI_PATH/.sshconfig"
	done
}
