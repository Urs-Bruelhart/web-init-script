source setup/functions.sh # load our functions

# Basic System Configuration
# -------------------------

# ### Add Mail-in-a-Box's PPA.

# We've built several .deb packages on our own that we want to include.
# One is a replacement for Ubuntu's stock postgrey package that makes
# some enhancements. The other is dovecot-lucene, a Lucene-based full
# text search plugin for (and by) dovecot, which is not available in
# Ubuntu currently.
#
# Add that to the system's list of repositories using add-apt-repository.
# But add-apt-repository may not be installed. If it's not available,
# then install it. But we have to run apt-get update before we try to
# install anything so the package index is up to date. After adding the
# PPA, we have to run apt-get update *again* to load the PPA's index,
# so this must precede the apt-get update line below.

if [ ! -f /usr/bin/add-apt-repository ]; then
	echo "Installing add-apt-repository..."
	hide_output apt-get update
	apt_install software-properties-common
fi

hide_output add-apt-repository -y ppa:mail-in-a-box/ppa

# ### Update Packages

# Update system packages to make sure we have the latest upstream versions of things from Ubuntu.

echo Updating system packages...
hide_output apt-get update
apt_get_quiet upgrade

# ### Install System Packages

# Install basic utilities.
#
# * haveged: Provides extra entropy to /dev/random so it doesn't stall
#	         when generating random numbers for private keys (e.g. during
#	         ldns-keygen).
# * unattended-upgrades: Apt tool to install security updates automatically.
# * cron: Runs background processes periodically.
# * ntp: keeps the system time correct
# * fail2ban: scans log files for repeated failed login attempts and blocks the remote IP at the firewall
# * netcat-openbsd: `nc` command line networking tool
# * git: we install some things directly from github
# * sudo: allows privileged users to execute commands as root without being root
# * coreutils: includes `nproc` tool to report number of processors, mktemp
# * bc: allows us to do math to compute sane defaults

echo Installing system packages...
apt_install python3 python3-dev python3-pip \
	netcat-openbsd wget curl git sudo coreutils bc \
	haveged unattended-upgrades cron ntp fail2ban

# Allow apt to install system updates automatically every day.

cat > /etc/apt/apt.conf.d/02periodic <<EOF;
APT::Periodic::MaxAge "7";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Verbose "1";
EOF

# ### Firewall

# Various virtualized environments like Docker and some VPSs don't provide #NODOC
# a kernel that supports iptables. To avoid error-like output in these cases, #NODOC
# we skip this if the user sets DISABLE_FIREWALL=1. #NODOC
if [ -z "$DISABLE_FIREWALL" ]; then
	# Install `ufw` which provides a simple firewall configuration.
	apt_install ufw

	# Allow incoming connections to SSH.
	ufw_allow ssh;

	# ssh might be running on an alternate port. Use sshd -T to dump sshd's #NODOC
	# settings, find the port it is supposedly running on, and open that port #NODOC
	# too. #NODOC
	SSH_PORT=$(sshd -T 2>/dev/null | grep "^port " | sed "s/port //") #NODOC
	if [ ! -z "$SSH_PORT" ]; then
	if [ "$SSH_PORT" != "22" ]; then

	echo Opening alternate SSH port $SSH_PORT. #NODOC
	ufw_allow $SSH_PORT #NODOC

	fi
	fi

	ufw --force enable;
fi #NODOC

# ### Fail2Ban Service

# Configure the Fail2Ban installation to prevent dumb bruce-force attacks against dovecot, postfix and ssh
cp conf/fail2ban/jail.local /etc/fail2ban/jail.local

restart_service fail2ban