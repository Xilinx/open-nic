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

for n in $(seq 0 $(($2-1))); do
    sudo ip netns exec qdma-ns-${n} ip link del qdma-vlan-${n}
    sudo ip netns del qdma-ns-${n}
    sudo ip tuntap del dev qdma-func-${n} mode tap multi_queue
done

for n in $(seq 0 $(($2-1))); do
    sudo ip netns exec cmac-ns-${n} ip link del cmac-vlan-${n}
    sudo ip netns del cmac-ns-${n}
    sudo ip tuntap del dev cmac-${n} mode tap
done
