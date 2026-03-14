NC='\e[0m'
DEFBOLD='\e[39;1m'
RB='\e[31;1m'
GB='\e[32;1m'
YB='\e[33;1m'
BB='\e[34;1m'
MB='\e[35;1m'
CB='\e[35;1m'
WB='\e[37;1m'
clear
domain=$(cat /usr/local/etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  ${WB}Add Vless Account${NC}                 "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -rp "User: " -e user
CLIENT_EXISTS=$(grep -w $user /usr/local/etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "                  Add Vless Account                 "
echo -e "${BB}————————————————————————————————————————————————————${NC}"
echo -e "${YB}A client with the specified name was already created, please choose another name.${NC}"
echo -e "${BB}————————————————————————————————————————————————————${NC}"
read -n 1 -s -r -p "Press any key to back on menu"
add-vless
fi
done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (days): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vless$/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
sed -i '/#vless-grpc$/a\#= '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /usr/local/etc/xray/config.json
vlesslink1="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user"
vlesslink2="vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user"
vlesslink3="vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user"
xrayvless4="vless://${uuid}@cdn.who.int:80?path=/vless&encryption=none&type=ws&host=cdn.who.int.${domain}#${user}"
xrayvless5="vless://${uuid}@api.useinsider.com:80?path=/vless&encryption=none&type=ws&host=${domain}#${user}"
xrayvless6="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=open.spotify.com#${user}"
xrayvless7="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=playtv.unifi.com.my#${user}"
xrayvless8="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=music.u.com.my#${user}"
xrayvless9="vless://${uuid}@prod-in.viu.com.${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=prod-in.viu.com#${user}"
xrayvless10="vless://${uuid}@www.speedtest.net:80?path=/vless&encryption=none&type=ws&host=www.speedtest.net.${domain}#${user}"
xrayvless11="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=music.u.com.my#$user"
xrayvless12="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=open.spotify.com#$user"
xrayvless13="vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=playtv.unifi.com.my#$user"
 cat <<EOF >>"/user/config-user/${user}"
vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user
vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user
vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user
vless://${uuid}@yes.mascorp.eu.org:80?path=/vless&encryption=none&type=ws&host=cdn.who.int.${domain}#${user}@yes4g
vless://${uuid}@api.useinsider.com:80?path=/vless&encryption=none&type=ws&host=${domain}#${user}@digi
vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=open.spotify.com#${user}@beone
vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=playtv.unifi.com.my#${user}@unifi
vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=opensignal.com#${user}@umo
vless://${uuid}@prod-in.viu.com.${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=prod-in.viu.com#${user}@maxistv
vless://${uuid}@www.speedtest.net:80?path=/vless&encryption=none&type=ws&host=www.speedtest.net.${domain}#${user}@celcombooster
vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=opensignal.com#$user@umo2
vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=open.spotify.com#$user@beone2
vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=playtv.unifi.com.my#$user@unifi
EOF
cat > /var/www/html/vless/vless-$user.txt << END
==========================
Vless WS (CDN) TLS
==========================
- name: Vless-$user
type: vless
server: ${domain}
port: 443
uuid: ${uuid}
cipher: auto
udp: true
tls: true
skip-cert-verify: true
servername: ${domain}
network: ws
ws-opts:
path: /vless
headers:
Host: ${domain}
==========================
Vless WS (CDN)
==========================
- name: Vless-$user
type: vless
server: ${domain}
port: 80
uuid: ${uuid}
cipher: auto
udp: true
tls: false
skip-cert-verify: false
network: ws
ws-opts:
path: /vless
headers:
Host: ${domain}
==========================
Vless gRPC (CDN)
==========================
- name: Vless-$user
server: $domain
port: 443
type: vless
uuid: $uuid
cipher: auto
network: grpc
tls: true
servername: $domain
skip-cert-verify: true
grpc-opts:
grpc-service-name: "vless-grpc"
==========================
Link Vless Account
==========================
Link TL   : vless://$uuid@$domain:443?path=/vless&security=tls&encryption=none&host=$domain&type=ws&sni=$domain#$user
==========================
Link NTLS : vless://$uuid@$domain:80?path=/vless&security=none&encryption=none&host=$domain&type=ws#$user
==========================
Link gRPC : vless://$uuid@$domain:443?security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=$domain#$user
==========================
END
	base64Result=$(base64 -w 0 /user/config-user/${user})
    echo ${base64Result} >"/var/www/html/vless/${uuid}"
    systemctl restart xray.service
ISP=$(cat /usr/local/etc/xray/org)
CITY=$(cat /usr/local/etc/xray/city)
systemctl restart xray
clear
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "                    Vless Account                   " | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Remarks       : ${user}" | tee -a /user/log-vless-$user.txt
echo -e "Domain        : ${domain}" | tee -a /user/log-vless-$user.txt
echo -e "ISP           : $ISP" | tee -a /user/log-vless-$user.txt
echo -e "City          : $CITY" | tee -a /user/log-vless-$user.txt
echo -e "Wildcard      : (bug.com).${domain}" | tee -a /user/log-vless-$user.txt
echo -e "Port TLS      : 443" | tee -a /user/log-vless-$user.txt
echo -e "Port NTLS     : 80" | tee -a /user/log-vless-$user.txt
echo -e "Port gRPC     : 443" | tee -a /user/log-vless-$user.txt
echo -e "Alt Port TLS  : 2053, 2083, 2087, 2096, 8443" | tee -a /user/log-vless-$user.txt
echo -e "Alt Port NTLS : 8080, 8880, 2052, 2082, 2086, 2095" | tee -a /user/log-vless-$user.txt
echo -e "id            : ${uuid}" | tee -a /user/log-vless-$user.txt
echo -e "Encryption    : none" | tee -a /user/log-vless-$user.txt
echo -e "Network       : Websocket, gRPC" | tee -a /user/log-vless-$user.txt
echo -e "Path          : /vless" | tee -a /user/log-vless-$user.txt
echo -e "ServiceName   : vless-grpc" | tee -a /user/log-vless-$user.txt
echo -e "Alpn          : h2, http/1.1" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link TLS      : ${vlesslink1}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link NTLS     : ${vlesslink2}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Link gRPC     : ${vlesslink3}" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Format Clash  : http://$domain:8000/vless/vless-$user.txt" | tee -a /user/log-vless-$user.txt
echo -e " Link url OPENWRT/xrayN PC: http://${domain}:81/vless/${uuid}"
echo -e "=========================" | tee -a /user/log-vless-$user.txt
echo -e "Link TLS    : ${xrayvless1}" | tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e "Link No TLS : ${xrayvless2}" | tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e "Link GRPC   : ${xrayvless3}" | tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link Yes4g   : ${xrayvless4}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link Digi Booster   : ${xrayvless5}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link Redone/Beone music(GRPC)   : ${xrayvless6}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link Redone/Beone music(WS)   : ${xrayvless12}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link Unifi Freeze (GRPC): ${xrayvless7}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link Unifi Freeze (WS): ${xrayvless13}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link umobile (GRPC): ${xrayvless8}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link umobile (WS): ${xrayvless11}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link maxis tv: ${xrayvless9}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "Link celcom freeze kuota/booster : ${xrayvless10}"| tee -a /user/log-vless-$user.txt
echo -e " "| tee -a /user/log-vless-$user.txt
echo -e "========================="| tee -a /user/log-vless-$user.txt
echo "Script Mod By surun"| tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo -e "Expired On    : $exp" | tee -a /user/log-vless-$user.txt
echo -e "${BB}————————————————————————————————————————————————————${NC}" | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
echo " " | tee -a /user/log-vless-$user.txt
read -n 1 -s -r -p "Press any key to back on menu"
clear
vless
