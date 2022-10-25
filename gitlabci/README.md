# GitlabCI

## How it works (CI/CD process overview)

- [Ensure you have runners available](https://docs.gitlab.com/ee/ci/quick_start/#ensure-you-have-runners-available) to run your jobs. GitLab SaaS provides runners, so if you’re using GitLab.com, you can skip this step.

If you don’t have a runner, [install GitLab Runner](https://docs.gitlab.com/runner/install/) and [register a runner](https://docs.gitlab.com/runner/register/) for your instance, project, or group.

- [Create a .gitlab-ci.yml file](https://docs.gitlab.com/ee/ci/quick_start/#create-a-gitlab-ciyml-file) at the root of your repository. This file is where you define your CI/CD jobs.

## Core Concepts

## Script synatx

> Use special characters with `script`

- <https://docs.gitlab.com/ee/ci/yaml/script.html#use-special-characters-with-script>

## Varibles

## Jobs Rules

## FAQ

### 1. Git Submodule - Permission Denied

- 错误描述(类似如下)：

```sh
$ git submodule update --init --recursive
Submodule 'lib/urlgrabber' (git@gitlab.colynn.com:linux/urlgrabber.git) registered for path 'lib/urlgrabber'
Cloning into 'lib/urlgrabber'...
Host key verification failed.
fatal: Could not read from remote repository.
```

- 解决方案：
__方案1）[使用相对路径](https://docs.gitlab.com/ee/ci/git_submodules.html#configure-the-gitmodules-file)：I had to change the paths in .gitmodules to relative__

```sh
[submodule "lib/urlgrabber"]
        path = lib/urlgrabber
-       url = git@gitlab.deif.com:linux/urlgrabber.git
+       url = ../../linux/urlgrabber.git
```

__方案2）通过前置脚本修改`git config` 替换掉`git@gitlab.colynn.com:linux/urlgrabber.git`__

a. 通过为`gitlab-ci.yml`添加`before_script`的方式实现替换

```yaml
before_script:
  - git config --global --add url."https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@gitlab.colynn.com/linux/urlgrabber.git".insteadOf "git@gitlab.colynn.com:linux/urlgrabber.git"
```

b. 通过`runner`的配置文件，添加[`pre_clone_script`](https://docs.gitlab.com/runner/configuration/advanced-configuration.html#the-runners-section)的方式实现替换

```toml
  pre_clone_script="git config --global --add url.\"https://${GITLAB_USERNAME}:${GITLAB_TOKEN}@gitlab.colynn.com/linux/urlgrabber.git\".insteadOf \"git@gitlab.colynn.com:linux/urlgrabber.git\"\n"
```
