#!/bin/bash

set -e

echo "[*] Installing bpftrace..."
if command -v apt &>/dev/null; then
    apt update && apt install -y bpftrace
elif command -v dnf &>/dev/null; then
    dnf install -y bpftrace
elif command -v pacman &>/dev/null; then
    pacman -Sy --noconfirm bpftrace
else
    echo "Unsupported package manager. Please install bpftrace manually."
    exit 1
fi

echo "[*] Creating bpftrace script at /usr/local/bin/cmdscope.bt..."

cat << 'EOF' > /usr/local/bin/cmdscope.bt
tracepoint:syscalls:sys_enter_execve
{
    time("%Y-%m-%d %H:%M:%S ");
    printf("uid=%d %s [%d] ran:", uid, comm, pid);

    printf(" %s", str(args->argv[0]));
    printf(" %s", str(args->argv[1]));
    printf(" %s", str(args->argv[2]));
    printf(" %s", str(args->argv[3]));
    printf(" %s", str(args->argv[4]));
    printf(" %s", str(args->argv[5]));
    printf(" %s", str(args->argv[6]));
    printf(" %s", str(args->argv[7]));
    printf(" %s", str(args->argv[8]));
    printf(" %s", str(args->argv[9]));

    printf("\n");
}
EOF

chmod +x /usr/local/bin/cmdscope.bt

echo "[*] Creating systemd service at /etc/systemd/system/cmdscope.service..."

cat << 'EOF' > /etc/systemd/system/cmdscope.service
[Unit]
Description=cmdscope
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/bpftrace /usr/local/bin/cmdscope.bt
StandardOutput=append:/var/log/cmdscope.log
StandardError=append:/var/log/cmdscope.err
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Creating log files..."
touch /var/log/cmdscope.log /var/log/cmdscope.err
chmod 644 /var/log/cmdscope.log /var/log/cmdscope.err

echo "[*] Enabling and starting systemd service..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now cmdscope.service

echo "[✓] cmdscope is now running!"
echo "Check output in: /var/log/cmdscope.log"
