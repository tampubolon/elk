#!/bin/bash
apt update -y
apt upgrade -y

%{ if elasticsearch == "true" }
# Additional script
chmod +x install.sh
./install.sh
%{ endif }
