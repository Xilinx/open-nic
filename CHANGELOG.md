# CHANGELOG

## [1.0] 2021-04-07

First public release.  Here are the changes compared with the last early-access
release version 0.4.2.

### OpenNIC Shell

- Upgraded to Vivado 2020.2.
- Changed the AXI-stream interfaces between shell and user logic boxes.  See
  [README.md](https://github.com/Xilinx/open-nic-shell/blob/3b6f94a5855d468001d895e1768f25d25907bf02/README.md)
  for details.
- Restructured the repo.  Now all the RTL code are under "open-nic-shell". The
  "open-nic" repo will become an umbrella for the OpenNIC project.
- Introduced a new approach to build the shell with user plugins.  See
  [README.md](https://github.com/Xilinx/open-nic-shell/blob/3b6f94a5855d468001d895e1768f25d25907bf02/README.md)
  for details.
- Added support for build timestamp.  The timestamp is recorded automatically in
  the format 0xMMDD_HHMM, where the first MM is for month and the second for
  minute. It can be read from the register 0x0 via BAR2.
- Adjust RX insertion loss from 12dB to 20dB, so that longer cables can work
  more reliably.
- Enable RS-FEC on CMAC.
- Simulation code is removed and will be pushed into a separate repo.

### OpenNIC Driver

- Updated the CMAC core version check to be compatiable with Vivado 2020.2.
- Added randomization of MAC address generation.
- Enabled RS-FEC support.
- Adjusted the waiting time for RX lane alignment.

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
