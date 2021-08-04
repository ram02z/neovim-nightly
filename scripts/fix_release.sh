#!/bin/bash

echo -ne 'NAME="void"\nID="void"\nDISTRIB_ID="void"\nPRETTY_NAME="void"\n' > /etc/os-release

cat /etc/*release | grep ^ID
