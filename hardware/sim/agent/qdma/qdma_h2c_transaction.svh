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
`ifndef _QDMA_H2C_TRANSACTION_
`define _QDMA_H2C_TRANSACTION_

class qdma_h2c_transaction extends uvm_sequence_item;
  `uvm_object_utils(qdma_h2c_transaction)

  typedef qdma_h2c_transaction this_t;

  rand byte payload[];
  rand bit [10:0] qid;
  rand bit [2:0] port_id;
  rand bit [31:0] mdata;

  function new(string name="qdma_h2c_transaction");
    super.new(name);
    qid     = 0;
    port_id = 0;
    mdata   = 0;
  endfunction: new

  function void do_stream_in(byte tdata[], int mty, bit tlast);
    int n = payload.size();

    if (tlast) begin
      payload = new[payload.size() + tdata.size() - mty](payload);
    end
    else begin
      payload = new[payload.size() + tdata.size()](payload);
    end
    for (int i = n; i < payload.size(); i++) begin
      payload[i] = tdata[i-n];
    end
  endfunction: do_stream_in

  function bit do_stream_out(int index, int tdata_w, output byte tdata[], output int mty);
    int tdata_size = tdata_w / 8;
    int rem_size = payload.size() - index * tdata_size;

    tdata = new[tdata_size];
    foreach (tdata[i]) begin
      tdata[i] = payload[index * tdata_size + i];
    end

    mty = (rem_size > tdata_size) ? 0 : (tdata_size - rem_size);
    do_stream_out = (rem_size > tdata_size);
  endfunction: do_stream_out

  function void do_copy(uvm_object rhs);
    this_t _rhs;
    $cast(_rhs, rhs);

    super.do_copy(_rhs);
    payload = new[_rhs.payload.size()](_rhs.payload);
    qid     = _rhs.qid;
    port_id = _rhs.port_id;
    mdata   = _rhs.mdata;
  endfunction: do_copy

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    this_t _rhs;
    $cast(_rhs, rhs);

    if (!super.do_compare(_rhs, comparer)) begin
      return 0;
    end

    if (payload.size() != _rhs.payload.size()) begin
      return 0;
    end

    if (qid != _rhs.qid || port_id != _rhs.port_id || mdata != _rhs.mdata) begin
      return 0;
    end

    foreach (payload[i]) begin
      if (payload[i] != _rhs.payload[i]) begin
        return 0;
      end
    end

    return 1;
  endfunction: do_compare

  function string convert2string();
    string s = super.convert2string();
    s = {s, $sformatf("\n%s: len = %d, qid = %x, port_id = %x, mdata = %x", get_name(), payload.size(), qid, port_id, mdata)};
    foreach (payload[i]) begin
      if (i % 16 == 0) begin
        s = {s, $sformatf("\n0x%3h   ", (i / 16))};
      end
      s = {s, $sformatf(" %2h", payload[i])};
    end
    s = {s, "\n"};
    return s;
  endfunction: convert2string

endclass: qdma_h2c_transaction

`endif
