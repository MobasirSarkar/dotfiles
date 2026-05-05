#!/usr/bin/env bash
set -Eeuo pipefail

# CONFIG
PROXY="teleport.roadcast.net:443"
USER="Mobasir"
CLUSTER="teleport.roadcast.net"

CHECK_INTERVAL=60 # seconds between health checks

LOG_DIR="${HOME}/.teleport-tunnels"
mkdir -p "$LOG_DIR"

TUNNELS=(
    "revamp_beta|revamp_admin|bolt_revamp_beta_db|6201|bolt-do-revamp-database"
    "revamp_prod|revamp_prod|bolt_revamp_db|6200|bolt-revam-database-prod"
    "mesh_db|boltdbusermesh|bolt_db|5594|bolt-do-mesh-database"
    "postgres_admin|boltadminsuper|bolt_db|6000|bolt-do-postgres-database"
    "timescale_oc|boltvpsadminsuper|boltvps|5592|bolt-timescale-database-oc"
    "track_postgres|trackadminsuper|track_db|6202|track-do-postgres"
    "track_mesh|trackusermesh|track_db|5591|track-do-mesh-database"
    "track_timescale|trackadmingc|boltvps|6203|track-timescale-database"
)

# UTILS
log() {
    echo "[$(date '+%F %T')] $*"
}

require_cmd() {
    command -v "$1" >/dev/null || {
        echo "Missing dependency: $1"
        exit 1
    }
}

port_in_use() {
    ss -ltn | awk '{print $4}' | grep -q ":$1$"
}

session_valid() {
    tsh status >/dev/null 2>&1
}

login() {
    log "Refreshing Teleport session..."

    tsh login \
        --proxy="$PROXY" \
        --auth=local \
        --user="$USER" \
        "$CLUSTER"
}

# VALIDATION
require_cmd tsh
require_cmd ss

# STATE
declare -A PIDS

# CLEANUP
cleanup() {
    log "Stopping tunnels..."

    for pid in "${PIDS[@]:-}"; do
        kill "$pid" 2>/dev/null || true
    done

    wait || true
    log "Shutdown complete."
}

trap cleanup EXIT INT TERM

# START SINGLE TUNNEL
start_tunnel() {

    local name="$1"
    local db_user="$2"
    local db_name="$3"
    local port="$4"
    local tunnel="$5"

    if port_in_use "$port"; then
        log "Port $port busy → skipping $name"
        return
    fi

    local logfile="${LOG_DIR}/${name}.log"

    log "Starting $name"

    tsh proxy db \
        --db-user="$db_user" \
        --db-name="$db_name" \
        --port="$port" \
        --tunnel="$tunnel" \
        >>"$logfile" 2>&1 &

    PIDS["$name"]=$!
}

# ENSURE ALL TUNNELS RUNNING
ensure_tunnels() {

    for entry in "${TUNNELS[@]}"; do

        IFS="|" read -r name db_user db_name port tunnel <<<"$entry"

        pid="${PIDS[$name]:-}"

        if [[ -z "${pid:-}" ]] || ! kill -0 "$pid" 2>/dev/null; then
            log "Restarting tunnel: $name"
            start_tunnel "$name" "$db_user" "$db_name" "$port" "$tunnel"
        fi

    done
}

# MAIN LOOP
log "Teleport tunnel supervisor started"

while true; do

    if ! session_valid; then
        login
    fi

    ensure_tunnels

    sleep "$CHECK_INTERVAL"

done
