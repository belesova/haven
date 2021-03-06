--*****************************************************************************
-- DISCLAIMER OF LIABILITY
--
-- This text/file contains proprietary, confidential
-- information of Xilinx, Inc., is distributed under license
-- from Xilinx, Inc., and may be used, copied and/or
-- disclosed only pursuant to the terms of a valid license
-- agreement with Xilinx, Inc. Xilinx hereby grants you a
-- license to use this text/file solely for design, simulation,
-- implementation and creation of design files limited
-- to Xilinx devices or technologies. Use with non-Xilinx
-- devices or technologies is expressly prohibited and
-- immediately terminates your license unless covered by
-- a separate agreement.
--
-- Xilinx is providing this design, code, or information
-- "as-is" solely for use in developing programs and
-- solutions for Xilinx devices, with no obligation on the
-- part of Xilinx to provide support. By providing this design,
-- code, or information as one possible implementation of
-- this feature, application or standard, Xilinx is making no
-- representation that this implementation is free from any
-- claims of infringement. You are responsible for
-- obtaining any rights you may require for your implementation.
-- Xilinx expressly disclaims any warranty whatsoever with
-- respect to the adequacy of the implementation, including
-- but not limited to any warranties or representations that this
-- implementation is free from claims of infringement, implied
-- warranties of merchantability or fitness for a particular
-- purpose.
--
-- Xilinx products are not intended for use in life support
-- appliances, devices, or systems. Use in such applications is
-- expressly prohibited.
--
-- Any modifications that are made to the Source Code are
-- done at the user's sole risk and will be unsupported.
--
-- Copyright (c) 2006-2007 Xilinx, Inc. All rights reserved.
--
-- This copyright and support notice must be retained as part
-- of this text at all times.
--------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor             : Xilinx
-- \   \   \/     Version            : 2.2
--  \   \         Application        : MIG
--  /   /         Filename           : qdrii_top_phy.vhd
-- /___/   /\     Timestamp          : 15 May 2006
-- \   \  /  \    Date Last Modified : $Date$
--  \___\/\___\
--
--Device: Virtex-5
--Design: QDRII
--
--Purpose:
--    This module
--       1. serves as the top level phy layer. The phy layer serves as the main
--          interface section between the FPGA and the memory.
--       2. Instantiates all the interface modules to the memory, including the
--          clocks, address, commands, write interface and read data interface.

--Revision History:
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity qdrii_top_phy is
  generic (
    -- Following parameters are for 72-bit design (for ML561 Reference board
    -- design). Actual values may be different. Actual parameters values are
    -- passed from design top module qdrii_sram module. Please refer to the
    -- qdrii_sram module for actual values.
    ADDR_WIDTH   : integer := 19;
    BURST_LENGTH : integer := 4;
    BW_WIDTH     : integer := 8;
    CLK_FREQ     : integer := 300;
    CLK_WIDTH    : integer := 2;
    CQ_WIDTH     : integer := 2;
    DATA_WIDTH   : integer := 72;
    DEBUG_EN     : integer := 0;
    MEMORY_WIDTH : integer := 36;
    Q_PER_CQ     : integer := 18;
    SIM_ONLY     : integer := 0
    );
  port (
    clk0                                : in std_logic;
    clk180                              : in std_logic;
    clk270                              : in std_logic;
    user_rst_0                          : in std_logic;
    user_rst_180                        : in std_logic;
    user_rst_270                        : in std_logic;
    wr_init_n                           : in std_logic;
    rd_init_n                           : in std_logic;
    fifo_ad_wr                          : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    fifo_bw_h                           : in std_logic_vector(BW_WIDTH-1 downto 0);
    fifo_bw_l                           : in std_logic_vector(BW_WIDTH-1 downto 0);
    fifo_dwl                            : in std_logic_vector(DATA_WIDTH-1 downto 0);
    fifo_dwh                            : in std_logic_vector(DATA_WIDTH-1 downto 0);
    fifo_ad_rd                          : in std_logic_vector(ADDR_WIDTH-1 downto 0);
    idelay_ctrl_rdy                     : in std_logic;
    rd_qrl                              : out std_logic_vector(DATA_WIDTH-1 downto 0);
    rd_qrh                              : out std_logic_vector(DATA_WIDTH-1 downto 0);
    data_valid                          : out std_logic;
    cal_done                            : out std_logic;
    wr_init2_n                          : out std_logic;
    --Indicates that the calibration of Input delay tap is done
    qdr_c                               : out std_logic_vector(CLK_WIDTH-1 downto 0);
    qdr_c_n                             : out std_logic_vector(CLK_WIDTH-1 downto 0);
    qdr_dll_off_n                       : out std_logic;
    qdr_k                               : out std_logic_vector(CLK_WIDTH-1 downto 0);
    qdr_k_n                             : out std_logic_vector(CLK_WIDTH-1 downto 0);
    qdr_sa                              : out std_logic_vector(ADDR_WIDTH-1 downto 0);
    qdr_bw_n                            : out std_logic_vector(BW_WIDTH-1 downto 0);
    qdr_w_n                             : out std_logic;
    qdr_d                               : out std_logic_vector(DATA_WIDTH-1 downto 0);
    qdr_r_n                             : out std_logic;
    qdr_q                               : in std_logic_vector(DATA_WIDTH-1 downto 0);
    qdr_cq                              : in std_logic_vector(CQ_WIDTH-1 downto 0);
    qdr_cq_n                            : in std_logic_vector(CQ_WIDTH-1 downto 0);
    dummy_wrl                           : out std_logic_vector(DATA_WIDTH-1 downto 0);
    dummy_wrh                           : out std_logic_vector(DATA_WIDTH-1 downto 0);
    dummy_wren                          : out std_logic;
    -- Debug Signals
    dbg_idel_up_all                      : in  std_logic;
    dbg_idel_down_all                    : in  std_logic;
    dbg_idel_up_q_cq                     : in  std_logic;
    dbg_idel_down_q_cq                   : in  std_logic;
    dbg_idel_up_q_cq_n                   : in  std_logic;
    dbg_idel_down_q_cq_n                 : in  std_logic;
    dbg_idel_up_cq                       : in  std_logic;
    dbg_idel_down_cq                     : in  std_logic;
    dbg_idel_up_cq_n                     : in  std_logic;
    dbg_idel_down_cq_n                   : in  std_logic;
    dbg_sel_idel_q_cq                    : in  std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_sel_all_idel_q_cq                : in  std_logic;
    dbg_sel_idel_q_cq_n                  : in  std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_sel_all_idel_q_cq_n              : in  std_logic;
    dbg_sel_idel_cq                      : in  std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_sel_all_idel_cq                  : in  std_logic;
    dbg_sel_idel_cq_n                    : in  std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_sel_all_idel_cq_n                : in  std_logic;
    dbg_init_count_done                  : out std_logic;
    dbg_q_cq_init_delay_done             : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_q_cq_n_init_delay_done           : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_q_cq_init_delay_done_tap_count   : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
    dbg_q_cq_n_init_delay_done_tap_count : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
    dbg_cq_cal_done                      : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_cq_n_cal_done                    : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_cq_cal_tap_count                 : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
    dbg_cq_n_cal_tap_count               : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
    dbg_we_cal_done_cq                   : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_we_cal_done_cq_n                 : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_cq_q_data_valid                  : out std_logic_vector(CQ_WIDTH-1 downto 0);
    dbg_cq_n_q_data_valid                : out std_logic_vector(CQ_WIDTH-1 downto 0)
     );
end entity qdrii_top_phy;

architecture arch_qdrii_top_phy of qdrii_top_phy is

  attribute X_CORE_INFO : string;
  attribute X_CORE_INFO of arch_qdrii_top_phy : ARCHITECTURE IS
    "mig_v2_1_qdrii_sram_v5, Coregen 10.1i_ip0";
  attribute CORE_GENERATION_INFO : string;
  attribute CORE_GENERATION_INFO of arch_qdrii_top_phy : ARCHITECTURE IS "qdrii_sram_v5,mig_v2_1,{component_name=qdrii_sram_v5, addr_width = 20, burst_length = 4, bw_width = 2, clk_freq = 250, clk_width = 1, cq_width = 1, data_width = 18, memory_width = 18, rst_act_low = 1}";

  constant Q_PER_CQ_9 : integer := Q_PER_CQ/9; -- Number of sets of 9 bits in
                                               -- every read data bits associated
                                               -- with the corresponding read strobe
                                               -- (CQ) bit.

  signal dummy_write      : std_logic_vector(1 downto 0);
  signal dummy_read       : std_logic_vector(1 downto 0);
  signal init_cnt_done    : std_logic;
  signal rd_init_delay_n  : std_logic;
  signal cal_done_i       : std_logic;
  signal rd_init_delay2_n : std_logic;

  component qdrii_phy_addr_io
    generic(
      ADDR_WIDTH   : integer := ADDR_WIDTH;
      BURST_LENGTH : integer := BURST_LENGTH
      );
    port(
      clk180          : in  std_logic;
      clk270          : in  std_logic;
      user_rst_180    : in  std_logic;
      user_rst_270    : in  std_logic;
      wr_init_n       : in  std_logic;
      rd_init_n       : in  std_logic;
      dummy_write     : in  std_logic_vector(1 downto 0);
      dummy_read      : in  std_logic_vector(1 downto 0);
      fifo_ad_wr      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      fifo_ad_rd      : in  std_logic_vector(ADDR_WIDTH-1 downto 0);
      cal_done        : in  std_logic;
      rd_init_delay_n : in  std_logic;
      qdr_sa          : out std_logic_vector(ADDR_WIDTH-1 downto 0)
      );
  end component qdrii_phy_addr_io;

  component qdrii_phy_clk_io
    generic (
      CLK_WIDTH : integer := CLK_WIDTH
      );
    port(
      clk0          : in  std_logic;
      user_rst_0    : in  std_logic;
      init_cnt_done : in  std_logic;
      qdr_c         : out std_logic_vector(CLK_WIDTH-1 downto 0);
      qdr_c_n       : out std_logic_vector(CLK_WIDTH-1 downto 0);
      qdr_k         : out std_logic_vector(CLK_WIDTH-1 downto 0);
      qdr_k_n       : out std_logic_vector(CLK_WIDTH-1 downto 0);
      qdr_dll_off_n : out std_logic
      );
  end component qdrii_phy_clk_io;

  component qdrii_phy_write
    generic(
      BURST_LENGTH : integer := BURST_LENGTH;
      DATA_WIDTH   : integer := DATA_WIDTH;
      BW_WIDTH     : integer := BW_WIDTH
      );
    port(
      clk0             : in  std_logic;
      clk180           : in  std_logic;
      clk270           : in  std_logic;
      user_rst_0       : in  std_logic;
      user_rst_180     : in  std_logic;
      user_rst_270     : in  std_logic;
      fifo_bw_h        : in  std_logic_vector(BW_WIDTH-1 downto 0);
      fifo_bw_l        : in  std_logic_vector(BW_WIDTH-1 downto 0);
      fifo_dwh         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      fifo_dwl         : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      dummy_wr         : in  std_logic_vector(1 downto 0);
      wr_init_n        : in  std_logic;
      wr_init2_n       : out std_logic;
      qdr_bw_n         : out std_logic_vector(BW_WIDTH-1 downto 0);
      qdr_d            : out std_logic_vector(DATA_WIDTH-1 downto  0);
      qdr_w_n          : out std_logic;
      dummy_wrl        : out std_logic_vector(DATA_WIDTH-1 downto  0);
      dummy_wrh        : out std_logic_vector(DATA_WIDTH-1 downto  0);
      dummy_wren       : out std_logic
      );
  end component qdrii_phy_write;

  component qdrii_phy_read
   generic(
     BURST_LENGTH : integer := BURST_LENGTH;
     CLK_FREQ     : integer := CLK_FREQ;
     CQ_WIDTH     : integer := CQ_WIDTH;
     DATA_WIDTH   : integer := DATA_WIDTH;
     DEBUG_EN     : integer := DEBUG_EN;
     MEMORY_WIDTH : integer := MEMORY_WIDTH;
     Q_PER_CQ     : integer := Q_PER_CQ;
     Q_PER_CQ_9   : integer := Q_PER_CQ_9;
     SIM_ONLY     : integer := SIM_ONLY
     );
   port(
     clk0                                 : in  std_logic;
     clk180                               : in  std_logic;
     clk270                               : in  std_logic;
     user_rst_0                           : in  std_logic;
     user_rst_180                         : in  std_logic;
     user_rst_270                         : in  std_logic;
     idly_ctrl_rdy                        : in  std_logic;
     rd_init_n                            : in  std_logic;
     qdr_q                                : in  std_logic_vector(DATA_WIDTH-1 downto 0);
     qdr_cq                               : in  std_logic_vector(CQ_WIDTH-1 downto 0);
     qdr_cq_n                             : in  std_logic_vector(CQ_WIDTH-1 downto 0);
     read_data_rise                       : out std_logic_vector(DATA_WIDTH-1 downto 0);
     read_data_fall                       : out std_logic_vector(DATA_WIDTH-1 downto 0);
     data_valid                           : out std_logic;
     dummy_write                          : out std_logic_vector(1 downto 0);
     dummy_read                           : out std_logic_vector(1 downto 0);
     cal_done                             : out std_logic;
     init_cnt_done                        : out std_logic;
     qdr_r_n                              : out std_logic;
     rd_init_delay_n                      : out std_logic;
     rd_init_delay2_n                     : out std_logic;
     -- Debug Signals
     dbg_idel_up_all                      : in  std_logic;
     dbg_idel_down_all                    : in  std_logic;
     dbg_idel_up_q_cq                     : in  std_logic;
     dbg_idel_down_q_cq                   : in  std_logic;
     dbg_idel_up_q_cq_n                   : in  std_logic;
     dbg_idel_down_q_cq_n                 : in  std_logic;
     dbg_idel_up_cq                       : in  std_logic;
     dbg_idel_down_cq                     : in  std_logic;
     dbg_idel_up_cq_n                     : in  std_logic;
     dbg_idel_down_cq_n                   : in  std_logic;
     dbg_sel_idel_q_cq                    : in  std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_sel_all_idel_q_cq                : in  std_logic;
     dbg_sel_idel_q_cq_n                  : in  std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_sel_all_idel_q_cq_n              : in  std_logic;
     dbg_sel_idel_cq                      : in  std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_sel_all_idel_cq                  : in  std_logic;
     dbg_sel_idel_cq_n                    : in  std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_sel_all_idel_cq_n                : in  std_logic;
     dbg_q_cq_init_delay_done             : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_q_cq_n_init_delay_done           : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_q_cq_init_delay_done_tap_count   : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
     dbg_q_cq_n_init_delay_done_tap_count : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
     dbg_cq_cal_done                      : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_cq_n_cal_done                    : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_cq_cal_tap_count                 : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
     dbg_cq_n_cal_tap_count               : out std_logic_vector((6*CQ_WIDTH)-1 downto 0);
     dbg_we_cal_done_cq                   : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_we_cal_done_cq_n                 : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_cq_q_data_valid                  : out std_logic_vector(CQ_WIDTH-1 downto 0);
     dbg_cq_n_q_data_valid                : out std_logic_vector(CQ_WIDTH-1 downto 0)
     );
  end component qdrii_phy_read;

begin

  dbg_init_count_done <= init_cnt_done;

  cal_done <= cal_done_i;

  U_QDRII_PHY_ADDR_IO : qdrii_phy_addr_io
    generic map (
      ADDR_WIDTH   => ADDR_WIDTH,
      BURST_LENGTH => BURST_LENGTH
      )
    port map (
      clk180          => clk180,
      clk270          => clk270,
      user_rst_180    => user_rst_180,
      user_rst_270    => user_rst_270,
      wr_init_n       => wr_init_n,
      rd_init_n       => rd_init_n,
      dummy_write     => dummy_write,
      dummy_read      => dummy_read,
      fifo_ad_wr      => fifo_ad_wr,
      fifo_ad_rd      => fifo_ad_rd,
      cal_done        => cal_done_i,
      rd_init_delay_n => rd_init_delay_n,
      qdr_sa          => qdr_sa
      );

   U_QDRII_PHY_CLK_IO : qdrii_phy_clk_io
     generic map (
       CLK_WIDTH  => CLK_WIDTH
       )
     port map (
       clk0          => clk0,
       user_rst_0    => user_rst_0,
       init_cnt_done => init_cnt_done,
       qdr_c         => qdr_c,
       qdr_c_n       => qdr_c_n,
       qdr_k         => qdr_k,
       qdr_k_n       => qdr_k_n,
       qdr_dll_off_n => qdr_dll_off_n
       );

  U_QDRII_PHY_WRITE : qdrii_phy_write
    generic map (
      BURST_LENGTH => BURST_LENGTH,
      DATA_WIDTH   => DATA_WIDTH,
      BW_WIDTH     => BW_WIDTH
      )
    port map (
       clk0             => clk0,
       clk180           => clk180,
       clk270           => clk270,
       user_rst_0       => user_rst_0,
       user_rst_180     => user_rst_180,
       user_rst_270     => user_rst_270,
       fifo_bw_h        => fifo_bw_h,
       fifo_bw_l        => fifo_bw_l,
       fifo_dwh         => fifo_dwh,
       fifo_dwl         => fifo_dwl,
       dummy_wr         => dummy_write,
       wr_init_n        => wr_init_n,
       wr_init2_n       => wr_init2_n,
       qdr_bw_n         => qdr_bw_n,
       qdr_d            => qdr_d,
       qdr_w_n          => qdr_w_n,
       dummy_wrl        => dummy_wrl,
       dummy_wrh        => dummy_wrh,
       dummy_wren       => dummy_wren
       );

  --phy_read #

  U_QDRII_PHY_READ : qdrii_phy_read
    generic map (
      BURST_LENGTH => BURST_LENGTH,
      CLK_FREQ     => CLK_FREQ,
      CQ_WIDTH     => CQ_WIDTH,
      DATA_WIDTH   => DATA_WIDTH,
      DEBUG_EN     => DEBUG_EN,
      MEMORY_WIDTH => MEMORY_WIDTH,
      Q_PER_CQ     => Q_PER_CQ,
      Q_PER_CQ_9   => Q_PER_CQ_9,
      SIM_ONLY     => SIM_ONLY
      )
    port map (
      clk0                                 => clk0,
      clk180                               => clk180,
      clk270                               => clk270,
      user_rst_0                           => user_rst_0,
      user_rst_180                         => user_rst_180,
      user_rst_270                         => user_rst_270,
      idly_ctrl_rdy                        => idelay_ctrl_rdy,
      rd_init_n                            => rd_init_n,
      qdr_q                                => qdr_q,
      qdr_cq                               => qdr_cq,
      qdr_cq_n                             => qdr_cq_n,
      read_data_rise                       => rd_qrh,
      read_data_fall                       => rd_qrl,
      data_valid                           => data_valid,
      dummy_write                          => dummy_write,
      dummy_read                           => dummy_read,
      cal_done                             => cal_done_i,
      init_cnt_done                        => init_cnt_done,
      qdr_r_n                              => qdr_r_n,
      rd_init_delay_n                      => rd_init_delay_n,
      rd_init_delay2_n                     => rd_init_delay2_n,
      -- Debug Signals
      dbg_idel_up_all                      => dbg_idel_up_all,
      dbg_idel_down_all                    => dbg_idel_down_all,
      dbg_idel_up_q_cq                     => dbg_idel_up_q_cq,
      dbg_idel_down_q_cq                   => dbg_idel_down_q_cq,
      dbg_idel_up_q_cq_n                   => dbg_idel_up_q_cq_n,
      dbg_idel_down_q_cq_n                 => dbg_idel_down_q_cq_n,
      dbg_idel_up_cq                       => dbg_idel_up_cq,
      dbg_idel_down_cq                     => dbg_idel_down_cq,
      dbg_idel_up_cq_n                     => dbg_idel_up_cq_n,
      dbg_idel_down_cq_n                   => dbg_idel_down_cq_n,
      dbg_sel_idel_q_cq                    => dbg_sel_idel_q_cq,
      dbg_sel_all_idel_q_cq                => dbg_sel_all_idel_q_cq,
      dbg_sel_idel_q_cq_n                  => dbg_sel_idel_q_cq_n,
      dbg_sel_all_idel_q_cq_n              => dbg_sel_all_idel_q_cq_n,
      dbg_sel_idel_cq                      => dbg_sel_idel_cq,
      dbg_sel_all_idel_cq                  => dbg_sel_all_idel_cq,
      dbg_sel_idel_cq_n                    => dbg_sel_idel_cq_n,
      dbg_sel_all_idel_cq_n                => dbg_sel_all_idel_cq_n,
      dbg_q_cq_init_delay_done             => dbg_q_cq_init_delay_done,
      dbg_q_cq_n_init_delay_done           => dbg_q_cq_n_init_delay_done,
      dbg_q_cq_init_delay_done_tap_count   => dbg_q_cq_init_delay_done_tap_count,
      dbg_q_cq_n_init_delay_done_tap_count => dbg_q_cq_n_init_delay_done_tap_count,
      dbg_cq_cal_done                      => dbg_cq_cal_done,
      dbg_cq_n_cal_done                    => dbg_cq_n_cal_done,
      dbg_cq_cal_tap_count                 => dbg_cq_cal_tap_count,
      dbg_cq_n_cal_tap_count               => dbg_cq_n_cal_tap_count,
      dbg_we_cal_done_cq                   => dbg_we_cal_done_cq,
      dbg_we_cal_done_cq_n                 => dbg_we_cal_done_cq_n,
      dbg_cq_q_data_valid                  => dbg_cq_q_data_valid,
      dbg_cq_n_q_data_valid                => dbg_cq_n_q_data_valid
      );

end architecture arch_qdrii_top_phy;