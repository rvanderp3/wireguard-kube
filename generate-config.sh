for i in {1..4095}; do 
PRIV_KEY=$(wg genkey)
export PUB_KEY=$(echo $PRIV_KEY | wg pubkey)
echo $PRIV_KEY >> privkeys

export THIRD_OCTET_START=240
export THIRD_OCTET=$(((i / 256) + THIRD_OCTET_START))
export FOURTH_OCTET=$((i % 256))

export IP="172.16.$THIRD_OCTET.$FOURTH_OCTET/32"; 
envsubst < /tmp/peerpart >> wg0.conf.peers
done