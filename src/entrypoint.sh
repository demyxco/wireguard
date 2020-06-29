#!/usr/bin/dumb-init /bin/bash
# Demyx
# https://demyx.sh
set -euo pipefail

# Generate server keys
[[ ! -f "$DEMYX"/server_private && ! -f "$DEMYX"/server_public ]] && wg genkey | tee "$DEMYX"/server_private | wg pubkey > "$DEMYX"/server_public

# Remove existing peer file
[[ -f "$DEMYX"/peer ]] && rm "$DEMYX"/peer

# Generate peer keys and peer file
DEMYX_PEER_ADDRESS_1="$(echo "$DEMYX_ADDRESS" | awk -F '[.]' '{print $1}')"
DEMYX_PEER_ADDRESS_2="$(echo "$DEMYX_ADDRESS" | awk -F '[.]' '{print $2}')"
DEMYX_PEER_ADDRESS_3="$(echo "$DEMYX_ADDRESS" | awk -F '[.]' '{print $3}')"
DEMYX_PEER_ADDRESS_4="$(echo "$DEMYX_ADDRESS" | awk -F '[.]' '{print $4}')"
for ((i=1; i<=DEMYX_PEER; i++))
do
    [[ ! -f "$DEMYX"/peer_"$i"_private && ! -f "$DEMYX"/peer_"$i"_public ]] && wg genkey | tee "$DEMYX"/peer_"$i"_private | wg pubkey > "$DEMYX"/peer_"$i"_public
    echo -e "[Peer]\nPublicKey = $(cat ${DEMYX}/peer_${i}_public)\nAllowedIPs = ${DEMYX_PEER_ADDRESS_1}.${DEMYX_PEER_ADDRESS_2}.${DEMYX_PEER_ADDRESS_3}.$(( $DEMYX_PEER_ADDRESS_4 + $i ))\n" >> "$DEMYX"/peer
done

# Generate interface config
echo "[Interface] 
Address = $DEMYX_ADDRESS
ListenPort = $DEMYX_PORT
PrivateKey = $(cat ${DEMYX}/server_private)
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -t nat -A POSTROUTING -o $DEMYX_INTERFACE -j MASQUERADE; iptables -A FORWARD -o %i -j ACCEPT 
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -t nat -D POSTROUTING -o $DEMYX_INTERFACE -j MASQUERADE; iptables -D FORWARD -o %i -j ACCEPT 

$(cat ${DEMYX}/peer)" > /etc/wireguard/wg0.conf

# Set permissions
chmod 600 "$DEMYX"/*
chown -R root:root /etc/wireguard
chmod 600 /etc/wireguard/wg0.conf

# Bring up the interface
wg-quick up wg0

# Output wg and commands to user
echo 
demyx-wg
echo 
echo "[INFO] To output keys from host: docker exec -it <wireguard_container> demyx-wg keys"
echo "[INFO] To output keys from container: demyx-wg keys"
echo

# Keep container alive
crond -f
