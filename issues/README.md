# Issues:


```
Nov 08 03:22:19 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:22:19.533029 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
Nov 08 03:22:20 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:22:20.534916 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
Nov 08 03:22:22 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:22:22.538977 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
Nov 08 03:22:26 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:22:26.551107 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
Nov 08 03:22:34 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:22:34.566968 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
Nov 08 03:22:50 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:22:50.599163 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
Nov 08 03:23:22 worker-0.openshift.local dockerd-current[1071]: WARN: 2020/11/08 08:23:22.630939 TCP connection from 10.40.0.0:42226 to 10.38.0.1:80 blocked by Weave NPC.
```

No network policies are used
```
[root@dell-r440-40 kube]# kubectl get networkpolicies --all-namespaces
No resources found
```

Disable network policies
```
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')&disable-npc=true"
```
