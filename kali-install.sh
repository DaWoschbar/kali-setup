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
https://github.com/samratashok/nishang.git
https://github.com/trustedsec/unicorn.git
)

GIT_PYTHON=(
https://github.com/SecureAuthCorp/impacket.git
)

ARRAY_RUBY=(
https://github.com/Hackplayers/evil-winrm.git
)

ARRAY_APT=(
gobuster
hexedit
tmux
python3-pip
xclip
crackmapexec
exiftool
gem
)

ARRAY_FOLDER=(
vh
overTheWire
htb
)

function prep_repos()
{
	echo -e "\e[93m Installing git repos..."

	read -r -p "Should the existing repos in /opt/ updated before the install? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		update_repos
	fi

	for i in "${ARRAY_GIT[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		if [[ -d "/opt/$repo_name" ]]
		then
			echo "$repo_name already exists in /opt!"
		else
			echo " => \e[32m Installing ${repo_name}"
			git clone -q $i /opt/$repo_name
			echo "Installed $repo_name successfully!"
		fi
	done

	for i in "${GIT_PYTHON[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		if [[ -d "/opt/$repo_name" ]]
		then
			echo "$repo_name already exists in /opt!"
		else
			echo " => \e[32mInstalling ${repo_name}"
			git clone -q $i /opt/$repo_name
			pip3 install -r /opt/$repo_name/requirements.txt > /dev/null
			python3 /opt/$repo_name/setup.py install > /dev/null
			echo "Installed $repo_name successfully!"
		fi		
	done

	echo -e "\e[92m Finished Repo Download!"
}

function update_repos()
{
	echo -e "\e[93mUpdating git repos"
	
	for d in /opt/*
	do
		cd $d;
		if [[ -d $d/.git ]]
		then
			echo " => Updating $d"; git stash --quiet; (git pull --quiet &); cd ..;
		fi
	done
	echo -e "\e[92mFinished repo updates!"
}

function prep_apt()
{
	echo -e "\e[93m Installing Aptitude packages"
	echo "update APTITUDE"
	apt-get update > /dev/null
	for i in "${ARRAY_APT[@]}"; do
		echo -e " => \e[93m Installing ${i}"
		apt-get install $i -y -qq >/dev/null
	done

	echo -e "\e[93m Performing apt full-upgrade..."
	apt-get full-upgrade -y -qq
	echo -e "\e[93m Performing apt autoremove..."
	apt-get autoremove -y -qq

	echo -e "\e[92m Finished download apt packages"
}

function update_apt()
{
	echo "Updating Aptitude packages"
	echo "update APTITUDE"
	apt-get update -qq
	for i in "${ARRAY_APT[@]}"; do
		echo "=> Updating ${i}"
		apt-get update $i -y -qq
	done

	echo -e "\e[92m Finished apt update"

	echo "Running apt autoremove..."
	apt-get autoremove -y -qq
}

function prep_ruby()
{
	echo -e "\e[93m Installing Ruby gem packages"
	
	for i in "${ARRAY_RUBY[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		echo -e " => \e[32mInstalling ${repo_name}"
		gem install $basename --silent
		echo "Installed $repo_name successfully!"

	done
}

function update_ruby()
{
	for i in "${ARRAY_RUBY[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		echo -e " => \e[32m Updating ${repo_name}"
		gem update $basename --silent
	done
	echo -e "Finished ruby updates"
}

function prep_shell_env()
{
	echo "Preparing ZSH-Shell environment"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	echo "Changing shell to ZSH"
	chsh -s /bin/zsh
	cp -r /opt/kali-setup/.zshrc ~/.zshrc

}

function do_misc()
{
	echo "Executing misc"
	echo "Removing unnecessary folders..."
	rmdir rmdir ~/Documents/ ~/Downloads/ ~/Music/ ~/Pictures/ ~/Public/ ~/Videos/ ~/Templates/ 2> /dev/null

	echo "Adding system links from shared folder in the home directory"
	shared-folder-syslinks
	
	read -r -p "Should Atom be installed? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		#echo -e "\e[93mCheck if atom is installed, help: https://discuss.atom.io/t/is-there-a-way-to-detect-if-atom-is-installed-on-a-computer/61029/2"
		wget https://atom.io/download/deb -O /tmp/atom.deb
		dpkg -i /tmp/atom.deb
	fi

	read -r -p "Should autologon be enabled? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		echo "AutomaticLoginEnable = true" >> /etc/gdm3/daemon.conf
		echo "AutomaticLogin = root" >> /etc/gdm3/daemon.conff
	fi
	
	read -r -p "Should repos in /opt/ checked for updates? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
		update_repos
	fi
	
	echo "Disable auto-suspend..."
	systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

	prep_shell_env
}

function to_do()
{
	echo "****Consider the following actions to be implemented in the future... ****"
	echo "- APT: Stegosolve, stegohide"
	echo "- Automatic installation of some installed git repos"
	echo "- Install FoxyProxy and try to configure it automatically (if possible)"
	echo "- OneDrive Shared folder"
	echo "- colored output"
}

function usage ()
{

	echo "-u 	--update	 		Update git repos & aptitude packages ."
	echo "-s 	--shell-env	 		Only prep ZSH-Shell env"
	echo "-apt 	--apt-only			Install only apt packages. Apt update included."
	echo "-sf	--shared-folders	-sf | --shared-folders 			Install VMware tools and add softlinks of shared folders to it."
	echo "-m 	--misc-only			Execute misc tasks like removing home folders."
	echo "		--to-do				Print the to-do list."
	echo "-a 	--full-install		Run the whole script. Recommended by after clean installs."
	echo ""
	echo "-h 	--help 				This help page."
}

function shared-folder-syslinks ()
{
	#echo "Running shared folder VMware script..."	
	#cp /opt/kali-setup/mount-shared-folders ~/Desktop/

	echo "Creating sys links from shared folders..."
	for i in "${ARRAY_FOLDER[@]}"
	do
		if [[ ! -d ~/$i ]]
		then
			echo "Creating $i"
			ln -s /mnt/hgfs/Hacking/$i ~/$i
		fi
	done
}

function full_install ()
{
	prep_apt
	prep_repos
	prep_ruby
	do_misc
}

function full_update ()
{
	update_repos 
	update_apt 
	update_ruby
}

if [[ $# -eq 0 ]] ; then
    echo 'No Arguments provided'
	usage
	echo ""
    exit 0
fi

echo "===== This script was written by DaWoschbar ====="
echo "Find me on GitHub: https://github.com/DaWoschbar"
echo -e "\e[96mPreparing your environment..."
while [ "$1" != "" ]; do
    case $1 in
        -h | --help ) usage
		exit;;

		-u | --update )	full_update
		exit;;
		-s | --shell-env )	prep_shell_env
		exit;;

		-g | --git-only ) prep_repos
		exit;;

		-apt | --apt-only )	prep_apt
		exit;;

		-m | --misc-only )	do_misc
		exit;;

		-sf | --shared-folders ) shared-folder-syslinks
		exit;;

		-sl | --soft-links ) shared-folder-syslinks
		exit;;

		--to-do ) to_do
		exit;;

		-a | --full-install ) full_install
		exit;;

        * ) echo "Invalid argument" usage
		exit 1
    esac
    shift
done


echo -e "Script ended."
