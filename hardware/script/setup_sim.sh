# *************************************************************************
#
# Copyright 2020 Xilinx, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# *************************************************************************
#! /bin/bash

for n in $(seq 0 $(($1-1))); do
    sudo ip tuntap add dev qdma-func-${n} mode tap multi_queue user $USER
    sudo ip link set qdma-func-${n} up

    sudo ip netns add qdma-ns-${n}
    sudo ip link add link qdma-func-${n} name qdma-vlan-${n} type macvlan
    sudo ip link set qdma-vlan-${n} netns qdma-ns-${n}
    sudo ip netns exec qdma-ns-${n} ip addr add 192.168.1.$(($n+10))/24 dev qdma-vlan-${n}
    sudo ip netns exec qdma-ns-${n} ip link set qdma-vlan-${n} up
done

for n in $(seq 0 $(($2-1))); do
    sudo ip tuntap add dev cmac-${n} mode tap user $USER
    sudo ip link set cmac-${n} up

    sudo ip netns add cmac-ns-${n}
    sudo ip link add link cmac-${n} name cmac-vlan-${n} type macvlan
    sudo ip link set cmac-vlan-${n} netns cmac-ns-${n}
    sudo ip netns exec cmac-ns-${n} ip addr add 192.168.1.$(($n+20))/24 dev cmac-vlan-${n}
    sudo ip netns exec cmac-ns-${n} ip link set cmac-vlan-${n} up
done
