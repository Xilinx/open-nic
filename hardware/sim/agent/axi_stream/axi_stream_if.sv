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
interface axi_stream_if#(TDATA_W, TUSER_W=8, TID_W=8, TDEST_W=4)(input aclk, input aresetn);

  logic                   tvalid;
  logic     [TDATA_W-1:0] tdata;
  logic [(TDATA_W/8)-1:0] tkeep;
  logic                   tlast;
  logic     [TUSER_W-1:0] tuser;
  logic       [TID_W-1:0] tid;
  logic     [TDEST_W-1:0] tdest;
  logic                   tready;

endinterface: axi_stream_if
