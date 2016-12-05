# zqcd: Zkk quick CD command library
function cdmk --description 'Interactive cd command for marked path'
	# Record file path
	set recordFile ~/.config/fish/zqcd/cdmk
	# Full shortcut option list, expand if you need more
	set options 1 2 3 4 5 6 7 8 9 0 a b c d e f g h i j k l m n o p q r s t u v w x y z
	# Shortcut path global variable name.
	# In command line, you can reference the marked path as '$cdmk[{index}]'.
	# Change this if the name conflicts with global variable defined by other library.
	set cacheName 'cdmk'
	# Maximum number of shortcut marks recorded, overflow mark will be dropped
	# You can change it to bigger (or smaller) number if you like,
	# but remember to make full shortcut option list fit as well
	set cacheSize 20

	# check argument
	while count $argv >/dev/null
		switch $argv[1]
			case -h --help
				echo "cdrec [-h|--help] [(-a|--add)] [(-c|--clean] [(-r|--reload)] [SHORTCUT]"
				return 0

			case -a --add
				set newMark (pwd)
				break

			case -c --clean
				set -e -g $cacheName
				if [ -f $recordFile ]
					rm $recordFile
				end
				echo "All marks cleaned!"
				return 0

			case -r --reload
				set -e -g $cacheName
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

	# load marks from file
	if not set -q -g $cacheName
		and [ -f $recordFile ]
		# construct shortcut list from persistence file
		cat $recordFile | while read -l line
			if test -z $line
				or [ (string sub -l 1 -- $line) = '#' ]
				continue
			end
			set -g $cacheName $$cacheName[1] $line
		end
	end

	# update marks
	if set -q -l newMark
		if set i (contains -i -- $newMark $$cacheName[1])
			set -e $cacheName[$i]
			echo "Bump existed mark: $newMark"
		else
			echo "Add mark: $newMark"
		end
		
		set -g $cacheName $newMark $$cacheName[1]
		set isChanged true
	end

	if set -q -g $cacheName
		and [ (count $$cacheName[1]) -gt 0 ]
		for i in (seq (count $$cacheName[1]) 1)
			if [ ! -d $$cacheName[1][$i] ]
				set_color red
				echo "Info> Remove invalid path: $$cacheName[1][$i]" 
				set_color normal
				set -e $cacheName[$i]
				set isChanged true
			end
		end

		while [ (count $$cacheName[1]) -gt $cacheSize ]
			set index (math "$cacheSize + 1")
			set -e $cacheName[(math "$cacheSize + 1")]
			set isChanged true
		end
	end

	if set -q -l isChanged
		if [ ! -e $recordFile ]
			mkdir -p (dirname $recordFile)
		else if [ ! -f $recordFile ]
			set_color red
			echo "Error> Invalid record file prevents presisting marks across shell sessions, need manually delete: $recordFile"
			set_color normal
			return 1
		end

		string join -- \n $$cacheName[1] > $recordFile
		set -e isChanged
	end

	if set -q -l newMark
		# end of --add
		return 0
	end

	if not set -q -g $cacheName
		or [ (count $$cacheName[1]) -eq 0 ]
		set_color red
		echo "Error> No mark found, use 'mkcd' to mark current path."
		set_color normal
		return 1
	end

	set options $options[1..(count $$cacheName[1])]

	# get selection
	if not set -q -l selection
		# print options
		echo "Please select a path shortcut:"
		for i in (seq (count $options))
			echo "$options[$i]) $$cacheName[1][$i]"
		end
		read -p 'set_color blue; echo -n "Select>"; set_color normal' -l input
		set selection $input
	end
	
	# find target path
	if test -z $selection
		return 0
	else if set i (contains -i -- $selection $options)
		set target $$cacheName[1][$i]
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
