#!/bin/bash

# Author  : M Rahman
# Copyright (c) shadikur.com
# Proxmox VE Auto Installer
#
# Turns a fresh, minimal Debian install into a Proxmox VE host.
# Supported base OS:
#   Debian 12 (bookworm) -> Proxmox VE 8.x
#   Debian 13 (trixie)   -> Proxmox VE 9.x
#
# Reference: https://pve.proxmox.com/wiki/Install_Proxmox_VE_on_Debian

set -euo pipefail

bold=$(tput bold 2>/dev/null || echo "")
normal=$(tput sgr0 2>/dev/null || echo "")
green=$(tput setaf 2 2>/dev/null || echo "")
red=$(tput setaf 1 2>/dev/null || echo "")

info()    { printf "%s\n" "${bold}$1${normal}"; }
success() { printf "%s\n" "${bold}${green}$1${normal}"; }
error()   { printf "%s\n" "${bold}${red}$1${normal}" >&2; }

trap 'error "Installation failed at line $LINENO. Aborting."' ERR

if [ "$(id -u)" -ne 0 ]; then
  error "This script must be run as root."
  exit 1
fi

info "Current RAM"
free -m
echo

# --- Detect the base OS and pick the matching Proxmox repo -----------------
if [ ! -r /etc/os-release ]; then
  error "Cannot detect OS (missing /etc/os-release)."
  exit 1
fi
. /etc/os-release

if [ "${ID:-}" != "debian" ]; then
  error "This installer must be run on plain Debian, not ${PRETTY_NAME:-$ID}."
  exit 1
fi

CODENAME="${VERSION_CODENAME:-}"
case "$CODENAME" in
  bookworm) PVE_LABEL="Proxmox VE 8.x" ;;
  trixie)   PVE_LABEL="Proxmox VE 9.x" ;;
  *)
    error "Unsupported Debian release: ${PRETTY_NAME:-unknown} (codename: ${CODENAME:-unknown})."
    error "This installer supports Debian 12 (bookworm) and Debian 13 (trixie) only."
    exit 1
    ;;
esac

info "Detected ${PRETTY_NAME} - will install ${PVE_LABEL}"
echo

info "Preparing server ..."
apt update
apt -y full-upgrade
apt install -y build-essential wget git zip unzip vim nano dialog curl lsb-release gnupg2 ca-certificates
success "System is ready for Proxmox installation."
echo

# --- Hostname / IP ----------------------------------------------------------
printf "%s" "${bold}Please enter a valid FQDN hostname (e.g. pve.example.com): ${normal}"
read -r RESPONSE
if [ -z "$RESPONSE" ]; then
  error "Hostname cannot be empty."
  exit 1
fi
case "$RESPONSE" in
  *.*) ;;
  *) error "Warning: '${RESPONSE}' is not a fully qualified domain name. Proxmox strongly recommends an FQDN." ;;
esac
SHORTNAME="${RESPONSE%%.*}"

printf "%s" "${bold}Please enter the public IP address of this server: ${normal}"
read -r PUBIP
if ! printf '%s' "$PUBIP" | grep -qE '^([0-9]{1,3}\.){3}[0-9]{1,3}$'; then
  error "Invalid IPv4 address: $PUBIP"
  exit 1
fi

info "Updating hostname to ${RESPONSE} ..."
cp /etc/hosts "/etc/hosts.bak.$(date +%s)"
hostnamectl set-hostname "$RESPONSE"

# Proxmox requires the hostname to resolve to a routable (non-loopback) IP.
# Drop any stale entries for this host/short name, then add the correct one.
sed -i "/[[:space:]]${SHORTNAME}\$/d;/[[:space:]]${RESPONSE}\$/d" /etc/hosts
printf "%s %s %s\n" "$PUBIP" "$RESPONSE" "$SHORTNAME" >> /etc/hosts

if [ "$(hostname --ip-address 2>/dev/null || true)" != "$PUBIP" ]; then
  error "Warning: 'hostname --ip-address' does not report ${PUBIP}. Double-check /etc/hosts after install."
fi
echo

success "Please wait, Proxmox is about to be installed ..."

# --- Add the Proxmox VE repository and signing key --------------------------
echo "deb [arch=amd64] http://download.proxmox.com/debian/pve ${CODENAME} pve-no-subscription" \
  > /etc/apt/sources.list.d/pve-install-repo.list

wget -q "https://enterprise.proxmox.com/debian/proxmox-release-${CODENAME}.gpg" \
  -O "/etc/apt/trusted.gpg.d/proxmox-release-${CODENAME}.gpg"
chmod +r "/etc/apt/trusted.gpg.d/proxmox-release-${CODENAME}.gpg"

apt update
apt -y full-upgrade
apt install -y proxmox-ve postfix open-iscsi

# os-prober can break GRUB on hosts with foreign OS partitions; Proxmox's
# own docs recommend removing it on dedicated PVE hosts.
apt remove -y os-prober || true

success "Proxmox is ready to use. Manage it at https://${PUBIP}:8006 once rebooted."
info "Rebooting in 10 seconds ... press Ctrl+C to cancel."
sleep 10
reboot
