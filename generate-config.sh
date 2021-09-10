for i in {1..253}; do 
PRIV_KEY=$(wg genkey)
export PUB_KEY=$(echo $PRIV_KEY | wg pubkey)
echo $PRIV_KEY >> privkeys
export IP="172.16.2.$i/32"; 
envsubst < peer.conf.tmpl >> wireguard.conf.peers
done