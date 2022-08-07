#!/usr/bin/bash
#######################################
# this script created by @mochammadhb #
#######################################
#      https://juraganssh.my.id       #
#######################################

checkingRoot ()
{
	echo -e "checking ROOT privilege..."
		if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
		fi
	sleep 3
	echo -e "checking OPENVZ is Supporting..."
		if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
		fi
	echo -e "Detecting Operating System is `lsb_release -i | awk '{print $3}'` ..."
	sleep 3
}

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
	IZIN=$( curl https://juraganssh.my.id/main/ipvps.php | grep "$MYIP" );
			
			if [ $MYIP = $IZIN ]; then
			echo -e "${NC}${GREEN}Permission Accepted...${NC}"
			else
			echo -e "${NC}${RED}Permission Denied!${NC}";
			echo -e "${NC}${LIGHT}Please Contact Admin!!"
			echo -e "${NC}${LIGHT}WhatsApp : 082233341225"
			echo -e "${NC}${LIGHT}Telegram : https://t.me/mochammadhb"
			exit 0
			fi
			
}

cloudflare() 
{
		clear
		apt install jq curl -y 
		DOMAIN=miss.my.id
		sub=$(</dev/urandom tr -dc a-z0-9 | head -c5)
		SUB_DOMAIN=${sub}.miss.my.id
		CF_BEARER=o5kpt_u92oJtIhzv_i7CyleJEb9Ou55W_HbzYl6h
		set -euo pipefail
		IP=$(wget -qO- ipinfo.io/ip);
		echo "Updating DNS for ${SUB_DOMAIN}..."
		ZONE=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones?name=${DOMAIN}&status=active" \
			 -H "Authorization: Bearer $CF_BEARER" \
			 -H "Content-Type: application/json" | jq -r .result[0].id)

		RECORD=$(curl -sLX GET "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records?name=${SUB_DOMAIN}" \
			 -H "Authorization: Bearer $CF_BEARER" \
			 -H "Content-Type: application/json" | jq -r .result[0].id)

		if [[ "${#RECORD}" -le 10 ]]; then
			 RECORD=$(curl -sLX POST "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records" \
			 -H "Authorization: Bearer $CF_BEARER" \
			 -H "Content-Type: application/json" \
			 --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}' | jq -r .result.id)
		fi

		RESULT=$(curl -sLX PUT "https://api.cloudflare.com/client/v4/zones/${ZONE}/dns_records/${RECORD}" \
			 -H "Authorization: Bearer $CF_BEARER" \
			 -H "Content-Type: application/json" \
			 --data '{"type":"A","name":"'${SUB_DOMAIN}'","content":"'${IP}'","ttl":120,"proxied":false}')
			 
		echo "Host : $SUB_DOMAIN"
		echo $SUB_DOMAIN > /root/domain
		# / / Make Main Directory
		mkdir -p /usr/bin/xray
		mkdir -p /etc/xray
		cp /root/domain /etc/xray
}

checkSystem()
{
	if [[ -n $(find /etc -name "redhat-release") ]] || grep </proc/version -q -i "centos"; then
		mkdir -p /etc/yum.repos.d

		if [[ -f "/etc/centos-release" ]]; then
			centosVersion=$(rpm -q centos-release | awk -F "[-]" '{print $3}' | awk -F "[.]" '{print $1}')

			if [[ -z "${centosVersion}" ]] && grep </etc/centos-release -q -i "release 8"; then
				centosVersion=8
			fi
		fi

		release="centos"
		installType='yum -y install'
		removeType='yum -y remove'
		upgrade="yum update -y --skip-broken"

	elif grep </etc/issue -q -i "debian" && [[ -f "/etc/issue" ]] || grep </etc/issue -q -i "debian" && [[ -f "/proc/version" ]]; then
		release="debian"
		installType='apt -y install'
		upgrade="apt update"
		updateReleaseInfoChange='apt-get --allow-releaseinfo-change update'
		removeType='apt -y autoremove'

	elif grep </etc/issue -q -i "ubuntu" && [[ -f "/etc/issue" ]] || grep </etc/issue -q -i "ubuntu" && [[ -f "/proc/version" ]]; then
		release="ubuntu"
		installType='apt -y install'
		upgrade="apt update"
		updateReleaseInfoChange='apt-get --allow-releaseinfo-change update'
		removeType='apt -y autoremove'
		if grep </etc/issue -q -i "16."; then
			release=
		fi
	fi

	if [[ -z ${release} ]]; then
		echo -e "\nThis script does not support this system, please feedback the log below to the developer\n"
		echo -e "$(cat /etc/issue)"
		echo -e "$(cat /proc/version)"
		exit 0
	fi
}

checkCPUVendor() 
{
	if [[ -n $(which uname) ]]; then
		if [[ "$(uname)" == "Linux" ]]; then
			case "$(uname -m)" in
			'amd64' | 'x86_64')
				xrayCoreCPUVendor="Xray-linux-64"
				;;
			'armv8' | 'aarch64')
				xrayCoreCPUVendor="Xray-linux-arm64-v8a"
				;;
			*)
				echo " ----> Arsitektur CPU ini tidak didukung..!"
				exit 1
				;;
			esac
		fi
	else
		echo -e "----> Arsitektur CPU ini tidak dikenal, default amd64, x86_64"
		xrayCoreCPUVendor="Xray-linux-64"
	fi
}

installXrayCore() 
{
       # Installing
       clear
       checkCPUVendor
       echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
       echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
       apt install iptables iptables-persistent -y 
       apt install unzip curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
       apt install socat cron bash-completion ntpdate -y 
       ntpdate pool.ntp.org
       apt -y install chrony 
       timedatectl set-ntp true
       systemctl enable chronyd && systemctl restart chronyd
       systemctl enable chrony && systemctl restart chrony
       timedatectl set-timezone Asia/Jakarta
       chronyc sourcestats -v
       chronyc tracking -v
       date

      # Ambil Xray Core Versi Terbaru
      version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
      echo -e " ---> installing XRAY Core : ${version}"
      sleep 3
      xrayurl="https://github.com/XTLS/Xray-core/releases/download/v${version}/${xrayCoreCPUVendor}.zip"
      
      mkdir -p /usr/bin/xray/
      mkdir -p /etc/xray/conf/
      mkdir -p /etc/xray/subscribe/
      
      cd `mktemp -d`
      wget "${xrayurl}" && unzip Xray-linux-64.zip && mv xray /usr/local/bin/ && chmod +x /usr/local/bin/xray
      
      # Make Folder XRay
      mkdir -p /var/log/xray/
}

certv2ray() 
{
      # Make Certificate
      domain=$(cat /etc/xray/domain)
      cd /root/
      wget https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh
      bash acme.sh --install
      rm acme.sh
      cd .acme.sh
      clear
      echo "Creating SSL Certificate..."
      bash acme.sh --set-default-ca  --server  letsencrypt
      bash acme.sh --register-account -m juragansshmyid@gmail.com
      bash acme.sh --issue --standalone -d $domain --force
      bash acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key
}

configureXray() 
{
        # Generate UUID
        uuid=$(cat /proc/sys/kernel/random/uuid)
        # // Certificate File
        path_crt="/etc/xray/xray.crt"
        path_key="/etc/xray/xray.key"
        
		# Buat Config Xray
		cat > /etc/xray/conf/config.json << END
{
  "log": {
     "access": "/var/log/xray/access5.log",
     "error": "/var/log/xray/error.log",
     "loglevel": "info"
   },
    "inbounds":[
    {
      "port": 443,
      "protocol": "vless",
      "settings": {
        "clients": [
         {
            "id": "${uuid}"
          }
        ],
        "decryption": "none",
        "fallbacks": [
            {"dest":31300,"xver":0},{"alpn":"h2","dest":31305,"xver":0}
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "minVersion": "1.2",
          "alpn": [
            "http/1.1",
            "h2"
          ],
          "certificates": [
            {
              "certificateFile": "${path_crt}",
              "keyFile": "${path_key}",
              "ocspStapling": 3600,
              "usage":"encipherment"
                }
              ]
            }
          }
    },
    {
        "port": 31301,
        "listen": "127.0.0.1",
        "protocol": "vmess",
        "settings": {
            "clients": [
                {
                    "id": "${uuid}",
	    "alterId": 0
#xray-vmess-grpc
                }
            ]
        },
        "streamSettings": {
            "network": "grpc",
            "grpcSettings": {
                "serviceName": "xray-vmess-grpc"
            }
        }
    },
	{
        "port": 31302,
        "listen": "127.0.0.1",
        "protocol": "vless",
        "settings": {
            "clients": [
                {
                    "id": "${uuid}"
#xray-vless-grpc
                }
            ],
            "decryption": "none"
        },
        "streamSettings": {
            "network": "grpc",
            "grpcSettings": {
                "serviceName": "xray-vless-grpc"
            }
        }
    },
	{
            "port": 31303,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "${uuid}"
#xray-trojan-grpc
                    }
                ],
                "fallbacks": [
                    {
                        "dest": "31300"
                    }
                ]
            },
            "streamSettings": {
                "network": "grpc",
                "grpcSettings": {
                    "serviceName": "xray-trojan-grpc"
                }
            }
        },
		 {
			"port": 31304,
            "listen": "127.0.0.1",
            "protocol": "shadowsocks",
            "settings": {
		"clients": [
		{
                "method": "chacha20-ietf-poly1305",
                "password": "${uuid}"
#xray-shadows-grpc
			}
		]
            },
            "streamSettings": {
                "network": "grpc",
                "grpcSettings": {
                    "serviceName": "xray-shadows-grpc"
                }
            }
        }
],
    "outbounds":[
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv4"
            },
            "tag":"IPv4-out"
        },
        {
            "protocol":"freedom",
            "settings":{
                "domainStrategy":"UseIPv6"
            },
            "tag":"IPv6-out"
        },
        {
            "protocol":"blackhole",
            "tag":"blackhole-out"
        }
    ],
        "dns": {
             "servers": [
               "localhost"
        ]
  }
}
END

		# Installation Xray Service
		execStart='/usr/local/bin/xray run -confdir /etc/xray/conf'
		cat <<EOF >/etc/systemd/system/xray.service
[Unit]
Description=Xray - A unified platform for anti-censorship
# Documentation=https://v2ray.com https://guide.v2fly.org
After=network.target nss-lookup.target
Wants=network-online.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_BIND_SERVICE CAP_NET_RAW
NoNewPrivileges=yes
ExecStart=${execStart}
Restart=on-failure
RestartPreventExitStatus=23


[Install]
WantedBy=multi-user.target
EOF

		echo -e "---> Configure Xray to start automatically after booting ."
		sleep 2
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
		iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
		iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
		iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
		iptables-save > /etc/iptables.up.rules
		iptables-restore -t < /etc/iptables.up.rules
		netfilter-persistent save
		netfilter-persistent reload
		systemctl daemon-reload
		systemctl stop xray.service
		systemctl start xray.service
		systemctl enable xray.service
		systemctl restart xray.service
}

installNginxTools()
{
	if [[ "${release}" == "debian" ]]; then
		sudo apt install gnupg2 ca-certificates lsb-release -y 
		echo "deb http://nginx.org/packages/mainline/debian $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list 
		echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
		curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key 
		# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
		sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc
		sudo apt update 

	elif [[ "${release}" == "ubuntu" ]]; then
		sudo apt install gnupg2 ca-certificates lsb-release -y 
		echo "deb http://nginx.org/packages/mainline/ubuntu $(lsb_release -cs) nginx" | sudo tee /etc/apt/sources.list.d/nginx.list 
		echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" | sudo tee /etc/apt/preferences.d/99nginx 
		curl -o /tmp/nginx_signing.key https://nginx.org/keys/nginx_signing.key 
		# gpg --dry-run --quiet --import --import-options import-show /tmp/nginx_signing.key
		sudo mv /tmp/nginx_signing.key /etc/apt/trusted.gpg.d/nginx_signing.asc 
		sudo apt update 
	fi
	${installType} nginx 
	systemctl daemon-reload
	systemctl enable nginx
}

nginxConfiguration() 
{
		domain=$(cat /etc/xray/domain)
		cat <<EOF >/etc/nginx/conf.d/alone.conf
server {
        listen 80;
        listen [::]:80;
        server_name ${domain};
        # shellcheck disable=SC2154
        return 301 https://${domain};
    }
        
server {
        listen 127.0.0.1:31300;
        server_name _;
        return 403;
    }

server {
        listen 127.0.0.1:31305 http2 so_keepalive=on;
        server_name ${domain};
        root /usr/share/nginx/html;

        client_header_timeout 1071906480m;
        keepalive_timeout 1071906480m;

        location /s/ {
        add_header Content-Type text/plain;
        alias /etc/xray/subscribe/;
        }

        location /xray-vmess-grpc {
        if (\$content_type !~ "application/grpc") {
        return 404;
        }
 		
        client_max_body_size 0;
        grpc_set_header X-Real-IP \$proxy_add_x_forwarded_for;
        client_body_timeout 1071906480m;
        grpc_read_timeout 1071906480m;
        grpc_pass grpc://127.0.0.1:31301;
        }
		
        location /xray-vless-grpc {
        if (\$content_type !~ "application/grpc") {
        return 404;
        }

        client_max_body_size 0;
        grpc_set_header X-Real-IP \$proxy_add_x_forwarded_for;
        client_body_timeout 1071906480m;
        grpc_read_timeout 1071906480m;
        grpc_pass grpc://127.0.0.1:31302;
        }

        location /xray-trojan-grpc {
        if (\$content_type !~ "application/grpc") {
        return 404;
        }
		
        client_max_body_size 0;
        grpc_set_header X-Real-IP \$proxy_add_x_forwarded_for;
        client_body_timeout 1071906480m;
        grpc_read_timeout 1071906480m;
        grpc_pass grpc://127.0.0.1:31303;
        }
		
        location /xray-shadows-grpc {
        if (\$content_type !~ "application/grpc") {
        return 404;
        }
		
        client_max_body_size 0;
        grpc_set_header X-Real-IP \$proxy_add_x_forwarded_for;
        client_body_timeout 1071906480m;
        grpc_read_timeout 1071906480m;
        grpc_pass grpc://127.0.0.1:31304;
        }
    }

server {
        listen 127.0.0.1:31300;
        server_name ${domain};
        root /usr/share/nginx/html;
        
		location /s/ {
        add_header Content-Type text/plain;
        alias /etc/xray/subscribe/;
        }
        
		location / {
        add_header Strict-Transport-Security "max-age=15552000; preload" always;
        }
}
EOF

}

installMenu() {
	sudo apt install neofetch -y
	sudo apt install boxes -y 
	apt-get install ruby -y 
	cd `mktemp -d`
	wget https://github.com/busyloop/lolcat/archive/master.zip 
	unzip master.zip 
	cd lolcat-master/bin
	gem install lolcat 
	cd /usr/bin/
	wget -O menu https://juraganssh.my.id/main/setup/grpc/menu.sh >/dev/null 2>&1
	chmod +x menu
cat <<END >~/.profile
clear
neofetch && echo -e "\033[0mType \033[0;1;31mmenu\033[0m Show Menu List\033[0m"
END
}

callBack() {
Info="\033[32m[information]\033[0m"
clear
checkingRoot
clear
echo -e "${Info} Checking Lisensi.."
sleep 2
checkLisensi
clear
echo -e "${Info} Get Domain Cloudflare.."
sleep 2
cloudflare
checkSystem
clear
echo -e "${Info} Installing Xray Core.."
sleep 2
installXrayCore
clear
echo -e "${Info} Installing Certificate.."
sleep 2
certv2ray
clear
echo -e "${Info} Configure Xray Core.."
sleep 2
configureXray
clear
echo -e "${Info} Configure Nginx/Webserver.."
sleep 2
installNginxTools
nginxConfiguration
clear
echo -e "${Info} Installing Main Menu.."
sleep 2
installMenu
clear
echo -e "${Info} Installasi Berhasil"
echo -e "Reboot 15s"
sleep 15
rm ~/install.sh
reboot
}

callBack