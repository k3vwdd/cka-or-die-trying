#!/bin/bash
set -e

# Intentionally break kubelet systemd drop-in so kubelet cannot start.
# Based strictly on provided source material.

CONF="/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf"
BACKUP="/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf.bak.ckaprep"

if [ -f "$CONF" ] && [ ! -f "$BACKUP" ]; then
  cp "$CONF" "$BACKUP"
fi

if [ -f "$CONF" ]; then
  python3 - <<'PY'
from pathlib import Path
p = Path('/usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf')
text = p.read_text()
lines = text.splitlines()
out = []
replaced = False
for line in lines:
    if line.startswith('ExecStart=') and '/usr/bin/kubelet' in line and not replaced:
        out.append('ExecStart=/usr/bin/kubelet-broken $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS')
        replaced = True
    else:
        out.append(line)
if not replaced:
    out.append('')
    out.append('[Service]')
    out.append('ExecStart=')
    out.append('ExecStart=/usr/bin/kubelet-broken $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS')
p.write_text('\n'.join(out) + '\n')
PY
fi

systemctl daemon-reload
systemctl stop kubelet || true

# Try to ensure the failure state is visible.
systemctl start kubelet || true
systemctl stop kubelet || true
