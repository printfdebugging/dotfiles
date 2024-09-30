<!--toc:start-->
- [Why GNU/Linux and Which Distribution](#why-gnulinux-and-which-distribution)
- [The Text Editor: Neovim Or Emacs](#the-text-editor-neovim-or-emacs)
- [Tiling Window Manager](#tiling-window-manager)
- [Configuration Management](#configuration-management)
  - [GNU Stow](#gnu-stow)
  - [Ansible](#ansible)
- [Sources and Links](#sources-and-links)
<!--toc:end-->

# Why GNU/Linux and Which Distribution

<div align="justify"> 
I use GNU/Linux  BTW.  When I got introducted to  Ubuntu for the first time, I  was surprised on how easy was  it to install/remove packages
from the  command line  unlike windows,  where one has  to go  to the site,  then download  the installer,  run it, and  then they  have the
application. On Ubuntu it was  just `sudo apt install <pacakge-name>`. Another good thing about using  Ubuntu as your first linux distribution
is that  it has a  big community, meaning  that if you  are facing any issue,  then someone else  might have faced  it as well,  and finding
solutions on forums will be relatively easy.
<br>
<br>
I started trying  other distributions because Ubuntu has very  old packages which sometimes breaks  a lot of things. Like once  I was trying
someone's neovim config, and I got a lot of errors because neovim was  very old. I use ARCH now. It's not the best distribution in the world
considering that without AUR, Archlinux is  same as any other distribution, and AUR breaks the system very  often. Today itself I was trying
to install docker-desktop but it errored because some dependency was owned  by some other package. But putting all that aside, it has almost
all the packages (latest) one can think of, and the learning experience cusotmizing Archlinux is very valuable.
<br>
<br>

I tried Void Linux, and I love it. It has very updated packages, and the init system is `runit` which is considered light weight and bloat free.
I have added separate tasks for Void Linux in the `void.yml` files. In the end I could reuse most of my dotfiles, and I didn't have to learn
something like nix which whould have been like going away from the "default linux" way.
</div>

# The Text Editor: Neovim Or Emacs

<div align="justify"> 
A text editor is the tool that developers use to edit sourcecode. As  a developer, taking some time out to know your text editor is the best
investment one can make. There are two choices Neovim or Emacs, and I  am happy with none, and the dissatisfaction is so much that I plan to
write one of my own. I use neovim (primarily) to write code, and I use emacs to take notes, and maintain this site. Neovim is super fast and
when paired with tmux,  it's a fatal solution.  Emacs on the other  hand is very powerful for text editing, but  it's very slow when working
with large files.
<br>
<br>

I struggled to choose between the two for a long time to the point where it started affecting my work.  I stopped thinking about it anymore,
and just decided on what  works for the job. I still believe that If  we don't have an editor as fast as neovim, and  as capable as emacs in
2024, then it's a  shame. These editors are from the 80's and  90's, and things have changed. We have new  scripting languages, more capable
Graphics APIs, and bigger than ever community around FOSS.
</div>

# Tiling Window Manager

<div align="justify"> 
Tiling Window Managers basically  arrange the windows such that maximum space on  the screen is utilized. There are a lot  of them, i3, DWM,
awesomewm, BSPWM. With tiling window managers, you can control most  aspects of your desktop windows with keyboard shortkuts, making it very
efficient, which is questionable considering  how much time one spends hunting and configuring them.  I  don't like desktop environments, as
they are very resource heavy, and mouse driven which makes them slow compared  to tiling ones. Even then if I were to choose, I would prefer
KDE over Gnome.
<br>
<br>

I  have used  all of  the  mentioned tilers  at some  point or  the  other.  I  used DWM  for  the longest  time, and  recently switched  to
awesomewm. Awesome unlike  other tiling window managers  comes with really good  mouse support, builtin topbar/notification  system, and has
titlebars with buttons.  This is how my awesomewm looks like as of writing this blog. Update: After using awesomewm for some time, I am back
to DWM. Now I am of the opinion that DWM's simplicity is something not worth giving up for titlebars and icons.
</div>

# Configuration Management

<div align="justify"> 
This is my  favourite topic, and it's the most  frustrating part of using linux. Now  when you have configured your text  editor, the tiling
window manager, and other programs, you would want to save it. There are a  lot of ways to do so. First one is very simple, just put all the
files/folders in a git repository, and  Done! Now whenever you reinstall the system just clone that repository,  and move the files to their
desired locations.
</div>

## GNU Stow

<div align="justify"> 
Slight upgrade to  this approach would be  to use some shell  scripts to symlink/hardlink/copy the  files to the required  places. There's a
program to just do that,  it's called `GNU stow`. It creates and manages all  the symlinks for you. But I often found it  broken, and I had to
remove the symlinks to  restow the new files. It's a nice upgrade  over symlinking with shell scripts, but it's just  not enough. What about
packages, will it be another shell script? What about private files like ssh keys and .gitconfigs?
</div>

## Ansible

<div align="justify"> 
Ansible is a provisioning tool, which  is used by system adminstrators to manage the state of the systems  they are looking after.  In other
words, you can  specify how you want  the system, and it's  ansible's responsibility to maintain that  state. Make sure that  you learn YAML
before ansible, or else you won't  understand anything. Ansible consists of playbooks, which are a series of  tasks to be performed form top
to bottom, like copy this file to `.config/emacs`, or create a user named `so-and-so`, or install these packages. This is how a task looks like.
It's quite simple  to understand. It says using `community.general.pacman`  modules of ansible, loop over the  specified packages, and install
them (more or less).
</div>
<br>

``` yaml
- name: install emacs packages tags:
    - emacs
    - packages
  community.general.pacman:
    name: "{{ item }}"
    state: latest
    extra_args: "--nodeps --noconfirm --overwrite '#'"
  loop:
    - emacs-nativecomp
    - ttf-iosevka-nerd
```
<br>

<div align="justify"> 
In ansible we  can group tasks like  installing packages and copying  configuration files together into  roles so that tasks  related to one
thing are exected  together.  Ansible has a utility called  `ansilbe-vault`, with which we can  encrypt some file with a password,  and we can
decrypt it back using that password.  This is very helpful when it comes to managing ssh keys or .gitconfigs. This is how my private ssh key
looks in my dotfiles repo. So I don't have to keep it private anymore, and just by knowing the password, I can setup my system.
</div>
<br>

``` yaml
private_ssh_key_file: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  37303736323131396536383363323933663436363335653061343365643832353036383035666665
  3663643136613130343266616462646633653930626434620a393533626166633130643666396336
  38653562666538346434663535333864346639343134396539616261386463663733393063373330
  ...
```

<br>
<div align="justify"> 
I created a  script to automate the  cloning process, and it's available  on this site https://printfdebugging.in/install.sh.  So whenever I
reinstall my system, I run the following command. After installing some  basic packages and ansible, it asks me for the passwords, and after
that it's all on it's own.
</div>
<br>

``` sh
curl -LO https://printfdebugging.in/intall.sh && sh install.sh
```

<br>
<div align="justify"> 
One issue that I faced was that  whenever I make some changes in my `.configs`, I had to manually copy  back the files to the respective roles
directory. This became very annoying, and to solve this issue, I wrote additional tasks, which are tagged as `save, save-$role`, so whenever I
change anything in `.config/emacs` for example,  I just run `dotfiles save-emacs`, and it run's the save-role,  which copies back the files from
the respective .config directory to the role's directory.

<br>
<br>
The dotfiles can be found on my gitlab. Special thanks to [@techdufus](https://www.youtube.com/watch?v=hPPIScBt4Gw).  He was the one to inspire me to move from stow to ansible, by showing
how easy and convinient it is.
</div>


# Sources and Links
1. [dotfiles repository](https://gitlab.com/printfdebugging/dotfiles)
2. [techdufus dotfiles](https://www.youtube.com/watch?v`hPPIScBt4Gw)
