# kali-setup script
A little script setting up my kali environment including the tools and repository I use the most. 

Feel free to open any issues and feature requests as well as improvements. 

Feedback is appreciated!

# Latest implementations & Improvements
The script has been improved and now supports even more essential features, which will enrich your life by a lot:

## Batch mode
You now can go entirely afk during the installation process, just use the `-y` or `--batch` flag, all questions will then be skipped and not executed.

## Disable system bell
By default the script will also disable the annoying system bell clock. Even though it will be disabled using bash variables as well as with a blacklist, depending on your window manager, you might still encounter the beeping sound! Currently I don't know if there are other universal solutions available.

## Profile mode
In order to make this script more versatile, I decided to take out some parts of the code and put them into an external file allow to use profiles. This way every person is able to import their own shell environment as well as to perform their own tasks individually. 

Profiles can be executed via the `-p` or `--profile` flag and require the foldername as parameter. The provided folder must contain the `profile.sh` script in order to run successfully.

The `profile.sh` script will be called from the installation script.

## OwO mode
Essential mode which will brigthen your day. It fulfills all requirements as per the geneva conventions. 

## Script Usage
	-u 		    --update			Update git repos & apt packages.

	-apt 		--apt-only			Install only apt packages. Apt update and upgrade included.

	-m 		    --misc-only			Execute misc tasks like removing home folders.

	-a 	    	--full-install		Run the whole installation part script. Recommended after clean installs.

	-p <name>	--profile <name>	Executes the task with the specified profile - the given name must be the same as the current working directory. 

	-y 			--batch				Autonomous mode - auto-answers every interactive question with no.

	-h 		    --help 				This help page.

	--owo							OwO Mode :3


# ToDo
- [x] Disable bell sounds
- [x] Batch mode - the script will auto-answer the questions
- [x] Code Refactoring
- [x] Implementing profiles
- [x] OwO mode

