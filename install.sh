#!/bin/sh

# Author : M Rahman
# Copyright (c) shadikur.com
# Script follows here:
# Requirement: Debian 9, x64 bit, HyPervision Enabled

#All the variables
bold=$(tput bold)
normal=$(tput sgr0)
green=$(tput setaf 2)

echo "${bold}Current RAM${normal}"
free -m
#
echo "\n"
echo "${bold}Preparing Server ... \n"
apt update -y && apt -y upgrade && apt install build-essential -y && apt install wget git zip unzip vim nano dialog curl lsb-release -y
echo  "\n${bold}${green}System is ready for Proxmox Installation.${normal} \n"

#Domain Name (Valid Hostname)
echo "${bold}Please enter a valid hostname: ${normal}"
read RESPONSE

#Update Hostname
echo "${bold}Hostname is updating ... ${normal}\n"
rm -rf /etc/hostname
echo  ${RESPONSE} >> /etc/hostname
echo "\n"
echo "${bold}Enter the Public IP of this server${normal}"
read PUBIP
echo ${PUBIP} ${RESPONSE} >> /etc/hosts
echo "${green}Please wait.. Proxmox is going to be installed very shortly ... ${normal}\n"
echo "deb http://download.proxmox.com/debian/pve stretch pve-no-subscription" > /etc/apt/sources.list.d/pve-install-repo.list
wget http://download.proxmox.com/debian/proxmox-ve-release-5.x.gpg -O /etc/apt/trusted.gpg.d/proxmox-ve-release-5.x.gpg
chmod +r /etc/apt/trusted.gpg.d/proxmox-ve-release-5.x.gpg  # optional, if you have a changed default umask
apt update -y && apt dist-upgrade -y
apt install proxmox-ve postfix open-iscsi -y
echo "${green}Proxmox is ready to use. Please use the web browser for further configuration${normal}\n"
reboot
