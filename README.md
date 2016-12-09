# fish-scripts

Some fish function scripts I am using personally.

## Content
Including commands:
* __,__ - _ls -lphG_
* __,,__ - _ls -alphG_
* __fish\_prompt__ - _Very simple fish prompt_
* __cdnow__ - _Interactive **cd** command for predefined shortcut paths_
* __cdmk__ - _Interactive **cd** command for marked paths_
* __mkcd__ - _A shortcut command to mark current path_

### cdnow ###
This command shows a list of predefined shorcut paths for you to select, or you can directly pass shortcut in commandline for quick switch.
Use **cdnow -e** to edit the config file to add predefined shortcut path as you need.

Normally, I add current project root path to config file to quickly jump to project I am working on.

__Note:__ Using this command will save config on ~/.config/zqcd/ folder, and create $ZQCD_cdnow global variable.

### cdmk ###
This command can 'mark' a path, then you can quick jump back to marked paths using shortcut or select the shortcut in interactive mode.
Use **mkcd** or **cdmk -a** to mark current path.

You can also use $cdmk[_index_] to reference the marked path in command line.

Normally, I use it to switch back and forth among several related paths for copying or comparison.

__Note:__ Using this command will save config on ~/.config/zqcd/ folder, and create $CDMK global variable (variable name can be changed).

## Installation
Put all files into __~/.config/fish/__ folder or add this ./functions folder location to __$fish\_function\_path__ environment variable.

## Composer
Sonicfly, a.k.a Zkk

## License
Project is published under FreeBSD license.
