## NOTE:
this repository has been archived. this is a really complicated solution for the problem.
i now use a shell script to setup packages and files and all the files exist in a single
git repository, configs with more than one file exist as github repositories. see [dots](https://github.com/printfdebugging/dots.git)

## introduction
+ i use ansible to manage my dotfiles
+ these currently work on void linux
+ in the past i have tried other solutions like shell scripts and gnu stow, but most of them suck.
+ i use `ansible-vault` to encrypt my secrets. everything is in this public repository, at one place.

## action

```bash
fetch https://printfdebugging.in/dotfiles as dotfiles
run dotfiles
```

+ the dotfiles script manages everything, it installs the needed dependencies like ansible, git etc.
+ then once everything is ready, it asks me for the sudo and vault passwords, and that's all!
+ once it's done, i reboot the computer, and i have simple minimal dwm setup ready.
+ it clones my git repositories, sets up ssh keys, config files, everything else that i can think of.

## how
+ learn ansible first, [learnlinuxtv's ansible playlist] is a nice resource.
+ then watch [techdufus's video] demonstrating his dotfiles in action to get more excited.
+ put your dotfiles together bit by bit :).

[learnlinuxtv's ansible playlist]: https://youtube.com/playlist?list=PLT98CRl2KxKEUHie1m24-wkyHpEsa4Y70&si=h0LGnnwsCFtm7cvp
[techdufus's video]: https://www.youtube.com/watch?v=hPPIScBt4Gw

## gotchas
+ don't use relative paths, they don't work. use `/home/{{ ansible_user }}/path` instead.
