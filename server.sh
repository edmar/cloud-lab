#!/bin/zsh

# Configuration Variables

ec2_id="i-05395d6174e31f424"
key_pem="~/.ssh/lab.pem"

close_tunnel() {
    ps aux | grep "ssh -i $key_pem -N -f -L" | grep 8889 | awk "{print \$2}" | xargs kill
}

check_status() {
    state=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].State')
    if [[ $state == *"running"* ]]; then 
        echo "running" 
    fi 
}

describe() {

aws ec2 describe-instances \
--instance-ids  $ec2_id \
--query "Reservations[*].Instances[*].{PublicIP:PublicIpAddress,Name:Tags[?Key=='Name']|[0].Value,Status:State.Name,InstanceID:InstanceId,Instancetype:InstanceType}"  \
--output table

}

connect() {
    elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
    echo -e "Connecting to IP: $elastic_ip" 
    ssh -i $key_pem -o 'ConnectionAttempts 5'  ubuntu@$elastic_ip
}

notebook() {
    elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
    echo -e "Start Jupyter Notebook on IP: $elastic_ip" 
    ssh -i $key_pem -o 'ConnectionAttempts 5' ubuntu@$elastic_ip jupyter lab --no-browser --port=8889 & 
}

upload() {
   elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
   scp -i $key_pem $1 ubuntu@$elastic_ip:$2
}

download() {
   elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
   scp -i $key_pem ubuntu@$elastic_ip:$1 $2
}

start(){
    echo -e "Starting instance: $ec2_id"
    aws ec2 start-instances --instance-ids $ec2_id | cat
}

tunnel(){
    elastic_ip=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].PublicIpAddress' | cut -d'"' -f2)
    echo -e "\nCreating SSH tunnel to IP: $elastic_ip" 
    until ssh -i $key_pem -N -f -L ${1}:localhost:$1 ubuntu@$elastic_ip; do
        sleep 1
        echo "Trying again..."
        close_tunnel
        ssh -i $key_pem -N -f -L ${1}:localhost:$1 ubuntu@$elastic_ip
    done
}

login() {
    while true; do
        state=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].State')
        if [[ $state == *"running"* ]]; then 
            sleep 1
            connect
            break 
        fi        
        sleep 1
        echo -n '.'
    done
}

server() {
    while true; do
        state=$(aws ec2 describe-instances --instance-ids $ec2_id --query 'Reservations[0].Instances[0].State')
        if [[ $state == *"running"* ]]; then 
            sleep 2
            tunnel 8889
            notebook
            break 
        fi        
        sleep 1
        echo -n '.'
    done
}

update() {
    $(aws ec2 modify-instance-attribute --instance-id $ec2_id --instance-type "{\"Value\": \"$instance_type\"}")
}

if [ $1 = "start" ]
then
    start
    login
fi

if [ $1 = "connect" ]
then 
   connect 
fi

if [ $1 = "jupyter" ]
then 
   start
   server 
fi

if [ $1 = "tunnel" ]
then
    close_tunnel $2
    tunnel $2 
fi

if [ $1 = "cloase-tunnel" ]
then
    close_tunnel $2
fi

if [ $1 = "upload" ]
then 
    upload $2 $3 
fi

if [ $1 = "download" ]
then 
    download $2 $3 
fi

if [ $1 = "stop" ]
then 
    echo -e "Stopping instance: $ec2_id"
    aws ec2 stop-instances --instance-ids $ec2_id | cat
fi

if [ $1 = "status" ]
then 
   describe 
fi

if [ $1 = "update" ]
then 
   instance_type=$2
   update
fi
