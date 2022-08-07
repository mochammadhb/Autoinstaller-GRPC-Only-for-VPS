#!/bin/bash

checkLisensi () 
{

	RED='\033[0;31m'
	NC='\033[0m'
	GREEN='\033[0;32m'
	ORANGE='\033[0;33m'
	BLUE='\033[0;34m'
	PURPLE='\033[0;35m'
	CYAN='\033[0;36m'
	LIGHT='\033[0;37m'

	MYIP=$(curl -s -X GET https://checkip.amazonaws.com);
	echo "Checking VPS"
	IZIN=$( curl https://juraganssh.my.id/installer/grpc/ipvps.txt | grep "$MYIP" );
			
			if [ $MYIP = $IZIN >/dev/null 2>&1 ]; then
			echo -e "${NC}${GREEN}Permission Accepted...${NC}"
			else
			echo -e "${NC}${RED}Permission Denied!${NC}";
			echo -e "${NC}${LIGHT}Please Contact Admin!!"
			echo -e "${NC}${LIGHT}WhatsApp : 082233341225"
			echo -e "${NC}${LIGHT}Telegram : https://t.me/mochammadhb"
			exit 0
			fi
			
}

clear
m="\033[0;1;36m"
y="\033[0;1;37m"
yy="\033[0;1;31m"
yl="\033[0;1;33m"
bl="\033[0;1;34m"
wh="\033[0m"
echo -e "-----========[ XRAY GRPC Auto Installer ]========-----\n    JuraganSSH Service AutoScript - juraganssh.my.id" | boxes -d cat | lolcat
echo -e ""
echo -e "${yy} 1${wh}.  Create XRAY Vmess GRPC Account (${bl}addvmess${wh})"
echo -e "${yy} 2${wh}.  Delete XRAY Vmess GRPC Account (${bl}delvmess${wh})"
echo -e "${yy} 3${wh}.  Create XRAY Vless GRPC Account (${bl}addvless${wh})"
echo -e "${yy} 4${wh}.  Delete XRAY Vless GRPC Account (${bl}delvless${wh})"
echo -e "${yy} 5${wh}.  Create XRAY Trojan GRPC Account (${bl}addtrojan${wh})"
echo -e "${yy} 6${wh}.  Delete XRAY Trojan GRPC Account (${bl}deltrojan${wh})"
echo -e "${yy} 7${wh}.  Create XRAY Shadowsocks GRPC Account (${bl}addss${wh})"
echo -e "${yy} 8${wh}.  Delete XRAY Shadowsocks GRPC Account (${bl}delss${wh})"
echo -e "${yy} 9${wh}.  Delete AutoScripts (${bl}delscript${wh})"
echo -e "${yy} x${wh}.  Exit (${bl}exit${wh})"
echo -e ""
read -p "Please Enter Number [ 1-9 or x ] : " menu
case $menu in
1)
checkLisensi
clear
get=$(curl -s -X GET https://checkip.amazonaws.com);
domain=$(cat /etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/conf/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo -e "Username \033[0;31m${CLIENT_EXISTS}\033[0m Already On VPS Please Choose Another"
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#xray-vmess-grpc$/a\### '"$user $exp"'\
},{"id": "'""$uuid""'"' /etc/xray/conf/config.json
cat <<EOF >/etc/xray/vmess-$user-grpc.json
{
	"v": "2",
	"ps": "${user}",
	"add": "${domain}",
	"port": "443",
	"id": "${uuid}",
	"aid": "0",
	"net": "grpc",
	"type": "none",
	"host": "${domain}",
	"path": "xray-vmess-grpc",
	"tls": "tls"
}
EOF
config="vmess://$(base64 -w 0 /etc/xray/vmess-$user-grpc.json)"
rm -rf /etc/xray/vmess-$user-grpc.json
systemctl restart xray.service
service cron restart
clear
echo -e ""
echo -e "======-XRAYS/VMESS GRPC-======"
echo -e "Remarks     : ${user}"
echo -e "Protocol    : vmess"
echo -e "IP/Host     : ${get}"
echo -e "Address     : ${domain}"
echo -e "Port        : 443"
echo -e "User ID     : ${uuid}"
echo -e "Alter ID    : 0"
echo -e "Security    : auto"
echo -e "Network     : grpc"
echo -e "ServiceName : xray-vmess-grpc"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "==============================="
echo -e "Link TLS    : ${config}"
echo -e "==============================="
;;
2)
checkLisensi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/conf/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/conf/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $user $exp/,/^},{/d" /etc/xray/conf/config.json
sed -i "/^### $user $exp/,/^},{/d" /etc/xray/conf/config.json
systemctl restart xray.service
service cron restart
clear
echo ""
echo "==============================="
echo "  XRAYS/Vmess Account Deleted  "
echo "==============================="
echo "Username  : $user"
echo "Expired   : $exp"
echo "==============================="
echo "     Script By JuraganSSH"
;;
3)
checkLisensi
clear
get=$(curl -s -X GET https://checkip.amazonaws.com);
domain=$(cat /etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/conf/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo -e "Username \033[0;31m${CLIENT_EXISTS}\033[0m Already On VPS Please Choose Another"
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#xray-vless-grpc$/a\#### '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/conf/config.json
config="vless://${uuid}@${domain}:443?encryption=none&security=tls&type=grpc&host=${domain}&path=xray-vless-grpc&serviceName=xray-vless-grpc&alpn=h2&sni=${domain}\n"
systemctl restart xray.service
service cron restart
clear
echo -e ""
echo -e "======-XRAYS/VLESS GRPC-======"
echo -e "Remarks     : ${user}"
echo -e "Protocol    : vless"
echo -e "IP/Host     : ${get}"
echo -e "Address     : ${domain}"
echo -e "Port        : 443"
echo -e "User ID     : ${uuid}"
echo -e "Encryption  : none"
echo -e "Security    : auto"
echo -e "Network     : grpc"
echo -e "ServiceName : xray-vless-grpc"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "==============================="
echo -e "Link TLS    : ${config}"
echo -e "==============================="
;;
4)
checkLisensi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#### " "/etc/xray/conf/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^#### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#### " "/etc/xray/conf/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^#### $user $exp/,/^},{/d" /etc/xray/conf/config.json
sed -i "/^#### $user $exp/,/^},{/d" /etc/xray/conf/config.json
systemctl restart xray.service
service cron restart
clear
echo ""
echo "==============================="
echo "  XRAYS/Vless Account Deleted  "
echo "==============================="
echo "Username  : $user"
echo "Expired   : $exp"
echo "==============================="
echo "     Script By JuraganSSH"
;;
5)
checkLisensi
clear
get=$(curl -s -X GET https://checkip.amazonaws.com);
domain=$(cat /etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/conf/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo -e "Username \033[0;31m${CLIENT_EXISTS}\033[0m Already On VPS Please Choose Another"
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#xray-trojan-grpc$/a\##### '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/conf/config.json
config="trojan://${uuid}@${domain}:443?encryption=none&peer=${domain}&security=tls&type=grpc&sni=${domain}&alpn=h2&path=xray-trojan-grpc&serviceName=xray-trojan-grpc#${domain}_TRGRPC\n"
systemctl restart xray.service
service cron restart
clear
echo -e ""
echo -e "======-XRAYS/TROJAN GRPC-======"
echo -e "Remarks     : ${user}"
echo -e "Protocol    : trojan"
echo -e "IP/Host     : ${get}"
echo -e "Address     : ${domain}"
echo -e "Port        : 443"
echo -e "User ID     : ${uuid}"
echo -e "Encryption  : none"
echo -e "Security    : auto"
echo -e "Network     : grpc"
echo -e "ServiceName : xray-trojan-grpc"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "==============================="
echo -e "Link TLS    : ${config}"
echo -e "==============================="
;;
6)
checkLisensi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^##### " "/etc/xray/conf/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^##### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^##### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^##### " "/etc/xray/conf/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^##### $user $exp/,/^},{/d" /etc/xray/conf/config.json
sed -i "/^##### $user $exp/,/^},{/d" /etc/xray/conf/config.json
systemctl restart xray.service
service cron restart
clear
echo ""
echo "==============================="
echo "  XRAYS/Trojan Account Deleted  "
echo "==============================="
echo "Username  : $user"
echo "Expired   : $exp"
echo "==============================="
echo "     Script By JuraganSSH"
;;
7)
checkLisensi
clear
get=$(curl -s -X GET https://checkip.amazonaws.com);
domain=$(cat /etc/xray/domain)
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
		read -rp "Username : " -e user
		CLIENT_EXISTS=$(grep -w $user /etc/xray/conf/config.json | wc -l)

		if [[ ${CLIENT_EXISTS} == '1' ]]; then
			echo ""
			echo -e "Username \033[0;31m${CLIENT_EXISTS}\033[0m Already On VPS Please Choose Another"
			exit 1
		fi
	done
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "Expired (Days) : " masaaktif
hariini=`date -d "0 days" +"%Y-%m-%d"`
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#xray-shadows-grpc$/a\###### '"$user $exp"'\
},{"method": "'""chacha20-ietf-poly1305""'","password": "'""$uuid""'"' /etc/xray/conf/config.json
systemctl restart xray.service
service cron restart
clear
echo -e ""
echo -e "======-XRAYS/SS GRPC-=========="
echo -e "Remarks     : ${user}"
echo -e "Protocol    : shadowsocks"
echo -e "IP/Host     : ${get}"
echo -e "Address     : ${domain}"
echo -e "Port        : 443"
echo -e "User ID     : ${uuid}"
echo -e "Security    : auto"
echo -e "Network     : grpc"
echo -e "ServiceName : xray-shadows-grpc"
echo -e "Created     : $hariini"
echo -e "Expired     : $exp"
echo -e "==============================="
;;
8)
checkLisensi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^###### " "/etc/xray/conf/config.json")
	if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
		echo ""
		echo "You have no existing clients!"
		exit 1
	fi

	clear
	echo ""
	echo " Select the existing client you want to remove"
	echo " Press CTRL+C to return"
	echo " ==============================="
	echo "     No  Expired   User"
	grep -E "^###### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
	until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
		if [[ ${CLIENT_NUMBER} == '1' ]]; then
			read -rp "Select one client [1]: " CLIENT_NUMBER
		else
			read -rp "Select one client [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
		fi
	done
user=$(grep -E "^###### " "/etc/xray/conf/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^###### " "/etc/xray/conf/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^###### $user $exp/,/^},{/d" /etc/xray/conf/config.json
sed -i "/^###### $user $exp/,/^},{/d" /etc/xray/conf/config.json
systemctl restart xray.service
service cron restart
clear
echo ""
echo "==============================="
echo "    XRAYS/SS Account Deleted   "
echo "==============================="
echo "Username  : $user"
echo "Expired   : $exp"
echo "==============================="
echo "     Script By JuraganSSH"
;;
9)
read -p "Apakah anda yakin uninstall autoscripts (y/n)" uns
case $uns in
y)
Info="\033[32m[information]\033[0m"
echo -e "${Info} Uninstall Nginx Webserver"
apt purge nginx* -y >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
sleep 2
echo -e "${Info} Uninstall Xray Core"
rm -r /etc/xray/
rm -f /etc/systemd/system/xray.service
rm -f /usr/local/bin/xray
rm -f /usr/bin/menu
sleep 2
echo -e "${Info} Uninstall Berhasil"
echo -e ""
exit
;;
n)
menu
;;
esac
;;
x)
exit
;;
esac