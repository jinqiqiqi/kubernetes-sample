svc="etcd docker kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy"


start_kube() {
	for s in $svc;
	do
		echo "starting $s"
		systemctl start $s;
	done
	
}

stop_kube() {
	for s in $svc;
	do
		echo "stoping $s"
		systemctl stop $s
	done
}

restart_kube(){
	for s in $svc;
	do
		echo "restarting $s"
		systemctl restart $s
	done
}

status_kube(){
	for s in $svc;
	do
		status=$(systemctl status $s | grep Active | awk '{print $3}')
		echo "$s is $status"
	done
}

case $1 in
	stop)
		stop_kube
		;;

	start)
		start_kube
		;;

	restart)
		restart_kube
		;;
	status)
		status_kube
		;;
	*)
		echo "Available Params: start, stop, restart, status."
		;;
esac



