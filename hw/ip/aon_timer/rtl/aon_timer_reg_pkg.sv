// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// Register Package auto-generated by `reggen` containing data structure

package aon_timer_reg_pkg;

  // Address width within the block
  parameter int BlockAw = 6;

  ////////////////////////////
  // Typedefs for registers //
  ////////////////////////////
  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } enable;
    struct packed {
      logic [11:0] q;
      logic        qe;
    } prescaler;
  } aon_timer_reg2hw_wkup_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aon_timer_reg2hw_wkup_thold_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aon_timer_reg2hw_wkup_count_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } enable;
    struct packed {
      logic        q;
      logic        qe;
    } pause_in_sleep;
  } aon_timer_reg2hw_wdog_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aon_timer_reg2hw_wdog_bark_thold_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aon_timer_reg2hw_wdog_bite_thold_reg_t;

  typedef struct packed {
    logic [31:0] q;
    logic        qe;
  } aon_timer_reg2hw_wdog_count_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
    } wkup_timer_expired;
    struct packed {
      logic        q;
    } wdog_timer_expired;
  } aon_timer_reg2hw_intr_state_reg_t;

  typedef struct packed {
    struct packed {
      logic        q;
      logic        qe;
    } wkup_timer_expired;
    struct packed {
      logic        q;
      logic        qe;
    } wdog_timer_expired;
  } aon_timer_reg2hw_intr_test_reg_t;

  typedef struct packed {
    logic        q;
    logic        qe;
  } aon_timer_reg2hw_wkup_cause_reg_t;


  typedef struct packed {
    struct packed {
      logic        d;
    } enable;
    struct packed {
      logic [11:0] d;
    } prescaler;
  } aon_timer_hw2reg_wkup_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } aon_timer_hw2reg_wkup_thold_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } aon_timer_hw2reg_wkup_count_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
    } enable;
    struct packed {
      logic        d;
    } pause_in_sleep;
  } aon_timer_hw2reg_wdog_ctrl_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } aon_timer_hw2reg_wdog_bark_thold_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } aon_timer_hw2reg_wdog_bite_thold_reg_t;

  typedef struct packed {
    logic [31:0] d;
  } aon_timer_hw2reg_wdog_count_reg_t;

  typedef struct packed {
    struct packed {
      logic        d;
      logic        de;
    } wkup_timer_expired;
    struct packed {
      logic        d;
      logic        de;
    } wdog_timer_expired;
  } aon_timer_hw2reg_intr_state_reg_t;

  typedef struct packed {
    logic        d;
  } aon_timer_hw2reg_wkup_cause_reg_t;


  ///////////////////////////////////////
  // Register to internal design logic //
  ///////////////////////////////////////
  typedef struct packed {
    aon_timer_reg2hw_wkup_ctrl_reg_t wkup_ctrl; // [191:177]
    aon_timer_reg2hw_wkup_thold_reg_t wkup_thold; // [176:144]
    aon_timer_reg2hw_wkup_count_reg_t wkup_count; // [143:111]
    aon_timer_reg2hw_wdog_ctrl_reg_t wdog_ctrl; // [110:107]
    aon_timer_reg2hw_wdog_bark_thold_reg_t wdog_bark_thold; // [106:74]
    aon_timer_reg2hw_wdog_bite_thold_reg_t wdog_bite_thold; // [73:41]
    aon_timer_reg2hw_wdog_count_reg_t wdog_count; // [40:8]
    aon_timer_reg2hw_intr_state_reg_t intr_state; // [7:6]
    aon_timer_reg2hw_intr_test_reg_t intr_test; // [5:2]
    aon_timer_reg2hw_wkup_cause_reg_t wkup_cause; // [1:0]
  } aon_timer_reg2hw_t;

  ///////////////////////////////////////
  // Internal design logic to register //
  ///////////////////////////////////////
  typedef struct packed {
    aon_timer_hw2reg_wkup_ctrl_reg_t wkup_ctrl; // [179:167]
    aon_timer_hw2reg_wkup_thold_reg_t wkup_thold; // [166:135]
    aon_timer_hw2reg_wkup_count_reg_t wkup_count; // [134:103]
    aon_timer_hw2reg_wdog_ctrl_reg_t wdog_ctrl; // [102:101]
    aon_timer_hw2reg_wdog_bark_thold_reg_t wdog_bark_thold; // [100:69]
    aon_timer_hw2reg_wdog_bite_thold_reg_t wdog_bite_thold; // [68:37]
    aon_timer_hw2reg_wdog_count_reg_t wdog_count; // [36:5]
    aon_timer_hw2reg_intr_state_reg_t intr_state; // [4:1]
    aon_timer_hw2reg_wkup_cause_reg_t wkup_cause; // [0:0]
  } aon_timer_hw2reg_t;

  // Register Address
  parameter logic [BlockAw-1:0] AON_TIMER_WKUP_CTRL_OFFSET = 6'h 0;
  parameter logic [BlockAw-1:0] AON_TIMER_WKUP_THOLD_OFFSET = 6'h 4;
  parameter logic [BlockAw-1:0] AON_TIMER_WKUP_COUNT_OFFSET = 6'h 8;
  parameter logic [BlockAw-1:0] AON_TIMER_WDOG_REGWEN_OFFSET = 6'h c;
  parameter logic [BlockAw-1:0] AON_TIMER_WDOG_CTRL_OFFSET = 6'h 10;
  parameter logic [BlockAw-1:0] AON_TIMER_WDOG_BARK_THOLD_OFFSET = 6'h 14;
  parameter logic [BlockAw-1:0] AON_TIMER_WDOG_BITE_THOLD_OFFSET = 6'h 18;
  parameter logic [BlockAw-1:0] AON_TIMER_WDOG_COUNT_OFFSET = 6'h 1c;
  parameter logic [BlockAw-1:0] AON_TIMER_INTR_STATE_OFFSET = 6'h 20;
  parameter logic [BlockAw-1:0] AON_TIMER_INTR_TEST_OFFSET = 6'h 24;
  parameter logic [BlockAw-1:0] AON_TIMER_WKUP_CAUSE_OFFSET = 6'h 28;


  // Register Index
  typedef enum int {
    AON_TIMER_WKUP_CTRL,
    AON_TIMER_WKUP_THOLD,
    AON_TIMER_WKUP_COUNT,
    AON_TIMER_WDOG_REGWEN,
    AON_TIMER_WDOG_CTRL,
    AON_TIMER_WDOG_BARK_THOLD,
    AON_TIMER_WDOG_BITE_THOLD,
    AON_TIMER_WDOG_COUNT,
    AON_TIMER_INTR_STATE,
    AON_TIMER_INTR_TEST,
    AON_TIMER_WKUP_CAUSE
  } aon_timer_id_e;

  // Register width information to check illegal writes
  parameter logic [3:0] AON_TIMER_PERMIT [11] = '{
    4'b 0011, // index[ 0] AON_TIMER_WKUP_CTRL
    4'b 1111, // index[ 1] AON_TIMER_WKUP_THOLD
    4'b 1111, // index[ 2] AON_TIMER_WKUP_COUNT
    4'b 0001, // index[ 3] AON_TIMER_WDOG_REGWEN
    4'b 0001, // index[ 4] AON_TIMER_WDOG_CTRL
    4'b 1111, // index[ 5] AON_TIMER_WDOG_BARK_THOLD
    4'b 1111, // index[ 6] AON_TIMER_WDOG_BITE_THOLD
    4'b 1111, // index[ 7] AON_TIMER_WDOG_COUNT
    4'b 0001, // index[ 8] AON_TIMER_INTR_STATE
    4'b 0001, // index[ 9] AON_TIMER_INTR_TEST
    4'b 0001  // index[10] AON_TIMER_WKUP_CAUSE
  };
endpackage

