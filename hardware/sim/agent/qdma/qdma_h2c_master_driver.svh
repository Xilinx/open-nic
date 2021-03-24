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
`ifndef _QDMA_H2C_MASTER_DRIVER_
`define _QDMA_H2C_MASTER_DRIVER_

class qdma_h2c_master_driver#(TDATA_W) extends uvm_driver#(qdma_h2c_transaction);
  `uvm_component_param_utils(qdma_h2c_master_driver#(TDATA_W))

  typedef qdma_h2c_transaction seq_item_t;

  virtual qdma_h2c_if#(TDATA_W) _if;

  function new(string name="qdma_h2c_master_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  task reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    phase.raise_objection(this);

    @(posedge _if.aclk iff ~_if.aresetn);
    _if.tvalid          <= 1'b0;
    _if.tdata           <= 0;
    _if.tcrc            <= 0;
    _if.tlast           <= 1'b0;
    _if.tuser_qid       <= 0;
    _if.tuser_port_id   <= 0;
    _if.tuser_err       <= 1'b0;
    _if.tuser_mdata     <= 0;
    _if.tuser_mty       <= 0;
    _if.tuser_zero_byte <= 0;

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

    _if.tvalid          <= 1'b1;
    _if.tuser_qid       <= item.qid;
    _if.tuser_port_id   <= item.port_id;
    _if.tuser_err       <= 1'b0;
    _if.tuser_mdata     <= item.mdata;
    _if.tuser_zero_byte <= 1'b0;

    for (int index = 0; ; index++) begin
      byte tdata[];
      int mty;
      bit has_more = item.do_stream_out(index, TDATA_W, tdata, mty);

      _if.tdata     <= {<<8{tdata}};
      _if.tcrc      <= 0;
      _if.tlast     <= ~has_more;
      _if.tuser_mty <= mty;

      @(posedge _if.aclk iff _if.tready);

      if (~has_more) begin
        break;
      end
    end

    _if.tvalid <= 1'b0;
  endtask: do_drive

endclass: qdma_h2c_master_driver

`endif
