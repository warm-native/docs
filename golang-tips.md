# Golang Learning For Beginner

- [Golang Learning For Beginner](#golang-learning-for-beginner)
  - [Overview](#overview)
  - [书籍推荐](#书籍推荐)
  - [How to try it](#how-to-try-it)
  - [How to setup develop env](#how-to-setup-develop-env)
    - [Install](#install)
    - [Env profile](#env-profile)
    - [Go module](#go-module)
    - [vscode plugins](#vscode-plugins)
  - [First program/module](#first-programmodule)
  - [Project Layout/Advices](#project-layoutadvices)
  - [Resources](#resources)
  
## Overview

- Strong and statically typed

- Excellect community
- Key features
  - Simplicity
  - Fast compile times
  - Garbage collected
  - Built-in concurrency
  - Compile to standalone binaries

## 书籍推荐

1. <https://github.com/unknwon/the-way-to-go_ZH_CN>
2. <https://golang2.eddycjy.com/posts/ch1/01-simple-flag/>

## How to try it

<https://play.golang.org/>

## How to setup develop env

### Install

1. [下载golang](https://golang.org/dl/)

2. [vscode](https://code.visualstudio.com/)

### Env profile

- `GOROOT` is a variable that defines where your Go SDK is located. You do not need to change this variable, unless you plan to use different Go versions.

- `GOPATH` is a variable that defines the root of your workspace.

  - `src/`: location of Go source code (for example, .go, .c, .g, .s).

  - `pkg/`: location of compiled package code (for example, .a).
  
  - `bin/`: location of compiled executable programs built by Go.

### Go module

[Go Mod 包管理 & 常见问题](https://colynn.github.io/2019-08-15-introducing_go_mod/)

### vscode plugins

- Go

- Bracket Pair Colorizer
- GitLens - Git supercharged
- indent-rainbow

## First program/module

## Project Layout/Advices

1. [project-laybout](https://github.com/golang-standards/project-layout)
2. [golang 代码规范等](https://colynn.github.io/2020-03-29-golang-101/)
3. [Tencent Go安全指南](https://github.com/Tencent/secguide/blob/main/Go%E5%AE%89%E5%85%A8%E6%8C%87%E5%8D%97.md)
4. [golang 101](https://go101.org/article/101.html)

## Resources

1. <https://golang.org/doc/>
2. <https://github.com/golang/go/wiki/CodeReviewComments>
