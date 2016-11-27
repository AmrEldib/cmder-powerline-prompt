# Cmder-powerline-prompt

This is a custom prompt for [Cmder](http://cmder.net/) (the alternative console emulator for Windows).  
It looks like this:  
![screenshot](screenshot.png)

It has a blue background for the prompt.  
For folders with git repos, you get yellow background for changes, and green for clean repos.  
I'm using Consolas font.

The look is inspired by [Powerline for Vim](https://github.com/powerline/powerline), and [Zsh's theme agnoster](https://github.com/agnoster/agnoster-zsh-theme).

# Requirements

Download the [AnonymousPro font](https://github.com/powerline/fonts/tree/master/AnonymousPro)  
You'll be able to use any font in Cmder, but this font contains the symbols included in the prompt.  

# Usage

Download the `.lua` file, and place it in `%CMDER_ROOT%/config` folder.  
Restart Cmder to load the prompt.

__Alternatively__, if you want to maintain link with the original repo, you can clone this repo into any folder  
`git clone https://github.com/AmrEldib/cmder-powerline-prompt.git git-repo-folder-name`  
then create a symbolic link from the `%CMDER_ROOT%/config` folder to the `.lua` file.  
```
cd %CMDER_ROOT%/config  
mklink -H cmder-powerline-prompt.lua <git-repo-folder-name>/cmder-powerline-prompt.lua 
```  