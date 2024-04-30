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

## 4. 问题4 - 现象是：kuberntes节点上拉取镜像被hang住，等一段时间后，镜像又可以正常被拉取下来

* 问题描述

如标题，场景是在一次性通过helm的方式部署了很多应用，因为业务服务依赖于TiDB，观察发现TiDB的服务在拉取镜像时消耗了很多时间（10mins+, 这个具体的环境有关系），但等了一段时间后
TiDB又正常拉取到镜像并运行起来了。
  
* 问题分析

我们知道镜像的拉取动作属于kubelet组件的职责（不知道的哥哥们可以看下，一个pod是如何在kubernetes上运行起来的详细介绍类的文章），那我们就先去看下对应节点Kubelet的日志，
  
* 问题原因

默认情况下`serializeImagePulls=true`. In other words, `kubelet` sends only one image pull request to the image service at a time. Other image pull requests have to wait until the one being processed is complete.

* 解决方案

修改`serializeImagePulls=false`, 

When `serializeImagePulls` is set to `false`, the kubelet defaults to no limit on the maximum number of images being pulled at the same time. If you would like to limit the number of parallel image pulls, you can set the field `maxParallelImagePulls` in kubelet configuration. With `maxParallelImagePulls` set to `n`, only `n` images can be pulled at the same time, and any image pull beyond `n` will have to wait until at least one ongoing image pull is complete.

Limiting the number parallel image pulls would prevent image pulling from consuming too much network bandwidth or disk I/O, when parallel image pulling is enabled.

You can set `maxParallelImagePulls` to a positive number that is greater than or equal to 1. If you set `maxParallelImagePulls` to be greater than or equal to 2, you must set the `serializeImagePulls` to false. The kubelet will fail to start with invalid `maxParallelImagePulls` settings.

* 扩展

查看当前`kubelet`当前的配置参数

```sh
$ kubectl get --raw "/api/v1/nodes/<nodename>/proxy/configz" | jq
```
Just make sure you replace`<nodename>` with your node name. And if you don't have `jq` installed, leave out the  `| jq` part as that's only for formatting.
  
