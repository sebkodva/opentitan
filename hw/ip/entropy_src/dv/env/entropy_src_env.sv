// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

class entropy_src_env extends cip_base_env #(
    .CFG_T              (entropy_src_env_cfg),
    .COV_T              (entropy_src_env_cov),
    .VIRTUAL_SEQUENCER_T(entropy_src_virtual_sequencer),
    .SCOREBOARD_T       (entropy_src_scoreboard)
  );
  `uvm_component_utils(entropy_src_env)

   push_pull_agent#(.HostDataWidth(entropy_src_pkg::RNG_BUS_WIDTH))         m_rng_agent;
   push_pull_agent#(.HostDataWidth(entropy_src_pkg::FIPS_CSRNG_BUS_WIDTH))  m_csrng_agent;

  `uvm_component_new

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    m_rng_agent = push_pull_agent#(.HostDataWidth(entropy_src_pkg::RNG_BUS_WIDTH))::type_id::
                  create("m_rng_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.HostDataWidth(entropy_src_pkg::RNG_BUS_WIDTH)))::set
                  (this, "m_rng_agent*", "cfg", cfg.m_rng_agent_cfg);
    cfg.m_rng_agent_cfg.agent_type = push_pull_agent_pkg::PushAgent;
    cfg.m_rng_agent_cfg.if_mode    = dv_utils_pkg::Host;

    // To correctly model ast/rng behavior, back-to-back entropy is not allowed
    cfg.m_rng_agent_cfg.zero_delays = 0;
    cfg.m_rng_agent_cfg.host_delay_min = 6;
    cfg.m_rng_agent_cfg.host_delay_max = 12;

    m_csrng_agent = push_pull_agent#(.HostDataWidth(entropy_src_pkg::FIPS_CSRNG_BUS_WIDTH))::type_id::
                    create("m_csrng_agent", this);
    uvm_config_db#(push_pull_agent_cfg#(.HostDataWidth(entropy_src_pkg::FIPS_CSRNG_BUS_WIDTH)))::set
                  (this, "m_csrng_agent*", "cfg", cfg.m_csrng_agent_cfg);
    cfg.m_csrng_agent_cfg.agent_type = push_pull_agent_pkg::PullAgent;
    cfg.m_csrng_agent_cfg.if_mode    = dv_utils_pkg::Host;

    if (!uvm_config_db#(virtual pins_if#(8))::get(this, "", "otp_en_es_fw_read_vif",
        cfg.otp_en_es_fw_read_vif)) begin
      `uvm_fatal(get_full_name(), "failed to get otp_en_es_fw_read_vif from uvm_config_db")
    end
    if (!uvm_config_db#(virtual pins_if#(8))::get(this, "", "otp_en_es_fw_over_vif",
        cfg.otp_en_es_fw_over_vif)) begin
      `uvm_fatal(get_full_name(), "failed to get otp_en_es_fw_over_vif from uvm_config_db")
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    m_rng_agent.monitor.analysis_port.connect(scoreboard.rng_fifo.analysis_export);
    m_csrng_agent.monitor.analysis_port.connect(scoreboard.csrng_fifo.analysis_export);

    virtual_sequencer.csrng_sequencer_h = m_csrng_agent.sequencer;
    virtual_sequencer.rng_sequencer_h   = m_rng_agent.sequencer;

  endfunction

endclass
