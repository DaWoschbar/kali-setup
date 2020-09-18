#!/bin/bash
ARRAY_GIT=(
https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
#https://github.com/rebootuser/LinEnum.git
#https://github.com/danielmiessler/SecLists.git
#https://github.com/ffuf/ffuf.git
#https://github.com/PowerShellMafia/PowerSploit.git
#https://github.com/SecureAuthCorp/impacket.git
#https://github.com/pentestmonkey/php-reverse-shell.git
#https://github.com/fox-it/mitm6.git
#https://github.com/samratashok/nishang.git
#https://github.com/FortyNorthSecurity/EyeWitness
#https://github.com/gentilkiwi/mimikatz.git
)

GIT_PYTHON=(
https://github.com/SecureAuthCorp/impacket.git
#https://github.com/Dionach/CMSmap.git
#https://github.com/aboul3la/Sublist3r.git
)

ARRAY_RUBY=(
https://github.com/Hackplayers/evil-winrm.git
)

ARRAY_APT=(
gobuster
hexedit
tmux
python
python3
python-pip
python3-pip
xclip
crackmapexec
exiftool
bloodhound
nikto
open-vm-tools
)

ARRAY_FOLDER=(
vh
overTheWire
htb
)

#Color Legend:
# Red = Cannot/Won't do it							\e[91
# Yellow = Info (ex. something already exists)		\e[93m
# Green = done										\e[92m

function prep_repos()
{
	echo -e "\e[93mInstalling git repos..."

	read -r -p "[?] Should the existing repos in /opt/ updated before the install? [y/N] " response
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
			echo -e " => \e[93m[!] $repo_name already exists in /opt/ - skipping..."
		else
			echo -e " => \e[32mInstalling ${repo_name}"
			git clone -q $i /opt/$repo_name
		fi
	done

	for i in "${GIT_PYTHON[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		if [[ -d "/opt/$repo_name" ]]
		then
			echo -e " => \e[93m[!] $repo_name already exists in /opt/ - skipping..."
		else
			echo -e " => \e[32mInstalling ${repo_name}"
			git clone -q $i /opt/$repo_name
			pip3 install -r /opt/$repo_name/requirements.txt > /dev/null
			python3 /opt/$repo_name/setup.py install > /dev/null
		fi		
	done

	echo -e "\e[92m[*] Finished Github Repository download!"
}

function update_repos()
{
	echo -e "Updating git repos..."
	
	for d in /opt/*
	do	
		cd $d;
		if [[ -d $d/.git ]]
		then
			echo -e "\e[93m => Updating $d"; git stash --quiet; (git pull --quiet &); cd ..;
		fi
	done
	echo -e "\e[92m[*] Finished repo updates!"
}

function prep_apt()
{
	echo -e "\e[93mInstalling apt packages..."
	apt-get update -y > /dev/null
	for i in "${ARRAY_APT[@]}"; do
		echo -e " => \e[93m Installing ${i}"
		apt-get install $i -y -qq >/dev/null
	done

	echo -e "\e[93m[*] Performing apt full-upgrade..."
	apt-get full-upgrade -y -qq
	echo -e "\e[93m[*] Performing apt autoremove..."
	apt-get autoremove -y -qq

	echo -e "\e[92m[*] Finished download apt packages!"
}

function update_apt()
{
	echo "Updating apt packages..."
	apt-get update -qq -y

	echo -e "\e[93m[!] Running apt autoremove..."
	apt-get autoremove -y -qq

	echo -e "\e[92m[*] Finished apt update!"
}

function prep_ruby()
{
	echo -e "\e[93mInstalling Ruby gem packages..."
	
	for i in "${ARRAY_RUBY[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		echo -e " => \e[93mInstalling ${repo_name}"
		gem install $basename --silent
	done

	echo -e "\e[92m[*] Sucessfully installed ruby packages!"
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
	echo -e "\e[92m[*] Finished ruby updates!"
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
	echo -e "\e[93m[*] Executing misc"
	echo -e "\e[93m[!] Removing unnecessary folders..."
	rmdir rmdir ~/Documents/ ~/Downloads/ ~/Music/ ~/Pictures/ ~/Public/ ~/Videos/ ~/Templates/ 2> /dev/null

	echo -e "\e[93m[!] Adding system links from shared folder in the home directory"
	shared-folder-syslinks

	read -r -p "[?] Should autologin be enabled? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
	#I was told this part can be done using sed, but I just don't know how
		sed -i "s/#  TimedLoginEnable = true/TimedLoginEnable = true/" /etc/gdm3/daemon.conf
		sed -i "s/#  AutomaticLogin = user1/AutomaticLogin = root/" /etc/gdm3/daemon.conf
	fi
	
	echo -e "\e[93m[!] Disable auto-suspend and redefine lockout rules ..."
	systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target
	 # disable session idle
    gsettings set org.gnome.desktop.session idle-delay 0
    # disable sleep when on AC power
    gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
    # disable screen timeout on AC
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/blank-on-ac -s 0 --create --type int
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-off -s 0 --create --type int
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/dpms-on-ac-sleep -s 0 --create --type int
    # disable sleep when on AC
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/inactivity-on-ac -s 14 --create --type int
    # hibernate when power is critical
    xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/critical-power-action -s 2 --create --type int

	#prep_shell_env

	if [ ! -f /usr/share/wordlists/rockyou.txt ]; then
		echo -e "\e[93m[!] Unpacking rockyou.txt"
		gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
	else
		echo -e "\e[93m[!] Rockyou.txt already exists unpacked - skipping!"
	fi
	

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
	echo -e "\e[93m[*] Creating sys links from shared folders..."
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
	prep_repos
	prep_apt
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