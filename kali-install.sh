#!/bin/bash
ARRAY_GIT=(
https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
https://github.com/rebootuser/LinEnum.git
https://github.com/danielmiessler/SecLists.git
https://github.com/ffuf/ffuf.git
https://github.com/PowerShellMafia/PowerSploit.git
https://github.com/SecureAuthCorp/impacket.git
https://github.com/pentestmonkey/php-reverse-shell.git
https://github.com/fox-it/mitm6.git
https://github.com/Hackplayers/evil-winrm.git
)

ARRAY_APT=(
gobuster
hexedit
tmux
python-pip
python3-pip
)

ARRAY_FOLDER=(
vh
overTheWire
htb
CTFs/picoCTF19
)

function prep_repos()
{
	echo "Installing git repos...."

	for i in "${ARRAY_GIT[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

	if [ -d "/opt/$repo_name" ]; then
   echo "${repo_name} already exists."

	else
		echo "\e[32m >>installing ${repo_name}"
		git clone -q $i /opt/$repo_name
		echo "Installed $repo_name successfully!"
	fi
	done
}

function update_repos ()
{
	echo "Updating git repos"
	for i in "${ARRAY_GIT[@]}"; do
		basename=$(basename $i)
		repo_name=${basename%.*}
		echo ">>Updating ${repo_name}"
		git pull -q /opt/$i
	done
}

function prep_apt()
{
	echo "Installing Aptitude packages"
	echo "update APTITUDE"
	apt update
	for i in "${ARRAY_APT[@]}"; do
		echo ">>installing ${i}"
		apt install $i -y -qq
	done
}

function update_apt ()
{
	echo "Updating Aptitude packages"
	echo "update APTITUDE"
	apt update
	for i in "${ARRAY_APT[@]}"; do
		echo ">>installing ${i}"
		apt update $i -y -qq
	done
}

function prep_shell_env()
{
	echo "Preparing ZSH-Shell environment"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	echo "Changing shell to ZSH"
	chsh -s /bin/zsh
	echo "IMPLEMENT: Copy custom config file from GITHUB repo"
}

function do_misc ()
{
	echo "Executing misc"
	echo "Removing unnecessary folders..."
	rmdir rmdir ~/Documents/ ~/Downloads/ ~/Music/ ~/Pictures/ ~/Public/ ~/Videos/ ~/Templates/

	echo "Adding system links from shared folder in the home directory"
	ln -s /mnt/hgfs/Hacking/vh ~/vh
	ln -s /mnt/hgfs/Hacking/htb ~/htb
	ln -s /mnt/hgfs/Hacking/OverTheWire ~/overTheWire
	ln -s /mnt/hgfs/Hacking/CTFs/PicoCTF19 ~/pico19

	echo "Installing Atom"
	wget https://atom.io/download/deb -O /tmp/atom.deb
	dpkg -i /tmp/atom.deb

	prep_shell_env
}

function to_do()
{
	echo "****Consider the following actions to be implemented in the future... ****"
	echo "- APT: Stegosolve, stegohide"
	echo "- Windows Exploitation Repos"
	echo "- Automatic installation of some installed git repos"
	echo "- Install FoxyProxy and try to configure it automatically (if possible)"
	echo "- autologin in virtual machine"
	echo "- OneDrive Shared folder"
	echo "- colored output"
	echo "- A setup/Wizzard -> choose what exactly to do..."
	echo ""
	echo "Link to 'Wizzard' resources:"
	echo "http://linuxcommand.org/lc3_wss0120.php"
}

function wizzard ()
{
	usage
response=
    echo -n "Choose an option > "
    read response

    if [ -a "$response" ]; then
        prep_repos
		prep_apt
		do_misc
    fi

	if [ -apt "$response" ]; then
        prep_apt
    fi

	if [ -g "$response" ]; then
        prep_repos
    fi

	if [ -m "$response" ]; then
        do_misc
    fi
}

function usage ()
{

	echo "-u 	--update	 		Update repos & aptitude packages."
	echo "-s 	--shell-env	 		Only prep ZSH-Shell env"
	echo "-g 	--git-only			Install git repos only."
	echo "-apt 	--apt-only			Install only apt packages. Apt update included."
	echo "-sf	--shared-folders	-sf | --shared-folders 			Install VMware tools and add softlinks of shared folders to it."
	echo "-m 	--misc-only			Execute misc tasks like removing home folders."
	echo "		--to-do				Print the to-do list."
	echo "-a 	--full-install		Run the whole script. Recommended by after clean installs."
	echo ""
	echo "-w 	--wizzard			Run the wizard."
	echo ""
	echo "-h 	--help 				This help page."
}

function to_imp ()
{
	echo "currently not implemented"
}

function shared-folder-syslinks ()
{
	echo "Creating sys links from shared folders..."

	for i in "${ARRAY_FOLDER[@]}"
	do
		echo "creating $i"
		echo $i
		ln -s /mnt/hgfs/Hacking/$i ~/$i
	done
}

function full_install ()
{
	prep_repos
	prep_apt
	do_misc
}

if [[ $# -eq 0 ]] ; then
    echo 'No Arguments provided'
	usage
	echo ""
    exit 0
fi

echo "===== This script was written by DaWoschbar ====="
echo "Find me on GitHub: https://github.com/DaWoschbar"
echo "Preparing your environment..."
while [ "$1" != "" ]; do
    case $1 in
        -h | --help ) usage
		exit;;

		-u | --update )	update_repos update_apt
		exit;;
		-s | --shell-env )	prep_shell_env
		exit;;

		-g | --git-only ) prep_repos
		exit;;

		-apt | --apt-only )	prep_apt
		exit;;

		-m | --misc-only )	do_misc
		exit;;

		-sf | --shared-folders )	vmware-tools shared-folder-syslinks
		exit;;

		-sl | --soft-links ) shared-folder-syslinks
		exit;;

		--to-do ) to_do
		exit;;

		-a | --full-install ) full_install
		exit;;

		-w | --wizzard )	wizzard
		exit;;

        * ) echo "Invalid argument" usage
		exit 1
    esac
    shift
done
