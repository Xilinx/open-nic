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
package qdma_pkg;

  import uvm_pkg::*;

  `include "uvm_macros.svh"

  `include "qdma_h2c_transaction.svh"
  `include "qdma_h2c_master_driver.svh"
  `include "qdma_h2c_monitor.svh"
  `include "qdma_h2c_master_agent.svh"

  `include "qdma_c2h_transaction.svh"
  `include "qdma_c2h_token.svh"
  `include "qdma_c2h_slave_driver.svh"
  `include "qdma_c2h_monitor.svh"
  `include "qdma_c2h_slave_agent.svh"

  `include "qdma_cpl_transaction.svh"
  `include "qdma_cpl_token.svh"
  `include "qdma_cpl_slave_driver.svh"
  `include "qdma_cpl_monitor.svh"
  `include "qdma_cpl_slave_agent.svh"

endpackage: qdma_pkg
