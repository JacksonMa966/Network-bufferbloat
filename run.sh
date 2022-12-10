#!/bin/bash
set -e

# Note: Mininet must be run as root.  So invoke this shell script
# using sudo.

time=100
bwnet=10

# TODO: If you want the RTT to be 4ms what should the delay on each
# link be?  Set this value correctly.

# RTT = 2xpropagation delay = 4ms, so single trip propagation delay = 4ms/2 = 2ms
# there are two links in the path, so delay on each link = 2ms/2 = 1ms

# 1Gbps, 100Mbps are capacity of the links, if the link is a river, then 1Gbps 100Mbps are the width of the river
# are how wide the river is.
# Delay 1ms is how long it takes from a bit to travel from one end of the link to 
# the other end,i.e how fast the river is flowing.

delay=1

iperf_port=5001

modprobe tcp_probe
# make sure we don't use a cached cwnd
sysctl -w net.ipv4.tcp_no_metrics_save=1

for qsize in 20 100; do
    dir=bb-q$qsize

    python bufferbloat.py --dir=$dir --time=$time --bw-net=$bwnet --delay=$delay --maxq=$qsize

    # TODO: Ensure the input file names match the ones you use in
    # bufferbloat.py script.  Also ensure the plot file names match
    # the required naming convsention when submitting your tarball.
    python plot_tcpprobe.py -f $dir/cwnd.txt -o $dir/cwnd-iperf.png -p $iperf_port
    python plot_queue.py -f $dir/q.txt -o $dir/q.png
    python plot_ping.py -f $dir/ping.txt -o $dir/rtt.png
done
