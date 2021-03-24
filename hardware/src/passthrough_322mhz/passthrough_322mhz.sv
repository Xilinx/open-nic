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
`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
module passthrough_322mhz #(
  parameter int NUM_CMAC_PORT = 1
) (
  input                          s_axil_awvalid,
  input                   [31:0] s_axil_awaddr,
  output                         s_axil_awready,
  input                          s_axil_wvalid,
  input                   [31:0] s_axil_wdata,
  output                         s_axil_wready,
  output                         s_axil_bvalid,
  output                   [1:0] s_axil_bresp,
  input                          s_axil_bready,
  input                          s_axil_arvalid,
  input                   [31:0] s_axil_araddr,
  output                         s_axil_arready,
  output                         s_axil_rvalid,
  output                  [31:0] s_axil_rdata,
  output                   [1:0] s_axil_rresp,
  input                          s_axil_rready,

  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tvalid,
  input  [512*NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tlast,
  input      [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tuser_err,
  output     [NUM_CMAC_PORT-1:0] s_axis_adap_tx_322mhz_tready,

  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tlast,
  output     [NUM_CMAC_PORT-1:0] m_axis_adap_rx_322mhz_tuser_err,

  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tlast,
  output     [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tuser_err,
  input      [NUM_CMAC_PORT-1:0] m_axis_cmac_tx_tready,

  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tvalid,
  input  [512*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tlast,
  input      [NUM_CMAC_PORT-1:0] s_axis_cmac_rx_tuser_err,

  input                          mod_rstn,
  output                         mod_rst_done,

  input                          axil_aclk,
  input      [NUM_CMAC_PORT-1:0] cmac_clk
);

  wire                         axil_aresetn;
  wire     [NUM_CMAC_PORT-1:0] cmac_rstn;

  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tuser_err;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_tx_322mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adap_rx_322mhz_tuser_err;

  generic_reset #(
    .NUM_INPUT_CLK  (1 + NUM_CMAC_PORT),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (mod_rstn),
    .mod_rst_done (mod_rst_done),
    .clk          ({cmac_clk, axil_aclk}),
    .rstn         ({cmac_rstn, axil_aresetn})
  );

  axi_lite_slave #(
    .REG_ADDR_W (12),
    .REG_PREFIX (16'hB001)
  ) reg_inst (
    .s_axil_awvalid (s_axil_awvalid),
    .s_axil_awaddr  (s_axil_awaddr),
    .s_axil_awready (s_axil_awready),
    .s_axil_wvalid  (s_axil_wvalid),
    .s_axil_wdata   (s_axil_wdata),
    .s_axil_wready  (s_axil_wready),
    .s_axil_bvalid  (s_axil_bvalid),
    .s_axil_bresp   (s_axil_bresp),
    .s_axil_bready  (s_axil_bready),
    .s_axil_arvalid (s_axil_arvalid),
    .s_axil_araddr  (s_axil_araddr),
    .s_axil_arready (s_axil_arready),
    .s_axil_rvalid  (s_axil_rvalid),
    .s_axil_rdata   (s_axil_rdata),
    .s_axil_rresp   (s_axil_rresp),
    .s_axil_rready  (s_axil_rready),

    .aclk           (axil_aclk),
    .aresetn        (axil_aresetn)
  );

  generate for (genvar i = 0; i < NUM_CMAC_PORT; i++) begin
    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_0_inst (
      .s_axis_tvalid (s_axis_adap_tx_322mhz_tvalid[i]),
      .s_axis_tdata  (s_axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (s_axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (s_axis_adap_tx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_adap_tx_322mhz_tuser_err[i]),
      .s_axis_tready (s_axis_adap_tx_322mhz_tready[i]),

      .m_axis_tvalid (axis_adap_tx_322mhz_tvalid[i]),
      .m_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (axis_adap_tx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_tx_322mhz_tuser_err[i]),
      .m_axis_tready (axis_adap_tx_322mhz_tready[i]),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) tx_slice_1_inst (
      .s_axis_tvalid (axis_adap_tx_322mhz_tvalid[i]),
      .s_axis_tdata  (axis_adap_tx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (axis_adap_tx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (axis_adap_tx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (axis_adap_tx_322mhz_tuser_err[i]),
      .s_axis_tready (axis_adap_tx_322mhz_tready[i]),

      .m_axis_tvalid (m_axis_cmac_tx_tvalid[i]),
      .m_axis_tdata  (m_axis_cmac_tx_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (m_axis_cmac_tx_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (m_axis_cmac_tx_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_cmac_tx_tuser_err[i]),
      .m_axis_tready (m_axis_cmac_tx_tready[i]),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_0_inst (
      .s_axis_tvalid (s_axis_cmac_rx_tvalid[i]),
      .s_axis_tdata  (s_axis_cmac_rx_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (s_axis_cmac_rx_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (s_axis_cmac_rx_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (s_axis_cmac_rx_tuser_err[i]),
      .s_axis_tready (),

      .m_axis_tvalid (axis_adap_rx_322mhz_tvalid[i]),
      .m_axis_tdata  (axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (axis_adap_rx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (axis_adap_rx_322mhz_tuser_err[i]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );

    axi_stream_register_slice #(
      .TDATA_W (512),
      .TUSER_W (1),
      .MODE    ("full")
    ) rx_slice_1_inst (
      .s_axis_tvalid (axis_adap_rx_322mhz_tvalid[i]),
      .s_axis_tdata  (axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .s_axis_tkeep  (axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .s_axis_tlast  (axis_adap_rx_322mhz_tlast[i]),
      .s_axis_tid    (0),
      .s_axis_tdest  (0),
      .s_axis_tuser  (axis_adap_rx_322mhz_tuser_err[i]),
      .s_axis_tready (),

      .m_axis_tvalid (m_axis_adap_rx_322mhz_tvalid[i]),
      .m_axis_tdata  (m_axis_adap_rx_322mhz_tdata[`getvec(512, i)]),
      .m_axis_tkeep  (m_axis_adap_rx_322mhz_tkeep[`getvec(64, i)]),
      .m_axis_tlast  (m_axis_adap_rx_322mhz_tlast[i]),
      .m_axis_tid    (),
      .m_axis_tdest  (),
      .m_axis_tuser  (m_axis_adap_rx_322mhz_tuser_err[i]),
      .m_axis_tready (1'b1),

      .aclk          (cmac_clk[i]),
      .aresetn       (cmac_rstn[i])
    );
  end
  endgenerate

endmodule: passthrough_322mhz
