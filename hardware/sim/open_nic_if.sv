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
interface open_nic_if(input powerup_rstn);

  localparam MAX_CMAC = 2;

  logic                axil_aclk;
  logic                axis_aclk;
  logic [MAX_CMAC-1:0] cmac_clk;

  axi_lite_if s_axil(axil_aclk, powerup_rstn);

  qdma_h2c_if#(.TDATA_W(512)) qdma_h2c(axis_aclk, powerup_rstn);
  qdma_c2h_if#(.TDATA_W(512)) qdma_c2h(axis_aclk, powerup_rstn);
  qdma_cpl_if qdma_cpl(axis_aclk, powerup_rstn);

  axi_stream_if#(.TDATA_W(512), .TUSER_W(1)) cmac_tx[MAX_CMAC]();
  axi_stream_if#(.TDATA_W(512), .TUSER_W(1)) cmac_rx[MAX_CMAC]();

  generate for (genvar i = 0; i < MAX_CMAC; i++) begin
    assign cmac_tx[i].aclk    = cmac_clk[i];
    assign cmac_rx[i].aclk    = cmac_clk[i];
    assign cmac_tx[i].aresetn = powerup_rstn;
    assign cmac_rx[i].aresetn = powerup_rstn;
  end
  endgenerate

endinterface: open_nic_if
