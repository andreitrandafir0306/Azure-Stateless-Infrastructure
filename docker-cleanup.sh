#!/bin/bash

# ------------------------------------------------
# Default variables (CLI flags / config can override them)
# ------------------------------------------------

AUTO_CONFIRM=${AUTO_CONFIRM:-"false"}
DRY_RUN=${DRY_RUN:-"false"}
LOGFILE=${LOGFILE:-"./logs/docker-cleaner.log"}
remove_containers=${remove_containers:-"false"}
remove_images=${remove_images:-"false"}
remove_volumes=${remove_volumes:-"false"}
remove_networks=${remove_networks:-"false"}
remove_all=${remove_all:-"false"}


# Load config file if available

CONFIG_FILE="~/.docker-cleanup.conf"
[[ -f $CONFIG_FILE ]] && source $CONFIG_FILE

# ------------------------------------------------
# Functions
# ------------------------------------------------

# EMPTY PARAMS

empty_param() {
    cat <<EOF

This script is used to clean up docker images, containers, networks and volumes.
It also has logging for debugging or other isuses.
If you need further assistance, use -h or --help.

EOF
}

# HELP

show_help() {
    cat <<EOF
Usage: $0 [OPTIONS]

Options:
  --lc                   Show all containers
  --lv                   Show all volumes
  --ln                   Show all networks
  --li                   Show all images
  --la <file>            Show all containers, volumes, networks & images in a file of your choice
  --containers           Remove all containers
  --all                  Remove all containers, networks, volumes and images
  --status <status>      Remove containers by status (running, exited, paused, stopped)
  --images [dangling]    Remove images (default: dangling only)
  --volumes [dangling]   Remove volumes (default: dangling only)
  --networks [dangling]  Remove networks (default: dangling only)
  --dry-run              Show what would be removed
  --log <file>           Log actions to a file
  -y, --yes              Skip confirmation prompts
  -h, --help             Show this help message
EOF
}


# Log action


log_action() {
    local msg="$1"
    echo "$(date '+%F %T') - $msg" | tee -a "$LOGFILE"
}

[[ "$#" == 0 ]] && empty_param && exit 0
[[ "$1" == "--help" || "$1" == "-h" ]] && show_help && exit 0


# Remove everything after warning user

remove_all() {
    echo "Cleaning up docker images, standby ..."
    sudo docker images prune -af
}

# Remove containers

remove_containers() {
    echo ""
    echo "Do you wish to remove all containers, just a container or multiple containers, but not all of them? Please type your answer below:"
    read user_input
    if [[ $user_input == "all" || $user_input == "All" || $user_input == "ALL" ]]
    local ids=($(docker ps -aq))
    for id in "${ids[@]}"; do 
        if [[ $DRY_RUN == true ]]; then
            echo "DRY RUN: Container $id would be removed"
        else
            docker rm -f $id && log_action "Removed container $id"
        fi
    done
}

# Remove networks

remove_networks () {
    echo "Removing networks, standby ..."
}

# Remove volumes

remove_volumes () {
    echo "Removing volumes, standby ..."
}

# Remove images

remove_images () {
    read -p "Do you wish to remove all images, just an image or multiple images, but not all of them? Please type your answer below." user_input
    local ids=($(docker images -aq))
    for id in "${ids[@]}"; do
        if [[ $DRY_RUN == true ]]; then
            echo "DRY RUN: Image $id would be removed"
        else
            docker image rm -f $id
        fi
    done
}

 # Flag configuration with CASE

flag_config() {
    while [[ $# -gt 0 ]]; do
        for arg in "$@"; do
            case $arg in
            --containers) remove_containers=true; shift ;;
            --networks) remove_networks=true; shift ;;
            --images) remove_images=true; shift;;
            --dry-run) DRY_RUN=true; shift ;;
            *) echo "Unknown option: $1! Please try again!"; exit 1 ;;
            esac
        done
    done
}
    

# ------------------------------------------------
# Lists
# ------------------------------------------------


[[ $1 == "--li" ]] && echo "Here are your images..." && echo "" && sudo docker images -a && exit 0
[[ $1 == "--lc" ]] && echo "Here are your containers..." && echo "" && sudo docker ps -a && exit 0
[[ $1 == "--ln" ]] && echo "Here are your networks..." && echo "" && sudo docker network ls && exit 0
[[ $1 == "--lv" ]] && echo "Here are your volumes..." && echo "" && sudo docker volume ls && exit 0
[[ $1 == "--la" && $2 == * && $2 != "" ]] && sudo docker ps -a >> $2 && sudo docker images -a >> $2 && sudo docker network ls >> $2 && sudo docker volume ls >> $2  && exit 0
[[ $1 == "--la" && $2 == "" ]] && echo "" && sudo docker ps -a && echo "" && sudo docker images -a && echo "" && sudo docker network ls && echo "" && sudo docker volume ls  && exit 0


flag_config "$@"


# ------------------------------------------------
# Function execution logic -> it needs to run regardless of the param position
# ------------------------------------------------

[[ $remove_containers == true ]] && remove_containers
[[ $remove_images == true ]] && remove_images

