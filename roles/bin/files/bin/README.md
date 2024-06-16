# Utils/bin

Will Do

- [ ] clean Up the scripts
  - [ ] QemuInstall
  - [x] setupScript
  - [ ] Download and delete
- [ ] Another script in install to define the directory structure
- [ ] Move icons to utils/dunst/icons (say)
- [ ] In every script, put the constants like iconpath, directorypath etc on the top (make them standard)

---

Download script gets the title of the video being downloaded first, and
once it gets that, it starts downloading it (saving the pid and the title)
of that instance of yt-dlp (if possible would be i guess)

Then it will save that in a cache file somewhere.

If the delete script is ran now, it should show the options on which process to kill
therefore if multiple videos are being downloaded, should be able to delete specifically
or there should be an option all at the end of the dmenu prompt, which says
delete all in case
