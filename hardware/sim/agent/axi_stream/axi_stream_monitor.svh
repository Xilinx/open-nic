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
`ifndef _AXI_STREAM_MONITOR_
`define _AXI_STREAM_MONITOR_

class axi_stream_monitor#(TDATA_W, TUSER_W, TID_W, TDEST_W, type seq_item_t=axi_stream_transaction)
  extends uvm_monitor;

  `uvm_component_param_utils(axi_stream_monitor#(TDATA_W, TUSER_W, TID_W, TDEST_W, seq_item_t))

  virtual axi_stream_if#(TDATA_W, TUSER_W, TID_W, TDEST_W) _if;
  uvm_analysis_port#(seq_item_t) analysis_port;

  function new(string name="axi_stream_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_port = new("analysis_port", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_t item = seq_item_t::type_id::create("item", this);
      do_monitor(item);
    end
  endtask: run_phase

  function void do_stream_in(seq_item_t item);
    byte tdata[] = new[TDATA_W / 8];
    bit tkeep[] = new[TDATA_W / 8];
    bit tuser[] = new[TUSER_W];
    bit tlast;

    tdata = {<<8{_if.tdata}};
    tkeep = {<<1{_if.tkeep}};
    tuser = {<<1{_if.tuser}};
    tlast = _if.tlast;

    item.do_stream_in(tdata, tuser, tkeep, tlast);
  endfunction: do_stream_in

  task do_monitor(seq_item_t item);
    @(posedge _if.aclk iff _if.tvalid);
    item.id   = _if.tid;
    item.dest = _if.tdest;
    analysis_port.write(item);

    if (_if.tready) begin
      do_stream_in(item);
    end

    while (~_if.tlast) begin
      @(posedge _if.aclk iff (_if.tvalid && _if.tready));
      do_stream_in(item);
    end

    analysis_port.write(item);
  endtask: do_monitor

endclass: axi_stream_monitor

`endif
