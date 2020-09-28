# kali-setup script
A little script setting up my kali environment including the tools and repository I use the most. 


# Latest implementations & Improvements
The script has been improved and now supports two essential features, which will enrich your life by a lot:

## Profile mode
In order to make this script more versatile, I decided to take out some parts of the code and put them into an external file allow to use profiles. This way every person is able to import their own shell environment as well as to perform their own tasks individually. 

Profiles can be executed via the `-p` or `--profile` flag and require the foldername as parameter. The provided folder must contain the `profile.sh` script in order to run successfully.

The `profile.sh` script will will be called from the installation script.

## OwO mode
Essential mode which will brigthen your day. It fulfills all requirements as per the geneva conventions. 

## Script Usage
	-u 		    --update			Update git repos & apt packages.

	-apt 		--apt-only			Install only apt packages. Apt update and upgrade included.

	-m 		    --misc-only			Execute misc tasks like removing home folders.

	-a 	    	--full-install		Run the whole installation part script. Recommended after clean installs.

	-p <name>	--profile <name>	Executes the task with the specified profile - the given name must be the same as the current working directory. 

	-h 		    --help 				This help page.

	--owo							OwO Mode :3


# ToDo
- [ ] Batch mode - the script will auto-answer the questions
- [ ] Code Refactoring
- [x] Implementing profiles
- [x] OwO mode

