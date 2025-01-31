# Backup Name Servers (Buns) Backup Script
#
# 20250131 by Pewejekubam

## Overview

This project contains a Bash script (`buns.sh`) that performs backups of name server configurations and manages the retention of those backups. The script reads configuration parameters from a YAML file (`buns.yaml`).

In all practicality, this script can be used to backup any linux host to the local host, but it's genesis was the need to backup name servers from several remote third-party locations and keep the configs and zone files local for security and recovery reasons.

File system created by the script below the specified root:
```text
/backup_operation_root
├── name_servers
│   ├── example-ns1.example.com
│   │   ├── 202501311503
│   │   │   ├── etc
│   │   │   │   └── bind
│   │   │   └── var
│   │   │       └── cache
│   │   │           └── bind
│   ├── example-ns2.example.com
│   │   ├── 202501311503
│   │   │   ├── etc
│   │   │   │   └── bind
│   │   │   └── var
│   │   │       └── cache
│   │   │           └── bind
│   ├── example-ns3.example.com
│   │   ├── 202501311503
│   │   │   ├── etc
│   │   │   │   └── bind
│   │   │   └── var
│   │   │       └── cache
│   │   │           └── bind
│   └── example-ns4.example.com
│       ├── 202501311503
│       │   ├── etc
│       │   │   └── bind
│       │   └── var
│       │       └── cache
│       │           └── bind
└── buns.log
```

## Configuration

The `buns.json` file contains the following configuration parameters:

```json
{
  "name_servers": [
    "example-ns1.example.com",
    "example-ns2.example.com",
    "example-ns3.example.com",
    "example-ns4.example.com"
  ],
  "backup_directories": [
    "/etc/bind",
    "/var/cache/bind"
  ],
  "retention_limit": 20,
  "private_key": "/home/example/.ssh/id_example_key",
  "backup_operation_root": "/example/backup/root",
  "user": "example_user",
  "group": "example_group"
}
```

- `name_servers`: List of name servers to back up.
- `backup_directories`: List of directories to back up from each server.
- `retention_limit`: Maximum number of backups to retain.
- `private_key`: Path to the SSH private key for connecting to the servers.
- `backup_operation_root`: Root directory where the script will create the log file and backup files.
- `user`: User to set as the owner of the backup files.
- `group`: Group to set as the owner of the backup files.

## Usage

1. Ensure that `jq` is installed on your system. You can install it using the following command:
    ```bash
    sudo apt-get install jq
    ```

2. Make sure the `buns.sh` script is executable:
    ```bash
    chmod +x buns.sh
    ```

3. Run the script:
    ```bash
    ./buns.sh
    ```


## License

This project is licensed under the MIT License.