# Changelog

## [Unreleased]

## [v0.4.2] 2020-11-22

### Hardware

- Fixed a bug that causes corrupted MTY/TKEEP signals from
  `axi_stream_standardizer`, which in turns causes corrupted data path
- Enabled the customization of `num_q` in QDMA IP
- Fixed an issue that causes `box0` and `box1` registers unreadable

## [v0.4.1] 2020-10-14

### Hardware

- Added a user logic box, `box_322mhz`, running at 322MHz between CMAC IP and
  CMAC adapters; the original user logic box is renamed to `box_250mhz`
- Added support for `NUM_FUNC = 0` which ties off the AXI-Stream interfaces
  between QDMA subsystem and `box_250mhz`
- Added supports for up to 4 physical functions (PFs) and up to 2 CMAC ports
- Implemented RSS capabilty for each PF instance
- Re-allocated the register addresses for QDMA subsystem
- Added `tuser_mty` signal to the interface between shell and user logic box
  - For packets coming from the shell (i.e., QDMA H2C and CMAC RX), it is
    guaranteed that both `tkeep` and `tuser_mty` have valid values
  - For packets going into the shell, users can choose to use either `tkeep` or
    `tuser_mty` to reflect packet length
- Added a few utility RTL blocks
- Improved timing
- Updated simulation library to support multiple multi-queue PFs
  - The simulation code, which is still a bit hard-coded, will have more updates
    in the next release

### Software

- Changed the driver prefix from `xlni` to `onic` (for OpenNIC)
- Added support for multi-PF and RSS
- Fixed an issue that causes too many RX interrupts

## [v0.4.0] 2020-07-01

- Major code restructuring
  - Splitted the hardware repo into `open-nic` and `open-nic-shell`
  - `open-nic` keeps the top-level and a user logic box module used to host
    other user modules
  - `open-nic-shell` implements QDMA and CMAC subsystems as well as other
    system-related logic
  - Moved `open-nic-shell` and `open-nic-driver` as git submodules of `open-nic`
  - `open-nic-driver` contains the Linux driver
- Started to use a single version number for `open-nic` repo; `open-nic-shell`
  and `open-nic-driver` no longer reports their own version numbers

### Hardware

- Added support for multiple QDMA PFs and dual CMAC ports
- Added the `tid` and `tdest` fields to the data path AXI-Stream interface to
  mark the source and destination of packets
- Added top-level design parameters to customize various aspects such as the
  supported MTU, number of PFs and CMAC ports
- Added simulation support that simulates the design without QDMA and CMAC IPs
  and connects both ends to Linux kernel network stack
- Fixed bugs

### Software

- Rewrote part of the Linux driver to support multiple PFs and dual CMAC ports
- Added changes to support the same number of queues as the number of queue vectors
- Updated code to make it compatible with newer kernel version
- Fixed bugs

## [v0.3.1] 2020-04-08

- Fixed confusing address notations in header comments
- Updated the archive-all.sh script to correctly archive submodules

## [v0.3.0] 2020-04-07

- Restructured the codebase
  - Moved shell components into a separate folder under `src`
  - Each user logic component should have its own folder under `src`
- Updated system config and the user logic wrapper code
  - To add a user submodule, only certain part of the `user_logic_box` submodule
    need to be modified
  - User submodules can be individually reset
- Updated scripts
  - Added `export_ip.tcl` to export IP Tcl scripts from manage IP project
  - Each IP can be individually modified and rebuilt accordingly, which was done
    at a submodule level before
  - Added a `-sdnet` option to allow specifying path to SDNet executable
- Updated README.md
  - Updated the overview to reflect the new code architecture
  - Added U280 timing closure to known issues
  - Added description to the `-sdnet` option
- Pinned the driver version to `v0.2.3`
- Added CHANGELOG.md

## [v0.2.4] 2020-03-31

- Added axi-stream register slice with auto-pipelining to improve timing for SLR
  crossing
- Added a pblock constraint for U280
- Added SoC-250 BSP information and an overview on the build scirpt into
  README.md
- Removed trailing whitespaces and trailing blank lines

## [v0.2.3] 2020-03-24

- Fixed a script issue that causes verilog defines to be overwritten
- Updated build script for SoC-250
- Removed all the debug markings

## [v0.2.2] 2020-03-18

- Added `100G-driver` as a submodule
- Pinned the driver version to `v0.2.2`
- Fixed a critical issue for Alveo U280 (AR# 72926)
  - Pin `D32` needs to be tied to 0 in custom flow; otherwise the board could
    enter an unrecoverable state
- Updated `user_logic_dummy` to make the number of register stages configurable

## [v0.2.1] 2020-03-12

- Updated README.md
  - Mention that U280 still has timing failure
  - Updated known issues
- Updated support for U280 board and fixed a missing part in build script

## [v0.2] 2020-02-28

- Added an AXI-stream register slice utility module
- Fixed missing license header on some design files
- Updated README.md and build script; now board repo can be specified as Tcl
  argument
- Fixed a bug in QDMA C2H engine that potentially results in mismatch between
  advertised packet length and length of actual payload
- Added an implementation of AXI-Stream packet FIFO, as there seems to be issues
  with the XPM version
- Added constraints and build scripts for Alveo U280
- Fixed a bug in RX packet buffer that results in incorrect data count after
  discarding packets
- Added CDC primitive in submodule reset blocks so that there is no need to set
  false paht on the system-level reset path
- Changed board names into lower case letters
- Fixed a bug in QDMA C2H engine that causes mismatch between C2H packets and
  the corrsponding completion packets
- Fixed a bug in CMAC RX adapter that causes a packet to be splitted into two
  streams
- Fixed an issue that registers are incorrectly clocked in RX packet adapter
- Updated the system-level address map
- Updated the register mapping of CMAC subsystem and QDMA subsystem
- Added a dummy user logic block to directly connects CMAC and QDMA
- Merged packet adapter into CMAC subsystem, which is renamed from ethernet_100G

---

# Copyright Notice and Disclaimer

This file contains confidential and proprietary information of Xilinx, Inc. and
is protected under U.S. and international copyright and other intellectual
property laws.

DISCLAIMER

This disclaimer is not a license and does not grant any rights to the materials
distributed herewith.  Except as otherwise provided in a valid license issued to
you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NONINFRINGEMENT, OR
FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable (whether
in contract or tort, including negligence, or under any other theory of
liability) for any loss or damage of any kind or nature related to, arising
under or in connection with these materials, including for any direct, or any
indirect, special, incidental, or consequential loss or damage (including loss
of data, profits, goodwill, or any type of loss or damage suffered as a result
of any action brought by a third party) even if such damage or loss was
reasonably foreseeable or Xilinx had been advised of the possibility of the
same.

CRITICAL APPLICATIONS

Xilinx products are not designed or intended to be fail-safe, or for use in any
application requiring failsafe performance, such as life-support or safety
devices or systems, Class III medical devices, nuclear facilities, applications
related to the deployment of airbags, or any other applications that could lead
to death, personal injury, or severe property or environmental damage
(individually and collectively, "Critical Applications"). Customer assumes the
sole risk and liability of any use of Xilinx products in Critical Applications,
subject only to applicable laws and regulations governing limitations on product
liability.

THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT
ALL TIMES.
