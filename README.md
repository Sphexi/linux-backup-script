# Simple Linux Backup Script

I have a number of small one-off systems running on some form of SoC (ie Pi) or other random hardware and needed a way to do periodic backups of them.  These are non-critical systems and I just wanted a way to automate backups in case I needed to rebuild them in the future, this was the result.

I have a NFS share on a NAS, and I wanted to run a scheduled backup once a week and have a couple of checks:
- Is the NFS share mounted?
- Is the local mount point created?
- Is there a cron job for this script?
- Are there more than x existing backup files with the hostname of this machine as a prefix in the NFS share?

Each of these checks results in something happening, to the point where you can can run this once initially, as long as it can access the NFS share it should do it's job, and it'll schedule the cron job for future backups.  You can change the variables at the top of the script for the folders and NFS server information, limit on how many backup files you want (default of 5), and the partition that you want backed up.

If you want to change the cron schedule that's further down in the script, set it to whatever you want.
