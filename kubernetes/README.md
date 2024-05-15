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

### 问题描述

如标题，场景是在一次性通过helm的方式部署了很多应用，因为业务服务依赖于TiDB，观察发现TiDB的服务在拉取镜像时消耗了很多时间（10mins+, 这个具体的环境有关系），但等了一段时间后
TiDB又正常拉取到镜像并运行起来了。
  
### 问题分析

我们知道镜像的拉取动作属于kubelet组件的职责（不知道的哥哥们可以看下，一个pod是如何在kubernetes上运行起来的详细介绍类的文章），我们从TiDB的events事件中只可以看到拉取镜像消耗了近10分钟的时间，而且均是`Normal`事件，观察对应节点Kubelet的日志也没有看到对应的明显错误，所以推断有可能是配置不匹配导致的异常, 所以下一步来到kubernetes官网查看[kubelet与image相关的配置](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
  
### 问题原因

默认情况下`serializeImagePulls=true`. In other words, `kubelet` sends only one image pull request to the image service at a time. Other image pull requests have to wait until the one being processed is complete.

我们的场景下是通过helm触发很多charts应用的部署, 虽然镜像仓库均在本机，但有些服务的镜像太大（6G+），在加上默认情况下`serializeImagePulls=true`的影响，而且`kubelet` 镜像拉取的请求的串行发送只是控制的发送端（换句话说，kubelet并不能保证docker service是串行拉取镜像的？），从而也就符合我们在TiDB的事件日志看到的类似如下的现象了。

```sh
  Normal   Pulling           14m    kubelet         Pulling image "registry.sensenebula.io:5000/pingcap/busybox:1.34.1"
  Normal   Pulled            3m39s  kubelet         Successfully pulled image "registry.sensenebula.io:5000/pingcap/busybox:1.34.1" in 11m12.669101707s
  Normal   Created           3m38s  kubelet         Created container slowlog
```

### 解决方案

修改`serializeImagePulls=false`,

When `serializeImagePulls` is set to `false`, the kubelet defaults to no limit on the maximum number of images being pulled at the same time. If you would like to limit the number of parallel image pulls, you can set the field `maxParallelImagePulls` in kubelet configuration. With `maxParallelImagePulls` set to `n`, only `n` images can be pulled at the same time, and any image pull beyond `n` will have to wait until at least one ongoing image pull is complete.

Limiting the number parallel image pulls would prevent image pulling from consuming too much network bandwidth or disk I/O, when parallel image pulling is enabled.

You can set `maxParallelImagePulls` to a positive number that is greater than or equal to 1. If you set `maxParallelImagePulls` to be greater than or equal to 2, you must set the `serializeImagePulls` to false. The kubelet will fail to start with invalid `maxParallelImagePulls` settings.

### 扩展 - 写给依然有疑惑的你
  
也许你通过上面显示的事件日志看到`Pulling`到`Pulled`消耗了很多的时间，你是否怀疑一个镜像会为什么会拉取这么久，其实在发送`Pulling`只是表示进入了`image pull requests`的队列， 我们就从下面的kubelet的代码给你答案，

```go
// pkg/kubelet/images/image_manager.go

// EnsureImageExists pulls the image for the specified pod and container, and returns
// (imageRef, error message, error).
func (m *imageManager) EnsureImageExists(ctx context.Context, pod *v1.Pod, container *v1.Container, pullSecrets []v1.Secret, podSandboxConfig *runtimeapi.PodSandboxConfig, podRuntimeHandler string) (string, string, error) {
  ...
 m.podPullingTimeRecorder.RecordImageStartedPulling(pod.UID)
 m.logIt(ref, v1.EventTypeNormal, events.PullingImage, logPrefix, fmt.Sprintf("Pulling image %q", container.Image), klog.Info)
 startTime := time.Now()
 pullChan := make(chan pullResult)
 m.puller.pullImage(ctx, spec, pullSecrets, pullChan, podSandboxConfig)
 imagePullResult := <-pullChan
 if imagePullResult.err != nil {
  m.logIt(ref, v1.EventTypeWarning, events.FailedToPullImage, logPrefix, fmt.Sprintf("Failed to pull image %q: %v", container.Image, imagePullResult.err), klog.Warning)
  m.backOff.Next(backOffKey, m.backOff.Clock.Now())

  msg, err := evalCRIPullErr(container, imagePullResult.err)
  return "", msg, err
 }
 m.podPullingTimeRecorder.RecordImageFinishedPulling(pod.UID)
 imagePullDuration := time.Since(startTime).Truncate(time.Millisecond)
 m.logIt(ref, v1.EventTypeNormal, events.PulledImage, logPrefix, fmt.Sprintf("Successfully pulled image %q in %v (%v including waiting). Image size: %v bytes.",
  ...
```

```go
// pkg/kubelet/images/puller.go

// Maximum number of image pull requests than can be queued.
const maxImagePullRequests = 10

type serialImagePuller struct {
 imageService kubecontainer.ImageService
 pullRequests chan *imagePullRequest
}

func newSerialImagePuller(imageService kubecontainer.ImageService) imagePuller {
 imagePuller := &serialImagePuller{imageService, make(chan *imagePullRequest, maxImagePullRequests)}
 go wait.Until(imagePuller.processImagePullRequests, time.Second, wait.NeverStop)
 return imagePuller
}

type imagePullRequest struct {
 ctx              context.Context
 spec             kubecontainer.ImageSpec
 pullSecrets      []v1.Secret
 pullChan         chan<- pullResult
 podSandboxConfig *runtimeapi.PodSandboxConfig
}

func (sip *serialImagePuller) pullImage(ctx context.Context, spec kubecontainer.ImageSpec, pullSecrets []v1.Secret, pullChan chan<- pullResult, podSandboxConfig *runtimeapi.PodSandboxConfig) {
 sip.pullRequests <- &imagePullRequest{
  ctx:              ctx,
  spec:             spec,
  pullSecrets:      pullSecrets,
  pullChan:         pullChan,
  podSandboxConfig: podSandboxConfig,
 }
}

func (sip *serialImagePuller) processImagePullRequests() {
 for pullRequest := range sip.pullRequests {
  startTime := time.Now()
  imageRef, err := sip.imageService.PullImage(pullRequest.ctx, pullRequest.spec, pullRequest.pullSecrets, pullRequest.podSandboxConfig)
  var size uint64
  if err == nil && imageRef != "" {
   // Getting the image size with best effort, ignoring the error.
   size, _ = sip.imageService.GetImageSize(pullRequest.ctx, pullRequest.spec)
  }
  pullRequest.pullChan <- pullResult{
   imageRef:  imageRef,
   imageSize: size,
   err:       err,
   // Note: pullDuration includes credential resolution and getting the image size.
   pullDuration: time.Since(startTime),
  }
 }
}

```

### 代码注解

通过上面的函数可以看到，大致逻辑是这样的：

1. `image_manager.go` :
a. 在开始拉取镜像前先输出一条 `Pulling image %q`的日志，
b. 再创建一个接收拉取镜像结果的channel,  
c. 调用`imagePuller`的`pullimage`方法，将镜像拉取的请求添加至队列内，
d. `imagePullResult := <-pullChan`  等待镜像拉取的结果。

2. `puller.go`:
a. `pullImage`方法其实只是将拉取镜像的请求添加至队列，
b. 再依赖`processImagePullRequests` 循环调用imageService拉取镜像。

3. 所以你在日志中看到的`Pulling`事件并不能代表当前此镜像正在拉取，只能说明此镜像拉取的请求即将被添加至队列内（因为队列最大值是 10，更多的请求将会pending），

### 附录

1. 查看当前`kubelet`的所有配置参数

```sh
kubectl get --raw "/api/v1/nodes/<nodename>/proxy/configz" | jq
```

Just make sure you replace`<nodename>` with your node name. And if you don't have `jq` installed, leave out the  `| jq` part as that's only for formatting.
  