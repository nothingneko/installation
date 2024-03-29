# Generated by pykickstart v3.29
#version=DEVEL
# X Window System configuration information
xconfig  --startxonboot
# Keyboard layouts
keyboard 'us'
# Root password
rootpw --iscrypted --lock locked
# System language
lang en_US.UTF-8
# Network information
network  --bootproto=dhcp --device=link --activate
# System authorization information
authselect --useshadow --enablemd5
# Firewall configuration
firewall --enabled --service=mdns
# Use network installation
url --url="https://kojipkgs.fedoraproject.org/compose/34/Fedora-34-20210423.0/compose/Everything/$basearch/os"
repo --name="koji-override-0" --baseurl=https://kojipkgs.fedoraproject.org/compose/34/Fedora-34-20210423.0/compose/Everything/$basearch/os
repo --name="released" --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=fedora-34&arch=$basearch
repo --name="updates" --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f34&arch=$basearch
repo --name="risi" --mirrorlist=https://download.copr.fedorainfracloud.org/results/risi/risiOS/fedora-$releasever-$basearch/
# System timezone
timezone US/Pacific
# SELinux configuration
selinux --disabled

# System services
services --disabled="network,sshd" --enabled="NetworkManager"
# System bootloader configuration
bootloader --location=none
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all
# Disk partitioning information
part / --size=4096

%post
cat >> /etc/rc.d/init.d/livesys << EOF
# disable gnome-software automatically downloading updates
cat >> /usr/share/glib-2.0/schemas/org.gnome.software.gschema.override << FOE
[org.gnome.software]
download-updates=false
FOE

# don't autostart gnome-software session service
rm -f /etc/xdg/autostart/gnome-software-service.desktop

# disable the gnome-software shell search provider
cat >> /usr/share/gnome-shell/search-providers/org.gnome.Software-search-provider.ini << FOE
DefaultDisabled=true
FOE

# don't run gnome-initial-setup
mkdir ~liveuser/.config
touch ~liveuser/.config/gnome-initial-setup-done

# suppress anaconda spokes redundant with gnome-initial-setup
cat >> /etc/sysconfig/anaconda << FOE
[NetworkSpoke]
visited=1

[PasswordSpoke]
visited=1

[UserSpoke]
visited=1
FOE

# make the installer show up
if [ -f /usr/share/applications/liveinst.desktop ]; then
  # Show harddisk install in shell dash
  sed -i -e 's/NoDisplay=true/NoDisplay=false/' /usr/share/applications/liveinst.desktop ""
  # need to move it to anaconda.desktop to make shell happy
  mv /usr/share/applications/liveinst.desktop /usr/share/applications/anaconda.desktop

  cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
[org.gnome.shell]
favorite-apps=['anaconda.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Terminal.desktop', 'firefox.desktop']
FOE

  # Make the welcome screen show up
  if [ -f /usr/share/anaconda/gnome/fedora-welcome.desktop ]; then
    mkdir -p ~liveuser/.config/autostart
    cp /usr/share/anaconda/gnome/fedora-welcome.desktop /usr/share/applications/
    cp /usr/share/anaconda/gnome/fedora-welcome.desktop ~liveuser/.config/autostart/
  fi

  # Disable GNOME welcome tour so it doesn't overlap with Fedora welcome screen
  cat >> /usr/share/glib-2.0/schemas/org.gnome.shell.gschema.override << FOE
welcome-dialog-last-shown-version='4294967295'
FOE

  # Copy Anaconda branding in place
  if [ -d /usr/share/lorax/product/usr/share/anaconda ]; then
    cp -a /usr/share/lorax/product/* /
  fi
fi

# rebuild schema cache with any overrides we installed
glib-compile-schemas /usr/share/glib-2.0/schemas

# set up auto-login
cat > /etc/gdm/custom.conf << FOE
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=liveuser
FOE

# Turn off PackageKit-command-not-found while uninstalled
if [ -f /etc/PackageKit/CommandNotFound.conf ]; then
  sed -i -e 's/^SoftwareSourceSearch=true/SoftwareSourceSearch=false/' /etc/PackageKit/CommandNotFound.conf
fi

# make sure to set the right permissions and selinux contexts
chown -R liveuser:liveuser /home/liveuser/

EOF

echo Defaults pwfeedback >> /etc/sudoers
sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
rm /etc/os-release && echo "NAME=risiOS
VERSION="0.1 Andesite (Pre-release)"
ID=risios
VERSION_ID=0.1
VERSION_CODENAME="Andesite"
PLATFORM_ID="platform:f34"
PRETTY_NAME="risiOS 0.1 Andesite (Pre-release"
ANSI_COLOR="0;38;2;60;110;180"
LOGO=fedora-logo-icon
CPE_NAME="cpe:/o:fedoraproject:fedora:34"
HOME_URL="https://fedoraproject.org/"
DOCUMENTATION_URL="https://docs.fedoraproject.org/en-US/fedora/f33/system-administrators-guide/"
SUPPORT_URL="https://fedoraproject.org/wiki/Communicating_and_getting_help"
BUG_REPORT_URL="https://bugzilla.redhat.com/"
REDHAT_BUGZILLA_PRODUCT="Fedora"
REDHAT_BUGZILLA_PRODUCT_VERSION=34
REDHAT_SUPPORT_PRODUCT="Fedora"
REDHAT_SUPPORT_PRODUCT_VERSION=34
PRIVACY_POLICY_URL="https://fedoraproject.org/wiki/Legal:PrivacyPolicy"
VARIANT="Workstation Edition"
VARIANT_ID=workstation"  >> /etc/os-release

%end

%packages
@^workstation-product-environment
@admin-tools
@anaconda-tools
@base
@base-x
@core
@gnome
@hardware-support
@printing
@x86-baremetal-tools
.
aajohan-comfortaa-fonts
anaconda
anaconda-install-env-deps
anaconda-live
chkconfig
dracut-live
glibc-all-langpacks
initscripts
kernel
kernel-modules
kernel-modules-extra
lollypop
memtest86+
risi-pre-meta
wget
-@dial-up
-@input-methods
-@standard
-a2ps
-device-mapper-multipath
-esc
-fcoe-utils
-gfs2-utils
-mpage
-reiserfs-utils
-rhythmbox
-samba-client
-specspo

%end
