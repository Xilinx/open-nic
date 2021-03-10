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
`ifndef _AXI_LITE_MONITOR_
`define _AXI_LITE_MONITOR_

class axi_lite_monitor extends uvm_monitor;
  `uvm_component_utils(axi_lite_monitor)

  virtual axi_lite_if _if;
  uvm_analysis_port#(axi_lite_transaction) analysis_port;

  function new(string name="axi_lite_monitor", uvm_component parent=null);
    super.new(name, parent);
  endfunction: new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    analysis_port = new("analysis_port", this);
  endfunction: build_phase

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      axi_lite_transaction item = axi_lite_transaction::type_id::create("item", this);
      do_monitor(item);
      analysis_port.write(item);
    end
  endtask: run_phase

  task do_monitor(axi_lite_transaction item);
    @(posedge _if.aclk iff ((_if.arvalid && _if.arready) ||
      (_if.awvalid && _if.wvalid && _if.awready && _if.wready)));

    if (_if.arvalid && _if.arready) begin
      item.rw   = 1'b0;
      item.addr = _if.araddr;

      @(posedge _if.aclk iff (_if.rvalid && _if.rready));
      assert(_if.rresp == 0);

      item.data = _if.rdata;
      item.strb = 4'hF;
    end
    else begin
      item.rw   = 1'b1;
      item.addr = _if.awaddr;
      item.data = _if.wdata;
      item.strb = _if.wstrb;

      @(posedge _if.aclk iff (_if.bvalid && _if.bready));
      assert(_if.bresp == 0);
    end
  endtask: do_monitor

endclass: axi_lite_monitor

`endif
