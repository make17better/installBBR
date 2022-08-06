local test1=$(sed -n '/net.ipv4.tcp_congestion_control/p' /etc/sysctl.conf)
local test2=$(sed -n '/net.core.default_qdisc/p' /etc/sysctl.conf)
if [[ $(uname -r | cut -b 1) -eq 4 ]]; then
	case $(uname -r | cut -b 3-4) in
	9. | [1-9][0-9])
		if [[ $test1 == "net.ipv4.tcp_congestion_control = bbr" && $test2 == "net.core.default_qdisc = fq" ]]; then
			local is_bbr=true
		else
			local try_enable_bbr=true
		fi
		;;
	esac
fi
if [[ $is_bbr ]]; then
	echo
	echo -e "$green BBR 已经启用啦...无需再安装$none"
	echo
elif [[ $try_enable_bbr ]]; then
	sed -i '/net.ipv4.tcp_congestion_control/d' /etc/sysctl.conf
	sed -i '/net.core.default_qdisc/d' /etc/sysctl.conf
	echo "net.ipv4.tcp_congestion_control = bbr" >>/etc/sysctl.conf
	echo "net.core.default_qdisc = fq" >>/etc/sysctl.conf
	sysctl -p >/dev/null 2>&1
	echo
	echo -e "$green ..由于你的 VPS 内核支持开启 BBR ...已经为你启用 BBR 优化....$none"
	echo
else
	# https://teddysun.com/489.html
	bash <(curl -s -L https://github.com/teddysun/across/raw/master/bbr.sh)
fi
