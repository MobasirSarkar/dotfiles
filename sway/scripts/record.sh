#!/usr/bin/env sh

# Record Screen Script.

set -e  # Exit immediately if any command fails

############
## COLORS ##
############
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

##################
## LOG FUNCTION ##
##################
log_info()    { printf "${BLUE}[INFO]${RESET} %s\n" "$1"; }
log_warning() { printf "${YELLOW}[WARNING]${RESET} %s\n" "$1"; }
log_error()   { printf "${RED}[ERROR]${RESET} %s\n" "$1"; }
log_success() { printf "${GREEN}[SUCCESS]${RESET} %s\n" "$1"; }

###############
## MAIN LOGIC #
###############

DEFAULT_OUTPUT="$HOME/Videos/recording_$(date +'%Y-%m-%d_%H-%M-%S').mkv"

log_info "Specify the output file (Press Enter for default: $DEFAULT_OUTPUT): "
read -r OUTPUT
OUTPUT=${OUTPUT:-$DEFAULT_OUTPUT}

# Trap before running wf-recorder
trap 'log_success "Recording stopped. File saved as $OUTPUT"; exit' INT

log_info "Starting recording... Press Ctrl+C to stop."
wf-recorder -a -f "$OUTPUT"
