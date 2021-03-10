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
module open_nic #(
  parameter int MAX_PKT_LEN   = 1514,
  parameter int MIN_PKT_LEN   = 64,
  parameter int USE_PHYS_FUNC = 1,
  parameter int NUM_PHYS_FUNC = 1,
  parameter int NUM_QUEUE     = 2048,
  parameter int USE_CMAC_PORT = 1,
  parameter int NUM_CMAC_PORT = 1
) (
`ifdef __synthesis__
`ifdef __au280__
  output                         hbm_cattrip, // Fix the CATTRIP issue for AU280 custom flow
`endif

  input                   [15:0] pcie_rxp,
  input                   [15:0] pcie_rxn,
  output                  [15:0] pcie_txp,
  output                  [15:0] pcie_txn,
  input                          pcie_refclk_p,
  input                          pcie_refclk_n,
  input                          pcie_rstn,

  input    [4*NUM_CMAC_PORT-1:0] qsfp_rxp,
  input    [4*NUM_CMAC_PORT-1:0] qsfp_rxn,
  output   [4*NUM_CMAC_PORT-1:0] qsfp_txp,
  output   [4*NUM_CMAC_PORT-1:0] qsfp_txn,
  input      [NUM_CMAC_PORT-1:0] qsfp_refclk_p,
  input      [NUM_CMAC_PORT-1:0] qsfp_refclk_n
`else // !`ifdef __synthesis__
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

  input                          s_axis_qdma_h2c_tvalid,
  input                          s_axis_qdma_h2c_tlast,
  input                  [511:0] s_axis_qdma_h2c_tdata,
  input                   [63:0] s_axis_qdma_h2c_dpar,
  input                   [10:0] s_axis_qdma_h2c_tuser_qid,
  input                    [2:0] s_axis_qdma_h2c_tuser_port_id,
  input                          s_axis_qdma_h2c_tuser_err,
  input                   [31:0] s_axis_qdma_h2c_tuser_mdata,
  input                    [5:0] s_axis_qdma_h2c_tuser_mty,
  input                          s_axis_qdma_h2c_tuser_zero_byte,
  output                         s_axis_qdma_h2c_tready,

  output                         m_axis_qdma_c2h_tvalid,
  output                         m_axis_qdma_c2h_tlast,
  output                 [511:0] m_axis_qdma_c2h_tdata,
  output                  [63:0] m_axis_qdma_c2h_dpar,
  output                         m_axis_qdma_c2h_ctrl_marker,
  output                   [2:0] m_axis_qdma_c2h_ctrl_port_id,
  output                  [15:0] m_axis_qdma_c2h_ctrl_len,
  output                  [10:0] m_axis_qdma_c2h_ctrl_qid,
  output                         m_axis_qdma_c2h_ctrl_has_cmpt,
  output                   [5:0] m_axis_qdma_c2h_mty,
  input                          m_axis_qdma_c2h_tready,

  output                         m_axis_qdma_cpl_tvalid,
  output                 [511:0] m_axis_qdma_cpl_tdata,
  output                   [1:0] m_axis_qdma_cpl_size,
  output                  [15:0] m_axis_qdma_cpl_dpar,
  output                  [10:0] m_axis_qdma_cpl_ctrl_qid,
  output                   [1:0] m_axis_qdma_cpl_ctrl_cmpt_type,
  output                  [15:0] m_axis_qdma_cpl_ctrl_wait_pld_pkt_id,
  output                   [2:0] m_axis_qdma_cpl_ctrl_port_id,
  output                         m_axis_qdma_cpl_ctrl_marker,
  output                         m_axis_qdma_cpl_ctrl_user_trig,
  output                   [2:0] m_axis_qdma_cpl_ctrl_col_idx,
  output                   [2:0] m_axis_qdma_cpl_ctrl_err_idx,
  input                          m_axis_qdma_cpl_tready,

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

  output                         axil_aclk,
  output                         axis_aclk,
  output     [NUM_CMAC_PORT-1:0] cmac_clk,
  input                          powerup_rstn
`endif
  );

  // Parameter DRC
  initial begin
    if (MAX_PKT_LEN > 9600 || MAX_PKT_LEN < 256) begin
      $fatal("[%m] Maximum packet length should be within the range [256, 9600]");
    end
    if (MIN_PKT_LEN > 256 || MIN_PKT_LEN < 64) begin
      $fatal("[%m] Minimum packet length should be within the range [64, 256]");
    end
    if (USE_PHYS_FUNC) begin
      if (NUM_QUEUE > 2048 || NUM_QUEUE < 1) begin
        $fatal("[%m] Number of queues should be within the range [1, 2048]");
      end
      if ((NUM_QUEUE & (NUM_QUEUE - 1)) != 0) begin
        $fatal("[%m] Number of queues should be 2^n");
      end
      if (NUM_PHYS_FUNC > 4 || NUM_PHYS_FUNC < 1) begin
        $fatal("[%m] Number of physical functions should be within the range [1, 4]");
      end
    end
    if (USE_CMAC_PORT) begin
      if (NUM_CMAC_PORT > 2 || NUM_CMAC_PORT < 1) begin
        $fatal("[%m] Number of CMACs should be within the range [1, 2]");
      end
    end
  end

`ifdef __synthesis__
  wire                            axis_aclk;
  wire                            axil_aclk;
  wire        [NUM_CMAC_PORT-1:0] cmac_clk;
`endif

  wire                            axil_box0_awvalid;
  wire                  [31:0] axil_box0_awaddr;
  wire                         axil_box0_awready;
  wire                         axil_box0_wvalid;
  wire                  [31:0] axil_box0_wdata;
  wire                         axil_box0_wready;
  wire                         axil_box0_bvalid;
  wire                   [1:0] axil_box0_bresp;
  wire                         axil_box0_bready;
  wire                         axil_box0_arvalid;
  wire                  [31:0] axil_box0_araddr;
  wire                         axil_box0_arready;
  wire                         axil_box0_rvalid;
  wire                  [31:0] axil_box0_rdata;
  wire                   [1:0] axil_box0_rresp;
  wire                         axil_box0_rready;

  wire                         axil_box1_awvalid;
  wire                  [31:0] axil_box1_awaddr;
  wire                         axil_box1_awready;
  wire                         axil_box1_wvalid;
  wire                  [31:0] axil_box1_wdata;
  wire                         axil_box1_wready;
  wire                         axil_box1_bvalid;
  wire                   [1:0] axil_box1_bresp;
  wire                         axil_box1_bready;
  wire                         axil_box1_arvalid;
  wire                  [31:0] axil_box1_araddr;
  wire                         axil_box1_arready;
  wire                         axil_box1_rvalid;
  wire                  [31:0] axil_box1_rdata;
  wire                   [1:0] axil_box1_rresp;
  wire                         axil_box1_rready;

  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tvalid;
  wire [512*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tdata;
  wire  [64*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tkeep;
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tlast;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tuser_size;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tuser_src;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tuser_dst;
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tready;

  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tvalid;
  wire [512*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tdata;
  wire  [64*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tkeep;
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tlast;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tuser_size;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tuser_src;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tuser_dst;
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_tx_250mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_tx_250mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_tx_250mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_tx_250mhz_tlast;
  wire  [16*NUM_CMAC_PORT-1:0] axis_tx_250mhz_tuser_size;
  wire  [16*NUM_CMAC_PORT-1:0] axis_tx_250mhz_tuser_src;
  wire  [16*NUM_CMAC_PORT-1:0] axis_tx_250mhz_tuser_dst;
  wire     [NUM_CMAC_PORT-1:0] axis_tx_250mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_rx_250mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_rx_250mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_rx_250mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_rx_250mhz_tlast;
  wire  [16*NUM_CMAC_PORT-1:0] axis_rx_250mhz_tuser_size;
  wire  [16*NUM_CMAC_PORT-1:0] axis_rx_250mhz_tuser_src;
  wire  [16*NUM_CMAC_PORT-1:0] axis_rx_250mhz_tuser_dst;
  wire     [NUM_CMAC_PORT-1:0] axis_rx_250mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_adpt_tx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adpt_tx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adpt_tx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adpt_tx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adpt_tx_322mhz_tuser_err;
  wire     [NUM_CMAC_PORT-1:0] axis_adpt_tx_322mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_adpt_rx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_adpt_rx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_adpt_rx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_adpt_rx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_adpt_rx_322mhz_tuser_err;

  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_cmac_tx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_cmac_tx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_322mhz_tuser_err;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_322mhz_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_cmac_rx_322mhz_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_cmac_rx_322mhz_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_cmac_rx_322mhz_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_rx_322mhz_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_rx_322mhz_tuser_err;

  wire                  [31:0] user_rstn;
  wire                  [31:0] user_rst_done;

  wire                  [15:0] user_250mhz_rstn;
  wire                  [15:0] user_250mhz_rst_done;
  wire                   [7:0] user_322mhz_rstn;
  wire                   [7:0] user_322mhz_rst_done;

  wire                         box_250mhz_rstn;
  wire                         box_250mhz_rst_done;
  wire                         box_322mhz_rstn;
  wire                         box_322mhz_rst_done;

  // The box running at 250MHz takes 16+1 user reset pairs, with the extra one
  // used by the box itself.  Similarly, the box running at 322MHz takes 8+1
  // pairs.  The mapping is as follows.
  //
  // | 31    | 30    | 29 ... 24 | 23 ... 16 | 15 ... 0 |
  // ----------------------------------------------------
  // | b@250 | b@322 | Reserved  | user@322  | user@250 |
  assign user_250mhz_rstn     = user_rstn[15:0];
  assign user_rst_done[15:0]  = user_250mhz_rst_done;
  assign user_322mhz_rstn     = user_rstn[23:16];
  assign user_rst_done[23:16] = user_322mhz_rst_done;

  assign box_250mhz_rstn      = user_rstn[31];
  assign user_rst_done[31]    = box_250mhz_rst_done;
  assign box_322mhz_rstn      = user_rstn[30];
  assign user_rst_done[30]    = box_322mhz_rst_done;

  // Unused pairs must have their rst_done signals tied to 1
  assign user_rst_done[29:24] = {6{1'b1}};

  open_nic_shell #(
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .NUM_QUEUE     (NUM_QUEUE),
    .USE_CMAC_PORT (USE_CMAC_PORT),
    .NUM_CMAC_PORT (NUM_CMAC_PORT)
  ) shell_inst (
`ifdef __synthesis__
    .pcie_rxp                             (pcie_rxp),
    .pcie_rxn                             (pcie_rxn),
    .pcie_txp                             (pcie_txp),
    .pcie_txn                             (pcie_txn),
    .pcie_refclk_p                        (pcie_refclk_p),
    .pcie_refclk_n                        (pcie_refclk_n),
    .pcie_rstn                            (pcie_rstn),

    .qsfp_rxp                             (qsfp_rxp),
    .qsfp_rxn                             (qsfp_rxn),
    .qsfp_txp                             (qsfp_txp),
    .qsfp_txn                             (qsfp_txn),
    .qsfp_refclk_p                        (qsfp_refclk_p),
    .qsfp_refclk_n                        (qsfp_refclk_n),

`ifdef __au280__
    .hbm_cattrip                          (hbm_cattrip),
`endif
`else // !`ifdef __synthesis__
    .s_axil_awvalid                       (s_axil_awvalid),
    .s_axil_awaddr                        (s_axil_awaddr),
    .s_axil_awready                       (s_axil_awready),
    .s_axil_wvalid                        (s_axil_wvalid),
    .s_axil_wdata                         (s_axil_wdata),
    .s_axil_wready                        (s_axil_wready),
    .s_axil_bvalid                        (s_axil_bvalid),
    .s_axil_bresp                         (s_axil_bresp),
    .s_axil_bready                        (s_axil_bready),
    .s_axil_arvalid                       (s_axil_arvalid),
    .s_axil_araddr                        (s_axil_araddr),
    .s_axil_arready                       (s_axil_arready),
    .s_axil_rvalid                        (s_axil_rvalid),
    .s_axil_rdata                         (s_axil_rdata),
    .s_axil_rresp                         (s_axil_rresp),
    .s_axil_rready                        (s_axil_rready),

    .s_axis_qdma_h2c_tvalid               (s_axis_qdma_h2c_tvalid),
    .s_axis_qdma_h2c_tlast                (s_axis_qdma_h2c_tlast),
    .s_axis_qdma_h2c_tdata                (s_axis_qdma_h2c_tdata),
    .s_axis_qdma_h2c_dpar                 (s_axis_qdma_h2c_dpar),
    .s_axis_qdma_h2c_tuser_qid            (s_axis_qdma_h2c_tuser_qid),
    .s_axis_qdma_h2c_tuser_port_id        (s_axis_qdma_h2c_tuser_port_id),
    .s_axis_qdma_h2c_tuser_err            (s_axis_qdma_h2c_tuser_err),
    .s_axis_qdma_h2c_tuser_mdata          (s_axis_qdma_h2c_tuser_mdata),
    .s_axis_qdma_h2c_tuser_mty            (s_axis_qdma_h2c_tuser_mty),
    .s_axis_qdma_h2c_tuser_zero_byte      (s_axis_qdma_h2c_tuser_zero_byte),
    .s_axis_qdma_h2c_tready               (s_axis_qdma_h2c_tready),

    .m_axis_qdma_c2h_tvalid               (m_axis_qdma_c2h_tvalid),
    .m_axis_qdma_c2h_tlast                (m_axis_qdma_c2h_tlast),
    .m_axis_qdma_c2h_tdata                (m_axis_qdma_c2h_tdata),
    .m_axis_qdma_c2h_dpar                 (m_axis_qdma_c2h_dpar),
    .m_axis_qdma_c2h_ctrl_marker          (m_axis_qdma_c2h_ctrl_marker),
    .m_axis_qdma_c2h_ctrl_port_id         (m_axis_qdma_c2h_ctrl_port_id),
    .m_axis_qdma_c2h_ctrl_len             (m_axis_qdma_c2h_ctrl_len),
    .m_axis_qdma_c2h_ctrl_qid             (m_axis_qdma_c2h_ctrl_qid),
    .m_axis_qdma_c2h_ctrl_has_cmpt        (m_axis_qdma_c2h_ctrl_has_cmpt),
    .m_axis_qdma_c2h_mty                  (m_axis_qdma_c2h_mty),
    .m_axis_qdma_c2h_tready               (m_axis_qdma_c2h_tready),

    .m_axis_qdma_cpl_tvalid               (m_axis_qdma_cpl_tvalid),
    .m_axis_qdma_cpl_tdata                (m_axis_qdma_cpl_tdata),
    .m_axis_qdma_cpl_size                 (m_axis_qdma_cpl_size),
    .m_axis_qdma_cpl_dpar                 (m_axis_qdma_cpl_dpar),
    .m_axis_qdma_cpl_ctrl_qid             (m_axis_qdma_cpl_ctrl_qid),
    .m_axis_qdma_cpl_ctrl_cmpt_type       (m_axis_qdma_cpl_ctrl_cmpt_type),
    .m_axis_qdma_cpl_ctrl_wait_pld_pkt_id (m_axis_qdma_cpl_ctrl_wait_pld_pkt_id),
    .m_axis_qdma_cpl_ctrl_port_id         (m_axis_qdma_cpl_ctrl_port_id),
    .m_axis_qdma_cpl_ctrl_marker          (m_axis_qdma_cpl_ctrl_marker),
    .m_axis_qdma_cpl_ctrl_user_trig       (m_axis_qdma_cpl_ctrl_user_trig),
    .m_axis_qdma_cpl_ctrl_col_idx         (m_axis_qdma_cpl_ctrl_col_idx),
    .m_axis_qdma_cpl_ctrl_err_idx         (m_axis_qdma_cpl_ctrl_err_idx),
    .m_axis_qdma_cpl_tready               (m_axis_qdma_cpl_tready),

    .m_axis_cmac_tx_tvalid                (m_axis_cmac_tx_tvalid),
    .m_axis_cmac_tx_tdata                 (m_axis_cmac_tx_tdata),
    .m_axis_cmac_tx_tkeep                 (m_axis_cmac_tx_tkeep),
    .m_axis_cmac_tx_tlast                 (m_axis_cmac_tx_tlast),
    .m_axis_cmac_tx_tuser_err             (m_axis_cmac_tx_tuser_err),
    .m_axis_cmac_tx_tready                (m_axis_cmac_tx_tready),

    .s_axis_cmac_rx_tvalid                (s_axis_cmac_rx_tvalid),
    .s_axis_cmac_rx_tdata                 (s_axis_cmac_rx_tdata),
    .s_axis_cmac_rx_tkeep                 (s_axis_cmac_rx_tkeep),
    .s_axis_cmac_rx_tlast                 (s_axis_cmac_rx_tlast),
    .s_axis_cmac_rx_tuser_err             (s_axis_cmac_rx_tuser_err),

    .powerup_rstn                         (powerup_rstn),
`endif

    .m_axil_box0_awvalid                  (axil_box0_awvalid),
    .m_axil_box0_awaddr                   (axil_box0_awaddr),
    .m_axil_box0_awready                  (axil_box0_awready),
    .m_axil_box0_wvalid                   (axil_box0_wvalid),
    .m_axil_box0_wdata                    (axil_box0_wdata),
    .m_axil_box0_wready                   (axil_box0_wready),
    .m_axil_box0_bvalid                   (axil_box0_bvalid),
    .m_axil_box0_bresp                    (axil_box0_bresp),
    .m_axil_box0_bready                   (axil_box0_bready),
    .m_axil_box0_arvalid                  (axil_box0_arvalid),
    .m_axil_box0_araddr                   (axil_box0_araddr),
    .m_axil_box0_arready                  (axil_box0_arready),
    .m_axil_box0_rvalid                   (axil_box0_rvalid),
    .m_axil_box0_rdata                    (axil_box0_rdata),
    .m_axil_box0_rresp                    (axil_box0_rresp),
    .m_axil_box0_rready                   (axil_box0_rready),

    .m_axil_box1_awvalid                  (axil_box1_awvalid),
    .m_axil_box1_awaddr                   (axil_box1_awaddr),
    .m_axil_box1_awready                  (axil_box1_awready),
    .m_axil_box1_wvalid                   (axil_box1_wvalid),
    .m_axil_box1_wdata                    (axil_box1_wdata),
    .m_axil_box1_wready                   (axil_box1_wready),
    .m_axil_box1_bvalid                   (axil_box1_bvalid),
    .m_axil_box1_bresp                    (axil_box1_bresp),
    .m_axil_box1_bready                   (axil_box1_bready),
    .m_axil_box1_arvalid                  (axil_box1_arvalid),
    .m_axil_box1_araddr                   (axil_box1_araddr),
    .m_axil_box1_arready                  (axil_box1_arready),
    .m_axil_box1_rvalid                   (axil_box1_rvalid),
    .m_axil_box1_rdata                    (axil_box1_rdata),
    .m_axil_box1_rresp                    (axil_box1_rresp),
    .m_axil_box1_rready                   (axil_box1_rready),

    .m_axis_qdma_h2c_tvalid               (axis_qdma_h2c_tvalid),
    .m_axis_qdma_h2c_tdata                (axis_qdma_h2c_tdata),
    .m_axis_qdma_h2c_tkeep                (axis_qdma_h2c_tkeep),
    .m_axis_qdma_h2c_tlast                (axis_qdma_h2c_tlast),
    .m_axis_qdma_h2c_tuser_size           (axis_qdma_h2c_tuser_size),
    .m_axis_qdma_h2c_tuser_src            (axis_qdma_h2c_tuser_src),
    .m_axis_qdma_h2c_tuser_dst            (axis_qdma_h2c_tuser_dst),
    .m_axis_qdma_h2c_tready               (axis_qdma_h2c_tready),

    .s_axis_qdma_c2h_tvalid               (axis_qdma_c2h_tvalid),
    .s_axis_qdma_c2h_tdata                (axis_qdma_c2h_tdata),
    .s_axis_qdma_c2h_tkeep                (axis_qdma_c2h_tkeep),
    .s_axis_qdma_c2h_tlast                (axis_qdma_c2h_tlast),
    .s_axis_qdma_c2h_tuser_size           (axis_qdma_c2h_tuser_size),
    .s_axis_qdma_c2h_tuser_src            (axis_qdma_c2h_tuser_src),
    .s_axis_qdma_c2h_tuser_dst            (axis_qdma_c2h_tuser_dst),
    .s_axis_qdma_c2h_tready               (axis_qdma_c2h_tready),

    .s_axis_tx_250mhz_tvalid              (axis_tx_250mhz_tvalid),
    .s_axis_tx_250mhz_tdata               (axis_tx_250mhz_tdata),
    .s_axis_tx_250mhz_tkeep               (axis_tx_250mhz_tkeep),
    .s_axis_tx_250mhz_tlast               (axis_tx_250mhz_tlast),
    .s_axis_tx_250mhz_tuser_size          (axis_tx_250mhz_tuser_size),
    .s_axis_tx_250mhz_tuser_src           (axis_tx_250mhz_tuser_src),
    .s_axis_tx_250mhz_tuser_dst           (axis_tx_250mhz_tuser_dst),
    .s_axis_tx_250mhz_tready              (axis_tx_250mhz_tready),

    .m_axis_rx_250mhz_tvalid              (axis_rx_250mhz_tvalid),
    .m_axis_rx_250mhz_tdata               (axis_rx_250mhz_tdata),
    .m_axis_rx_250mhz_tkeep               (axis_rx_250mhz_tkeep),
    .m_axis_rx_250mhz_tlast               (axis_rx_250mhz_tlast),
    .m_axis_rx_250mhz_tuser_size          (axis_rx_250mhz_tuser_size),
    .m_axis_rx_250mhz_tuser_src           (axis_rx_250mhz_tuser_src),
    .m_axis_rx_250mhz_tuser_dst           (axis_rx_250mhz_tuser_dst),
    .m_axis_rx_250mhz_tready              (axis_rx_250mhz_tready),

    .m_axis_adpt_tx_322mhz_tvalid         (axis_adpt_tx_322mhz_tvalid),
    .m_axis_adpt_tx_322mhz_tdata          (axis_adpt_tx_322mhz_tdata),
    .m_axis_adpt_tx_322mhz_tkeep          (axis_adpt_tx_322mhz_tkeep),
    .m_axis_adpt_tx_322mhz_tlast          (axis_adpt_tx_322mhz_tlast),
    .m_axis_adpt_tx_322mhz_tuser_err      (axis_adpt_tx_322mhz_tuser_err),
    .m_axis_adpt_tx_322mhz_tready         (axis_adpt_tx_322mhz_tready),

    .s_axis_adpt_rx_322mhz_tvalid         (axis_adpt_rx_322mhz_tvalid),
    .s_axis_adpt_rx_322mhz_tdata          (axis_adpt_rx_322mhz_tdata),
    .s_axis_adpt_rx_322mhz_tkeep          (axis_adpt_rx_322mhz_tkeep),
    .s_axis_adpt_rx_322mhz_tlast          (axis_adpt_rx_322mhz_tlast),
    .s_axis_adpt_rx_322mhz_tuser_err      (axis_adpt_rx_322mhz_tuser_err),

    .s_axis_cmac_tx_322mhz_tvalid         (axis_cmac_tx_322mhz_tvalid),
    .s_axis_cmac_tx_322mhz_tdata          (axis_cmac_tx_322mhz_tdata),
    .s_axis_cmac_tx_322mhz_tkeep          (axis_cmac_tx_322mhz_tkeep),
    .s_axis_cmac_tx_322mhz_tlast          (axis_cmac_tx_322mhz_tlast),
    .s_axis_cmac_tx_322mhz_tuser_err      (axis_cmac_tx_322mhz_tuser_err),
    .s_axis_cmac_tx_322mhz_tready         (axis_cmac_tx_322mhz_tready),

    .m_axis_cmac_rx_322mhz_tvalid         (axis_cmac_rx_322mhz_tvalid),
    .m_axis_cmac_rx_322mhz_tdata          (axis_cmac_rx_322mhz_tdata),
    .m_axis_cmac_rx_322mhz_tkeep          (axis_cmac_rx_322mhz_tkeep),
    .m_axis_cmac_rx_322mhz_tlast          (axis_cmac_rx_322mhz_tlast),
    .m_axis_cmac_rx_322mhz_tuser_err      (axis_cmac_rx_322mhz_tuser_err),

    .user_rstn                            (user_rstn),
    .user_rst_done                        (user_rst_done),

    .axil_aclk                            (axil_aclk),
    .axis_aclk                            (axis_aclk),
    .cmac_clk                             (cmac_clk)
  );

  box_250mhz #(
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .USE_CMAC_PORT (USE_CMAC_PORT),
    .NUM_CMAC_PORT (NUM_CMAC_PORT)
  ) box_250mhz_inst (
    .s_axil_awvalid              (axil_box0_awvalid),
    .s_axil_awaddr               (axil_box0_awaddr),
    .s_axil_awready              (axil_box0_awready),
    .s_axil_wvalid               (axil_box0_wvalid),
    .s_axil_wdata                (axil_box0_wdata),
    .s_axil_wready               (axil_box0_wready),
    .s_axil_bvalid               (axil_box0_bvalid),
    .s_axil_bresp                (axil_box0_bresp),
    .s_axil_bready               (axil_box0_bready),
    .s_axil_arvalid              (axil_box0_arvalid),
    .s_axil_araddr               (axil_box0_araddr),
    .s_axil_arready              (axil_box0_arready),
    .s_axil_rvalid               (axil_box0_rvalid),
    .s_axil_rdata                (axil_box0_rdata),
    .s_axil_rresp                (axil_box0_rresp),
    .s_axil_rready               (axil_box0_rready),

    .s_axis_qdma_h2c_tvalid      (axis_qdma_h2c_tvalid),
    .s_axis_qdma_h2c_tdata       (axis_qdma_h2c_tdata),
    .s_axis_qdma_h2c_tkeep       (axis_qdma_h2c_tkeep),
    .s_axis_qdma_h2c_tlast       (axis_qdma_h2c_tlast),
    .s_axis_qdma_h2c_tuser_size  (axis_qdma_h2c_tuser_size),
    .s_axis_qdma_h2c_tuser_src   (axis_qdma_h2c_tuser_src),
    .s_axis_qdma_h2c_tuser_dst   (axis_qdma_h2c_tuser_dst),
    .s_axis_qdma_h2c_tready      (axis_qdma_h2c_tready),

    .m_axis_qdma_c2h_tvalid      (axis_qdma_c2h_tvalid),
    .m_axis_qdma_c2h_tdata       (axis_qdma_c2h_tdata),
    .m_axis_qdma_c2h_tkeep       (axis_qdma_c2h_tkeep),
    .m_axis_qdma_c2h_tlast       (axis_qdma_c2h_tlast),
    .m_axis_qdma_c2h_tuser_size  (axis_qdma_c2h_tuser_size),
    .m_axis_qdma_c2h_tuser_src   (axis_qdma_c2h_tuser_src),
    .m_axis_qdma_c2h_tuser_dst   (axis_qdma_c2h_tuser_dst),
    .m_axis_qdma_c2h_tready      (axis_qdma_c2h_tready),

    .m_axis_tx_250mhz_tvalid     (axis_tx_250mhz_tvalid),
    .m_axis_tx_250mhz_tdata      (axis_tx_250mhz_tdata),
    .m_axis_tx_250mhz_tkeep      (axis_tx_250mhz_tkeep),
    .m_axis_tx_250mhz_tlast      (axis_tx_250mhz_tlast),
    .m_axis_tx_250mhz_tuser_size (axis_tx_250mhz_tuser_size),
    .m_axis_tx_250mhz_tuser_src  (axis_tx_250mhz_tuser_src),
    .m_axis_tx_250mhz_tuser_dst  (axis_tx_250mhz_tuser_dst),
    .m_axis_tx_250mhz_tready     (axis_tx_250mhz_tready),

    .s_axis_rx_250mhz_tvalid     (axis_rx_250mhz_tvalid),
    .s_axis_rx_250mhz_tdata      (axis_rx_250mhz_tdata),
    .s_axis_rx_250mhz_tkeep      (axis_rx_250mhz_tkeep),
    .s_axis_rx_250mhz_tlast      (axis_rx_250mhz_tlast),
    .s_axis_rx_250mhz_tuser_size (axis_rx_250mhz_tuser_size),
    .s_axis_rx_250mhz_tuser_src  (axis_rx_250mhz_tuser_src),
    .s_axis_rx_250mhz_tuser_dst  (axis_rx_250mhz_tuser_dst),
    .s_axis_rx_250mhz_tready     (axis_rx_250mhz_tready),

    .mod_rstn                    (user_250mhz_rstn),
    .mod_rst_done                (user_250mhz_rst_done),

    .box_rstn                    (box_250mhz_rstn),
    .box_rst_done                (box_250mhz_rst_done),

    .axil_aclk                   (axil_aclk),
    .axis_aclk                   (axis_aclk)
  );

  box_322mhz #(
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .USE_CMAC_PORT (USE_CMAC_PORT),
    .NUM_CMAC_PORT (NUM_CMAC_PORT)
  ) box_322mhz_inst (
    .s_axil_awvalid                  (axil_box1_awvalid),
    .s_axil_awaddr                   (axil_box1_awaddr),
    .s_axil_awready                  (axil_box1_awready),
    .s_axil_wvalid                   (axil_box1_wvalid),
    .s_axil_wdata                    (axil_box1_wdata),
    .s_axil_wready                   (axil_box1_wready),
    .s_axil_bvalid                   (axil_box1_bvalid),
    .s_axil_bresp                    (axil_box1_bresp),
    .s_axil_bready                   (axil_box1_bready),
    .s_axil_arvalid                  (axil_box1_arvalid),
    .s_axil_araddr                   (axil_box1_araddr),
    .s_axil_arready                  (axil_box1_arready),
    .s_axil_rvalid                   (axil_box1_rvalid),
    .s_axil_rdata                    (axil_box1_rdata),
    .s_axil_rresp                    (axil_box1_rresp),
    .s_axil_rready                   (axil_box1_rready),

    .s_axis_adpt_tx_322mhz_tvalid    (axis_adpt_tx_322mhz_tvalid),
    .s_axis_adpt_tx_322mhz_tdata     (axis_adpt_tx_322mhz_tdata),
    .s_axis_adpt_tx_322mhz_tkeep     (axis_adpt_tx_322mhz_tkeep),
    .s_axis_adpt_tx_322mhz_tlast     (axis_adpt_tx_322mhz_tlast),
    .s_axis_adpt_tx_322mhz_tuser_err (axis_adpt_tx_322mhz_tuser_err),
    .s_axis_adpt_tx_322mhz_tready    (axis_adpt_tx_322mhz_tready),

    .m_axis_adpt_rx_322mhz_tvalid    (axis_adpt_rx_322mhz_tvalid),
    .m_axis_adpt_rx_322mhz_tdata     (axis_adpt_rx_322mhz_tdata),
    .m_axis_adpt_rx_322mhz_tkeep     (axis_adpt_rx_322mhz_tkeep),
    .m_axis_adpt_rx_322mhz_tlast     (axis_adpt_rx_322mhz_tlast),
    .m_axis_adpt_rx_322mhz_tuser_err (axis_adpt_rx_322mhz_tuser_err),

    .m_axis_cmac_tx_322mhz_tvalid    (axis_cmac_tx_322mhz_tvalid),
    .m_axis_cmac_tx_322mhz_tdata     (axis_cmac_tx_322mhz_tdata),
    .m_axis_cmac_tx_322mhz_tkeep     (axis_cmac_tx_322mhz_tkeep),
    .m_axis_cmac_tx_322mhz_tlast     (axis_cmac_tx_322mhz_tlast),
    .m_axis_cmac_tx_322mhz_tuser_err (axis_cmac_tx_322mhz_tuser_err),
    .m_axis_cmac_tx_322mhz_tready    (axis_cmac_tx_322mhz_tready),

    .s_axis_cmac_rx_322mhz_tvalid    (axis_cmac_rx_322mhz_tvalid),
    .s_axis_cmac_rx_322mhz_tdata     (axis_cmac_rx_322mhz_tdata),
    .s_axis_cmac_rx_322mhz_tkeep     (axis_cmac_rx_322mhz_tkeep),
    .s_axis_cmac_rx_322mhz_tlast     (axis_cmac_rx_322mhz_tlast),
    .s_axis_cmac_rx_322mhz_tuser_err (axis_cmac_rx_322mhz_tuser_err),

    .mod_rstn                        (user_322mhz_rstn),
    .mod_rst_done                    (user_322mhz_rst_done),

    .box_rstn                        (box_322mhz_rstn),
    .box_rst_done                    (box_322mhz_rst_done),

    .axil_aclk                       (axil_aclk),
    .cmac_clk                        (cmac_clk)
  );

endmodule: open_nic
