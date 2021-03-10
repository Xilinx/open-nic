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
`ifndef _AXI_LITE_TRANSACTION_
`define _AXI_LITE_TRANSACTION_

class axi_lite_transaction extends uvm_sequence_item;
  `uvm_object_utils(axi_lite_transaction)

  rand bit rw;
  rand bit [31:0] addr;
  rand bit [31:0] data;
  rand bit [3:0] strb;

  function new(string name="axi_lite_transaction");
    super.new(name);
    rw   = 1'b0;
    addr = 0;
    data = 0;
    strb = 4'hF;
  endfunction: new

  function void do_copy(uvm_object rhs);
    axi_lite_transaction _rhs;
    $cast(_rhs, rhs);

    super.do_copy(_rhs);
    rw   = _rhs.rw;
    addr = _rhs.addr;
    data = _rhs.data;
    strb = _rhs.strb;
  endfunction: do_copy

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axi_lite_transaction _rhs;
    $cast(_rhs, rhs);

    if (!super.do_compare(rhs, comparer)) begin
      return 0;
    end
    return (rw == _rhs.rw) && (addr == _rhs.addr) && (data == _rhs.data) && (strb == _rhs.strb);
  endfunction: do_compare

  function string convert2string();
    string s = super.convert2string();
    string t = (rw == 0) ? "read request" : "write request";
    s = {s, $sformatf("\n  addr = 0x%8h", addr)};
    if (rw == 1) begin
      s = {s, $sformatf("\n  data = 0x%8h, strobe = 0x%2h", data, strb)};
    end
    return s;
  endfunction: convert2string

endclass: axi_lite_transaction

`endif
