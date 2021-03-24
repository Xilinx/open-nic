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
module open_nic_wrapper#(
  parameter MAX_PKT_LEN   = 1514,
  parameter MIN_PKT_LEN   = 64,
  parameter USE_PHYS_FUNC = 1,
  parameter NUM_PHYS_FUNC = 1,
  parameter NUM_QUEUE     = 2048,
  parameter NUM_CMAC_PORT = 1
) (open_nic_if _if);

  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_cmac_tx_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_cmac_tx_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_tuser_err;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_tx_tready;

  wire     [NUM_CMAC_PORT-1:0] axis_cmac_rx_tvalid;
  wire [512*NUM_CMAC_PORT-1:0] axis_cmac_rx_tdata;
  wire  [64*NUM_CMAC_PORT-1:0] axis_cmac_rx_tkeep;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_rx_tlast;
  wire     [NUM_CMAC_PORT-1:0] axis_cmac_rx_tuser_err;

  generate for (genvar i = 0; i < NUM_CMAC_PORT; i++) begin
    assign _if.cmac_tx[i].tvalid               = axis_cmac_tx_tvalid[i];
    assign _if.cmac_tx[i].tdata                = axis_cmac_tx_tdata[`getvec(512, i)];
    assign _if.cmac_tx[i].tkeep                = axis_cmac_tx_tkeep[`getvec(64, i)];
    assign _if.cmac_tx[i].tlast                = axis_cmac_tx_tlast[i];
    assign _if.cmac_tx[i].tuser                = axis_cmac_tx_tuser_err[i];
    assign axis_cmac_tx_tready[i]              = _if.cmac_tx[i].tready;

    assign axis_cmac_rx_tvalid[i]              = _if.cmac_rx[i].tvalid;
    assign axis_cmac_rx_tdata[`getvec(512, i)] = _if.cmac_rx[i].tdata;
    assign axis_cmac_rx_tkeep[`getvec(64, i)]  = _if.cmac_rx[i].tkeep;
    assign axis_cmac_rx_tlast[i]               = _if.cmac_rx[i].tlast;
    assign axis_cmac_rx_tuser_err[i]           = _if.cmac_rx[i].tuser;
    assign _if.cmac_rx[i].tready               = 1'b1;
  end
  endgenerate

  open_nic #(
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .NUM_QUEUE     (NUM_QUEUE),
    .NUM_CMAC_PORT (NUM_CMAC_PORT)
  ) dut (
    .s_axil_sim_awvalid                       (_if.s_axil.awvalid),
    .s_axil_sim_awaddr                        (_if.s_axil.awaddr),
    .s_axil_sim_awready                       (_if.s_axil.awready),
    .s_axil_sim_wvalid                        (_if.s_axil.wvalid),
    .s_axil_sim_wdata                         (_if.s_axil.wdata),
    .s_axil_sim_wready                        (_if.s_axil.wready),
    .s_axil_sim_bvalid                        (_if.s_axil.bvalid),
    .s_axil_sim_bresp                         (_if.s_axil.bresp),
    .s_axil_sim_bready                        (_if.s_axil.bready),
    .s_axil_sim_arvalid                       (_if.s_axil.arvalid),
    .s_axil_sim_araddr                        (_if.s_axil.araddr),
    .s_axil_sim_arready                       (_if.s_axil.arready),
    .s_axil_sim_rvalid                        (_if.s_axil.rvalid),
    .s_axil_sim_rdata                         (_if.s_axil.rdata),
    .s_axil_sim_rresp                         (_if.s_axil.rresp),
    .s_axil_sim_rready                        (_if.s_axil.rready),

    .s_axis_qdma_h2c_sim_tvalid               (_if.qdma_h2c.tvalid),
    .s_axis_qdma_h2c_sim_tdata                (_if.qdma_h2c.tdata),
    .s_axis_qdma_h2c_sim_tcrc                 (_if.qdma_h2c.tcrc),
    .s_axis_qdma_h2c_sim_tlast                (_if.qdma_h2c.tlast),
    .s_axis_qdma_h2c_sim_tuser_qid            (_if.qdma_h2c.tuser_qid),
    .s_axis_qdma_h2c_sim_tuser_port_id        (_if.qdma_h2c.tuser_port_id),
    .s_axis_qdma_h2c_sim_tuser_err            (_if.qdma_h2c.tuser_err),
    .s_axis_qdma_h2c_sim_tuser_mdata          (_if.qdma_h2c.tuser_mdata),
    .s_axis_qdma_h2c_sim_tuser_mty            (_if.qdma_h2c.tuser_mty),
    .s_axis_qdma_h2c_sim_tuser_zero_byte      (_if.qdma_h2c.tuser_zero_byte),
    .s_axis_qdma_h2c_sim_tready               (_if.qdma_h2c.tready),

    .m_axis_qdma_c2h_sim_tvalid               (_if.qdma_c2h.tvalid),
    .m_axis_qdma_c2h_sim_tdata                (_if.qdma_c2h.tdata),
    .m_axis_qdma_c2h_sim_tcrc                 (_if.qdma_c2h.tcrc),
    .m_axis_qdma_c2h_sim_tlast                (_if.qdma_c2h.tlast),
    .m_axis_qdma_c2h_sim_ctrl_marker          (_if.qdma_c2h.ctrl_marker),
    .m_axis_qdma_c2h_sim_ctrl_port_id         (_if.qdma_c2h.ctrl_port_id),
    .m_axis_qdma_c2h_sim_ctrl_ecc             (_if.qdma_c2h.ctrl_ecc),
    .m_axis_qdma_c2h_sim_ctrl_len             (_if.qdma_c2h.ctrl_len),
    .m_axis_qdma_c2h_sim_ctrl_qid             (_if.qdma_c2h.ctrl_qid),
    .m_axis_qdma_c2h_sim_ctrl_has_cmpt        (_if.qdma_c2h.ctrl_has_cmpt),
    .m_axis_qdma_c2h_sim_mty                  (_if.qdma_c2h.mty),
    .m_axis_qdma_c2h_sim_tready               (_if.qdma_c2h.tready),

    .m_axis_qdma_cpl_sim_tvalid               (_if.qdma_cpl.tvalid),
    .m_axis_qdma_cpl_sim_tdata                (_if.qdma_cpl.tdata),
    .m_axis_qdma_cpl_sim_size                 (_if.qdma_cpl.size),
    .m_axis_qdma_cpl_sim_dpar                 (_if.qdma_cpl.dpar),
    .m_axis_qdma_cpl_sim_ctrl_qid             (_if.qdma_cpl.ctrl_qid),
    .m_axis_qdma_cpl_sim_ctrl_cmpt_type       (_if.qdma_cpl.ctrl_cmpt_type),
    .m_axis_qdma_cpl_sim_ctrl_wait_pld_pkt_id (_if.qdma_cpl.ctrl_wait_pld_pkt_id),
    .m_axis_qdma_cpl_sim_ctrl_port_id         (_if.qdma_cpl.ctrl_port_id),
    .m_axis_qdma_cpl_sim_ctrl_marker          (_if.qdma_cpl.ctrl_marker),
    .m_axis_qdma_cpl_sim_ctrl_user_trig       (_if.qdma_cpl.ctrl_user_trig),
    .m_axis_qdma_cpl_sim_ctrl_col_idx         (_if.qdma_cpl.ctrl_col_idx),
    .m_axis_qdma_cpl_sim_ctrl_err_idx         (_if.qdma_cpl.ctrl_err_idx),
    .m_axis_qdma_cpl_sim_ctrl_no_wrb_marker   (_if.qdma_cpl.ctrl_no_wrb_marker),
    .m_axis_qdma_cpl_sim_tready               (_if.qdma_cpl.tready),

    .m_axis_cmac_tx_sim_tvalid                (axis_cmac_tx_tvalid),
    .m_axis_cmac_tx_sim_tdata                 (axis_cmac_tx_tdata),
    .m_axis_cmac_tx_sim_tkeep                 (axis_cmac_tx_tkeep),
    .m_axis_cmac_tx_sim_tlast                 (axis_cmac_tx_tlast),
    .m_axis_cmac_tx_sim_tuser_err             (axis_cmac_tx_tuser_err),
    .m_axis_cmac_tx_sim_tready                (axis_cmac_tx_tready),

    .s_axis_cmac_rx_sim_tvalid                (axis_cmac_rx_tvalid),
    .s_axis_cmac_rx_sim_tdata                 (axis_cmac_rx_tdata),
    .s_axis_cmac_rx_sim_tkeep                 (axis_cmac_rx_tkeep),
    .s_axis_cmac_rx_sim_tlast                 (axis_cmac_rx_tlast),
    .s_axis_cmac_rx_sim_tuser_err             (axis_cmac_rx_tuser_err),

    .axil_aclk                                (_if.axil_aclk),
    .axis_aclk                                (_if.axis_aclk),
    .cmac_clk                                 (_if.cmac_clk),
    .powerup_rstn                             (_if.powerup_rstn)
  );

endmodule: open_nic_wrapper
