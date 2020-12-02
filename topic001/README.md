
# 如何定制镜像- jenkins + docker 持续集成实战前置篇
## 1.定制镜像jnlp、kaniko、kubectl

### 为什么需要定制镜像
1. 你是不是有想直接在容器内 telnet或tcpdump
2. 或是需要某语言的执行环境，如python

### 探究如何定制镜像
1. 一起来学习下镜像是如何一步步产生的
2. 基于最基础的镜像的来做定制，为什么

### 举例
#### jnlp
* 添加python 运行环境

#### kaniko
* [kaniko](https://github.com/GoogleContainerTools/kaniko)

#### kubectl
* [install kubectl](https://v1-16.docs.kubernetes.io/docs/tasks/tools/install-kubectl/)
