#!/bin/bash

wd=$(dirname "$0")
proxy=$1

# variables
bold=`tput bold`
red=`tput bold; tput setaf 1`
green=`tput bold; tput setaf 2`
yellow=`tput bold; tput setaf 3`
normal=`tput sgr0`

# server configs: "SHORT_NAME PORT ADDR BIND_PORT USER [PASSWORD]"
# _#_ in password will be replaced by white space
CONFIGS=(
    "SRV0 22 srv0.domain.com port0 user passw"
    "SRV1 22 srv1.domain.com port1 user passw"
    "SRV2 22 srv2.domain.com port2 user passw"
)

# length
CONFIG_LENGTH=${#CONFIGS[@]}

# login menu
function LoginMenu() {

    if [ "${proxy}X" == "proxyX" ]
    then
        content="ID,SHORT NAME,USER,ADDRESS,BIND_PORT"
        for (( i = 0; i < ${CONFIG_LENGTH}; i++ ))
        do
            # config for one cluster
            CONFIG=(${CONFIGS[$i]})
            serverNum=$(( $i + 1 ))
            content="${content}\n${serverNum},${CONFIG[0]},${CONFIG[4]},${CONFIG[2]},${CONFIG[3]}"
        done
    else
        content="ID,SHORT NAME,USER,ADDRESS"
        for (( i = 0; i < ${CONFIG_LENGTH}; i++ ))
        do
            # config for one cluster
            CONFIG=(${CONFIGS[$i]})
            serverNum=$(( $i + 1 ))
            content="${content}\n${serverNum},${CONFIG[0]},${CONFIG[4]},${CONFIG[2]}"
        done
    fi
    echo -e $bold
    python $wd/asciicells.py -H -c "$(echo -e ${content})"
    echo -e $normal
    echo -e "${green}TO LOGIN CLUSTER ID: [1-${CONFIG_LENGTH}] ${normal}"
}

# choose server
function ChooseServer() {

    read serverNum
    if [[ $serverNum -lt 1 ]] || [[ $serverNum -gt $CONFIG_LENGTH ]]
    then
        echo -e "${red}CLUSTER ID SHOULD BE IN RANGE [1-$CONFIG_LENGTH]${normal}"
        echo -e "${green}TO LOGIN CLUSTER ID: ${normal}"
        ChooseServer
        return
    fi

    AutoLogin $serverNum
}

# auto login
function AutoLogin(){

    num=$(( $1 - 1 ))
    CONFIG=(${CONFIGS[$num]})
    pwd=$(sed "s/_#_/ /g" <<< "${CONFIG[5]}")
    echo -e "${yellow}Logging in ${CONFIG[0]}...${normal}"
    if [ "${proxy}X" == "proxyX" ]
    then
    expect -c "
        spawn ssh -p ${CONFIG[1]} ${CONFIG[4]}@${CONFIG[2]} -D ${CONFIG[3]}
        expect {
            \"*assword\" {set timeout 6000; send \"${pwd}\n\"; exp_continue ; sleep 3; }
            \"yes/no\" {send \"yes\n\"; exp_continue;}
            \"Last*\" {  send_user \"\nLogin ${CONFIG[0]} successfully\n\";}
        }

    interact"
    else
    expect -c "
        spawn ssh -p ${CONFIG[1]} ${CONFIG[4]}@${CONFIG[2]}
        expect {
            \"*assword\" {set timeout 6000; send \"${pwd}\n\"; exp_continue ; sleep 3; }
            \"yes/no\" {send \"yes\n\"; exp_continue;}
            \"Last*\" {  send_user \"\nLogin ${CONFIG[0]} successfully\n\";}
        }

    interact"
    fi
    echo -e "${yellow}Exit ${CONFIG[0]}${normal}"
}

LoginMenu
ChooseServer
