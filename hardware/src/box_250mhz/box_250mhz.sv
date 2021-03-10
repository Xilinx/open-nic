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
module box_250mhz #(
  parameter int MAX_PKT_LEN   = 1514,
  parameter int MIN_PKT_LEN   = 64,
  parameter int USE_PHYS_FUNC = 1,
  parameter int NUM_PHYS_FUNC = 1,
  parameter int USE_CMAC_PORT = 1,
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

  input      [NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tvalid,
  input  [512*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tdata,
  input   [64*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tkeep,
  input      [NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tlast,
  input   [16*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tuser_size,
  input   [16*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tuser_src,
  input   [16*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tuser_dst,
  output     [NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tready,

  output     [NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tvalid,
  output [512*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tdata,
  output  [64*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tkeep,
  output     [NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tlast,
  output  [16*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tuser_size,
  output  [16*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tuser_src,
  output  [16*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tuser_dst,
  input      [NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tready,

  output     [NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tvalid,
  output [512*NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tdata,
  output  [64*NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tkeep,
  output     [NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tlast,
  output  [16*NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tuser_size,
  output  [16*NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tuser_src,
  output  [16*NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tuser_dst,
  input      [NUM_CMAC_PORT-1:0] m_axis_tx_250mhz_tready,

  input      [NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tvalid,
  input  [512*NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tdata,
  input   [64*NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tkeep,
  input      [NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tlast,
  input   [16*NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tuser_size,
  input   [16*NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tuser_src,
  input   [16*NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tuser_dst,
  output     [NUM_CMAC_PORT-1:0] s_axis_rx_250mhz_tready,

  input                   [15:0] mod_rstn,
  output                  [15:0] mod_rst_done,

  input                          box_rstn,
  output                         box_rst_done,

  input                          axil_aclk,
  input                          axis_aclk
);

  // Reset for user logic box instance; do NOT touch
  wire internal_box_rstn;
  box_250mhz_reset reset_inst (
    .mod_rstn     (box_rstn),
    .mod_rst_done (box_rst_done),
    .box_rstn     (internal_box_rstn),
    .axil_aclk    (axil_aclk)
  );

  // Add interface signals for each user module
  wire        axil_pt_awvalid;
  wire [31:0] axil_pt_awaddr;
  wire        axil_pt_awready;
  wire        axil_pt_wvalid;
  wire [31:0] axil_pt_wdata;
  wire        axil_pt_wready;
  wire        axil_pt_bvalid;
  wire  [1:0] axil_pt_bresp;
  wire        axil_pt_bready;
  wire        axil_pt_arvalid;
  wire [31:0] axil_pt_araddr;
  wire        axil_pt_arready;
  wire        axil_pt_rvalid;
  wire [31:0] axil_pt_rdata;
  wire  [1:0] axil_pt_rresp;
  wire        axil_pt_rready;

  // Dummy signals as a workaround as AXI crossbar requires a minimum of two
  // master interfaces
  wire        axil_dummy_awvalid;
  wire [31:0] axil_dummy_awaddr;
  wire        axil_dummy_awready;
  wire        axil_dummy_wvalid;
  wire [31:0] axil_dummy_wdata;
  wire        axil_dummy_wready;
  wire        axil_dummy_bvalid;
  wire  [1:0] axil_dummy_bresp;
  wire        axil_dummy_bready;
  wire        axil_dummy_arvalid;
  wire [31:0] axil_dummy_araddr;
  wire        axil_dummy_arready;
  wire        axil_dummy_rvalid;
  wire [31:0] axil_dummy_rdata;
  wire  [1:0] axil_dummy_rresp;
  wire        axil_dummy_rready;

  // Update the address map so that each user module that requires an AXI-lite
  // interface will get one
  box_250mhz_address_map address_map_inst (
    .s_axil_awvalid       (s_axil_awvalid),
    .s_axil_awaddr        (s_axil_awaddr),
    .s_axil_awready       (s_axil_awready),
    .s_axil_wvalid        (s_axil_wvalid),
    .s_axil_wdata         (s_axil_wdata),
    .s_axil_wready        (s_axil_wready),
    .s_axil_bvalid        (s_axil_bvalid),
    .s_axil_bresp         (s_axil_bresp),
    .s_axil_bready        (s_axil_bready),
    .s_axil_arvalid       (s_axil_arvalid),
    .s_axil_araddr        (s_axil_araddr),
    .s_axil_arready       (s_axil_arready),
    .s_axil_rvalid        (s_axil_rvalid),
    .s_axil_rdata         (s_axil_rdata),
    .s_axil_rresp         (s_axil_rresp),
    .s_axil_rready        (s_axil_rready),

    .m_axil_pt_awvalid    (axil_pt_awvalid),
    .m_axil_pt_awaddr     (axil_pt_awaddr),
    .m_axil_pt_awready    (axil_pt_awready),
    .m_axil_pt_wvalid     (axil_pt_wvalid),
    .m_axil_pt_wdata      (axil_pt_wdata),
    .m_axil_pt_wready     (axil_pt_wready),
    .m_axil_pt_bvalid     (axil_pt_bvalid),
    .m_axil_pt_bresp      (axil_pt_bresp),
    .m_axil_pt_bready     (axil_pt_bready),
    .m_axil_pt_arvalid    (axil_pt_arvalid),
    .m_axil_pt_araddr     (axil_pt_araddr),
    .m_axil_pt_arready    (axil_pt_arready),
    .m_axil_pt_rvalid     (axil_pt_rvalid),
    .m_axil_pt_rdata      (axil_pt_rdata),
    .m_axil_pt_rresp      (axil_pt_rresp),
    .m_axil_pt_rready     (axil_pt_rready),

    // Dummy interface only to satisfy the requirement of AXI crossbar IP, i.e.,
    // a minimum of two master interface.
    .m_axil_dummy_awvalid (axil_dummy_awvalid),
    .m_axil_dummy_awaddr  (axil_dummy_awaddr),
    .m_axil_dummy_awready (axil_dummy_awready),
    .m_axil_dummy_wvalid  (axil_dummy_wvalid),
    .m_axil_dummy_wdata   (axil_dummy_wdata),
    .m_axil_dummy_wready  (axil_dummy_wready),
    .m_axil_dummy_bvalid  (axil_dummy_bvalid),
    .m_axil_dummy_bresp   (axil_dummy_bresp),
    .m_axil_dummy_bready  (axil_dummy_bready),
    .m_axil_dummy_arvalid (axil_dummy_arvalid),
    .m_axil_dummy_araddr  (axil_dummy_araddr),
    .m_axil_dummy_arready (axil_dummy_arready),
    .m_axil_dummy_rvalid  (axil_dummy_rvalid),
    .m_axil_dummy_rdata   (axil_dummy_rdata),
    .m_axil_dummy_rresp   (axil_dummy_rresp),
    .m_axil_dummy_rready  (axil_dummy_rready),

    .aclk                 (axil_aclk),
    .aresetn              (internal_box_rstn)
  );

  // Sample user module that simply connects data path
  generate if (USE_PHYS_FUNC == 0) begin
    // Make sure for all the unused reset pair, corresponding bits in
    // "mod_rst_done" are tied to 0
    assign mod_rst_done[15:0] = {16{1'b1}};

    // Terminate H2C and C2H interfaces of the box
    assign s_axis_qdma_h2c_tready     = 1'b1;

    assign m_axis_qdma_c2h_tvalid     = 1'b0;
    assign m_axis_qdma_c2h_tdata      = 0;
    assign m_axis_qdma_c2h_tkeep      = 0;
    assign m_axis_qdma_c2h_tlast      = 1'b0;
    assign m_axis_qdma_c2h_tuser_size = 0;
    assign m_axis_qdma_c2h_tuser_src  = 0;
    assign m_axis_qdma_c2h_tuser_dst  = 0;

    // Loopback the TX and RX interface
    assign m_axis_tx_250mhz_tvalid     = s_axis_rx_250mhz_tvalid;
    assign m_axis_tx_250mhz_tdata      = s_axis_rx_250mhz_tdata;
    assign m_axis_tx_250mhz_tkeep      = s_axis_rx_250mhz_tkeep;
    assign m_axis_tx_250mhz_tlast      = s_axis_rx_250mhz_tlast;
    assign m_axis_tx_250mhz_tuser_size = s_axis_rx_250mhz_tuser_size;
    assign m_axis_tx_250mhz_tuser_src  = s_axis_rx_250mhz_tuser_src;
    assign m_axis_tx_250mhz_tuser_dst  = s_axis_rx_250mhz_tuser_dst;
    assign s_axis_rx_250mhz_tready     = m_axis_tx_250mhz_tready;

    axi_lite_slave #(
      .REG_ADDR_W (12),
      .REG_PREFIX (16'hD000)
    ) pt_reg_inst (
      .s_axil_awvalid (axil_pt_awvalid),
      .s_axil_awaddr  (axil_pt_awaddr),
      .s_axil_awready (axil_pt_awready),
      .s_axil_wvalid  (axil_pt_wvalid),
      .s_axil_wdata   (axil_pt_wdata),
      .s_axil_wready  (axil_pt_wready),
      .s_axil_bvalid  (axil_pt_bvalid),
      .s_axil_bresp   (axil_pt_bresp),
      .s_axil_bready  (axil_pt_bready),
      .s_axil_arvalid (axil_pt_arvalid),
      .s_axil_araddr  (axil_pt_araddr),
      .s_axil_arready (axil_pt_arready),
      .s_axil_rvalid  (axil_pt_rvalid),
      .s_axil_rdata   (axil_pt_rdata),
      .s_axil_rresp   (axil_pt_rresp),
      .s_axil_rready  (axil_pt_rready),

      .aresetn        (internal_box_rstn),
      .aclk           (axil_aclk)
    );
  end
  else if (NUM_CMAC_PORT == NUM_PHYS_FUNC) begin
    // Add reset pair signals for each user module and connect the reset pair to
    // an unused slot
    wire pt_rstn;
    wire pt_rst_done;

    assign pt_rstn         = mod_rstn[0];
    assign mod_rst_done[0] = pt_rst_done;

    // Make sure for all the unused reset pair, corresponding bits in
    // "mod_rst_done" are tied to 0
    assign mod_rst_done[15:1] = {15{1'b1}};

    passthrough_250mhz #(
      .NUM_INTF (NUM_PHYS_FUNC)
    ) pt_inst (
      .s_axil_awvalid              (axil_pt_awvalid),
      .s_axil_awaddr               (axil_pt_awaddr),
      .s_axil_awready              (axil_pt_awready),
      .s_axil_wvalid               (axil_pt_wvalid),
      .s_axil_wdata                (axil_pt_wdata),
      .s_axil_wready               (axil_pt_wready),
      .s_axil_bvalid               (axil_pt_bvalid),
      .s_axil_bresp                (axil_pt_bresp),
      .s_axil_bready               (axil_pt_bready),
      .s_axil_arvalid              (axil_pt_arvalid),
      .s_axil_araddr               (axil_pt_araddr),
      .s_axil_arready              (axil_pt_arready),
      .s_axil_rvalid               (axil_pt_rvalid),
      .s_axil_rdata                (axil_pt_rdata),
      .s_axil_rresp                (axil_pt_rresp),
      .s_axil_rready               (axil_pt_rready),

      .s_axis_qdma_h2c_tvalid      (s_axis_qdma_h2c_tvalid),
      .s_axis_qdma_h2c_tdata       (s_axis_qdma_h2c_tdata),
      .s_axis_qdma_h2c_tkeep       (s_axis_qdma_h2c_tkeep),
      .s_axis_qdma_h2c_tlast       (s_axis_qdma_h2c_tlast),
      .s_axis_qdma_h2c_tuser_size  (s_axis_qdma_h2c_tuser_size),
      .s_axis_qdma_h2c_tuser_src   (s_axis_qdma_h2c_tuser_src),
      .s_axis_qdma_h2c_tuser_dst   (s_axis_qdma_h2c_tuser_dst),
      .s_axis_qdma_h2c_tready      (s_axis_qdma_h2c_tready),

      .m_axis_qdma_c2h_tvalid      (m_axis_qdma_c2h_tvalid),
      .m_axis_qdma_c2h_tdata       (m_axis_qdma_c2h_tdata),
      .m_axis_qdma_c2h_tkeep       (m_axis_qdma_c2h_tkeep),
      .m_axis_qdma_c2h_tlast       (m_axis_qdma_c2h_tlast),
      .m_axis_qdma_c2h_tuser_size  (m_axis_qdma_c2h_tuser_size),
      .m_axis_qdma_c2h_tuser_src   (m_axis_qdma_c2h_tuser_src),
      .m_axis_qdma_c2h_tuser_dst   (m_axis_qdma_c2h_tuser_dst),
      .m_axis_qdma_c2h_tready      (m_axis_qdma_c2h_tready),

      .m_axis_tx_250mhz_tvalid     (m_axis_tx_250mhz_tvalid),
      .m_axis_tx_250mhz_tdata      (m_axis_tx_250mhz_tdata),
      .m_axis_tx_250mhz_tkeep      (m_axis_tx_250mhz_tkeep),
      .m_axis_tx_250mhz_tlast      (m_axis_tx_250mhz_tlast),
      .m_axis_tx_250mhz_tuser_size (m_axis_tx_250mhz_tuser_size),
      .m_axis_tx_250mhz_tuser_src  (m_axis_tx_250mhz_tuser_src),
      .m_axis_tx_250mhz_tuser_dst  (m_axis_tx_250mhz_tuser_dst),
      .m_axis_tx_250mhz_tready     (m_axis_tx_250mhz_tready),

      .s_axis_rx_250mhz_tvalid     (s_axis_rx_250mhz_tvalid),
      .s_axis_rx_250mhz_tdata      (s_axis_rx_250mhz_tdata),
      .s_axis_rx_250mhz_tkeep      (s_axis_rx_250mhz_tkeep),
      .s_axis_rx_250mhz_tlast      (s_axis_rx_250mhz_tlast),
      .s_axis_rx_250mhz_tuser_size (s_axis_rx_250mhz_tuser_size),
      .s_axis_rx_250mhz_tuser_src  (s_axis_rx_250mhz_tuser_src),
      .s_axis_rx_250mhz_tuser_dst  (s_axis_rx_250mhz_tuser_dst),
      .s_axis_rx_250mhz_tready     (s_axis_rx_250mhz_tready),

      .mod_rstn                    (pt_rstn),
      .mod_rst_done                (pt_rst_done),

      .axil_aclk                   (axil_aclk),
      .axis_aclk                   (axis_aclk)
    );
  end
  else begin
    initial begin
      $fatal("No user logic module implemented for NUM_PHYS_FUNC = %d and NUM_CMAC_PORT = %d",
        NUM_PHYS_FUNC, NUM_CMAC_PORT);
    end
  end
  endgenerate

  // Sink for the unused dummy register interface
  axi_lite_slave #(
    .REG_ADDR_W (12),
    .REG_PREFIX (16'hD000)
  ) dummy_reg_inst (
    .s_axil_awvalid (axil_dummy_awvalid),
    .s_axil_awaddr  (axil_dummy_awaddr),
    .s_axil_awready (axil_dummy_awready),
    .s_axil_wvalid  (axil_dummy_wvalid),
    .s_axil_wdata   (axil_dummy_wdata),
    .s_axil_wready  (axil_dummy_wready),
    .s_axil_bvalid  (axil_dummy_bvalid),
    .s_axil_bresp   (axil_dummy_bresp),
    .s_axil_bready  (axil_dummy_bready),
    .s_axil_arvalid (axil_dummy_arvalid),
    .s_axil_araddr  (axil_dummy_araddr),
    .s_axil_arready (axil_dummy_arready),
    .s_axil_rvalid  (axil_dummy_rvalid),
    .s_axil_rdata   (axil_dummy_rdata),
    .s_axil_rresp   (axil_dummy_rresp),
    .s_axil_rready  (axil_dummy_rready),

    .aresetn        (internal_box_rstn),
    .aclk           (axil_aclk)
  );

endmodule: box_250mhz
