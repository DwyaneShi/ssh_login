#!/bin/bash

wd=$(dirname "$0")

# variables
bold=`tput bold`
red=`tput bold; tput setaf 1`
green=`tput bold; tput setaf 2`
yellow=`tput bold; tput setaf 3`
normal=`tput sgr0`

# server configs: "SHORT_NAME PORT ADDR USER [PASSWORD]"
CONFIGS=(
    "SRV0 22 srv0.domain.com user passw"
    "SRV1 22 srv1.domain.com user passw"
    "SRV2 22 srv2.domain.com user passw"
)

# length
CONFIG_LENGTH=${#CONFIGS[@]}

# login menu
function LoginMenu() {

    content="ID,SHORT NAME,USER,ADDRESS"
    for (( i = 0; i < ${CONFIG_LENGTH}; i++ ))
    do
        # config for one cluster
        CONFIG=(${CONFIGS[$i]})
        serverNum=$(( $i + 1 ))
        content="${content}\n${serverNum},${CONFIG[0]},${CONFIG[3]},${CONFIG[2]}"
    done
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
    echo -e "${yellow}Logging in ${CONFIG[0]}...${normal}"
    expect -c "
        spawn ssh -p ${CONFIG[1]} ${CONFIG[3]}@${CONFIG[2]}
        expect {
            \"*assword\" {set timeout 6000; send \"${CONFIG[4]}\n\"; exp_continue ; sleep 3; }
            \"yes/no\" {send \"yes\n\"; exp_continue;}
            \"Last*\" {  send_user \"\nLogin ${CONFIG[0]} successfully\n\";}
        }

   interact"
   echo -e "${yellow}Exit ${CONFIG[0]}${normal}"

}

LoginMenu
ChooseServer
