# Open-vm-tools

```
systemd:
  units:
    - name: open-vm-tools.service
      enabled: true
      contents: |
        [Unit]
        Description=Open VM Tools
        After=network-online.target
        Wants=network-online.target

        [Service]
        TimeoutStartSec=0
        ExecStartPre=-/bin/podman kill open-vm-tools
        ExecStartPre=-/bin/podman rm open-vm-tools
        ExecStartPre=/bin/podman pull open-vm-tools:fc31
        ExecStart=/bin/podman run -e SYSTEMD_IGNORE_CHROOT=1 -v  /proc/:/hostproc/ -v /sys/fs/cgroup:/sys/fs/cgroup -v /run/systemd:/run/systemd --pid=host --net=host --ipc=host --uts=host --rm  --privileged --name open-vm-tools open-vm-tools:fc31

        [Install]
        WantedBy=multi-user.target
```