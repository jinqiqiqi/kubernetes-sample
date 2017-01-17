svc="etcd docker kube-apiserver kube-controller-manager kube-scheduler kubelet kube-proxy"
for s in $svc;
do
	sudo systemctl restart $s;
	echo "finished $s."
done
