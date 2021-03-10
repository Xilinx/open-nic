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
`ifndef _OPEN_NIC_ENV_
`define _OPEN_NIC_ENV_

class open_nic_env extends uvm_env;
  `uvm_component_utils(open_nic_env)

  typedef axi_lite_master_agent reg_agent_t;

  typedef qdma_h2c_master_agent#(.TDATA_W(512)) qdma_h2c_agent_t;
  typedef qdma_c2h_slave_agent#(.TDATA_W(512)) qdma_c2h_agent_t;
  typedef qdma_cpl_slave_agent qdma_cpl_agent_t;

  typedef axi_stream_slave_agent#(.TDATA_W(512), .TUSER_W(1)) cmac_tx_agent_t;
  typedef axi_stream_master_agent#(.TDATA_W(512), .TUSER_W(1)) cmac_rx_agent_t;

  virtual open_nic_if _if;

  reg_agent_t reg_agent;
  qdma_h2c_agent_t qdma_h2c_agent;
  qdma_c2h_agent_t qdma_c2h_agent;
  qdma_cpl_agent_t qdma_cpl_agent;
  cmac_tx_agent_t cmac_tx_agent[];
  cmac_rx_agent_t cmac_rx_agent[];

  // Add a scoreboard instance if needed

  function new(string name="open_nic_env", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    int num_cmac_port;

    if (!uvm_config_db#(int)::get(this, "", "NUM_CMAC_PORT", num_cmac_port)) begin
      `uvm_error(get_type_name(), "NUM_CMAC_PORT not found");
    end

    super.build_phase(phase);

    reg_agent = reg_agent_t::type_id::create("reg_agent", this);

    qdma_h2c_agent = qdma_h2c_agent_t::type_id::create("qdma_h2c_agent", this);
    qdma_c2h_agent = qdma_c2h_agent_t::type_id::create("qdma_c2h_agent", this);
    qdma_cpl_agent = qdma_cpl_agent_t::type_id::create("qdma_cpl_agent", this);

    cmac_tx_agent = new[num_cmac_port];
    cmac_rx_agent = new[num_cmac_port];
    for (int i = 0; i < num_cmac_port; i++) begin
      cmac_tx_agent[i] = cmac_tx_agent_t::type_id::create($sformatf("cmac%0d_tx_agent", i), this);
      cmac_rx_agent[i] = cmac_rx_agent_t::type_id::create($sformatf("cmac%0d_rx_agent", i), this);
    end

    reg_agent._if = _if.s_axil;

    qdma_h2c_agent._if = _if.qdma_h2c;
    qdma_c2h_agent._if = _if.qdma_c2h;
    qdma_cpl_agent._if = _if.qdma_cpl;

    for (int i = 0; i < num_cmac_port; i++) begin
      cmac_tx_agent[i]._if = _if.cmac_tx[i];
      cmac_rx_agent[i]._if = _if.cmac_rx[i];
    end
  endfunction: build_phase

  // Override `connect_phase` if scoreboard is needed

endclass: open_nic_env

`endif
