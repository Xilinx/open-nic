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
`ifndef _QDMA_CPL_TOKEN_
`define _QDMA_CPL_TOKEN_

class qdma_cpl_token extends uvm_sequence_item;
  `uvm_object_utils(qdma_cpl_token)

  rand bit ready;

  function new(string name="qdma_c2h_token");
    super.new(name);
    ready = 1'b0;
  endfunction: new

endclass: qdma_cpl_token

`endif
