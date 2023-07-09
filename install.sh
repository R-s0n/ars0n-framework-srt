#!/bin/bash

chmod 777 temp

if ! command -v amass &> /dev/null; then
    echo "amass is not installed. Installing..."
    sudo snap install amass
    if [ $? -eq 0 ]; then
        echo "amass installed successfully."
    else
        echo "Failed to install amass."
        exit 1
    fi
else
    echo "amass is already installed."
fi

if ! command -v jq &> /dev/null; then
    echo "jq is not installed. Installing..."
    sudo apt update
    sudo apt install -y jq
    if [ $? -eq 0 ]; then
        echo "jq installed successfully."
    else
        echo "Failed to install jq."
        exit 1
    fi
else
    echo "jq is already installed."
fi

