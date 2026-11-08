# Copyright (C) 2022 Amazon Technologies, Inc. All Rights Reserved
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Description:
# Export the emmc lifetime_a lifetime_b and manfid from sysfs
#


TAG="emmc_health: "

mlog() {
    echo $TAG $@ > /dev/kmsg
}

hardware=`getprop ro.hardware`
METRICS_PERIOD=$((24*3600))

if [ "$hardware" != "mt8127" ] ; then
    mlog "Unknowm hardware type"
    exit;

fi

if [ ! -f /sys/class/mmc_host/mmc0/mmc0:0001/lifetime_est_a ] ; then
    mlog "Cannot get lifetime_est_a"
    exit;
fi

if [ ! -f /sys/class/mmc_host/mmc0/mmc0:0001/lifetime_est_b ] ; then
    mlog "Cannot get lifetime_est_b"
    exit;
fi

if [ ! -f /sys/class/mmc_host/mmc0/mmc0:0001/manfid ] ; then
    mlog "Cannot get manfid"
    exit;
fi

write_for_hynix() {
     data_part='179[[:space:]]\{7\}0[[:space:]]mmcblk0'
     diskstats_dat=(`cat /proc/diskstats |grep $data_part`)
     written_s=${diskstats_dat[9]}
     #check for 72m written per /proc/diskstats
     size_written=72
     size_check=$(($size_written*2048))
     while [[ $written_s -lt $size_check ]]; do
         sleep 5
         diskstats_dat=(`cat /proc/diskstats |grep $data_part`)
         written_s=${diskstats_dat[9]}
         mlog `date` written_s $written_s
     done
}

manfid=`cat /sys/class/mmc_host/mmc0/mmc0:0001/manfid`
manfid_hynix=0x000090
if [ "$manfid" == "$manfid_hynix" ] ; then
    write_for_hynix
fi

emit_metrics() {
    lifetime_a=`cat /sys/class/mmc_host/mmc0/mmc0:0001/lifetime_est_a`
    lifetime_b=`cat /sys/class/mmc_host/mmc0/mmc0:0001/lifetime_est_b`
    lifetime=`cat /sys/class/mmc_host/mmc0/mmc0:0001/life_time`

    if [ -n "$lifetime_a" ] && [ -n "$lifetime_b" ] && [ -n "$manfid" ] ; then
         mlog "emmc lifetime_est_a " $lifetime_a
         mlog "emmc lifetime_est_b " $lifetime_b
         mlog "emmc manfid " $manfid
         setprop sys.emmc_health.lifetime "$lifetime_a $lifetime_b $manfid"
    fi
}

while true; do
    emit_metrics
    sleep $METRICS_PERIOD
done
