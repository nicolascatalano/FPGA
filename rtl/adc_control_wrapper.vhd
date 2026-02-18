----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Wrapper for AXI data control and ADC receivers modules
--
-- Dependencies: None.
--
-- Revision: 2020-11-20
-- Additional Comments:
--
----------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

use work.fifo_record_pkg.all;
use work.adc_receiver_def_pkg.all;

entity adc_control_wrapper is
  generic (
    -- Core ID and version
    USER_CORE_ID_VER : std_logic_vector(31 downto 0) := X"20260218";
    N                : integer                       := 16;          --number of ADC channels
    N1               : integer                       := 14;          --number of ADC channels in receiver 1
    N2               : integer                       := 2;           --number of ADC channels in receiver 2
    RES_ADC          : integer                       := 14;          --ADC bit resolution
    FIFO_EMPTY_VAL   : std_logic_vector(31 downto 0) := X"CAFECAFE"; --output value when attempting to read from empty FIFO
    N_tr_b           : integer                       := 10           --bits for downsampler treshold register
  );
  port (
    ps_clk_i                : in std_logic;
    ps_rst_n_i              : in std_logic;
    --AXI interface
    s_axi4l_control_awaddr  : in std_logic_vector(10 - 1 downto 0);
    s_axi4l_control_awprot  : in std_logic_vector(2 downto 0);
    s_axi4l_control_awvalid : in std_logic;
    s_axi4l_control_awready : out std_logic;
    s_axi4l_control_wdata   : in std_logic_vector(32 - 1 downto 0);
    s_axi4l_control_wstrb   : in std_logic_vector((32/8) - 1 downto 0);
    s_axi4l_control_wvalid  : in std_logic;
    s_axi4l_control_wready  : out std_logic;
    s_axi4l_control_bresp   : out std_logic_vector(1 downto 0);
    s_axi4l_control_bvalid  : out std_logic;
    s_axi4l_control_bready  : in std_logic;
    s_axi4l_control_araddr  : in std_logic_vector(10 - 1 downto 0);
    s_axi4l_control_arprot  : in std_logic_vector(2 downto 0);
    s_axi4l_control_arvalid : in std_logic;
    s_axi4l_control_arready : out std_logic;
    s_axi4l_control_rdata   : out std_logic_vector(32 - 1 downto 0);
    s_axi4l_control_rresp   : out std_logic_vector(1 downto 0);
    s_axi4l_control_rvalid  : out std_logic;
    s_axi4l_control_rready  : in std_logic;

    --AXI interface for preprocessing regs
    s_axi4l_preproc_awaddr  : in std_logic_vector(6 - 1 downto 0);
    s_axi4l_preproc_awprot  : in std_logic_vector(2 downto 0);
    s_axi4l_preproc_awvalid : in std_logic;
    s_axi4l_preproc_awready : out std_logic;
    s_axi4l_preproc_wdata   : in std_logic_vector(32 - 1 downto 0);
    s_axi4l_preproc_wstrb   : in std_logic_vector((32/8) - 1 downto 0);
    s_axi4l_preproc_wvalid  : in std_logic;
    s_axi4l_preproc_wready  : out std_logic;
    s_axi4l_preproc_bresp   : out std_logic_vector(1 downto 0);
    s_axi4l_preproc_bvalid  : out std_logic;
    s_axi4l_preproc_bready  : in std_logic;
    s_axi4l_preproc_araddr  : in std_logic_vector(6 - 1 downto 0);
    s_axi4l_preproc_arprot  : in std_logic_vector(2 downto 0);
    s_axi4l_preproc_arvalid : in std_logic;
    s_axi4l_preproc_arready : out std_logic;
    s_axi4l_preproc_rdata   : out std_logic_vector(32 - 1 downto 0);
    s_axi4l_preproc_rresp   : out std_logic_vector(1 downto 0);
    s_axi4l_preproc_rvalid  : out std_logic;
    s_axi4l_preproc_rready  : in std_logic;

    --external reset for peripherals
    rst_peripherals_i       : in std_logic;

    --ADC signals
    adc_DCO1_p_i            : in std_logic;
    adc_DCO1_n_i            : in std_logic;
    adc_DCO2_p_i            : in std_logic;
    adc_DCO2_n_i            : in std_logic;
    adc_FCO1_p_i            : in std_logic;
    adc_FCO1_n_i            : in std_logic;
    adc_FCO2_p_i            : in std_logic;
    adc_FCO2_n_i            : in std_logic;
    adc_data_p_i            : in std_logic_vector((N - 1) downto 0);
    adc_data_n_i            : in std_logic_vector((N - 1) downto 0);
    adc_FCO1lck_o           : out std_logic;
    adc_FCO2lck_o           : out std_logic;

    --downsampler control signals
    treshold_value_i        : in std_logic_vector((N_tr_b - 1) downto 0);
    treshold_ld_i           : in std_logic;

    --delay control signals
    delay_locked_o          : out std_logic;
    delay_data_ld_i         : in std_logic_vector((N - 1) downto 0);
    delay_data_input_i      : in std_logic_vector((5 * N - 1) downto 0);
    delay_data_output_o     : out std_logic_vector((5 * N - 1) downto 0);
    delay_frame1_ld_i       : in std_logic;
    delay_frame1_input_i    : in std_logic_vector((5 - 1) downto 0);
    delay_frame1_output_o   : out std_logic_vector((5 - 1) downto 0);
    delay_frame2_ld_i       : in std_logic;
    delay_frame2_input_i    : in std_logic_vector((5 - 1) downto 0);
    delay_frame2_output_o   : out std_logic_vector((5 - 1) downto 0);

    --external trigger signal
    ext_trigger_i           : in std_logic
  );
end adc_control_wrapper;

architecture arch of adc_control_wrapper is
  --Xilinx attributes
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_DCO1_p_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO1_i CLK_P";
  attribute X_INTERFACE_INFO of adc_DCO1_n_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO1_i CLK_N";
  attribute X_INTERFACE_INFO of adc_DCO2_p_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO2_i CLK_P";
  attribute X_INTERFACE_INFO of adc_DCO2_n_i : signal is "xilinx.com:interface:diff_clock:1.0 adc_DCO2_i CLK_N";
  attribute X_INTERFACE_INFO of adc_FCO1_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO1_i V_P";
  attribute X_INTERFACE_INFO of adc_FCO1_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO1_i V_N";
  attribute X_INTERFACE_INFO of adc_FCO2_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO2_i V_P";
  attribute X_INTERFACE_INFO of adc_FCO2_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_FCO2_i V_N";
  attribute X_INTERFACE_INFO of adc_data_p_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_data_i V_P";
  attribute X_INTERFACE_INFO of adc_data_n_i : signal is "xilinx.com:interface:diff_analog_io:1.0 adc_data_i V_N";
  attribute X_INTERFACE_INFO of rst_peripherals_i : signal is "xilinx.com:signal:reset:1.0 rst_peripherals_i RST";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of rst_peripherals_i : signal is "POLARITY ACTIVE_HIGH";

  --label must be the same as label in idelay_wrapper.vhd
  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of IDELAYCTRL_inst : label is "Reception_Delays";

  signal async_rst_from_AXI, fifo_rst_from_AXI, fifo_rst, debug_rst : std_logic := '0';
  signal debug_enable_from_AXI : std_logic := '0';
  signal debug_control_from_AXI : std_logic_vector((N * 4 - 1) downto 0) := (others => '0');
  signal debug_w2w1_from_AXI : std_logic_vector((28 * N - 1) downto 0) := (others => '0');
  signal fifo_rd_en_from_AXI : std_logic_vector((N - 1) downto 0) := (others => '0');
  signal fifo_out_to_AXI : fifo_out_vector_t((N - 1) downto 0);
  signal adc_data_to_r1_p, adc_data_to_r1_n : std_logic_vector((N1 - 1) downto 0) := (others => '0');
  signal adc_data_to_r2_p, adc_data_to_r2_n : std_logic_vector((N2 - 1) downto 0) := (others => '0');
  signal delay_data_ld_to_r1 : std_logic_vector((N1 - 1) downto 0) := (others => '0');
  signal delay_data_ld_to_r2 : std_logic_vector((N2 - 1) downto 0) := (others => '0');
  signal delay_data_input_to_r1, delay_data_output_from_r1 : std_logic_vector((5 * N1 - 1) downto 0) := (others => '0');
  signal delay_data_input_to_r2, delay_data_output_from_r2 : std_logic_vector((5 * N2 - 1) downto 0) := (others => '0');
  signal delay_refclk : std_logic;

  --260 MHz clock
  signal clk_260_mhz : std_logic;
  --455 MHz clock
  signal clk_455_mhz : std_logic;
  --data from adcs
  signal deser_data_1 : adc_data_t(N1 - 1 downto 0);
  signal deser_data_2 : adc_data_t(N2 - 1 downto 0);
  signal deser_data : adc_data_t(N1 + N2 - 1 downto 0);
  signal valid_adc : std_logic;
  --preprocessing signals
  signal fifo_input_mux_sel : std_logic_vector(2 downto 0);
  signal data_source_sel : std_logic_vector(1 downto 0) := (others => '0');

  signal ch_1_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_1_valid : std_logic := '0';
  signal ch_1_sign : std_logic := '0';
  signal ch_1_sign_valid : std_logic := '0';

  signal ch_2_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_2_valid : std_logic := '0';
  signal ch_2_sign : std_logic := '0';
  signal ch_2_sign_valid : std_logic := '0';

  signal ch_3_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_3_valid : std_logic := '0';
  signal ch_3_sign : std_logic := '0';
  signal ch_3_sign_valid : std_logic := '0';

  signal ch_4_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_4_valid : std_logic := '0';
  signal ch_4_sign : std_logic := '0';
  signal ch_4_sign_valid : std_logic := '0';

  signal ch_5_freq : std_logic_vector(31 downto 0) := (others => '0');
  signal ch_5_valid : std_logic := '0';
  signal ch_5_sign : std_logic := '0';
  signal ch_5_sign_valid : std_logic := '0';

  signal local_osc : std_logic_vector(31 downto 0) := (others => '0');
  signal local_osc_valid : std_logic := '0';

  signal beam_selector : std_logic_vector(2 downto 0) := (others => '0');

begin

  data_control_inst : entity work.data_control(rtl)
    generic map(
      USER_CORE_ID_VER => USER_CORE_ID_VER,
      N                => N,
      FIFO_EMPTY_VAL   => FIFO_EMPTY_VAL
    )
    port map(
      S_AXI_ACLK      => ps_clk_i,                --: in std_logic;
      S_AXI_ARESETN   => ps_rst_n_i,              -- in std_logic;
      S_AXI_AWADDR    => s_axi4l_control_awaddr,  --: in std_logic_vector(10-1 downto 0);
      S_AXI_AWPROT    => s_axi4l_control_awprot,  --: in std_logic_vector(2 downto 0);
      S_AXI_AWVALID   => s_axi4l_control_awvalid, --: in std_logic;
      S_AXI_AWREADY   => s_axi4l_control_awready, -- : out std_logic;
      S_AXI_WDATA     => s_axi4l_control_wdata,
      S_AXI_WSTRB     => s_axi4l_control_wstrb,
      S_AXI_WVALID    => s_axi4l_control_wvalid,
      S_AXI_WREADY    => s_axi4l_control_wready,
      S_AXI_BRESP     => s_axi4l_control_bresp,
      S_AXI_BVALID    => s_axi4l_control_bvalid,
      S_AXI_BREADY    => s_axi4l_control_bready,
      S_AXI_ARADDR    => s_axi4l_control_araddr,
      S_AXI_ARPROT    => s_axi4l_control_arprot,
      S_AXI_ARVALID   => s_axi4l_control_arvalid,
      S_AXI_ARREADY   => s_axi4l_control_arready,
      S_AXI_RDATA     => s_axi4l_control_rdata,
      S_AXI_RRESP     => s_axi4l_control_rresp,
      S_AXI_RVALID    => s_axi4l_control_rvalid,
      S_AXI_RREADY    => s_axi4l_control_rready,
      async_rst_o     => async_rst_from_AXI,
      fifo_rst_o      => fifo_rst_from_AXI,
      debug_enable_o  => debug_enable_from_AXI,
      debug_control_o => debug_control_from_AXI,
      debug_w2w1_o    => debug_w2w1_from_AXI,
      fifo_rd_en_o    => fifo_rd_en_from_AXI,
      fifo_out_i      => fifo_out_to_AXI,
      ext_trigger_i   => ext_trigger_i
    );

  preprocessing_registers_inst : entity work.axi_16_reg_block(arch_imp)
    generic map(
      CORE_CONTROL => USER_CORE_ID_VER
    )
    port map(
      S_AXI_ACLK           => ps_clk_i,
      S_AXI_ARESETN        => ps_rst_n_i,
      S_AXI_AWADDR         => s_axi4l_preproc_awaddr,
      S_AXI_AWPROT         => s_axi4l_preproc_awprot,
      S_AXI_AWVALID        => s_axi4l_preproc_awvalid,
      S_AXI_AWREADY        => s_axi4l_preproc_awready,
      S_AXI_WDATA          => s_axi4l_preproc_wdata,
      S_AXI_WSTRB          => s_axi4l_preproc_wstrb,
      S_AXI_WVALID         => s_axi4l_preproc_wvalid,
      S_AXI_WREADY         => s_axi4l_preproc_wready,
      S_AXI_BRESP          => s_axi4l_preproc_bresp,
      S_AXI_BVALID         => s_axi4l_preproc_bvalid,
      S_AXI_BREADY         => s_axi4l_preproc_bready,
      S_AXI_ARADDR         => s_axi4l_preproc_araddr,
      S_AXI_ARPROT         => s_axi4l_preproc_arprot,
      S_AXI_ARVALID        => s_axi4l_preproc_arvalid,
      S_AXI_ARREADY        => s_axi4l_preproc_arready,
      S_AXI_RDATA          => s_axi4l_preproc_rdata,
      S_AXI_RRESP          => s_axi4l_preproc_rresp,
      S_AXI_RVALID         => s_axi4l_preproc_rvalid,
      S_AXI_RREADY         => s_axi4l_preproc_rready,
      fifo_input_mux_o     => fifo_input_mux_sel,
      data_source_selector => data_source_sel,

      ch_1_freq_data       => ch_1_freq,
      ch_1_freq_valid      => ch_1_valid,
      ch_1_freq_sign       => ch_1_sign,
      ch_1_freq_sign_valid => ch_1_sign_valid,
      ch_2_freq_data       => ch_2_freq,
      ch_2_freq_valid      => ch_2_valid,
      ch_2_freq_sign       => ch_2_sign,
      ch_2_freq_sign_valid => ch_2_sign_valid,
      ch_3_freq_data       => ch_3_freq,
      ch_3_freq_valid      => ch_3_valid,
      ch_3_freq_sign       => ch_3_sign,
      ch_3_freq_sign_valid => ch_3_sign_valid,
      ch_4_freq_data       => ch_4_freq,
      ch_4_freq_valid      => ch_4_valid,
      ch_4_freq_sign       => ch_4_sign,
      ch_4_freq_sign_valid => ch_4_sign_valid,
      local_osc_data       => local_osc,
      local_osc_valid      => local_osc_valid,
      beam_selector        => beam_selector
    );

  --CRC block

  ---- DELAY CONTROL
  -- instantiate IBUFDS and BUFG for external ref clk, and IDELAYCTRL to control IDELAYs in receivers

  -- BUFG: Global Clock Simple Buffer
  --       Kintex-7
  BUFG_inst_IDELAYCTRL : BUFG
  port map(
    O => delay_refclk, -- 1-bit output: Clock output
    I => ps_clk_i      -- 1-bit input: Clock input
  );

  -- IDELAYCTRL: IDELAYE2/ODELAYE2 Tap Delay Value Control
  --             Kintex-7
  IDELAYCTRL_inst : IDELAYCTRL
  port map(
    RDY    => delay_locked_o, -- 1-bit output: Ready output
    REFCLK => delay_refclk,   -- 1-bit input: Reference clock input
    RST    => debug_rst       -- 1-bit input: Active high reset input
  );

  --receiver for bank12 signals
  --bank12 has DCO2 and FCO2
  adc_receiver1_inst : entity work.adc_receiver(arch)
    generic map(
      RES_ADC => RES_ADC,
      N       => N1,
      N_tr_b  => N_tr_b
    )
    port map(
      fpga_clk_i           => ps_clk_i,
      async_rst_i          => debug_rst,

      adc_clk_p_i          => adc_DCO2_p_i,
      adc_clk_n_i          => adc_DCO2_n_i,
      adc_frame_p_i        => adc_FCO2_p_i,
      adc_frame_n_i        => adc_FCO2_n_i,
      adc_data_p_i         => adc_data_to_r1_p,
      adc_data_n_i         => adc_data_to_r1_n,
      adc_FCOlck_o         => adc_FCO2lck_o,

      delay_refclk_i       => delay_refclk,
      delay_data_ld_i      => delay_data_ld_to_r1,
      delay_data_input_i   => delay_data_input_to_r1,
      delay_data_output_o  => delay_data_output_from_r1,
      delay_frame_ld_i     => delay_frame1_ld_i,
      delay_frame_input_i  => delay_frame1_input_i,
      delay_frame_output_o => delay_frame1_output_o,

      --output
      clk_260_mhz_o        => clk_260_mhz,
      clk_455_mhz_o        => clk_455_mhz,
      data_adc_o           => deser_data_1,
      valid_adc_o          => valid_adc
    );

  --receiver for bank13 signals
  --bank13 has DCO1 and FCO1
  adc_receiver2_inst : entity work.adc_receiver(arch)
    generic map(
      RES_ADC => RES_ADC,
      N       => N2,
      N_tr_b  => N_tr_b
    )
    port map(
      fpga_clk_i           => ps_clk_i,
      async_rst_i          => debug_rst,

      adc_clk_p_i          => adc_DCO1_p_i,
      adc_clk_n_i          => adc_DCO1_n_i,
      adc_frame_p_i        => adc_FCO1_p_i,
      adc_frame_n_i        => adc_FCO1_n_i,
      adc_data_p_i         => adc_data_to_r2_p,
      adc_data_n_i         => adc_data_to_r2_n,
      adc_FCOlck_o         => adc_FCO1lck_o,

      delay_refclk_i       => delay_refclk,
      delay_data_ld_i      => delay_data_ld_to_r2,
      delay_data_input_i   => delay_data_input_to_r2,
      delay_data_output_o  => delay_data_output_from_r2,
      delay_frame_ld_i     => delay_frame2_ld_i,
      delay_frame_input_i  => delay_frame2_input_i,
      delay_frame_output_o => delay_frame2_output_o,

      --output
      clk_260_mhz_o        => open,
      clk_455_mhz_o        => open,
      data_adc_o           => deser_data_2,
      valid_adc_o          => open
    );

  --Instantiate data handler
  data_handler_inst : entity work.data_handler(arch)
    generic map(
      RES_ADC => RES_ADC,
      N1      => N1,
      N2      => N2
    )
    port map(
      sys_clk_i              => clk_260_mhz,
      async_rst_i            => debug_rst,
      fpga_clk_i             => ps_clk_i,
      clk_455_mhz_i          => clk_455_mhz,

      data_adc_i             => deser_data,
      valid_adc_i            => valid_adc,

      debug_enable_i         => debug_enable_from_AXI,
      debug_control_i        => debug_control_from_AXI,
      debug_w2w1_i           => debug_w2w1_from_AXI,

      fifo_input_mux_sel_i   => fifo_input_mux_sel,
      data_source_sel_i      => data_source_sel,
      ch_1_freq_i            => ch_1_freq,
      ch_1_freq_valid_i      => ch_1_valid,
      ch_1_sign_i            => ch_1_sign,
      ch_1_sign_valid_i      => ch_1_sign_valid,

      ch_2_freq_i            => ch_2_freq,
      ch_2_freq_valid_i      => ch_2_valid,
      ch_2_sign_i            => ch_2_sign,
      ch_2_sign_valid_i      => ch_2_sign_valid,

      ch_3_freq_i            => ch_3_freq,
      ch_3_freq_valid_i      => ch_3_valid,
      ch_3_sign_i            => ch_3_sign,
      ch_3_sign_valid_i      => ch_3_sign_valid,

      ch_4_freq_i            => ch_4_freq,
      ch_4_freq_valid_i      => ch_4_valid,
      ch_4_sign_i            => ch_4_sign,
      ch_4_sign_valid_i      => ch_4_sign_valid,

      ch_5_freq_i            => ch_5_freq,
      ch_5_freq_valid_i      => ch_5_valid,
      ch_5_sign_i            => ch_5_sign,
      ch_5_sign_valid_i      => ch_5_sign_valid,

      local_osc_freq_i       => local_osc,
      local_osc_freq_valid_i => local_osc_valid,

      beam_selector_i        => beam_selector,

      --output
      fifo_rst_i             => fifo_rst,
      fifo_rd_en_i           => fifo_rd_en_from_AXI,
      fifo_out_o             => fifo_out_to_AXI
    );

  --reset handling
  fifo_rst <= fifo_rst_from_AXI or rst_peripherals_i;
  debug_rst <= async_rst_from_AXI or rst_peripherals_i;

  --ADC data mapping
  adc_data_to_r1_p(0) <= adc_data_p_i(0);
  adc_data_to_r1_p(1) <= adc_data_p_i(1);
  adc_data_to_r1_p(2) <= adc_data_p_i(2);
  adc_data_to_r1_p(3) <= adc_data_p_i(3);
  adc_data_to_r1_p(4) <= adc_data_p_i(4);
  adc_data_to_r1_p(5) <= adc_data_p_i(5);
  adc_data_to_r1_p(6) <= adc_data_p_i(6);
  adc_data_to_r1_p(7) <= adc_data_p_i(7);
  adc_data_to_r1_p(8) <= adc_data_p_i(8);
  adc_data_to_r1_p(9) <= adc_data_p_i(9);
  adc_data_to_r1_p(10) <= adc_data_p_i(10);
  adc_data_to_r2_p(0) <= adc_data_p_i(11);
  adc_data_to_r1_p(11) <= adc_data_p_i(12);
  adc_data_to_r1_p(12) <= adc_data_p_i(13);
  adc_data_to_r1_p(13) <= adc_data_p_i(14);
  adc_data_to_r2_p(1) <= adc_data_p_i(15);
  adc_data_to_r1_n(0) <= adc_data_n_i(0);
  adc_data_to_r1_n(1) <= adc_data_n_i(1);
  adc_data_to_r1_n(2) <= adc_data_n_i(2);
  adc_data_to_r1_n(3) <= adc_data_n_i(3);
  adc_data_to_r1_n(4) <= adc_data_n_i(4);
  adc_data_to_r1_n(5) <= adc_data_n_i(5);
  adc_data_to_r1_n(6) <= adc_data_n_i(6);
  adc_data_to_r1_n(7) <= adc_data_n_i(7);
  adc_data_to_r1_n(8) <= adc_data_n_i(8);
  adc_data_to_r1_n(9) <= adc_data_n_i(9);
  adc_data_to_r1_n(10) <= adc_data_n_i(10);
  adc_data_to_r2_n(0) <= adc_data_n_i(11);
  adc_data_to_r1_n(11) <= adc_data_n_i(12);
  adc_data_to_r1_n(12) <= adc_data_n_i(13);
  adc_data_to_r1_n(13) <= adc_data_n_i(14);
  adc_data_to_r2_n(1) <= adc_data_n_i(15);

  --deserializer data mapping
  deser_data(0) <= deser_data_1(0);
  deser_data(1) <= deser_data_1(1);
  deser_data(2) <= deser_data_1(2);
  deser_data(3) <= deser_data_1(3);
  deser_data(4) <= deser_data_1(4);
  deser_data(5) <= deser_data_1(5);
  deser_data(6) <= deser_data_1(6);
  deser_data(7) <= deser_data_1(7);
  deser_data(8) <= deser_data_1(8);
  deser_data(9) <= deser_data_1(9);
  deser_data(10) <= deser_data_1(10);
  deser_data(11) <= deser_data_2(0);
  deser_data(12) <= deser_data_1(11);
  deser_data(13) <= deser_data_1(12);
  deser_data(14) <= deser_data_1(13);
  deser_data(15) <= deser_data_2(1);

  --delay data ld mapping
  delay_data_ld_to_r1(0) <= delay_data_ld_i(0);
  delay_data_ld_to_r1(1) <= delay_data_ld_i(1);
  delay_data_ld_to_r1(2) <= delay_data_ld_i(2);
  delay_data_ld_to_r1(3) <= delay_data_ld_i(3);
  delay_data_ld_to_r1(4) <= delay_data_ld_i(4);
  delay_data_ld_to_r1(5) <= delay_data_ld_i(5);
  delay_data_ld_to_r1(6) <= delay_data_ld_i(6);
  delay_data_ld_to_r1(7) <= delay_data_ld_i(7);
  delay_data_ld_to_r1(8) <= delay_data_ld_i(8);
  delay_data_ld_to_r1(9) <= delay_data_ld_i(9);
  delay_data_ld_to_r1(10) <= delay_data_ld_i(10);
  delay_data_ld_to_r2(0) <= delay_data_ld_i(11);
  delay_data_ld_to_r1(11) <= delay_data_ld_i(12);
  delay_data_ld_to_r1(12) <= delay_data_ld_i(13);
  delay_data_ld_to_r1(13) <= delay_data_ld_i(14);
  delay_data_ld_to_r2(1) <= delay_data_ld_i(15);

  --delay data input mapping
  delay_data_input_to_r1(4 downto 0) <= delay_data_input_i(4 downto 0);
  delay_data_input_to_r1(9 downto 5) <= delay_data_input_i(9 downto 5);
  delay_data_input_to_r1(14 downto 10) <= delay_data_input_i(14 downto 10);
  delay_data_input_to_r1(19 downto 15) <= delay_data_input_i(19 downto 15);
  delay_data_input_to_r1(24 downto 20) <= delay_data_input_i(24 downto 20);
  delay_data_input_to_r1(29 downto 25) <= delay_data_input_i(29 downto 25);
  delay_data_input_to_r1(34 downto 30) <= delay_data_input_i(34 downto 30);
  delay_data_input_to_r1(39 downto 35) <= delay_data_input_i(39 downto 35);
  delay_data_input_to_r1(44 downto 40) <= delay_data_input_i(44 downto 40);
  delay_data_input_to_r1(49 downto 45) <= delay_data_input_i(49 downto 45);
  delay_data_input_to_r1(54 downto 50) <= delay_data_input_i(54 downto 50);
  delay_data_input_to_r2(4 downto 0) <= delay_data_input_i(59 downto 55);
  delay_data_input_to_r1(59 downto 55) <= delay_data_input_i(64 downto 60);
  delay_data_input_to_r1(64 downto 60) <= delay_data_input_i(69 downto 65);
  delay_data_input_to_r1(69 downto 65) <= delay_data_input_i(74 downto 70);
  delay_data_input_to_r2(9 downto 5) <= delay_data_input_i(79 downto 75);

  --delay data output mapping
  delay_data_output_o(4 downto 0) <= delay_data_output_from_r1(4 downto 0);
  delay_data_output_o(9 downto 5) <= delay_data_output_from_r1(9 downto 5);
  delay_data_output_o(14 downto 10) <= delay_data_output_from_r1(14 downto 10);
  delay_data_output_o(19 downto 15) <= delay_data_output_from_r1(19 downto 15);
  delay_data_output_o(24 downto 20) <= delay_data_output_from_r1(24 downto 20);
  delay_data_output_o(29 downto 25) <= delay_data_output_from_r1(29 downto 25);
  delay_data_output_o(34 downto 30) <= delay_data_output_from_r1(34 downto 30);
  delay_data_output_o(39 downto 35) <= delay_data_output_from_r1(39 downto 35);
  delay_data_output_o(44 downto 40) <= delay_data_output_from_r1(44 downto 40);
  delay_data_output_o(49 downto 45) <= delay_data_output_from_r1(49 downto 45);
  delay_data_output_o(54 downto 50) <= delay_data_output_from_r1(54 downto 50);
  delay_data_output_o(59 downto 55) <= delay_data_output_from_r2(4 downto 0);
  delay_data_output_o(64 downto 60) <= delay_data_output_from_r1(59 downto 55);
  delay_data_output_o(69 downto 65) <= delay_data_output_from_r1(64 downto 60);
  delay_data_output_o(74 downto 70) <= delay_data_output_from_r1(69 downto 65);
  delay_data_output_o(79 downto 75) <= delay_data_output_from_r2(9 downto 5);

end arch; -- arch
