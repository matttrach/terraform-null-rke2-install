#!/bin/sh
set -x
set -e
ROLE="${1}"
SERVICE_NAME="rke2-${ROLE}.service"
TIMEOUT="${2}" # timeout in minutes
if [ "$(systemctl is-active "${SERVICE_NAME}")" = "active" ]; then
 systemctl stop "${SERVICE_NAME}"
fi
systemctl daemon-reload
systemctl enable "${SERVICE_NAME}"
systemctl start "${SERVICE_NAME}" &

EXIT=0
max_attempts=$((TIMEOUT * 60 / 10))

attempts=0
interval=10
while [ "$(systemctl is-active "${SERVICE_NAME}")" != "active" ]; do
  echo "${SERVICE_NAME} status is \"$(systemctl is-active "${SERVICE_NAME}")\""
  attempts=$((attempts + 1))
  if [ ${attempts} -eq ${max_attempts} ]; then EXIT=1; break; fi
  sleep ${interval};
done
echo "${SERVICE_NAME} status is \"$(systemctl is-active "${SERVICE_NAME}")\""

if [ $EXIT -eq 1 ]; then
  echo "Timed out attempting to start service:"

  echo "status:"
  systemctl status "${SERVICE_NAME}" > status.log || true
  cat status.log || true

  echo "last 20 lines of journal:"
  journalctl --lines 20 --unit "${SERVICE_NAME}" > last20.log || true
  cat last20.log || true

  echo "first 20 lines of journal:"
  journalctl --reverse --lines +20 --unit "${SERVICE_NAME}" > first20.log || true
  cat first20.log || true

  echo "rke2 config list:"
  ls -lah /etc/rancher/rke2/config.yaml.d > configlist.log || true
  cat configlist.log || true

  echo "kubelet:"
  tail /var/lib/rancher/rke2/agent/logs/kubelet.log || true

  echo "containerd:"
  tail /var/lib/rancher/rke2/agent/containerd/containerd.log || true
fi

exit $EXIT
