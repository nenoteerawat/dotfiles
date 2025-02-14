#!/bin/bash

# File to modify for enabling TouchID
SUDO_LOCAL_FILE="/etc/pam.d/sudo_local"

# Check if TouchID is already enabled
if grep -q "pam_tid.so" "$SUDO_LOCAL_FILE"; then
  echo "TouchID is already enabled for sudo."
else
  echo "Enabling TouchID for sudo..."

  # Create the file if it doesn't exist
  if [[ ! -f "$SUDO_LOCAL_FILE" ]]; then
    sudo touch "$SUDO_LOCAL_FILE"
  fi

  # Add configuration lines to enable TouchID
  sudo bash -c "echo 'auth       optional       /opt/homebrew/lib/pam/pam_reattach.so ignore_ssh' > $SUDO_LOCAL_FILE"
  sudo bash -c "echo 'auth       sufficient     pam_tid.so' >> $SUDO_LOCAL_FILE"

  echo "TouchID has been enabled for sudo."
fi
