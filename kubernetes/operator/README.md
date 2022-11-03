# Operator

## What is an Operator

The goal of an Operator is to put operational knowledge into software. Previously this knowledge only resided in the minds of administrators, various combinations of shell scripts, or automation software like Ansible. It was outside of your Kubernetes cluster and hard to integrate. With Operators, CoreOS __changed that__.

Operators implement and automate common Day-1(installation, configuration, etc.) and Day-2(re-configuration, update, failover, restore, etc.) activities in a piece of software running inside your Kubernetes cluster, by integrating natively with Kubernetes concepts and APIs.

We call this a Kubernetes-native application. With Operators, you can stop treating an application as a collection of primitives like Pods, Deployments, Services or ConfigMaps, but instead, as a single object that only exposes the knobs that make sense for the application.

* Software that runs within Kubernetes
* Interacts with the Kubernetes API to create/manage objects
* Works on the model of Eventual Consistency

## What is the Operator Framework

The Operator Framework is an open-source toolkit to manage Kubernetes native applications, called Operators, in an effective, automated, and scalable way.

## What is Operator SDK

It's a component of the Operator Framework, the Operator SDK makes it easier to build Kubernetes native applications, a process that can require deep, application-specific operational knowledge.

## What can I do with Operator SDK

The Operator SDK provides the tools to build, test, and package Operators. Initially, the SDK facilitates the marriage of an application's business logic(for example, how to scale, upgrade, or backup) with the Kubernetes API to execute those operations. Over time, the SDK can allow engineers to make applications smarter and have the user experience of cloud services.

Leading practices and code patterns that are shared across Operators are included in the SDK to help prevent reinventing the wheel.

The Operator SDK is a framework that uses the controller-runtime library to make writing operators easier by providing:

* High-level APIs and abstractions to write the operational logic more intuitively
* Tools for scaffolding and code generation to bootstrap a new project fast
* Extensions to cover common Operator use cases
  
## How can I write an operator with Operator SDK

### 1. install the SDK CLI

[install guide](https://sdk.operatorframework.io/docs/installation)

### 2. read the user guides

Operators can be created with the SDK using [Ansible](https://sdk.operatorframework.io/docs/building-operators/ansible/quickstart/), [Helm](https://sdk.operatorframework.io/docs/building-operators/helm/quickstart/), or [Go](https://sdk.operatorframework.io/docs/building-operators/golang/quickstart/).

## Operator Sample

[memcached-operator sample](./operator-sample.md)