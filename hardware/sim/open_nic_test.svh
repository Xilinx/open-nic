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
`ifndef _OPEN_NIC_TEST_
`define _OPEN_NIC_TEST_

import "DPI-C" function int qdma_init(int, int);
import "DPI-C" function void qdma_clear();
import "DPI-C" function int cmac_init(int);
import "DPI-C" function void cmac_clear();

class kstack_test extends uvm_test;
  `uvm_component_utils(kstack_test)

  virtual open_nic_if _if;
  open_nic_env env;

  function new(string name="kstack_test", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    set_report_verbosity_level(UVM_DEBUG);

    env = open_nic_env::type_id::create("env", this);
    if (!uvm_config_db#(virtual open_nic_if)::get(this, "", "dut_if", _if)) begin
      `uvm_error(get_type_name(), "DUT Interface not found !")
    end

    env._if = _if;
  endfunction: build_phase

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction: end_of_elaboration_phase

  virtual task reset_phase(uvm_phase phase);
    super.reset_phase(phase);
    phase.raise_objection(this);
    @(posedge _if.axil_aclk iff _if.powerup_rstn);
    repeat (100) begin
      @(posedge _if.axil_aclk);
    end
    phase.drop_objection(this);
  endtask: reset_phase

  virtual task main_phase(uvm_phase phase);
    register_sequence reg_seq;
    qdma_h2c_sequence qdma_h2c_seq;
    qdma_c2h_sequence qdma_c2h_seq;
    qdma_cpl_sequence qdma_cpl_seq;

    cmac_tx_sequence cmac_tx_seq[];
    cmac_rx_sequence cmac_rx_seq[];

    int num_phys_func;
    int num_cmac_port;

    if (!uvm_config_db#(int)::get(this, "", "NUM_PHYS_FUNC", num_phys_func)) begin
      `uvm_error(get_type_name(), "NUM_PHYS_FUNC not found");
    end
    if (!uvm_config_db#(int)::get(this, "", "NUM_CMAC_PORT", num_cmac_port)) begin
      `uvm_error(get_type_name(), "NUM_CMAC_PORT not found");
    end

    super.main_phase(phase);
    phase.raise_objection(this);

    if (qdma_init(num_phys_func, 8) < 0) begin
      `uvm_error(get_type_name(), "qdma_init failed");
    end
    if (cmac_init(num_cmac_port) < 0) begin
      `uvm_error(get_type_name(), "cmac_init failed");
    end

    reg_seq = new("reg_seq");
    reg_seq.starting_phase = phase;
    reg_seq.num_phys_func = num_phys_func;
    reg_seq.num_q = 8;

    reg_seq.start(env.reg_agent.sqr);

    qdma_h2c_seq = new("qdma_h2c_seq");
    qdma_h2c_seq.starting_phase = phase;

    qdma_c2h_seq = new("qdma_c2h_seq");
    qdma_c2h_seq.starting_phase = phase;
    qdma_c2h_seq.analysis_fifo = env.qdma_c2h_agent.analysis_fifo;

    qdma_cpl_seq = new("qdma_cpl_seq");
    qdma_cpl_seq.starting_phase = phase;

    cmac_tx_seq = new[num_cmac_port];
    cmac_rx_seq = new[num_cmac_port];
    for (int i = 0; i < num_cmac_port; i++) begin
      cmac_tx_seq[i] = new($sformatf("cmac%0d_tx_seq", i));
      cmac_tx_seq[i].starting_phase = phase;
      cmac_tx_seq[i].analysis_fifo = env.cmac_tx_agent[i].analysis_fifo;
      cmac_tx_seq[i].cmac_id = i;

      cmac_rx_seq[i] = new($sformatf("cmac%0d_rx_seq", i));
      cmac_rx_seq[i].starting_phase = phase;
      cmac_rx_seq[i].cmac_id = i;
    end

    fork
      qdma_h2c_seq.start(env.qdma_h2c_agent.sqr);
      qdma_c2h_seq.start(env.qdma_c2h_agent.sqr);
      qdma_cpl_seq.start(env.qdma_cpl_agent.sqr);
    join_none

    for (int i = 0; i < num_cmac_port; i++) begin
      automatic int k = i;
      fork
        cmac_tx_seq[k].start(env.cmac_tx_agent[k].sqr);
        cmac_rx_seq[k].start(env.cmac_rx_agent[k].sqr);
      join_none
    end

    wait fork;

    qdma_clear();
    cmac_clear();
    `uvm_info(get_name(), "Test finished", UVM_DEBUG);
    phase.drop_objection(this);
  endtask: main_phase

endclass: kstack_test

`endif
