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
`ifndef _OPEN_NIC_SEQUENCE_
`define _OPEN_NIC_SEQUENCE_

import "DPI-C" function int qdma_read(output byte pkt[]);
import "DPI-C" function int qdma_write(byte pkt[]);
import "DPI-C" function int cmac_read(int, output byte pkt[]);
import "DPI-C" function int cmac_write(int, byte pkt[]);

class register_sequence extends uvm_sequence#(axi_lite_transaction);
  `uvm_object_utils(register_sequence)

  typedef axi_lite_transaction seq_item_t;

  bit [319:0] hash_key = 320'h7C9C37DE18DC4386D9270F6F260374B8BFD0404B7872E224DC1B91BB011BA7A6376CC87ED6E31417;

  int num_phys_func;
  int num_queue;

  function new(string name="register_sequence");
    super.new(name);
  endfunction: new

  task body();
    seq_item_t item = seq_item_t::type_id::create("item");
    $display("num_phys_func = %d", num_phys_func);

    for (int i = 0; i < num_phys_func; i++) begin
      bit [31:0] base_addr = 32'h1000 + (i << 12);

      start_item(item);
      item.rw = 1;
      item.addr = base_addr + 12'h0;
      item.data = {16'(i << 3), 16'h8};
      finish_item(item);
      $display("writing %h into %h", item.data, item.addr);

      for (int j = 0; j < 128; j++) begin
        start_item(item);
        item.rw = 1;
        item.addr = base_addr + 12'h400 + (j << 2);
        item.data = {16'b0, 16'(j % num_queue)};
        finish_item(item);
      end

      for (int j = 0; j < 10; j++) begin
        start_item(item);
        item.rw = 1;
        item.addr = base_addr + 12'h600 + (j << 2);
        item.data = hash_key[j * 32 +: 32];
        finish_item(item);
      end
    end
  endtask: body

endclass: register_sequence

class qdma_h2c_sequence extends uvm_sequence#(qdma_h2c_transaction);
  `uvm_object_utils(qdma_h2c_sequence)

  typedef qdma_h2c_transaction seq_item_t;

  function new(string name="qdma_h2c_sequence");
    super.new(name);
  endfunction: new

  task body();
    byte pkt[2048];

    forever begin
      seq_item_t item = seq_item_t::type_id::create("item");
      int n = qdma_read(pkt);

      start_item(item);

      if (n > 0) begin
        item.payload = new[n];
        for (int i = 0; i < n; i++) begin
          item.payload[i] = pkt[8 + i];
        end
        item.qid = 11'({<<8{pkt[0:3]}});
        item.mdata[15:0] = n;
      end

      finish_item(item);
    end
  endtask: body

endclass: qdma_h2c_sequence

class qdma_c2h_sequence extends uvm_sequence#(qdma_c2h_token);
  `uvm_object_utils(qdma_c2h_sequence)

  typedef qdma_c2h_transaction seq_item_t;
  typedef qdma_c2h_token token_t;

  uvm_tlm_analysis_fifo#(seq_item_t) analysis_fifo;
  int handle;
  
  function new(string name="qdma_c2h_sequence");
    super.new(name);
  endfunction: new

  task body();
    forever begin
      token_t token = token_t::type_id::create("token");

      start_item(token);
      token.ready = 1'b1;
      finish_item(token);

      if (~analysis_fifo.is_empty() && (analysis_fifo.size() % 2 == 0)) begin
        seq_item_t item = seq_item_t::type_id::create("item");
        byte pkt[];

        analysis_fifo.get(item);
        analysis_fifo.get(item);
        pkt = new[item.payload.size() + 8];
        for (int i = 0; i < item.payload.size(); i++) begin
          pkt[8 + i] = item.payload[i];
        end
        pkt[0:3] = {<<8{int'(item.qid)}};

        void'(qdma_write(pkt));
      end
    end
  endtask: body

endclass: qdma_c2h_sequence

class qdma_cpl_sequence extends uvm_sequence#(qdma_cpl_token);
  `uvm_object_utils(qdma_cpl_sequence)

  typedef qdma_cpl_token token_t;

  function new(string name="qdma_cpl_sequence");
    super.new(name);
  endfunction: new

  task body();
    forever begin
      token_t token = token_t::type_id::create("token");

      start_item(token);
      token.ready = 1'b1;
      finish_item(token);
    end
  endtask: body

endclass: qdma_cpl_sequence

class cmac_tx_sequence extends uvm_sequence#(axi_stream_token);
  `uvm_object_utils(cmac_tx_sequence)

  typedef axi_stream_transaction seq_item_t;
  typedef axi_stream_token token_t;

  uvm_tlm_analysis_fifo#(seq_item_t) analysis_fifo;
  int cmac_id;

  function new(string name="cmac_tx_sequence");
    super.new(name);
  endfunction: new

  task body();
    forever begin
      token_t token = token_t::type_id::create("token");

      start_item(token);
      token.ready = 1'b1;
      finish_item(token);

      if (~analysis_fifo.is_empty() && (analysis_fifo.size() % 2 == 0)) begin
        seq_item_t item = seq_item_t::type_id::create("item");
        byte pkt[];

        analysis_fifo.get(item);
        analysis_fifo.get(item);
        pkt = item.payload;
        void'(cmac_write(cmac_id, pkt));
      end
    end
  endtask: body

endclass: cmac_tx_sequence

class cmac_rx_sequence extends uvm_sequence#(axi_stream_transaction);
  `uvm_object_utils(cmac_rx_sequence)

  typedef axi_stream_transaction seq_item_t;
  int cmac_id;

  function new(string name="cmac_tx_sequence");
    super.new(name);
  endfunction: new

  task body();
    byte pkt[2048];

    forever begin
      seq_item_t item = seq_item_t::type_id::create("item");
      int n = cmac_read(cmac_id, pkt);

      start_item(item);

      if (n > 0) begin
        item.payload = new[n](pkt);
      end

      finish_item(item);
    end
  endtask: body

endclass: cmac_rx_sequence

`endif
