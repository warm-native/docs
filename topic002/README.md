# Topic2. Jenkins + Kubernetes CI/CD 解决方案实战

[详细的配置教程](https://colynn.github.io/2019-10-22-kubernetes-ci-cd/)

## 1. 环境准备
### 1.1 jenkins部署
* 主机形式或docker或是集群内安装；
* kubernetes/git 插件

```sh
# start jenkins docker
$ docker run -d -p 8091:8080 -p50000:50000 --name jenkins -v $(pwd)/data:/var/jenkins_home colynn/jenkins:2.277.1-lts-alpine
```

### 1.2 基础镜像准备
    * `colynn/jenkins-jnlp-agent:latest`：　Jenkins jnlp agent, 还有另外一种ssh agent, 但还是推荐使用`jnlp-agent`
    * `colynn/kaniko-executor:debug`: 用于镜像制作及镜像推送 
> jnlp-agnet的基础镜像是必须的，对于其他的镜像可以根据需要定义`Pod`的`template`

## 2. jenkins Auth
> 创建jenkins连接至kubernetes的auh信息

### 2.1 创建 service account

> 请根据`jenkins`部署在k8s的集群内或外选择[`cluster`](https://github.com/warm-native/docs/tree/master/topic002/deploy/cluster) or [`outcluster`](https://github.com/warm-native/docs/tree/master/topic002/deploy/outcluster)

### 2.2 配置 Jenkins Credentials

1. 获取 service account auth信息
```sh
$ kubectl -n devops describe serviceaccount jenkins-admin
$ kubectl -n devops describe secret [jenkins-admin-token-name]
```
2. 创建 __Secret text__ 类型的Credentials

3. git auth
> 根据需要进行配置，如果不需要检出代码，可以不配置

## 3. Jenkins add kubernetes cloud


## 4. jenkins agent (提供agent的3种形式)
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

## 5. 拓展

1. 中间产物 构建目录
