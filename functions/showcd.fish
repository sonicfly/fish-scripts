function showcd --description 'Show current directory path'
	set -l platform (uname)
	set path (pwd)
	echo $path
	if [ (string sub -l 6 $platform) = "CYGWIN" ]
		# go to Windows User Profile directory, if you want to go to Unix home
		# use 'cd ~' explitcitly or just 'cd'
		cygpath -w $path
	end
end
