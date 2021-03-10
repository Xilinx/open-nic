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
interface qdma_cpl_if(input aclk, input aresetn);

  logic         tvalid;
  logic [511:0] tdata;
  logic   [1:0] size;
  logic  [15:0] dpar;
  logic  [10:0] ctrl_qid;
  logic   [1:0] ctrl_cmpt_type;
  logic  [15:0] ctrl_wait_pld_pkt_id;
  logic   [2:0] ctrl_port_id;
  logic         ctrl_marker;
  logic         ctrl_user_trig;
  logic   [2:0] ctrl_col_idx;
  logic   [2:0] ctrl_err_idx;
  logic         tready;

endinterface: qdma_cpl_if
