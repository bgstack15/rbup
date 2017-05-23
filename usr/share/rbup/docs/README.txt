File: usr/share/rbup/docs/README.txt
Package: rbup
Author: bgstack15
Startdate: 2017-05-21
Title: Readme file for rbup
Purpose: All packages should come with a readme
Usage: Read it.
Reference: README.txt
Improve:
Document: Below this line

### WELCOME
Please read /etc/rbup/rbup.conf to learn how to configure rbup.

### NOTES

### REFERENCE

### CHANGELOG

2017-05-21 B Stack <bgstack15@gmail.com> 0.0-1
- Initial rpm release.

2017-05-22 B Stack <bgstack15@gmail.com> 0.0-2
- Added RBUP_MOUNT_POINT to ensure it has been mounted before running sync. This check allows a concrete check before running the sync instead of relying on just the return code of whatever RBUP_DEST_MOUNT_CMD
- Added cronjob for rbup-storage1.
