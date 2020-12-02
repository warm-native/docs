# Topic2. Jenkins + Kubernetes CI/CD 解决方案实战

[详细的配置教程](https://colynn.github.io/2019-10-22-kubernetes-ci-cd/)

## 1. 环境准备
* jenkins
    * 主机形式或是集群内安装；
    * kubernetes/git 插件

* 基础镜像准备
    * jnlp-agent
    * maven
    * kaniko


## 2. jenkins 配置

jenkins as code

pod template 定义的几种形式；


1. 注意事项
* pod label
* jnlp container  command keep empty



2. 如何指定 agent label

```groovy
pipeline {
    agent 

}
```


3. pipeline script


## 3. 拓展

1. 中间产物 构建目录
