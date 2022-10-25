# Service

- [Service](#service)
  - [Headless Services](#headless-services)
    - [为什么需要Headless services](#为什么需要headless-services)
    - [示例](#示例)
    - [一些疑问](#一些疑问)
  - [Refeneces](#refeneces)

- [Refeneces](#refeneces)
  
## Headless Services

// 你了解有状态服务的Headless service吗？

Headless service 是一个常规的Kubernetes服务，需要满足如下两点：

1. 其中`spec.clusterIP`被明确设置为 "None"，
2. 还有就是`spec.type`被设置为 "ClusterIP"。

对于Headless service服务ClusterIP是没有分配的,kube-proxy是不会处理这些服务，而且它们没有负载和代理的概念，是kubernetes的DNS根据具体的标签直接转发至对应的后端的Pod.

### 为什么需要Headless services

对于无状态的服务kubernetes可以轻松管理，但是对于有状态服务的部署及复制提出了很多的挑战：

- 为了保持相同的状态，每个Pod均有自己的存储，并且pod之间还会存在持续的数据同步。

- Pod序次是不能互换的。`Pod`副本在任何重新调度中都有持久的标识符。

- 最重要的是, 有状态的Pod往往要直接到达特定的pod（例如，在数据库写操作期间）或有pod-pod通信（比如数据同步、选举重节点等），而不通过负载均衡。

根据我们上段对于Headless Services的介绍，它无疑是解决上述问题的最佳方案, 但是你也是可以通过为一个Pod创建一个service来解决这个问题（很明显这个不是很优雅），来我们一直看一个示例。

### 示例

> 示例中均只是显示helm charts中的部分template代码。

- 示例1：kafka 部署

通过Headless service的方式来声明kafka的service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ include "kafka.fullname" . }}
  labels:
    app.kubernetes.io/name: {{ include "kafka.name" . }}
    helm.sh/chart: {{ include "kafka.chart" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
    app.kubernetes.io/managed-by: {{ .Release.Service }}
spec:
  type: {{ .Values.service.type }}
  clusterIP: None
  ports:
    - port: {{ .Values.service.server }}
      name: server
    - port: {{ .Values.service.metrics }}
      name: metrics
  selector:
    app.kubernetes.io/name: {{ include "kafka.name" . }}
    app.kubernetes.io/instance: {{ .Release.Name }}
```

- 示例2：zookeeper 部署

通过普通ClusterIP的方式来为每一个节点声明service

```yaml
{{- range $i, $e := until (int .Values.replicas) }}
---
apiVersion: v1
kind: Service
metadata:
  name: "{{ $fullName }}-{{$i}}"
  labels:
    app.kubernetes.io/name: {{ $name }}
    helm.sh/chart: {{ $chart }}
    app.kubernetes.io/instance: {{ $release.Name }}
    app.kubernetes.io/managed-by: {{ $release.Service }}
spec:
  type: ClusterIP
  ports:
  - port: 2181
    name: client
  - port: 2888
    name: server
  - port: 3888
    name: leader-election
  selector:
    app.kubernetes.io/name: {{ $name }}
    app.kubernetes.io/instance: {{ $release.Name }}
    statefulset.kubernetes.io/pod-name: "{{ $fullName }}-{{$i}}"
{{- end }}
```

### 一些疑问

1. 为什么 headless service 无法直接编辑yaml改为nodePort类型的服务?

> 因为headless service的clusterIP没有分配，而NodePort类型的服务却是要强依赖于clusterIP, 所以编辑后[api-server校验service信息](https://github.com/kubernetes/kubernetes/blob/v1.25.0/pkg/apis/core/validation/validation.go#L4621)时就会报错了。

## Refeneces

1. [services-networking#headless-services](https://kubernetes.io/docs/concepts/services-networking/service/#headless-services)
