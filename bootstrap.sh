# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Did you leave out sudo?"
	exit
fi

# Clone the Mail-in-a-Box repository if it doesn't exist.
if [ ! -d $HOME/webserver ]; then
	if [ ! -f /usr/bin/git ]; then
		echo Installing git . . .
		apt-get -q -q update
		DEBIAN_FRONTEND=noninteractive apt-get -q -q install -y git < /dev/null
		echo
	fi

	echo Downloading Webserver
	git clone \
		https://github.com/sssmoves/web-init-script \
		$HOME/webserver \
		< /dev/null 2> /dev/null

	echo
fi

# Change directory to it.
cd $HOME/webserver

# Start setup script.
#setup/start.sh