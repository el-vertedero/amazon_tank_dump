#!/system/bin/sh
P2PIPADDRESS=$(getprop ftv.p2p.server.addr)
REG_ENDPOINT_FILE_NAME=/system/etc/ffs_endpoint_host_names.csv
DNSMASQ_FILE_NAME=/data/ftv_p2p/dnsmasq.conf


read_hosts () {
     local IFS=,
     read KEY HOST_NAME
}

if [[ $P2PIPADDRESS = "" ]]
then
     P2PIPADDRESS="192.168.49.1"
fi
echo $P2PIPADDRESS
while read_hosts;
do
     if [ -n "$HOST_NAME" ]
     then
         ARGS="${ARGS} \naddress=/$HOST_NAME/$P2PIPADDRESS"
     fi
done < $REG_ENDPOINT_FILE_NAME
ARGS="${ARGS} \nbind-interfaces"
echo $ARGS > $DNSMASQ_FILE_NAME
