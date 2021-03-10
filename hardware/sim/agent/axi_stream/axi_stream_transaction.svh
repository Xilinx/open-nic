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
`ifndef _AXI_STREAM_TRANSACTION_
`define _AXI_STREAM_TRANSACTION_

class axi_stream_transaction extends uvm_sequence_item;
  `uvm_object_utils(axi_stream_transaction)

  rand byte payload[];
  rand bit oob[];
  rand int id;
  rand int dest;

  function new(string name="axi_stream_transaction");
    super.new(name);
    id      = 0;
    dest    = 0;
  endfunction: new

  // Override this function if tuser is only valid at the last beat
  virtual function void do_stream_in(byte tdata[], bit tuser[], bit tkeep[], bit tlast);
    byte valid_data[$] = {};
    int n;
    
    foreach (tdata[i]) begin
      if (tkeep[i]) begin
        valid_data.push_back(tdata[i]);
      end
    end

    n = payload.size();
    payload = new[payload.size() + valid_data.size()](payload);
    for (int i = n; i < payload.size(); i++) begin
      payload[i] = valid_data[i-n];
    end

    n = oob.size();
    oob = new[oob.size() + tuser.size()](oob);
    for (int i = n; i < oob.size(); i++) begin
      oob[i] = tuser[i-n];
    end
  endfunction: do_stream_in

  virtual function bit do_stream_out(int index, int tdata_w, int tuser_w, output byte tdata[], output bit tuser[], output bit tkeep[]);
    int tdata_size = tdata_w / 8;
    int rem_size = payload.size() - index * tdata_size;

    tdata = new[tdata_size];
    foreach (tdata[i]) begin
      tdata[i] = payload[index * tdata_size + i];
    end

    tuser = new[tuser_w];
    foreach (tuser[i]) begin
      tuser[i] = oob[index * tuser_w + i];
    end

    tkeep = new[tdata_size];
    foreach (tkeep[i]) begin
      tkeep[i] = (rem_size > tdata_size) ? 1'b1 : (i < rem_size);
    end

    do_stream_out = (rem_size > tdata_size);
  endfunction: do_stream_out

  function void do_copy(uvm_object rhs);
    axi_stream_transaction _rhs;
    $cast(_rhs, rhs);

    super.do_copy(_rhs);
    payload = new[_rhs.payload.size()](_rhs.payload);
    oob     = new[_rhs.oob.size()](_rhs.oob);
    id      = _rhs.id;
    dest    = _rhs.dest;
  endfunction: do_copy

  function bit do_compare(uvm_object rhs, uvm_comparer comparer);
    axi_stream_transaction _rhs;
    $cast(_rhs, rhs);

    if (!super.do_compare(_rhs, comparer)) begin
      return 0;
    end

    if ((payload.size() != _rhs.payload.size()) || (oob.size() != _rhs.oob.size())) begin
      return 0;
    end

    if (id != _rhs.id || dest != _rhs.dest) begin
      return 0;
    end

    foreach (payload[i]) begin
      if (payload[i] != _rhs.payload[i]) begin
        return 0;
      end
    end

    foreach (oob[i]) begin
      if (oob[i] != _rhs.oob[i]) begin
        return 0;
      end
    end

    return 1;
  endfunction: do_compare

  function string convert2string();
    string s = super.convert2string();
    s = {s, $sformatf("\n%s: oob = %p, id = %x, dest = %x", get_name(), oob, id, dest)};
    foreach (payload[i]) begin
      if (i % 16 == 0) begin
        s = {s, $sformatf("\n0x%3h   ", (i / 16))};
      end
      s = {s, $sformatf(" %2h", payload[i])};
    end
    s = {s, "\n"};
    return s;
  endfunction: convert2string

endclass: axi_stream_transaction

`endif
