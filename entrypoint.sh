HOST_IP=$(ifconfig ens5 | grep 'inet ' | xargs | cut -d' ' -f2)

if [ -z $HOST_IP ]; then
    echo "could not retrieve IP address of node"    
fi

THIRD_OCTET=$(echo ${HOST_IP} | cut -d'.' -f 3)
FOURTH_OCTET=$(echo ${HOST_IP} | cut -d'.' -f 4)

INDEX=$((((THIRD_OCTET%16)*256)+FOURTH_OCTET))
if [ -z ${WG_INTERFACE} ]; then
    echo "WG_INTERFACE must be defined!"
fi
STARTING_THIRD_OCTET=${THIRD_OCTET:-240}
THIRD_OCTET=$(((INDEX/256)+STARTING_THIRD_OCTET))
export WG_CLIENTIP=$(printf '172.16.%s.%s/20' ${THIRD_OCTET} ${FOURTH_OCTET})
export WG_PRIVKEY=$(sed -n ${INDEX}p /etc/wireguard-profiles/peers)
echo Private key index ${INDEX} client IP ${WG_CLIENTIP}
envsubst < /etc/wireguard-profiles/wg0.conf.tmpl > /tmp/${WG_INTERFACE}.conf
wireguard-go ${WG_INTERFACE}
mkdir /etc/wireguard
mv /tmp/${WG_INTERFACE}.conf /etc/wireguard
sleep 10
wg-quick down ${WG_INTERFACE}
wg-quick up ${WG_INTERFACE}

echo Starting Wireguard on ${WG_CLIENTIP}

while true; do sleep 60; done
