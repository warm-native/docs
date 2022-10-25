FROM colynn/ops-debug

ARG HostFile=/etc/hosts

# method1
CMD tail -f $HostFile

# method2
CMD ["tail", "-f","$HostFile"]

# method3
CMD ["sh", "-c", "tail -f $HostFile"]
