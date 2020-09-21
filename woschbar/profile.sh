#Bash does not recognize when the current working directory changes in another script
#Therefore we require a global variable which creates our "new" working directory
PROFILE_DIR="$PWD/$1"

ARRAY_FOLDER=(
vh
overTheWire
htb
)

function prep_shell_env()
{
	echo -e "\e[93m[*] Preparing ZSH-Shell environment"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	echo -e "\e[93m[*] Changing shell to ZSH"
	chsh -s /bin/zsh
	cp -r $PROFILE_DIR/.zshrc ~/.zshrc
}

function remove_unwanted_dirs ()
{
	echo -e "\e[93m[!] Removing unnecessary folders..."
	rmdir ~/Documents/ ~/Downloads/ ~/Music/ ~/Pictures/ ~/Public/ ~/Videos/ ~/Templates/ 2> /dev/null
}

function enable_shared_folder ()
{

	if [[ -d /mnt/hgfs/Hacking ]]
	then
		echo -e "\e[93m[*] Creating sys links from shared folders..."
		for i in "${ARRAY_FOLDER[@]}"
		do
			if [[ ! -d ~/$i ]]
			then
				echo "Creating $i"
				ln -s /mnt/hgfs/Hacking/$i ~/$i
			fi
		done

		cp $PROFILE_DIR/mount-shared-folders /root/Desktop
		chmod +x /root/Destkop/mount-shared-folders

		cp $PROFILE_DIR/mount-shared-folders /home/*/Desktop/
		chmod +x /home/*/Desktop/mount-shared-folders
	else 
		echo -e "[!] Folders are not available! Check if they're activated..."
	fi
}

remove_unwanted_dirs
prep_shell_env
enable_shared_folder