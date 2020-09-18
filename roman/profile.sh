
#Bash does not recognize when the current working directory changes in another script
#Therefore we require a global variable which creates our "new" working directory
PROFILE_DIR="$PWD/$1"

function prep_shell_env()
{
	echo -e "\e[93m[*] Preparing ZSH-Shell environment"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	echo -e "\e[93m[*] Changing shell to ZSH"
	chsh -s /bin/zsh
	#cp -r $PWD.zshrc ~/.zshrc
}


function enable_shared_folder ()
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

prep_shell_env
enable_shared_folder