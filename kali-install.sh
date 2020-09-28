#!/bin/bash
ARRAY_GIT=(
https://github.com/carlospolop/privilege-escalation-awesome-scripts-suite.git
https://github.com/rebootuser/LinEnum.git
https://github.com/danielmiessler/SecLists.git
https://github.com/ffuf/ffuf.git
https://github.com/PowerShellMafia/PowerSploit.git
https://github.com/pentestmonkey/php-reverse-shell.git
https://github.com/fox-it/mitm6.git
https://github.com/samratashok/nishang.git
https://github.com/FortyNorthSecurity/EyeWitness
https://github.com/gentilkiwi/mimikatz.git
https://github.com/mishmashclone/BC-SECURITY-Empire.git
https://github.com/lgandx/Responder.git
https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git
https://github.com/Proxmark/proxmark3.git
https://github.com/FortyNorthSecurity/EyeWitness.git
)

GIT_PYTHON=(
https://github.com/SecureAuthCorp/impacket.git
https://github.com/Dionach/CMSmap.git
https://github.com/aboul3la/Sublist3r.git
https://github.com/AdrianVollmer/PowerHub.git
https://github.com/threat9/routersploit.git
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
neo4j
open-vm-tools
gem
golang
)

#globals
_OWO=0
_LOG=1

#Color Legend:
# Red = Cannot/Won't do it							\e[91
# Yellow = Info (ex. something already exists)		\e[93m
# Green = done										\e[92m

function log ()
{
	if [[ $_LOG ]]; then
		echo -e "\e[93m[*] $@"
	fi
}

function log_info ()
{
	if [[ $_LOG ]]; then
		echo -e "\e[93m[!] $@"
	fi
}

function log_error ()
{
	echo -e "\e[91m[!] $@"
}

#Echo-ing owo lines if the --owo parameter was set
function owo () 
{
    if [[ $_OWO -eq 1 ]]; then
        echo "$@"
    fi
}

#Essential starting function for the owo mode
function start_owo ()
{
	echo -en "( •_•)" "\r"
	sleep 1
	echo -en "( •_•)>⌐■-■" "\r"
	sleep 1 
	echo "(⌐■_■)        " 
	sleep 1

	echo "[*] OwO Mode activated!"
	sleep 1
	echo "Let's go (つ▀¯▀)つ" 
}

#Downloading repositories that are in the ARRAY_GIT variable
#Additionally executes the setup.py script when the scripts are written in python
function prep_repos()
{
	log_info "Installing git repos..."

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
			echo " => $repo_name already exists in /opt/ - skipping..."
		else
			log " => Installing ${repo_name}"
			git clone -q $i /opt/$repo_name
		fi
	done

	for i in "${GIT_PYTHON[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		if [[ -d "/opt/$repo_name" ]]
		then
			log_error "$repo_name already exists in /opt/ - skipping..."
		else
			echo " => Installing ${repo_name}"
			git clone -q $i /opt/$repo_name 
			pip3 install -r /opt/$repo_name/requirements.txt > /dev/null
			python3 /opt/$repo_name/setup.py install > /dev/null
		fi		
	done

	echo -e "\e[92m[*] Finished Github Repository download!"
}

#Update all repositories that are in ARRAY_GIT and GIT_PYTHON
function update_repos()
{
	log "Updating git repos..."
	
	for d in /opt/*
	do	
		cd $d;
		if [[ -d $d/.git ]]
		then
			echo " => Updating $d"; git stash --quiet; (git pull --quiet &); cd ..;
		fi
	done
	log "Finished repo updates!"
}

#Update and install apt packages + upgrades
function prep_apt()
{
	log_info "Installing apt packages..."
	log_info "Updating apt cache..."
	apt-get update -y > /dev/null
	for i in "${ARRAY_APT[@]}"; do
		echo " => Installing ${i}"
		apt-get install $i -y -qq >/dev/null
	done

	log "Performing apt full-upgrade..."
	apt-get full-upgrade -y -qq
	log "Performing apt autoremove..."
	apt-get autoremove -y -qq

	log "Finished download apt packages!"
}
#Update and auto-remove apt packages
function update_apt()
{
	log "Updating apt packages..."
	apt-get update -qq -y

	log_info "Running apt autoremove..."
	apt-get autoremove -y -qq

	log_info "Finished apt update!"
}

#Install ruby gem packages
function prep_ruby()
{
	log_info "Installing Ruby gem packages..."
	
	for i in "${ARRAY_RUBY[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		echo " => Installing ${repo_name}"
		gem install $basename --silent
	done

	log_info "Sucessfully installed ruby packages!"
}

#update ruby gem packages
function update_ruby()
{
	for i in "${ARRAY_RUBY[@]}"
	do
		basename=$(basename $i)
		repo_name=${basename%.*}

		echo " => Updating ${repo_name}"
		gem update $basename --silent
	done
	log "Finished ruby updates!"
}

#Perform unspecific 
function do_misc()
{
	log "Executing misc"
	read -r -p "[?] Should autologin be enabled? [y/N] " response
	if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]
	then
	#I was told this part can be done using sed, but I just don't know how
		sed -i "s/#  TimedLoginEnable = true/TimedLoginEnable = true/" /etc/gdm3/daemon.conf
		sed -i "s/#  AutomaticLogin = user1/AutomaticLogin = root/" /etc/gdm3/daemon.conf
	fi
	
	log_info "Disable auto-suspend and redefine lockout rules ..."
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

	if [ ! -f /usr/share/wordlists/rockyou.txt ]; then
		log_info "Unpacking rockyou.txt"
		gunzip /usr/share/wordlists/rockyou.txt.gz 2>/dev/null
	else
		log_error "Rockyou.txt already exists unpacked - skipping!"
	fi
	

}

#Profile functions that setup additional stuff like your shell environment
#Non-modular! It basically just calls the script in the profile directory.
function install_profile()
{
	PROFILE_NAME=$1
	
	if [ -d $PROFILE_NAME ]; then
		if [ -f $PROFILE_NAME/profile.sh ]; then

			log "Applying profile settings from $PROFILE_NAME"
			$PROFILE_NAME/profile.sh $PROFILE_NAME
		else
			log_error "Error: Missing profile.sh in $PROFILE_NAME!"
			owo "No profile.sh in your directory (＠´＿｀＠)"
		fi
	else
		log_error "Error: the specified profilename does not match the directory!"
		owo "(＠´＿｀＠)"
		exit 1;
	fi
}

#Print the available parameters
function usage ()
{
	echo "-u 		--update			Update git repos & apt packages ."
	echo "-apt 		--apt-only			Install only apt packages. Apt update and upgrade included."
	echo "-m 		--misc-only			Execute misc tasks like removing home folders."
	echo "-a 		--full-install		Run the whole installation part script. Recommended after clean installs."
	echo "-p <name>	--profile <name>	Executes the task with the specified profile - the given name must be the same as the current working directory. "
	echo ""
	echo "-h 		--help 				This help page."
	echo "--owo							OwO Mode :3"

	owo "\n What are these arguments? (╯°□°）╯︵ ┻━┻"
}

function full_install ()
{
	if [[ check_internet_connection ]]
	then
		owo "Going to install everything for you senpai (/◕ヮ◕)/"
		prep_apt
		owo "Going for the GitHub Repositories (≧∇≦)/"
		prep_repos
		owo "Going for Ruby stuff ヽ(⌐■_■)ノ♪♬"
		prep_ruby
		owo "Doing the rest (⌐■_■)"
		do_misc
	fi
}

function full_update ()
{
	if [[ check_internet_connection ]]
		then
		owo "Doing some updates(⌐■_■)"
		owo "This might take some time Ｏ(≧▽≦)Ｏ"
		update_repos 
		update_apt 
		update_ruby
		owo "Finsihed (ﾉ´ヮ´)ﾉ*:･ﾟ✧"
	fi

}

function check_internet_connection ()
{
	if : >/dev/tcp/8.8.8.8/53; then
		return true
	else
		log_error "No internet connection available!"
		exit 1
	fi
}

if [[ $# -eq 0 ]] ; then
    echo "No Arguments provided"
	usage
	
	echo -e "\n Where are my arguments? (╯°□°）╯︵ ┻━┻"
    exit 1
fi



echo "===== This script was written by DaWoschbar ====="
echo "Find me on GitHub: https://github.com/DaWoschbar"
echo -e "\e[96mPreparing your environment..."

#This loop is required in order to check if the owo parameter is called in general - Otherwise the parameters are executed in the defined order
#In the future this loop can also be used for a silent mode
#If you know how to make this process more efficent, contact me
for var in "$@"
do
	if [[ $var == "--owo" ]]
	then
		_OWO=1
		start_owo
	fi
done

#Check and execute provided parameter
while [ $# -gt 0 ]
do
    case $1 in
        -h | --help ) usage;;
		-u | --update )	full_update;;
		-s | --shell-env )	prep_shell_env;;
		-g | --git-only ) prep_repos;;
		-apt | --apt-only )	prep_apt;;
		-m | --misc-only )	do_misc;;
		-p | --profile ) 
			shift
				if test $# -gt 0; then
					export PROFILE=$1
					install_profile $PROFILE
				else
					echo "Profile name not specified or invalid name!"
					echo "The profilename must match the folder in the current working directory!"
					owo "ಗಾ ﹏ ಗಾ"
				fi
			shift;;
		-a | --full-install ) full_install ;;
		--owo ) ;;
        * ) log_error "Invalid arguments!\n\nUsage:"; usage
		exit 1;;
    esac
    shift
done


owo "(✿◠‿◠) Finished your installation (✿◠‿◠)"
log_error "Installation finished!"
log_error "You might need to reboot your machine."
log_error "Keep in mind that some tools require manual installation!"
owo "Σ(ノ°▽°)ノ BYE!"