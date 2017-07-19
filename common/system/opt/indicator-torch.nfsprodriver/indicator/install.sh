#!/bin/bash

set -e

mkdir -p /home/phablet/.config/upstart/
mkdir -p /home/phablet/.local/share/unity/indicators/

cp -v /opt/click.ubuntu.com/indicator-torch.nfsprodriver/current/indicator/nfsprodriver-indicator-torch.conf /home/phablet/.config/upstart/
cp -v /opt/click.ubuntu.com/indicator-torch.nfsprodriver/current/indicator/com.nfsprodriver.indicator.torch /home/phablet/.local/share/unity/indicators/

echo "indicator-torch installed!"
