# Operator Sample

## 写在前面

我们基于`Go`的Operator 来具体看下如何创建、运行Operator.

## 前置条件

1. 参照[官方链接](https://sdk.operatorframework.io/docs/building-operators/golang/installation)，安装基础环境依赖（[operator-sdk](https://sdk.operatorframework.io/docs/installation/), git/go1.18/docker 17.03+ / kubectl）
2. 确保你的开发环境对于kubectl操作的kubeconfig的context对应的k8s集群拥有`cluster-admin`的权限。
    * 这里你可以使用真实的kubernetes环境或是使用[kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)来创建一个虚拟cluster
    * 你可以通过如下命令确认或是切换自己的context

      ```sh
      # 确认在kubeconfig文件中当前使用的context
      $ kubectl config current-context
      # 切换使用的context
      $ kubectl config use-context CONTEXT_NAME
      ```

3. 一个有权限访问的镜像仓库（hub.docker.com或是自建的harbor等）用于存储构建的operator镜像.

## 下一步

你可以跟随着[memcached-operator的ChangeLog](https://github.com/colynn/memcached-operator/blob/master/CHANGELOG.md)看看如何一步步完善[`memcached-operator`](https://github.com/colynn/memcached-operator).
