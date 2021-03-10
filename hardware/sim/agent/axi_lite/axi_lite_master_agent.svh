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
`ifndef _AXI_LITE_MASTER_AGENT_
`define _AXI_LITE_MASTER_AGENT_

class axi_lite_master_agent extends uvm_agent;
  `uvm_component_utils(axi_lite_master_agent)

  typedef uvm_sequencer#(axi_lite_transaction) sequencer_t;
  typedef axi_lite_master_driver driver_t;
  typedef axi_lite_monitor monitor_t;

  virtual axi_lite_if _if;
  sequencer_t sqr;
  driver_t drv;
  monitor_t mon;
  uvm_analysis_port#(axi_lite_transaction) analysis_port;

  function new(string name="axi_lite_master_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = sequencer_t::type_id::create("sqr", this);
    drv = driver_t::type_id::create("drv", this);
    mon = monitor_t::type_id::create("mon", this);

    drv._if = _if;
    mon._if = _if;
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    analysis_port = mon.analysis_port;
    drv.seq_item_port.connect(sqr.seq_item_export);
  endfunction: connect_phase

endclass: axi_lite_master_agent

`endif
