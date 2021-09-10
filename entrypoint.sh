HOST_IP=$(ifconfig ens5 | grep 'inet ' | xargs | cut -d' ' -f2)

if [ -z $HOST_IP ]; then
    echo "could not retrieve IP address of node"    
fi

LAST_OCTET=$(echo ${HOST_IP} | cut -d'.' -f 4)

export WG_CLIENTIP=$(printf '172.16.2.%s/20' ${LAST_OCTET})
export WG_PRIVKEY=$(sed -n ${LAST_OCTET}p /etc/wireguard-profiles/peers)
envsubst < /etc/wireguard-profiles/wg0.conf.tmpl > /tmp/wg0.conf
wireguard-go wg0
mkdir /etc/wireguard
mv /tmp/wg0.conf /etc/wireguard
sleep 10
wg-quick down wg0
wg-quick up wg0

echo Starting Wireguard on ${WG_CLIENTIP}

while true; do sleep 60; done
