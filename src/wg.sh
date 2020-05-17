#!/bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

DEMYX_WG="${1:-}"

if [[ "$DEMYX_WG" = keys ]]; then
    echo "Server Private: $(cat ${DEMYX}/server_private)"
    echo "Server Public: $(cat ${DEMYX}/server_public)"

    for ((i=1; i<=DEMYX_PEER; i++))
    do
        echo "Peer $i Private: $(cat ${DEMYX}/peer_${i}_private)"
        echo "Peer $i Public: $(cat ${DEMYX}/peer_${i}_public)"
    done
else
    wg
fi
