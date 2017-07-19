#!/bin/bash

set -e

rm /home/phablet/.config/upstart/nfsprodriver-indicator-torch.conf
rm /home/phablet/.local/share/unity/indicators/com.nfsprodriver.indicator.torch

echo "indicator-torch uninstalled"
