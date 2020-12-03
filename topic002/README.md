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


## 2. jenkins Auth

1. kubernetes auth
```sh
$ kubectl -n devops describe serviceaccount jenkins-admin
$ kubectl -n devops describe secret [jenkins-admin-token-name]
```

> 注意： 使用`Secret text`类型

2. git auth


## 3. jenkins agent (提供agent的3种形式)
1. yaml in declarative pipeline

> 示例链接：[>yaml in declarative pipeline](https://github.com/jenkinsci/kubernetes-plugin#declarative-pipeline)

```yaml
pipeline {
  agent {
    kubernetes {
      yaml """
<A long yaml file>
"""
    }
  }
...
```

2. configuration in scripted pipeline
> 示例链接：[>container configuration](https://github.com/jenkinsci/kubernetes-plugin#container-configuration)

```yaml
podTemplate(cloud: 'kubernetes', containers: [
    containerTemplate(
<All kinds of configurations>
]) {
   ...
}
```

3. configuration in Jenkins UI

![image](https://user-images.githubusercontent.com/5203608/101015878-008b4280-35a3-11eb-9e6b-02eaf3567ffd.png)


__注意事项__:
1. 配置 Kubernetes Pod Template 时注意: 
    * 如果pipeline 没有指定agent 的标签，而是使用的 agent any， 那么 Usage 选项注意选择 Use this node as much as possible
    * 如果pipeline 指定的具体的agent 标签，那么 Usage 选项注意选择 ONly build jobs with label expressions matching this role, 而且 Lables 选项添加对应的标签。
    
    ```sh
    # 定义 pod template 时指定的标签是 atom-ci, 那么Jenkinsfile里的 agent也要添加上指定的标签
    ...
    agent {
        label 'atom-ci'
    }
    ...
    ```

2. 添加 jnlp-agent 类型的 __Container Template__ 时注意： 
    * __Command to run__ 和 __Arguments to pass to command__ 保持为空
    * 确保你拥有正确的 jenkins-jnlp-agent 镜像, 没有必要建议不要修改该镜像，直接使用默认的即可。

    ```Dockerfile
    COPY jenkins-slave /usr/local/bin/jenkins-slave
    ENTRYPOINT ["jenkins-slave"]
    ```

## 
jenkins as code

## 4. 拓展

1. 中间产物 构建目录
