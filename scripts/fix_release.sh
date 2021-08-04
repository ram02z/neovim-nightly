#!/bin/bash

if [ ! -f /etc/os-release ]; then
    echo -ne 'NAME="void"\nID="void"\nDISTRIB_ID="void"\nPRETTY_NAME="void"\n' > /etc/os-release
fi
