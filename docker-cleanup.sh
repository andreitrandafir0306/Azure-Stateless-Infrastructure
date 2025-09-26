#!/bin/bash

# -------------------------------------------------------
# Default variables (CLI flags can override them)
# -------------------------------------------------------

AUTO_CONFIRM=${AUTO_CONFIRM:-"false"}
DRY_RUN=${DRY_RUN:-"false"}
LOGFILE=${LOGFILE:-"./logs/docker-cleanup.log"}
REMOVE_CONTAINERS=${REMOVE_CONTAINERS:-false}
REMOVE_IMAGES=${REMOVE_IMAGES:-false}
REMOVE_VOLUMES=${REMOVE_VOLUMES:-false}
REMOVE_NETWORKS=${REMOVE_NETWORKS:-false}
REMOVE_ALL=${REMOVE_ALL:-false}


# ---------
# Functions
# ---------

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
  --status <status>      Remove containers by status (running, paused, exited)
  --images               Remove unused images
  --volumes              Remove unused volumes 
  --networks             Remove unused networks, except defaults
  --dry-run              Show what would be removed
  --log <file>           Log actions to a file
  -y, --yes              Skip confirmation prompt
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

# Confirm action

confirm_action () {
    [[ $AUTO_CONFIRM == true || $DRY_RUN == true ]] && return 0 # return is used to exit functions, exit for exiting the script
    read -p "Are you sure? This process is irreversible! Only acceptable answers are Yes/No" input
    if [[ $input == "Yes" ]]; then return 0
    else echo "Aborting..." && return 1
    fi
}


# Remove everything

remove_all() {
        local ids=($(docker ps -aq))
        if confirm_action "Yes"; then
            if [[ $DRY_RUN == true ]]; then
                echo "DRY RUN: This process removes every container, every image, every unused network and every unused volume. Use it carefully!"
            else
            echo "" && echo "Removing everything standby..." && echo ""
            for id in "${ids[@]}"; do 
                docker rm -f $id
            done
                docker image prune -af && \
                docker network prune -f && \
                docker volume prune -af && \
                echo "" && \
                echo "Done!" && \
                echo ""
            fi
        fi
}

# Remove containers

remove_containers() {
    local ids=($(docker ps -aq))
    [[ ${#ids[@]} -eq 0 ]] && echo "No containers to remove..." && return
    if confirm_action "Yes"; then
        for id in "${ids[@]}"; do 
            if [[ $DRY_RUN == true ]]; then
                echo "DRY RUN: Container $id would be removed"
            else
                docker rm -f $id && log_action "Removed container $id"
            fi
        done
    fi
}

# Remove containers based upon status

remove_containers_status() {
    local status=$1
    local ids=($(docker ps -aq -f status=$status))
    [[ ${#ids[@]} -eq 0 ]] && echo "No containers with the status $status to remove..." && return
    if confirm_action "Yes"; then
        for id in "${ids[@]}"; do 
            if [[ $DRY_RUN == true ]]; then
                echo "DRY RUN: Container $id with the status $status would be removed"
            else
                docker rm -f $id && log_action "Removed container $id with status $status"
            fi
        done
    fi
}


# Remove networks

remove_networks () {
    local ids=($(docker network ls -q))
    [[ ${#ids[@]} -eq 3 ]] && echo "No networks to remove... The three default networks cannot be deleted!" && return
    if confirm_action "Yes"; then
        if [[ $DRY_RUN == true ]]; then
                echo "DRY RUN: Every network not named "bridge", "host" or "none" will be removed because default networks cannot be deleted!"
            else
                for id in "${ids[@]}"; do 
                docker network rm -f 2> /dev/null $id && log_action "Removed network $id"
                done
        fi
    fi
}

# Remove volumes

remove_volumes () {
    local ids=($(docker volume ls -q))
    [[ ${#ids[@]} -eq 0 ]] && echo "No volumes to remove..." && return
    if confirm_action "Yes"; then
        for id in "${ids[@]}"; do 
            if [[ $DRY_RUN == true ]]; then
                echo "DRY RUN: Volume $id would be removed"
            else
                docker volume rm -f $id && log_action "Removed volume $id"
            fi
        done
    fi
}

# Remove images

remove_images () {
    local ids=($(docker images -aq))
    [[ ${#ids[@]} -eq 0 ]] && echo "No images to remove.." && return
    if confirm_action "Yes"; then
        for id in "${ids[@]}"; do
            if [[ $DRY_RUN == true ]]; then
                echo "DRY RUN: Image $id would be removed"
            else
                docker image rm -f $id
            fi
        done
    fi
}

 # Flag configuration with CASE

flag_config() {
    while [[ $# -gt 0 ]]; do
            case $1 in
            --containers) 
            REMOVE_CONTAINERS=true
            shift 
             ;;
            --networks) 
            REMOVE_NETWORKS=true
            shift 
            ;;
            --images)
            REMOVE_IMAGES=true
            shift
            ;;
            --volumes)
            REMOVE_VOLUMES=true
            shift
            ;;
            --dry-run) 
            DRY_RUN=true
            shift 
            ;;
            -y | --yes)
            AUTO_CONFIRM=true
            shift
            ;;
            --all)
            REMOVE_ALL=true
            shift
            ;;
            --status)
            REMOVE_CONTAINERS=true
            STATUS_FILTER=$2
            shift 2
            ;;
            --log)
            echo "Add log file" # To be continued 
            ;;
            *) echo "Unknown option! Please try again!"; exit 1 ;;
            esac
    done
}



# ------------------
# Lists of resources 
# ------------------

# images
[[ $1 == "--li" ]] && echo "Here are your images..." && echo "" && docker images -a && exit 0

# containers
[[ $1 == "--lc" ]] && echo "Here are your containers..." && echo "" &&  docker ps -a && exit 0

# networks
[[ $1 == "--ln" ]] && echo "Here are your networks..." && echo "" &&  docker network ls && exit 0

# volumes
[[ $1 == "--lv" ]] && echo "Here are your volumes..." && echo "" &&  docker volume ls && exit 0

# list everything in desginated file
[[ $1 == "--la" && $2 == * && $2 != "" ]] && echo "The list was redirected to $2" && \
     docker ps -a >> $2 && \
    echo "" >> $2 && \
    docker images -a >> $2 && \
    echo "" >> $2 && \
    docker network ls >> $2 && \
    echo "" >> $2 && \
    docker volume ls >> $2  && \
    echo "" >> $2 && \
    exit 0

# list everything to stdout
[[ $1 == "--la" && $2 == "" ]] && echo "" && \
    docker ps -a && \
    echo "" && \
    docker images -a && \
    echo "" && \
    docker network ls && \
    echo "" && \
    docker volume ls &&\
    exit 0


# ----------------------------------------------------------------------------
# Function execution logic -> they need to run regardless of the param position
# Interactive confirmation prompt feature (with no -y or --yes)
# With -y or --yes the script executes automatically
# ----------------------------------------------------------------------------

flag_config "$@" # PUT AFTER EVERYTHING SO THAT IT WON'T INTERFERE WITH THE LISTS

if [[ $STATUS_FILTER == "exited" || $STATUS_FILTER == "paused" || $STATUS_FILTER == "running" && -n $STATUS_FILTER && $REMOVE_CONTAINERS == true ]]; then
    remove_containers_status $STATUS_FILTER
elif [[ $STATUS_FILTER != "exited" && $STATUS_FILTER != "paused" && $STATUS_FILTER != "running" ]]; then
    echo "Wrong status selected! Please try again!" && exit 1
elif [[ $REMOVE_CONTAINERS == true ]]; then
    remove_containers
fi

[[ $REMOVE_IMAGES == true ]] && remove_images
[[ $REMOVE_VOLUMES == true ]] && remove_volumes
[[ $REMOVE_NETWORKS == true ]] && remove_networks
[[ $REMOVE_ALL == true ]] && remove_all





