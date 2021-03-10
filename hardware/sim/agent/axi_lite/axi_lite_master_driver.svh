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
`ifndef _AXI_LITE_MASTER_DRIVER_
`define _AXI_LITE_MASTER_DRIVER_

class axi_lite_master_driver extends uvm_driver#(axi_lite_transaction);
  `uvm_component_utils(axi_lite_master_driver)

  virtual axi_lite_if _if;

  function new(string name="axi_lite_master_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  task reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    phase.raise_objection(this);

    @(posedge _if.aclk iff ~_if.aresetn);
    _if.arvalid <= 1'b0;
    _if.araddr  <= 0;
    _if.rready  <= 1'b0;
    _if.awvalid <= 1'b0;
    _if.awaddr  <= 0;
    _if.wvalid  <= 1'b0;
    _if.wdata   <= 0;
    _if.wstrb   <= 0;
    _if.bready  <= 1'b0;

    phase.drop_objection(this);
  endtask: reset_phase

  task main_phase(uvm_phase phase);
    super.main_phase(phase);
    forever begin
      seq_item_port.get_next_item(req);

      if (req.rw == 1'b0) begin
        do_read();
      end
      else begin
        do_write();
      end

      seq_item_port.item_done();
    end
  endtask: main_phase

  task do_read();
    _if.arvalid <= 1'b1;
    _if.araddr  <= req.addr;
    @(posedge _if.aclk iff _if.arready);
    _if.arvalid <= 1'b0;

    _if.rready  <= 1'b1;
    @(posedge _if.aclk iff _if.rvalid);
    _if.rready  <= 1'b0;
  endtask: do_read

  task do_write();
    fork
      begin
        _if.awvalid <= 1'b1;
        _if.awaddr  <= req.addr;
        @(posedge _if.aclk iff _if.awready);
        _if.awvalid <= 1'b0;
      end

      begin
        _if.wvalid <= 1'b1;
        _if.wdata  <= req.data;
        _if.wstrb  <= req.strb;
        @(posedge _if.aclk iff _if.wready);
        _if.wvalid <= 1'b0;
      end
    join

    _if.bready <= 1'b1;
    @(posedge _if.aclk iff _if.bvalid);
    _if.bready <= 1'b0;
  endtask: do_write

endclass: axi_lite_master_driver

`endif
