# CmdScope

**CmdScope** is a lightweight Linux daemon that uses `bpftrace` to monitor and log all executed commands on a system in real time. It captures all `execve()` system calls and logs the full command-line, including arguments, to a persistent log file.

This tool is ideal for system auditing, security monitoring, and forensic analysis.


## Features

* Monitors all user and system command executions.
* Captures full command-line arguments via the `execve` syscall.
* Uses eBPF (`bpftrace`) for minimal system overhead.
* Logs to `/var/log/cmdscope.log` and integrates as a `systemd` service.
* Automatically starts at boot and restarts on failure.


## Requirements

* Linux kernel with eBPF and tracepoints support (typically 4.9+).
* `bpftrace` installed on the system.
* Root privileges (required by bpftrace to attach to syscall tracepoints).

Tested on:

* Ubuntu 20.04/22.04
* Debian 11/12
* Fedora 38+
* Arch Linux


## Installation

Run the setup script as root:

```bash
sudo bash setup_cmdscope.sh
```

This script will:

* Install `bpftrace` using your system’s package manager.
* Create the monitoring script at `/usr/local/bin/cmdscope.bt`.
* Configure the `systemd` service at `/etc/systemd/system/cmdscope.service`.
* Create `/var/log/cmdscope.log` and `/var/log/cmdscope.err` with appropriate permissions.
* Enable and start the service immediately.


## Usage

### View logs

```bash
sudo tail -f /var/log/cmdscope.log
```

Example output:

```
2025-05-22 14:05:31 bash [1234] ran: ls -la /tmp
2025-05-22 14:06:10 sudo [1289] ran: apt update
```

### Check service status

```bash
sudo systemctl status cmdscope.service
```

### Stop or restart

```bash
sudo systemctl stop cmdscope.service
sudo systemctl restart cmdscope.service
```

## Limitations

* Captures up to 10 arguments per command. This can be adjusted in the script if needed.
* Logs only `execve()` calls, which includes most commands but may miss built-in shell operations unless they invoke external binaries.
* Does not capture environment variables or current working directory by default.


## Uninstall

To fully remove `cmdscope`:

```bash
sudo systemctl stop cmdscope.service
sudo systemctl disable cmdscope.service
sudo rm /etc/systemd/system/cmdscope.service
sudo rm /usr/local/bin/cmdscope.bt
sudo rm /var/log/cmdscope.log /var/log/cmdscope.err
sudo systemctl daemon-reload
```

## License

MIT License
