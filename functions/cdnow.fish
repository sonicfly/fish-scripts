# zqcd: Zkk quick CD command library
function cdnow --description 'Interactive cd command for personal most used path'
	set configFile ~/.config/fish/zqcd/cdnow

	# check argument
	if not test -z $argv[1]
		set selection $argv[1]
		if [ $selection = '--help' ]; or [ $selection = '-h' ]
			echo "cdnow [ (-h|--help) | (-e|--edit) | SHORTCUT ]"
			return 0
		else if [ $selection = '--edit' ]; or [ $selection = '-e' ]
			if [ ! -f $configFile ]
				echo "mkdir"
				mkdir -p (dirname $configFile)
				if [ ! -f $configFile ]
					echo "GOOD"
					echo "# Format:\n#\t[identifier] = [path]\n# Example:\npictures=/Users/joe/pcitures" > $configFile
				else
					echo "FAIL"
				end
			end
			if set -q EDITOR
				$EDITOR $configFile
			else
				vim $configFile
				return 0
			end
		end
	end

	# shortcut 0 - home path
	set options 0
	set identifiers '<user home directory>'
	if [ (string sub -l 6 -- (uname)) = "CYGWIN" ]
		set isWindows true
	end

	if set -l -q isWindows
		set paths (cygpath -F 40)
	else
		set paths $HOME
	end

	# load shortcuts from config file
	if test ! -e $configFile
		echo "Cannot find config file, use 'cdnow --edit' to build one."
	else
		set index 0
		set i 0
		cat $configFile | while read -l line
			set index (math $index+1)
			if [ (string sub -l 1 -- $line) = '#' ]
				continue
			else if set config (string match -r "(.*?)=(.*)" $line)
				set i (math $i+1)
				set options $options $i
				set identifiers $identifiers (string trim -- $config[2])
				set paths $paths (string trim -- $config[3])
			else
				echo "Cannot parse line($index) in config file: $line"
			end
		end

		if [ (count $identifiers) -eq 1 ]
			echo "No valid configuration found in config file."
		end
	end

	# Windows drives
	if set -l -q isWindows
		set letters a b c d e f g h i j k l m n o p q r s t u v w x y z
		set LETTERS A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
		for i in (seq 26)
			if [ -d "/cygdrive/$letters[$i]" ]
				set options $options $letters[$i]
				set identifiers $identifiers "<Windows drive $LETTERS[$i]:>"
				set paths $paths "/cygdrive/$letters[$i]"
			end
		end
	end

	# shortcut ! - script path
	set options $options '!'
	set identifiers $identifiers '<custom shell script directory>'
	set paths $paths (dirname (status -f))

	# get selection
	if not set -l -q selection
		# print options
		echo "Please select shortcut path:"
		for i in (seq (count $options))
			echo "$options[$i]) $identifiers[$i]"
		end
		read -p 'set_color blue; echo -n "Select"; set_color normal; echo -n "> "' -l input
		set selection $input
	end
	
	# find target path
	if [ -z $selection ]
		return 0
	else if set i (contains -i -- $selection $options)
		set target $paths[$i]
	else
		set_color red
		echo "Error> Unknown shortcut \"$selection\"."
		set_color normal
		return 1
	end

	# go to target path
	echo "cd >>> $target"
	cd $target
end
