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
interface qdma_h2c_if#(TDATA_W)(input aclk, input aresetn);

  logic                         tvalid;
  logic           [TDATA_W-1:0] tdata;
  logic                  [31:0] tcrc;
  logic                         tlast;
  logic                  [10:0] tuser_qid;
  logic                   [2:0] tuser_port_id;
  logic                         tuser_err;
  logic                  [31:0] tuser_mdata;
  logic [$clog2(TDATA_W/8)-1:0] tuser_mty;
  logic                         tuser_zero_byte;
  logic                         tready;

endinterface: qdma_h2c_if
