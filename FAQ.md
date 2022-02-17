# Frequently Asked Questions

## Table of Contents

- [General Questions](#general-questions)
  * [How can I contribute to OpenNIC?](#how-can-i-contribute-to-opennic)
  * [Is OpenNIC supported by Xilinx?](#is-opennic-supported-by-xilinx)
  * [How is OpenNIC licensed?](#how-is-opennic-licensed)
  * [How does OpenNIC relate to the Xilinx SmartNIC product?](#how-does-opennic-relate-to-the-xilinx-smartnic-product)
  * [How does OpenNIC relate to Corundum?](#how-does-opennic-relate-to-corundum)
  * [How does OpenNIC relate to NetFPGA?](#how-does-opennic-relate-to-netfpga)
  * [How does OpenNIC relate to VNx and EasyNet?](#how-does-opennic-relate-to-vnx-and-easynet)
  * [Can I use P4 with OpenNIC?](#can-i-use-p4-with-opennic)
  * [How do I migrate from an older version of OpenNIC to version 1.0?](#how-do-i-migrate-from-an-older-version-of-opennic-to-version-10)
  * [Does Xilinx provide any examples using OpenNIC?](#does-xilinx-provide-any-examples-using-opennic)
- [Feature Set Questions](#feature-set-questions)
  * [Does OpenNIC support jumbo frames?](#does-opennic-support-jumbo-frames)
  * [Does OpenNIC support line-rate packet processing at the CMAC interfaces?](#does-opennic-support-line-rate-packet-processing-at-the-cmac-interfaces)
  * [Does OpenNIC support line-rate data at he QDMA-PCIe interface?](#does-opennic-support-line-rate-data-at-he-qdma-pcie-interface)
  * [Does OpenNIC provide any partial reconfiguration feature?](#does-opennic-provide-any-partial-reconfiguration-feature)
  * [Will on-board memory support be added to OpenNIC?](#will-on-board-memory-support-be-added-to-opennic)
  * [Will user-logic interrupt support be added to OpenNIC?](#will-user-logic-interrupt-support-be-added-to-opennic)
- [Hardware Questions](#hardware-questions)
  * [What Xilinx boards does OpenNIC support and how much FPGA resource is available to users?](#what-xilinx-boards-does-opennic-support-and-how-much-fpga-resource-is-available-to-users)
  * [What servers have been used with OpenNIC?](#what-servers-have-been-used-with-opennic)
  * [Are there recommendations for USB cables for programming the FPGA?](#are-there-recommendations-for-usb-cables-for-programming-the-fpga)
  * [How do I use handle the user-box TUSER signals with SDNet which does not support TUSER?](#how-do-i-use-handle-the-user-box-tuser-signals-with-sdnet-which-does-not-support-tuser)
  * [How many physical functions, virtual functions and queues are supported in OpenNIC?](#how-many-physical-functions-virtual-functions-and-queues-are-supported-in-opennic)
  * [Why are there two user logic boxes in OpenNIC?](#why-are-there-two-user-logic-boxes-in-opennic)
  * [What kinds of bus protocols are supported in the interface between OpenNIC shell and user logic boxes?](#what-kinds-of-bus-protocols-are-supported-in-the-interface-between-opennic-shell-and-user-logic-boxes)
  * [Are there recommendations for customizing clocking for user IP or adding additional clocks?](#are-there-recommendations-for-customizing-clocking-for-user-ip-or-adding-additional-clocks)
- [Software Questions](#software-questions)
  * [Can OpenNIC be used with the Vitis flow?](#can-opennic-be-used-with-the-vitis-flow)
  * [What SW support can I expect to use, for example, DPDK, eBPF, VM, etc.?](#what-sw-support-can-i-expect-to-use-for-example-dpdk-ebpf-vm-etc)
  * [Can I use HLS with OpenNIC?](#can-i-use-hls-with-opennic)
- [Operation Questions](#operation-questions)
  * [How can I tell if the OpenNIC is receiving any packets or check its status?](#how-can-i-tell-if-the-opennic-is-receiving-any-packets-or-check-its-status)
  * [What do I do if I do not see packets sent by the OpenNIC at the receiving host?](#what-do-i-do-if-i-do-not-see-packets-sent-by-the-opennic-at-the-receiving-host)

---

## General Questions

### How can I contribute to OpenNIC?
The OpenNIC shell and driver can be downloaded from this repository, and used in projects.  OpenNIC users are strongly encouraged to contribute back
to the community.  This encompasses enhancements to the shell or driver, example use cases of OpenNIC, documents and publications, and general feedback
and discussion.

### Is OpenNIC supported by Xilinx?
OpenNIC was originally developed within Xilinx Labs, to support networking-related research projects.  It has now been open sourced by Xilinx as a 
community resource.  Further evolution of OpenNIC will be done within Xilinx Labs as project needs evolve.  And members of Xilinx Labs will be active members of the
open source community, as well as providing informal support to others.  But OpenNIC is not a Xilinx product and so does not have formal Xilinx support in place.

### How is OpenNIC licensed?
The OpenNIC sources and scripts are licensed under Apache 2.0. The Xilinx IP used in the design is licensed under either the standard Vivado license or the free license used for the CMAC. The open-nic-driver is licensed under GPL2.0 as is standard for linux drivers.

### How does OpenNIC relate to the Xilinx SmartNIC product?
The Xilinx SN1000 (https://www.xilinx.com/applications/data-center/network-acceleration/alveo-sn1000.html) is a fully-supported Xilinx product that has a wide range of
SmartNIC features.  On the other hand, OpenNIC is an open source project, focused on easing the integration of user logic for experimental networking functions,
and the shell is carefully designed so that it hides many details and only exposes simple data and control interfaces to user logic.

### How does OpenNIC relate to Corundum?
Corundum (https://github.com/corundum/corundum) provides a complete NIC that includes various interesting features, some of which could potentially be brought into
OpenNIC as future enhancements.  One technical difference between OpenNIC and Corundum is that OpenNIC uses the Xilinx QDMA IP core for the host interface, while Corundum
uses a fully custom DMA subsystem.  As a result, OpenNIC benefits from mainstream support for the QDMA IP and software.  On the other hand, the DMA subsystem in Corundum
is more flexible, being open to customization.

### How does OpenNIC relate to NetFPGA?
NetFPGA (www.netfpga.org) is a long-running open source community for networking using Xilinx FPGAs.  It has traditionally been based on custom boards, the latest generation
being NetFPGA SUME.  However, the next generation - NetFPGA PLUS - is actually based upon OpenNIC, targeted at standard Xilinx Alveo boards.  So NetFPGA is now a major
OpenNIC community member, and has been working with early access versions prior to the open source version 1.0 release.

### How does OpenNIC relate to VNx and EasyNet?
VNx (https://github.com/Xilinx/xup_vitis_network_example) and EasyNet (https://github.com/fpgasystems/Vitis_with_100Gbps_TCP-IP) are two open source frameworks for
connecting FPGA-accelerated applications directly to networks without CPU intervention.  VNx, from the Xilinx University Program, offers UDP/IP support and
EasyNet, from ETH Zurich, offers TCP/IP support.  Both are targeted at users developing applications with Xilinx Vitis, who need "out of the box" 100Gb/s networking.
OpenNIC, on the other hand, is intended for networking research and experimentation with new FPGA-based networking components.

### Can I use P4 with OpenNIC?
Yes.  The Xilinx Vitis Networking P4 (VitisNetP4 for short, formerly known as SDNet) compiler can be used to generate an IP block with standard AXI interfaces that can be
placed in either user box of the OpenNIC shell.  Community work is currently under way to provide a "big green button" flow, similar to the longstanding P4->NetFPGA flow, to
simplify the process for using OpenNIC as a P4 target.

### How do I migrate from an older version of OpenNIC to version 1.0?
The main differences between the older versions (provided for early access purposes) and
version 1.0 include the register layout, the shell/box data interfaces, and how
user logic is integrated.  The register addresses and the shell/box data
interfaces are detailed in the OpenNIC technical reference guide.  To migrate the user
logic, one should extract the "in-place" modifications to the box into Verilog
header files, using the default p2p (port-to-port) plugin as a template, and
make sure that data interfaces of the user logic are compatible with those with
version 1.0.

### Does Xilinx provide any examples using OpenNIC?
Xilinx does not currently provide any examples in this repository.  The intention is to collect examples from the community as people embrace OpenNIC and, when ready,
share their work with others.

---

## Feature Set Questions

### Does OpenNIC support jumbo frames?
The CMAC subsystem can be configured to support jumbo frames by selecting the appropriate packet length option (max_pkt_len 9600) on the build command line.
However, the QDMA subsystem does not support jumbo frames yet. The maximum packet size that can be sent to the host or received from the host is limited
to about 4K bytes (1 page).

### Does OpenNIC support line-rate packet processing at the CMAC interfaces?
Yes, OpenNIC supports line-rate packet processing at the CMAC interface. The actual bytes/second depends on the packet size because of the fixed inter-packet gap
that is required between packets. 

### Does OpenNIC support line-rate data at the QDMA-PCIe interface?
Line-rate processing at the QDMA interface depends on whether the DPDK driver or the Linux kernel driver is used. For the DPDK driver, it is possible to achieve
receive and transmit throughput close to 100Gbps.  For the Linux kernel driver, there are currently two main obstacles,as follows:

1. To receive packets at line rate, the ingress traffic should be distributed over
   multiple flows.  With receive-side scaling (RSS) enabled, different flows
   are mapped to different cores.  But for single-flow traffic, a single CPU cannot
   handle such large bandwidth.
2. To send packets at line rate, certain offloads would need to be implemented in
   OpenNIC shell, such as TSO/GSO and checksum offloading.  Currently, without these
   offloads, host CPUs become the bottleneck as they cannot prepare packets
   quickly enough to saturate the link.

### Does OpenNIC provide any partial reconfiguration feature?
No, OpenNIC is not designed for partial reconfiguration.

### Will on-board memory support be added to OpenNIC?
This is currently in progress in the community, and is expected to be added to the next version of OpenNIC.

### Will user-logic interrupt support be added to OpenNIC?
This is currently in progress in the community, and is expected to be added to a future version of OpenNIC.

---

## Hardware Questions

### What Xilinx boards does OpenNIC support and how much FPGA resource is available to users?
OpenNIC currently runs on Alveo U50, U200, U250, and U280 boards. The OpenNIC consumes very few FPGA resources, and the resource consumption depends on the configuration paramters such as the number of CMACs and the number of physical functions. With the default configuration, the OpenNIC consumes about 5% of the available LUTs and BRAMs on the U250.

### What servers have been used with OpenNIC?
OpenNIC has been used with Dell Poweredge R740, Dell Precision 7290 servers, Supermicro AS-2024US-TRT, and with multiple other desktops and towers. In addition to this short list, Xilinx provides a list of servers that have been qualified to work with various Alveo cards, at //https://www.xilinx.com/products/boards-and-kits/alveo/qualified-servers.html.

### Are there recommendations for USB cables for programming the FPGA?
Most generic micro-usb cables that support data should be okay.  As an example, we have had success in using the "heyday micro-usb cables (for Android)" found at Target.

### How do I use handle the TUSER signals of user logic boxes when using VitisNetP4 (formerly known as SDNet)?
Use an SDNet Tuple to propagate the TUSER signals across different engines.

### How many physical functions, virtual functions and queues are supported in OpenNIC?
OpenNIC shell can use up to four physical functions and 2048 queues.  As of version
1.0, it does not support virtual functions.

### Why are there two user logic boxes in OpenNIC?
The user logic boxes allow for two roles with the OpenNIC shell.  Their names reflect the clock rates used.  The 322 MHz block is typically used for network-attached
accelerators where network traffic flows in and then back out, and its rate allows it to handle the worst case of sustained minimum-size Ethernet packets at 100Gbps line rate
(150 million packets per second).  The 250 MHz block is typically used for NIC use cases where network traffic flows in and out of the host.  This slower clock domain cannot
handle the theoretical worst-case packet rate but reflects the fact that, for packets to and from the host over PCIe, the QDMA only runs at 250 MHz.

### What kinds of bus protocols are supported in the interface between OpenNIC shell and user logic boxes?
A variant of AXI4-stream protocol is used, with additional fields for packet
size, source and destination.  See the OpenNIC technical reference guide for details.

### Are there recommendations for customizing clocking for user IP or adding additional clocks?
There are currently three main clock domains for data movement within the design: (a) cmac_clk at 322 MHz, (b) axis_clk from the QDMA IP at 250 MHz, and (c) axil_clk from the QDMA subsystem for memory-mapped control logic at 125 MHz.  The user logic boxes serve as placeholders for inserting user modules either in the 322 MHz clock domain or in the 250 MHz clock domain. If it becomes necessary to add custom clocking, the recommendation is to instantiate a clock wizard IP from the Vivado IP catalog, potentially using the axil_clk as the input clock with PLL or MMCM as appropriate.  It might make sense to create a similar user logic box to help organize the design.

---

## Software Questions

### Can OpenNIC be used with the Vitis flow?
OpenNIC cannot be used with the Vitis flow. Use Vivado.

### What SW support can I expect to use, for example, DPDK, eBPF, VM, etc.? 
Xilinx provides the linux open-nic-driver sources, and an excellent DPDK driver has been developed by the community.

### Can I use HLS with OpenNIC?
Yes, you can use HLS to design modules that fit within the user logic boxes in the OpenNIC. However, HLS does not generate the streaming interfaces that the OpenNIC expects, so you will have to create your own RTL wrappers to connect the HLS module to these interfaces.

---

## Operation Questions

### How can I check the link status or identify if OpenNIC received any packet?
To check the link status, read CMAC registers which are mapped to BAR2.

To identify if OpenNIC received any packet, check the values of built-in
registers.  As of version 1.0, the RX packet adapter registers can be used to
check if there is any received or dropped packet.

### What to do if I do not see packets sent by the OpenNIC at the receiving host?
First, make sure the receiving side has RS-FEC enabled.  Then check the TX link
status by reading CMAC registers.  If there is any link error, try a different
cable.  Otherwise, check that the packet has correct destination MAC/IP addresses.
In some cases, the packet might be dropped by the receiving NIC before it goes
up to the host.
