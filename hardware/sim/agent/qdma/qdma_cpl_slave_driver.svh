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
`ifndef _QDMA_CPL_SLAVE_DRIVER_
`define _QDMA_CPL_SLAVE_DRIVER_

class qdma_cpl_slave_driver extends uvm_driver#(qdma_cpl_token);
  `uvm_component_utils(qdma_cpl_slave_driver)

  virtual qdma_cpl_if _if;

  function new(string name="qdma_cpl_slave_driver", uvm_component parent=null);
    super.new(name, parent);
  endfunction

  task reset_phase(uvm_phase phase);
    super.reset_phase(phase);

    phase.raise_objection(this);

    @(posedge _if.aclk iff ~_if.aresetn);
    _if.tready <= 1'b0;

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

  task do_drive(qdma_cpl_token token);
    if (token.ready) begin
      _if.tready <= 1'b1;
      @(posedge _if.aclk iff _if.tvalid);
    end
    else begin
      _if.tready <= 1'b0;
      @(posedge _if.aclk);
    end
  endtask: do_drive

endclass: qdma_cpl_slave_driver

`endif
