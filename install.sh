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
echo "Please enter a valid hostname: "
read RESPONSE

#Update Hostname
echo "Hostname is updating ... \n"
rm -rf /etc/hostname
echo  "{RESPONSE}" >> /etc/hostname