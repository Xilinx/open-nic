// *************************************************************************
//
// Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************
package axi_stream_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"
  `include "axi_stream_transaction.svh"
  `include "axi_stream_token.svh"
  `include "axi_stream_master_driver.svh"
  `include "axi_stream_slave_driver.svh"
  `include "axi_stream_monitor.svh"
  `include "axi_stream_master_agent.svh"
  `include "axi_stream_slave_agent.svh"

endpackage: axi_stream_pkg
