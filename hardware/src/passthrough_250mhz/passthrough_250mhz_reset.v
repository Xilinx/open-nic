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
module passthrough_250mhz_reset (
  // Generic signal pair for reset
  input      mod_rstn,
  output reg mod_rst_done = 1'b0,

  output     axil_aresetn,
  input      axil_aclk
);

  localparam C_RESET_DURATION = 100;

  wire       rstn;
  reg        reset_in_progress = 1'b0;
  reg [15:0] reset_timer  = 0;

  // Local reset `rstn` will be asserted for at least 2 cycles asynchronously,
  // and deasserted synchronously with the clock
  xpm_cdc_async_rst #(
    .DEST_SYNC_FF    (2),
    .INIT_SYNC_FF    (0),
    .RST_ACTIVE_HIGH (0)
  ) async_rst_inst (
    .src_arst  (mod_rstn),
    .dest_arst (rstn),
    .dest_clk  (axil_aclk)
  );

  always @(posedge axil_aclk) begin
    if (~reset_in_progress && ~rstn) begin
      reset_in_progress <= 1'b1;
      mod_rst_done      <= 1'b0;
    end
    else if (reset_in_progress && (reset_timer >= C_RESET_DURATION)) begin
      reset_in_progress <= 1'b0;
      mod_rst_done      <= 1'b1;
    end
  end

  always @(posedge axil_aclk) begin
    if (reset_in_progress) begin
      reset_timer <= reset_timer + 1;
    end
    else begin
      reset_timer <= 0;
    end
  end

  assign axil_aresetn = ~reset_in_progress;

endmodule: passthrough_250mhz_reset
