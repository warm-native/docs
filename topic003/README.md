# 如何写好 Jenkinsfile | Jenkins Pipeline

## 前置条件
* jenkins
* jenkins plugins (pipeline/blue occean)

 https://www.jenkins.io/doc/book/using/
 
## What is Pipeline / Jenkinsfile

![image](./assets/pipeline.png)


## 为什么需要 pipeline

我们均知道 Jenkins是一个支持多种自动化模式的自动化引擎。 Pipeline在Jenkins上添加了一套强大的自动化工具，支持从简单的持续集成到全面的CD管道的用例。 通过对一系列相关任务进行建模。


### Pipeline concepts

* Pipeline
* Node
* Stage
* Step

`Pipeline` 下支持 `Parallel`, `Node`不支持`Parallel`

## Jenkinsfile work with Kubernetes plugin

[Kubernetes plugin for Jenkins GitHub](https://github.com/jenkinsci/kubernetes-plugin/blob/master/README.md)

[Kubernetes plugin docs](https://www.jenkins.io/doc/pipeline/steps/kubernetes/#kubernetes-plugin)