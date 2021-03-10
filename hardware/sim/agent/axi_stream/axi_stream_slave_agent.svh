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
`ifndef _AXI_STREAM_SLAVE_AGENT_
`define _AXI_STREAM_SLAVE_AGENT_

class axi_stream_slave_agent#(TDATA_W, TUSER_W=8, TID_W=8, TDEST_W=4, type seq_item_t=axi_stream_transaction)
  extends uvm_agent;

  `uvm_component_param_utils(axi_stream_slave_agent#(TDATA_W, TUSER_W, TID_W, TDEST_W, seq_item_t))

  typedef uvm_sequencer#(axi_stream_token) sequencer_t;
  typedef axi_stream_slave_driver#(TDATA_W, TUSER_W, TID_W, TDEST_W) driver_t;
  typedef axi_stream_monitor#(TDATA_W, TUSER_W, TID_W, TDEST_W, seq_item_t) monitor_t;

  virtual axi_stream_if#(TDATA_W, TUSER_W, TID_W, TDEST_W) _if;
  sequencer_t sqr;
  driver_t drv;
  monitor_t mon;
  uvm_tlm_analysis_fifo#(seq_item_t) analysis_fifo;
  uvm_analysis_port#(seq_item_t) analysis_port;

  function new(string name="axi_stream_slave_agent", uvm_component parent=null);
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

endclass: axi_stream_slave_agent

`endif
