#!/bin/bash

# ------------------------------------------------
# Default variables (CLI flags / config can override them)
# ------------------------------------------------

AUTO_CONFIRM=${AUTO_CONFIRM:-false}
DRY_RUN=${DRY_RUN:-false}
LOGFILE=${LOGFILE:-"./logs/docker-cleaner.log"}

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
  --all                  Remove ALL containers, networks, images or volumes
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

