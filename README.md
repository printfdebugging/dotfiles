## About my dotfiles
+ I use ansible to manage my dotfiles
+ I use void linux, so my dotfiles only work on void linux.
+ In the past I have tried other solutions like shell scripts and GNU stow, but most of them suck.
+ I use `ansible-vault` to encrypt my secrets. Everything is in this public repository, at one place.

## How I setup my environment

```bash
curl -LO https://raw.githubusercontent.com/printfdebugging/dotfiles/refs/heads/main/dotfiles
bash dotfiles
```

+ The dotfiles script manages everything, it installs the needed dependencies like ansible, git etc.
+ Then once everything is ready, it asks me for the sudo and vault passwords, and that's all!
+ Once it's done, I reboot the computer, and I have simple minimal dwm setup ready.
+ It clones my git repositories, sets up ssh keys, config files, everything else that I can think of.

## How to get started
+ Learn ansible first, [LearnLinuxTv's ansible playlist] is a nice resource.
+ Then watch [TechDufus's video] demonstrating his dotfiles in action to get more excited.
+ Put your dotfiles together bit by bit :).

[LearnLinuxTv's ansible playlist]: https://youtube.com/playlist?list=PLT98CRl2KxKEUHie1m24-wkyHpEsa4Y70&si=h0LGnnwsCFtm7cvp
[TechDufus's video]: https://www.youtube.com/watch?v=hPPIScBt4Gw
