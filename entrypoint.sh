HOST_IP=$(ifconfig ens5 | grep 'inet ' | xargs | cut -d' ' -f2)

if [ -z $HOST_IP ]; then
    echo "could not retrieve IP address of node"    
fi

THIRD_OCTET=$(echo ${HOST_IP} | cut -d'.' -f 3)
FOURTH_OCTET=$(echo ${HOST_IP} | cut -d'.' -f 4)

INDEX=$((((THIRD_OCTET%16)*256)+FOURTH_OCTET))

STARTING_THIRD_OCTET=${THIRD_OCTET:-240}
THIRD_OCTET=$(((INDEX/256)+STARTING_THIRD_OCTET))
export WG_CLIENTIP=$(printf '172.16.%s.%s/20' ${THIRD_OCTET} ${FOURTH_OCTET})
export WG_PRIVKEY=$(sed -n ${INDEX}p /etc/wireguard-profiles/peers)
echo Private key index ${INDEX} client IP ${WG_CLIENTIP}
envsubst < /etc/wireguard-profiles/wg0.conf.tmpl > /tmp/wg0.conf
wireguard-go wg0
mkdir /etc/wireguard
mv /tmp/wg0.conf /etc/wireguard
sleep 10
wg-quick down wg0
wg-quick up wg0

echo Starting Wireguard on ${WG_CLIENTIP}

while true; do sleep 60; done
