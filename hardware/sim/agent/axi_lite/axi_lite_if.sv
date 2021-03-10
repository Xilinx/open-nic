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
interface axi_lite_if(input aclk, input aresetn);

  logic        arvalid;
  logic [31:0] araddr;
  logic        arready;

  logic        rvalid;
  logic [31:0] rdata;
  logic  [1:0] rresp;
  logic        rready;

  logic        awvalid;
  logic [31:0] awaddr;
  logic        awready;

  logic        wvalid;
  logic [31:0] wdata;
  logic  [3:0] wstrb;
  logic        wready;

  logic        bvalid;
  logic  [1:0] bresp;
  logic        bready;

endinterface: axi_lite_if
