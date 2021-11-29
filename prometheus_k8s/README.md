# Integrating Prometheus with k8s cluster

## Prerequisite
- Deployed k8s cluster

## Install Helm package
```
$ curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
$ chmod 700 get_helm.sh
$ ./get_helm.sh
$ helm --help
```

## Add Prometheus repo to Helm
```
$ helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
$ helm repo update
```

## Create a namespace for Prometheus containers in k8s cluster
```
$ kubectl create namespace prometheus
```

## Use Helm to deploy Prometheus, Grafana and other services used to monitor k8s cluster
```
$ helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus
```

## Make sure all containers are running
```
$ kubectl get pods -n prometheus
NAME                                                     READY   STATUS    RESTARTS   AGE
alertmanager-prometheus-kube-prometheus-alertmanager-0   2/2     Running   0          18m
prometheus-grafana-5b44499cfd-x9ntv                      2/2     Running   0          18m
prometheus-kube-prometheus-operator-67d8f67f76-xs9p8     1/1     Running   0          18m
prometheus-kube-state-metrics-95d956569-f4mgq            1/1     Running   0          18m
prometheus-prometheus-kube-prometheus-prometheus-0       2/2     Running   1          18m
prometheus-prometheus-node-exporter-ctzn6                1/1     Running   0          18m
prometheus-prometheus-node-exporter-hg65v                1/1     Running   0          18m
prometheus-prometheus-node-exporter-j4p9b                1/1     Running   0          18m
prometheus-prometheus-node-exporter-ktq78                1/1     Running   0          18m
prometheus-prometheus-node-exporter-q9fc7                1/1     Running   0          18m
```

## Copy `kubectl` binary and `kubeconfig` file from master node to KVM host

## For Prometheus dashboard, listen for traffic on port 8000 on the KVM host and forward it to port 9090 inside the pod
```
# Since this is remote server, to access the dashboard remotely listen on the host's address and not the localhost.
$ HOST_ADDRESS=$(hostname -i)

$ kubectl port-forward --address $HOST_ADDRESS -n prometheus prometheus-prometheus-kube-prometheus-prometheus-0 8000:9090
Forwarding from HOST_ADDRESS:8000 -> 9090
Handling connection for 8000
Handling connection for 8000
```

## For Grafana dashboard, listen for traffic on port 9000 on the KVM host and forward it to port 3000 inside the pod
```
$ HOST_ADDRESS=$(hostname -i)

$ kubectl port-forward --address $HOST_ADDRESS -n prometheus prometheus-grafana-5b44499cfd-x9ntv 9000:3000
Forwarding from HOST_ADDRESS:9000 -> 3000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
Handling connection for 9000
```
#### With username `admin` and password `prom-operator` you should be able to login into the Grafana dashboard

## For k8s cluster metrics , listen for traffic on port 7000 on the KVM host and forward it to port 8080 inside the pod
```
$ HOST_ADDRESS=$(hostname -i)

$ kubectl port-forward --address $HOST_ADDRESS -n prometheus prometheus-kube-state-metrics-95d956569-f4mgq 7000:8080
Forwarding from 10.74.129.36:7000 -> 8080
Handling connection for 7000
Handling connection for 7000
```
