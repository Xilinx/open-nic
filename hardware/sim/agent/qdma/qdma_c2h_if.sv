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
`timescale 1ns/1ps
interface qdma_c2h_if#(TDATA_W)(input aclk, input aresetn);

  logic                         tvalid;
  logic           [TDATA_W-1:0] tdata;
  logic                  [31:0] tcrc;
  logic                         tlast;
  logic                         ctrl_marker;
  logic                   [2:0] ctrl_port_id;
  logic                   [6:0] ctrl_ecc;
  logic                  [15:0] ctrl_len;
  logic                  [10:0] ctrl_qid;
  logic                         ctrl_has_cmpt;
  logic [$clog2(TDATA_W/8)-1:0] mty;
  logic                         tready;

endinterface: qdma_c2h_if
