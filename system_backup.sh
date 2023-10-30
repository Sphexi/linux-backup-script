#!/bin/bash

# Small system backup script v1.0 - 2023/10/29

# Script will run weekly at 0200 Sunday and do a backup of the specified partition to a remote NFS share
# by gzipping everything up, and maintain up to x backup files before deleting any.

# Edit the variables below with the folders and partition information, and make sure your remote NFS server
# allows connections from this client.

# Set variables
backup_dir="<localMountedFolder>" # Replace with the local folder to mount the NFS share into
nfs_server="192.168.1.29"
nfs_share="<remoteNFSFolder>" # Replace with the NFS folder to put the backup files into
partition="/dev/sdX"  # Replace with the correct partition device
backup_limit=5 # How many backup files before deleting old ones
hostname=$(hostname)
current_date=$(date "+%Y-%m-%d")
backup_file="$hostname-$current_date-$(basename $partition).gz"

# Function to clean up old backups
cleanup_backups() {
  existing_backups=($(ls -1 $backup_dir/$hostname-*.gz | sort))
  num_backups=${#existing_backups[@]}
  
  if [ $num_backups -gt $backup_limit ]; then
    num_to_delete=$((num_backups - backup_limit))
    
    for ((i=0; i<num_to_delete; i++)); do
      rm "${existing_backups[$i]}"
    done
  fi
}

# Function to create a backup
create_backup() {
  dd if=$partition bs=1M | gzip -c > "$backup_dir/$backup_file"
}

# Check if the NFS share is mounted, and mount it if not
if ! mount | grep -q "$backup_dir"; then
  if [ ! -d "$backup_dir" ]; then # Check if the local mount point exists, create it if not
    mkdir -p "$backup_dir"
  fi
  mount -t nfs $nfs_server:$nfs_share $backup_dir
fi

# Check if a cron job is scheduled
if ! crontab -l | grep -q "$0"; then
  # If not, schedule the script as a weekly cron job
  (crontab -l; echo "0 2 * * 0 $PWD/$0") | crontab -
fi

# Perform the backup
if mount | grep -q "$backup_dir"; then # Only do the backup if the mount worked
  create_backup
fi

# Clean up old backups
cleanup_backups