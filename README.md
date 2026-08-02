# Proxmox (Virtualisation)

Proxmox Auto Installer. Simply clone this script and run it on a fresh, minimal **Debian 12 (bookworm)** or **Debian 13 (trixie)** 64-bit Dedicated Server / hypervisor-enabled VPS with root permission. The script detects your Debian release automatically and installs the matching Proxmox VE line (8.x for bookworm, 9.x for trixie). Once finished, you are ready to manage over the web interface. Enjoy.

----------------------
Installation Procedure
----------------------

At first, you will have to install git on your system.<br>

```
apt install git -y
```
<br><br>Once git is installed, you are ready to clone my script!<br>

```
git clone https://github.com/shadikur/proxmox.git
```
<br><br>
Then, enter to the directory and change the permission.<br><br>
```
cd proxmox

chmod +x install.sh

./install.sh
```
<br><br>
At the end, please visit your web browser for ``https://your_ip_address:8006`` further configuration.<br>

You will be required for username and password authentication which is same as your ssh username and password.

I hope that, you will enjoy using proxmox. If you need any help or support, please feel free to contact with me.

<a href='https://www.shadikur.com/contact'>[] CONTACT ME HERE []</a>
