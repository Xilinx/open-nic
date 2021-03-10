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
`ifndef _AXI_STREAM_MASTER_DRIVER_
`define _AXI_STREAM_MASTER_DRIVER_

class axi_stream_master_driver#(TDATA_W, TUSER_W, TID_W, TDEST_W, type seq_item_t=axi_stream_transaction)
  extends uvm_driver#(seq_item_t);

  `uvm_component_param_utils(axi_stream_master_driver#(TDATA_W, TUSER_W, TID_W, TDEST_W, seq_item_t))

  virtual axi_stream_if#(TDATA_W, TUSER_W, TID_W, TDEST_W) _if;

  function new(string name="axi_stream_master_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  task reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    phase.raise_objection(this);

    @(posedge _if.aclk iff ~_if.aresetn);
    _if.tvalid <= 1'b0;
    _if.tdata  <= 0;
    _if.tkeep  <= 0;
    _if.tlast  <= 1'b0;
    _if.tuser  <= 0;
    _if.tid    <= 0;
    _if.tdest  <= 0;

    phase.drop_objection(this);
  endtask: reset_phase

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    forever begin
      seq_item_port.get_next_item(req);
      do_drive(req);
      seq_item_port.item_done();
    end
  endtask: main_phase

  task do_drive(seq_item_t item);
    if (item.payload.size() == 0) begin
      @(posedge _if.aclk);
      return;
    end

    _if.tvalid <= 1'b1;
    _if.tid    <= item.id;
    _if.tdest  <= item.dest;

    for (int index = 0; ; index++) begin
      byte tdata[];
      bit tkeep[];
      bit tuser[];
      bit has_more = item.do_stream_out(index, TDATA_W, TUSER_W, tdata, tuser, tkeep);

      _if.tdata <= {<<8{tdata}};
      _if.tkeep <= {<<1{tkeep}};
      _if.tuser <= {<<1{tuser}};
      _if.tlast <= ~has_more;

      @(posedge _if.aclk iff _if.tready);

      if (~has_more) begin
        break;
      end
    end

    _if.tvalid <= 1'b0;
  endtask: do_drive

endclass: axi_stream_master_driver

`endif
