#!/bin/bash
#
# Enable Touch ID for sudo.
#
# Touch ID is turned on by adding "auth sufficient pam_tid.so" to
# /etc/pam.d/sudo_local — a file that /etc/pam.d/sudo `include`s and that
# survives macOS updates. The optional pam_reattach line additionally makes
# Touch ID work inside tmux/screen sessions.
#
# IMPORTANT: if sudo_local references a PAM module file that does NOT exist,
# sudo breaks completely with "unable to initialize PAM: No such file or
# directory". To stay safe, this script only adds the pam_reattach line when
# its .so is actually present (pam_tid.so always ships with macOS).

set -euo pipefail

SUDO_LOCAL_FILE="/etc/pam.d/sudo_local"
# Apple-Silicon Homebrew path; on Intel this would be /usr/local/lib/pam.
REATTACH_SO="/opt/homebrew/lib/pam/pam_reattach.so"

# Already enabled? (sudo_local is world-readable, so no sudo needed to check.)
if [[ -f "$SUDO_LOCAL_FILE" ]] && grep -q "pam_tid.so" "$SUDO_LOCAL_FILE"; then
  echo "Touch ID is already enabled for sudo."
  exit 0
fi

echo "Enabling Touch ID for sudo..."

# Build the desired config. pam_reattach MUST come before pam_tid so that,
# inside tmux/screen, the session is reattached to the GUI before pam_tid
# tries to talk to the Touch ID sensor.
config="# Touch ID for sudo — managed by update_sudo_tid.sh"$'\n'
if [[ -f "$REATTACH_SO" ]]; then
  config+="auth       optional       $REATTACH_SO ignore_ssh"$'\n'
else
  echo "  note: $REATTACH_SO not found — skipping pam_reattach."
  echo "        Touch ID will still work, just not inside tmux/screen."
  echo "        Run 'brew install pam-reattach' for tmux support, then re-run."
fi
config+="auth       sufficient     pam_tid.so"$'\n'

# Back up any existing file (for manual recovery), then write it in one shot.
if [[ -f "$SUDO_LOCAL_FILE" ]]; then
  sudo cp -p "$SUDO_LOCAL_FILE" "${SUDO_LOCAL_FILE}.bak"
  echo "  backed up existing file to ${SUDO_LOCAL_FILE}.bak"
fi
printf '%s' "$config" | sudo tee "$SUDO_LOCAL_FILE" >/dev/null

# Safety net: clear the cached sudo timestamp and confirm sudo's PAM still
# initializes. (|| true keeps set -e happy; sudo -n exits non-zero normally.)
sudo -k 2>/dev/null || true
pam_check="$(sudo -n true 2>&1 || true)"
if grep -q "unable to initialize PAM" <<<"$pam_check"; then
  echo "ERROR: sudo's PAM no longer initializes!" >&2
  echo "       Restore the backup from a working root shell:" >&2
  echo "         cp ${SUDO_LOCAL_FILE}.bak ${SUDO_LOCAL_FILE}" >&2
  exit 1
fi

echo "Done. Touch ID is enabled for sudo."
echo "Test it in a NEW terminal window:   sudo -k; sudo -v"
echo "(Note: Touch ID for sudo does not apply over SSH.)"
