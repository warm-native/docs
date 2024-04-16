# multi-arch

## 写在前面

There are currently __four different ways__ that one can build locally with Docker:

- The legacy builder in Docker Engine: `DOCKER_BUILDKIT=0 docker build .`
- BuildKit in Docker Engine: `DOCKER_BUILDKIT=1 docker build .`
- Buildx CLI plugin with the Docker driver: `docker buildx build .`
- Buildx CLI plugin with the Container driver: `docker buildx create && docker buildx build .`

## Without Using Docker BuildX

```sh
export DOCKER_CLI_EXPERIMENTAL=enabled

docker manifest create

docker manifest push
```

## buildx

<https://github.com/docker/buildx>

### Buildx CLI with driver

<https://github.com/docker/buildx/blob/master/docs/reference/buildx_create.md#-set-the-builder-driver-to-use---driver>

[Set buildx as default builder](https://github.com/docker/cli/pull/3314)

## buildKit

## golang project sample

<https://gist.github.com/AverageMarcus/78fbcf45e72e09d9d5e75924f0db4573>

## java project sample
