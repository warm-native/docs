# execsignal

```sh
# it can not catch exit signal
docker build  -f Dockerfile.v1  . -t colynn/signal:dockerv1
```

```sh
# it can catch exit signal
docker build  -f Dockerfile.v2  . -t colynn/signal:dockerv2
```
