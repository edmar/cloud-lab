# cloud-lab

## Setup

### 1. Edit the file cloud-lab.sh and change: 

ec2_id="your-instanc-eid"

key_pem="path-to-your-instance-key-pem"

### 2. Make script executable

> $ chmod +x cloud-lab/cloud-labh.sh

### Optional: Add script to path

Modify your path to add the directory where your script is located:

export PATH=$PATH:/appropriate/directory

(typically, you want $HOME/bin for storing your own scripts)

### Optional: Create alias to script
Add to your .bashrc or .zhsrc

alias cloud-lab="lab.sh"

## Usage

### Starts instance and log into it when it's ready

> $ lab start

### Create a ssh tunnel on that port

> $ lab tunnel 8888

### Stop instance

> $ lab stop

### Show instance status

> $ lab status

### SSH into instance

> $ lab login

### Download file from instance

> $ lab download  /machine-file-path  /path-where-to-save-file

### Upload file to instance

> $ lab upload /local-file-path /machine-path-to-save-file

### Change instance type

The machine needs to be stopped before changing instance type

> $ lab update instance_type_name
