// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// pwrmgr interface.
//
// Samples some internal signals to help coverage collection:
interface pwrmgr_if (
  input logic clk,
  input logic rst_n,
  input logic clk_slow,
  input logic rst_slow_n
);
  import pwrmgr_env_pkg::*;

  // Ports to the dut side.

  logic                                                              rst_main_n;

  pwrmgr_pkg::pwr_ast_req_t                                          pwr_ast_req;
  pwrmgr_pkg::pwr_ast_rsp_t                                          pwr_ast_rsp;

  pwrmgr_pkg::pwr_rst_req_t                                          pwr_rst_req;
  pwrmgr_pkg::pwr_rst_rsp_t                                          pwr_rst_rsp;

  pwrmgr_pkg::pwr_clk_req_t                                          pwr_clk_req;
  pwrmgr_pkg::pwr_clk_rsp_t                                          pwr_clk_rsp;

  pwrmgr_pkg::pwr_otp_req_t                                          pwr_otp_req;
  pwrmgr_pkg::pwr_otp_rsp_t                                          pwr_otp_rsp;

  pwrmgr_pkg::pwr_lc_req_t                                           pwr_lc_req;
  pwrmgr_pkg::pwr_lc_rsp_t                                           pwr_lc_rsp;

  pwrmgr_pkg::pwr_flash_t                                            pwr_flash;

  pwrmgr_pkg::pwr_cpu_t                                              pwr_cpu;

  lc_ctrl_pkg::lc_tx_t                                               fetch_en;

  logic                             [  pwrmgr_reg_pkg::NumWkups-1:0] wakeups_i;

  logic                             [pwrmgr_reg_pkg::NumRstReqs-1:0] rstreqs_i;

  logic                                                              strap;
  logic                                                              low_power;
  rom_ctrl_pkg::pwrmgr_data_t                                        rom_ctrl;

  prim_esc_pkg::esc_tx_t                                             esc_rst_tx;
  prim_esc_pkg::esc_rx_t                                             esc_rst_rx;

  logic                                                              intr_wakeup;

  // Relevant CSR values.
  logic                                                              low_power_hint;

  pwrmgr_env_pkg::control_enables_t                                  control_enables;

  logic                                                              wakeup_en_regwen;
  logic                             [  pwrmgr_reg_pkg::NumWkups-1:0] wakeup_en;
  logic                             [  pwrmgr_reg_pkg::NumWkups-1:0] wakeup_status;
  logic                                                              wakeup_capture_en;

  logic                             [pwrmgr_reg_pkg::NumRstReqs-1:0] reset_en;
  logic                             [pwrmgr_reg_pkg::NumRstReqs-1:0] reset_status;

  // Internal DUT signals.
`ifndef PATO_TO_DUT
  `define PATH_TO_DUT tb.dut
`endif

  // Slow fsm state.
  pwrmgr_pkg::slow_pwr_state_e slow_state;
  always_comb slow_state = `PATH_TO_DUT.u_slow_fsm.state_q;

  // Fast fsm state.
  pwrmgr_pkg::fast_pwr_state_e fast_state;
  always_comb fast_state = `PATH_TO_DUT.u_fsm.state_q;

  // Wakeup_status ro CSR.
  logic [pwrmgr_reg_pkg::NumWkups-1:0] wake_status;
  always_comb
    wake_status = {
      `PATH_TO_DUT.hw2reg.wake_status[4].d,
      `PATH_TO_DUT.hw2reg.wake_status[3].d,
      `PATH_TO_DUT.hw2reg.wake_status[2].d,
      `PATH_TO_DUT.hw2reg.wake_status[1].d,
      `PATH_TO_DUT.hw2reg.wake_status[0].d
    };

  logic intr_enable;
  always_comb intr_enable = `PATH_TO_DUT.reg2hw.intr_enable.q;

  // Used to disable assertions once with the first power glitch.
  bit internal_assertion_disabled;

  function automatic void update_ast_main_pok(logic value);
    pwr_ast_rsp.main_pok = value;
  endfunction

  function automatic void update_otp_done(logic value);
    pwr_otp_rsp.otp_done = value;
  endfunction

  function automatic void update_otp_idle(logic value);
    pwr_otp_rsp.otp_idle = value;
  endfunction

  function automatic void update_lc_done(logic value);
    pwr_lc_rsp.lc_done = value;
  endfunction

  function automatic void update_lc_idle(logic value);
    pwr_lc_rsp.lc_idle = value;
  endfunction

  function automatic void update_flash_idle(logic value);
    pwr_flash.flash_idle = value;
  endfunction

  function automatic void update_cpu_sleeping(logic value);
    pwr_cpu.core_sleeping = value;
  endfunction

  function automatic void update_wakeup_en_regwen(logic value);
    wakeup_en_regwen &= value;
  endfunction

  function automatic void update_wakeup_en(logic [pwrmgr_reg_pkg::NumWkups-1:0] value);
    wakeup_en = value;
  endfunction

  function automatic void update_wakeup_status(logic [pwrmgr_reg_pkg::NumWkups-1:0] value);
    wakeup_status = value;
  endfunction

  function automatic void update_wakeups(logic [pwrmgr_reg_pkg::NumWkups-1:0] wakeups);
    wakeups_i = wakeups;
  endfunction

  function automatic void update_wakeup_capture_dis(logic value);
    wakeup_capture_en = !value;
  endfunction

  function automatic void update_resets(logic [pwrmgr_reg_pkg::NumRstReqs-1:0] resets);
    rstreqs_i = resets;
  endfunction

  function automatic void update_reset_en(logic [pwrmgr_reg_pkg::NumRstReqs-1:0] reset_en_value);
    reset_en = reset_en_value;
  endfunction

  // Sends a main power glitch and disables a design assertion that trips for power glitches.
  task automatic glitch_power_reset();
    rst_main_n = 1'b0;
    if (!internal_assertion_disabled) begin
      internal_assertion_disabled = 1'b1;
      `uvm_info("pwrmgr_if", "disabling power glitch related SVA", UVM_MEDIUM)
      $assertoff(1, dut.u_slow_fsm.IntRstReq_A);
    end
    repeat (2) @(posedge clk_slow);
    rst_main_n = 1'b1;
  endtask

  function automatic void update_low_power_hint(logic value);
    `uvm_info("pwrmgr_if", $sformatf("Updating low power hint to 0x%x", value), UVM_MEDIUM)
    low_power_hint = value;
  endfunction

  function automatic void update_control_enables(pwrmgr_env_pkg::control_enables_t value);
    `uvm_info("pwrmgr_if", $sformatf("Updating control enables to 0x%x", value),
              UVM_MEDIUM)
    control_enables = value;
  endfunction

  // FIXME Move all these initializations to sequences.
  initial begin
    // From AST.
    pwr_ast_rsp = '{default: '0};
    pwr_rst_rsp = '{default: '0};
    pwr_clk_rsp = '{default: '0};
    pwr_otp_rsp = '{default: '0};
    pwr_lc_rsp = '{default: '0};
    pwr_flash = '{default: '0};
    pwr_cpu = pwrmgr_pkg::PWR_CPU_DEFAULT;
    wakeups_i = pwrmgr_pkg::WAKEUPS_DEFAULT;
    rstreqs_i = pwrmgr_pkg::RSTREQS_DEFAULT;
    rom_ctrl = rom_ctrl_pkg::PWRMGR_DATA_DEFAULT;
    esc_rst_tx = prim_esc_pkg::ESC_TX_DEFAULT;
  end

  clocking slow_cb @(posedge clk_slow);
    input slow_state;
    input pwr_ast_req;
    input control_enables;
    output pwr_ast_rsp;
  endclocking

  clocking fast_cb @(posedge clk);
    input fast_state;
    input pwr_rst_req;
    output pwr_rst_rsp;
    input pwr_clk_req;
    output pwr_clk_rsp;
    input pwr_lc_req;
    output pwr_lc_rsp;
    input pwr_otp_req;
    output pwr_otp_rsp;
  endclocking
endinterface
