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
`timescale 1ps/1ps
module open_nic_tb;

  `include "sim_config.vh"

  import uvm_pkg::*;
  import open_nic_test_pkg::*;
  
  logic powerup_rstn;

  open_nic_if dut_if(powerup_rstn);

  open_nic_wrapper #(
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .NUM_QUEUE     (NUM_QUEUE),
    .NUM_CMAC_PORT (NUM_CMAC_PORT)
  ) dut_wrapper(._if(dut_if));
  
  assign powerup_rstn = ~glbl.GSR;
  
  initial begin
    uvm_config_db#(int)::set(null, "*", "MAX_PKT_LEN", MAX_PKT_LEN);
    uvm_config_db#(int)::set(null, "*", "MIN_PKT_LEN", MIN_PKT_LEN);
    uvm_config_db#(int)::set(null, "*", "USE_PHYS_FUNC", USE_PHYS_FUNC);
    uvm_config_db#(int)::set(null, "*", "NUM_PHYS_FUNC", NUM_PHYS_FUNC);
    uvm_config_db#(int)::set(null, "*", "NUM_QUEUE", NUM_QUEUE);
    uvm_config_db#(int)::set(null, "*", "NUM_CMAC_PORT", NUM_CMAC_PORT);

    uvm_config_db#(virtual open_nic_if)::set(null, "uvm_test_top", "dut_if", dut_if);
    run_test("kstack_test");
  end
  
  // Simulate with:
  // vsim -sv_root ./tap -sv_lib tap -L xpm -L unisims_ver -L axi_crossbar_v2_1_21 -L generic_baseblocks_v2_1_0 -L axi_register_slice_v2_1_20 open_nic_tb glbl

endmodule: open_nic_tb
