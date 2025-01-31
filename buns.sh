#!/bin/bash

## 202501311503
# This script performs backups of specified directories from multiple servers.
# It reads configuration parameters from buns.json, creates backups using rsync,
# logs the backup operations, and manages retention of old backups.

# Load parameters from buns.json
config_backup_target_root=$(jq -r '.backup_target_root' buns.json)
config_private_key=$(jq -r '.private_key' buns.json)
config_group=$(jq -r '.group' buns.json)
config_retention_limit=$(jq -r '.retention_limit' buns.json)
config_name_servers=($(jq -r '.name_servers[]' buns.json))
config_backup_directories=($(jq -r '.backup_directories[]' buns.json))
log_file="${config_backup_target_root}/buns.log"

# Create backup target root directory if it doesn't exist
mkdir -p "${config_backup_target_root}"

# Function to create backup
create_backup() {
    local server=$1
    local timestamp=$(date +"%Y%m%d%H%M%S")
    local backup_dir="${config_backup_target_root}/name_servers/$server/$timestamp"
    local ssh_options="-i ${config_private_key} -o StrictHostKeyChecking=no"

    # Create backup directory
    mkdir -p "$backup_dir/etc"
    mkdir -p "$backup_dir/var/cache"

    # Backup directories using rsync
    for dir in "${config_backup_directories[@]}"; do
        rsync -avax --progress --delete -e "ssh $ssh_options" root@$server:$dir "$backup_dir/$dir"
    done

    # Log the backup
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Backup of $server completed and saved to $backup_dir" >> ${log_file}

    # Manage retention
    manage_retention "$server"

    # Set permissions and ownership after backup and retention management
    find "${config_backup_target_root}" -type d -exec chmod 775 {} \;
    find "${config_backup_target_root}" -type f -exec chmod 664 {} \;
    chown -R ${config_user}:${config_group} "${config_backup_target_root}"
}

# Function to manage retention
manage_retention() {
    local server=$1
    local backup_root="${config_backup_target_root}/name_servers/$server"
    local backups=($(ls -dt ${backup_root}/*))

    while [ ${#backups[@]} -gt ${config_retention_limit} ]; do
        local oldest_backup=${backups[-1]}
        rm -rf "$oldest_backup"
        backups=("${backups[@]:0:${#backups[@]}-1}")
    done

    # Log retention management
    echo "$(date +"%Y-%m-%d %H:%M:%S") - Retention management for $server completed. Kept ${#backups[@]} backups." >> ${log_file}
}

# Main script
for server in "${config_name_servers[@]}"; do
    create_backup "$server"
done
