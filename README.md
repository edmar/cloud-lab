# cloud-lab

## Starts instance and log into it when it's ready

$ lab start

## Create a ssh tunnel on that port

$ lab tunnel 8888

## Stop instance

$ lab stop

## Show instance status

$ lab status

## SSH into instance

$ lab login

## Download file from instance

$ lab download  /machine-file-path  /path-where-to-save-file

## Upload file to instance

$ lab upload /local-file-path /machine-path-to-save-file

## Change instance type

The machine needs to be stopped before changing instance type

$ lab update instance_type_name
