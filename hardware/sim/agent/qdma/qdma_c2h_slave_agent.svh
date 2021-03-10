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
`ifndef _QDMA_C2H_SLAVE_AGENT_
`define _QDMA_C2H_SLAVE_AGENT_

class qdma_c2h_slave_agent#(TDATA_W) extends uvm_agent;
  `uvm_component_param_utils(qdma_c2h_slave_agent#(TDATA_W))

  typedef qdma_c2h_transaction seq_item_t;
  typedef uvm_sequencer#(qdma_c2h_token) sequencer_t;
  typedef qdma_c2h_slave_driver#(TDATA_W) driver_t;
  typedef qdma_c2h_monitor#(TDATA_W) monitor_t;

  virtual qdma_c2h_if#(TDATA_W) _if;
  sequencer_t sqr;
  driver_t drv;
  monitor_t mon;
  uvm_tlm_analysis_fifo#(seq_item_t) analysis_fifo;
  uvm_analysis_port#(seq_item_t) analysis_port;

  function new(string name="qdma_c2h_slave_agent", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = sequencer_t::type_id::create("sqr", this);
    drv = driver_t::type_id::create("drv", this);
    mon = monitor_t::type_id::create("mon", this);
    analysis_fifo = new("analysis_fifo", this);

    drv._if = _if;
    mon._if = _if;
  endfunction: build_phase

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    drv.seq_item_port.connect(sqr.seq_item_export);
    mon.analysis_port.connect(analysis_fifo.analysis_export);
    analysis_port = mon.analysis_port;
  endfunction: connect_phase

endclass: qdma_c2h_slave_agent

`endif
