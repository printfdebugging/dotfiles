# dotfiles

A programmer  customizes his system by  modifying the configuration files  for the
system and the programs, and over time  crafts a system that he is comfortable and
efficient with. dotfiles describes a collection of such files.

I  manage  my  dotfiles  using  ansible.  Ansible  is  a  really  powerful  system
adminstration  tool which  maintains the  system in  a state  as specified  in the
configuration/files. [LearnLinuxTv's  ansible playlist] is a  really good resource
to learn  how ansible works. [TechDufus's  video] explains really well  how to use
ansible in the context of dotfiles.

[LearnLinuxTv's ansible playlist]: https://youtube.com/playlist?list=PLT98CRl2KxKEUHie1m24-wkyHpEsa4Y70&si=h0LGnnwsCFtm7cvp
[TechDufus's video]: https://www.youtube.com/watch?v=hPPIScBt4Gw

I use `ansible-vault` to encrypt my secrets like SSH keys, gitconfigs etc.
