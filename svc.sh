svc="etcd docker kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy"
for s in $svc;
do 
	systemctl restart $s 
	echo "$s done."
done
