# FAQ

## 1. 问题1 - about node taint

* 问题描述

```sh
Warning  FailedScheduling  4m38s (x426 over 8h)  default-scheduler  0/1 nodes are available: 1 node(s) had taint {node.kubernetes.io/disk-pressure: }, that the pod didn't tolerate.
```

* 解决方案

```yaml
# /var/lib/kubelet/config.yaml 
evictionHard:
  imagefs.available: 0%
  nodefs.available: 0%
```

```sh
service kubelet restart
```

> Refer To: <https://kubernetes.io/docs/concepts/scheduling-eviction/node-pressure-eviction/#minimum-eviction-reclaim>

## 2. 问题2 - unable to retrieve the complete list of server APIs

* 问题描述
  
```sh
$ kubectl api-resources

Error: could not get apiVersions from Kubernetes: unable to retrieve the complete list of server APIs: custom.metrics.k8s.io/v1beta1: the server is currently unable to handle the request
```

* 解决方案

```sh
# 找到出问题的api service
$ kubectl get apiservice

# delete api service
$ kubectl delete apiservice [service-name]
```

## 3. 问题3 - Error: container has runAsNonRoot and image has non-numeric user (memcache), cannot verify user is non-root

* 问题描述
  
```sh
$ kubectl describe pod [pod-name]

 Warning  Failed     25m (x12 over 27m)     kubelet, k8s-host1  Error: container has runAsNonRoot and image has non-numeric user (memcache), cannot verify user is non-root
```

* 问题原因

Here is the [implementation](https://github.com/kubernetes/kubernetes/blob/v1.25.0/pkg/kubelet/kuberuntime/security_context_others.go#L48) of the verification:

```golang
case uid == nil && len(username) > 0:
  return fmt.Errorf("container has runAsNonRoot and image has non-numeric user (%s), cannot verify user is non-root (pod: %q, container: %s)", username, format.Pod(pod), container.Name)
```

And here is the [validation](https://github.com/kubernetes/kubernetes/blob/v1.25.0/pkg/kubelet/kuberuntime/kuberuntime_container.go) call with the comment:

```golang
// Verify RunAsNonRoot. Non-root verification only supports numeric user.
if err := verifyRunAsNonRoot(pod, container, uid, username); err != nil {
  return nil, cleanupAction, err
}
```

As you can see, the only reason of that messages in your case is uid == nil. Based on the comment in the source code, we need to set a numeric user value.

* 解决方案

So, for the user with UID=999 you can do it in your pod definition [like that](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/#set-the-security-context-for-a-pod):

```yaml
securityContext:
    runAsUser: 999
```
