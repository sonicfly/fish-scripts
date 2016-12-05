# zqcd: Zkk quick CD command library
function cdnow --description 'Interactive cd command for predefined shortcut paths'
	set configFile ~/.config/fish/zqcd/cdnow

	# check argument
	while count $argv >/dev/null
		switch $argv[1]
			case -h --help
				echo "cdnow [(-h|--help)] [(-e|--edit)] [(-r|--reload)] [SHORTCUT]"
				return 0

			case -e --edit
				if [ ! -e $configFile ]
					mkdir -p (dirname $configFile)
					echo "# Format:\n#\t[identifier] = [path]\n# Example:\npictures = /Users/zkk/pictures" > $configFile
				else if [ ! -f $configFile ]
					set_color red
					echo "Error> Invalid config file, need manually delete: $configFile"
					set_color normal
					return 1
				end
				set -e -g ZQCD_cdnow
				if set -q EDITOR
					$EDITOR $configFile
				else
					vim $configFile
				end
				return 0

			case -r --reload
				set -e -g ZQCD_cdnow
				set -e argv[1]

			case --
				set -e argv[1]
				if [ (count $argv) -gt 0 ]
					set selection $argv[1]
				end
				break

			case "*"
				set selection $argv[1]
				break
		end
	end

	# check shortcut cache
	if set -q -g ZQCD_cdnow
		set optionTotal (count $ZQCD_cdnow)
		if [ (math "$optionTotal % 3") -eq 0 ]
			# already have valid shortcut lists
			set optionCount (math "$optionTotal / 3")
			set options $ZQCD_cdnow[1..$optionCount]
			set identifiers $ZQCD_cdnow[(math "$optionCount + 1")..(math "$optionCount * 2")]
			set paths $ZQCD_cdnow[(math "$optionCount * 2 + 1")..(math "$optionCount * 3")]
		end
	end

	if not set -q -l optionCount
		# construct shortcuts

		# shortcut 0 - home path
		set options 0
		set identifiers '<user home directory>'
		if [ (string sub -l 6 -- (uname)) = "CYGWIN" ]
			set isWindows true
		end

		if set -q -l isWindows
			set paths (cygpath -F 40)
		else
			set paths $HOME
		end

		# load shortcuts from config file
		if [ ! -f $configFile ]
			set_color red
			echo "Info> Cannot load config file, use 'cdnow --edit' to build one."
			set_color normal
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
					set_color red
					echo "Info> Cannot parse line($index) in config file: $line"
					set_color normal
				end
			end

			if [ (count $identifiers) -eq 1 ]
				set_color red
				echo "Info> No valid shortcut found in config file."
				set_color normal
			end
		end

		# Windows drives
		if set -q -l isWindows
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

		set -g ZQCD_cdnow $options $identifiers $paths
	end

	# get selection
	if not set -q -l selection
		# print shortcuts
		echo "Please select a path shortcut:"
		for i in (seq (count $options))
			echo "$options[$i]) $identifiers[$i]"
		end
		read -p 'set_color blue; echo -n "Select>"; set_color normal' -l input
		set selection $input
	end
	
	# find target path
	if test -z $selection
		return 0
	else if set i (contains -i -- $selection $options)
		set target $paths[$i]
	else if set i (contains -i -- $selection $identifiers)
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
