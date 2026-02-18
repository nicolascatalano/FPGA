----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: ADC signals reception module
--
-- Dependencies: None.
--
-- Revision: 2020-11-11
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

entity adc_receiver is
  generic (
    RES_ADC : integer := 14; --ADC resolution, can take values 14 or 12
    N       : integer := 1;  --number of ADC data channels
    N_tr_b  : integer := 10  --bits for downsampler treshold register
  );
  port (
    fpga_clk_i           : in std_logic;
    async_rst_i          : in std_logic;

    adc_clk_p_i          : in std_logic;
    adc_clk_n_i          : in std_logic;
    adc_frame_p_i        : in std_logic;
    adc_frame_n_i        : in std_logic;
    adc_data_p_i         : in std_logic_vector((N - 1) downto 0);
    adc_data_n_i         : in std_logic_vector((N - 1) downto 0);
    adc_FCOlck_o         : out std_logic;

    delay_refclk_i       : in std_logic;
    delay_data_ld_i      : in std_logic_vector((N - 1) downto 0);
    delay_data_input_i   : in std_logic_vector((5 * N - 1) downto 0);
    delay_data_output_o  : out std_logic_vector((5 * N - 1) downto 0);
    delay_frame_ld_i     : in std_logic;
    delay_frame_input_i  : in std_logic_vector((5 - 1) downto 0);
    delay_frame_output_o : out std_logic_vector((5 - 1) downto 0);

    --output
    clk_260_mhz_o        : out std_logic;
    clk_455_mhz_o        : out std_logic;
    data_adc_o           : out adc_data_t((N - 1) downto 0);
    valid_adc_o          : out std_logic
  );
end adc_receiver;

architecture arch of adc_receiver is

  component clk_wiz_preproc
    port (-- Clock in ports
      -- Clock out ports
      clk_out1 : out std_logic;
      -- Status and control signals
      reset    : in std_logic;
      locked   : out std_logic;
      clk_in1  : in std_logic
    );
  end component;

  --End preprocessing components
  signal clk_to_bufs, clk_to_iddr, clk_to_logic, clk_260_mhz : std_logic;
  signal data_to_idelays, data_to_iddr : std_logic_vector((N - 1) downto 0);

  signal data_from_IDDR_RE, data_from_IDDR_FE : std_logic_vector((N - 1) downto 0);
  signal data_to_des_RE, data_to_des_FE : std_logic_vector((N - 1) downto 0);
  signal data_from_deser : std_logic_vector((RES_ADC * N - 1) downto 0);
  signal valid_from_deser : std_logic_vector((N - 1) downto 0);

  signal frame_to_idelay, frame_to_iddr : std_logic;
  signal frame_delayed_from_iddr, frame_delayed_to_deser : std_logic;

  signal data_from_deser_slow : std_logic_vector(16 * N - 1 downto 0);
  signal valid_from_deser_slow : std_logic_vector((N - 1) downto 0);

  signal async_rst_n : std_logic;
begin

  async_rst_n <= not(async_rst_i);

  ---- CLOCK RECEPTION

  -- CLK > BUFIO > BUFG

  -- IDDR is driven by BUFIO
  -- BUFG output is used as clock for user logic

  -- IBUFDS: Differential Input Buffer
  --         Kintex-7
  IBUFDS_inst_clk : IBUFDS
  generic map(
    DIFF_TERM    => FALSE, -- Differential Termination
    IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD   => "LVDS_25")
  port map(
    O  => clk_to_bufs, -- Buffer output
    I  => adc_clk_p_i, -- Diff_p buffer input (connect directly to top-level port)
    IB => adc_clk_n_i  -- Diff_n buffer input (connect directly to top-level port)
  );

  -- BUFIO: Local Clock Buffer for I/O
  --        Kintex-7
  BUFIO_inst_clk : BUFIO
  port map(
    O => clk_to_iddr, -- 1-bit output: Clock output (connect to I/O clock loads).
    I => clk_to_bufs  -- 1-bit input: Clock input (connect to an IBUF or BUFMR).
  );

  -- BUFG: Global Clock Simple Buffer
  --       Kintex-7
  BUFG_inst : BUFG
  port map(
    O => clk_to_logic, -- 1-bit output: Clock output
    I => clk_to_bufs   -- 1-bit input: Clock input
  );

  ---- FRAME

  -- IBUFDS: Differential Input Buffer
  --         Kintex-7
  IBUFDS_inst_frame : IBUFDS
  generic map(
    DIFF_TERM    => FALSE, -- Differential Termination
    IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
    IOSTANDARD   => "LVDS_25")
  port map(
    O  => frame_to_idelay, -- Buffer output
    I  => adc_frame_p_i,   -- Diff_p buffer input (connect directly to top-level port)
    IB => adc_frame_n_i    -- Diff_n buffer input (connect directly to top-level port)
  );

  -- IDELAY: instantiate idelay_wrapper
  IDELAYE2_inst_frame : entity work.idelay_wrapper(arch)
    port map(
      async_rst_i => async_rst_i,
      data_i      => frame_to_idelay,
      data_o      => frame_to_iddr,
      clk_i       => delay_refclk_i,
      ld_i        => delay_frame_ld_i,
      input_i     => delay_frame_input_i,
      output_o    => delay_frame_output_o
    );

  -- IDDR: Double Data Rate Input Register with Set, Reset
  --       and Clock Enable.
  --       Kintex-7
  IDDR_inst_frame : IDDR
  generic map(
    DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE"
    -- or "SAME_EDGE_PIPELINED"
    INIT_Q1      => '0',                   -- Initial value of Q1: '0' or '1'
    INIT_Q2      => '0',                   -- Initial value of Q2: '0' or '1'
    SRTYPE       => "ASYNC")               -- Set/Reset type: "SYNC" or "ASYNC"
  port map(
    Q1 => open,                    -- 1-bit output for positive edge of clock
    Q2 => frame_delayed_from_iddr, -- 1-bit output for negative edge of clock
    C  => clk_to_iddr,             -- 1-bit clock input
    CE => '1',                     -- 1-bit clock enable input
    D  => frame_to_iddr,           -- 1-bit DDR data input
    R  => async_rst_i,             -- 1-bit reset
    S  => '0'                      -- 1-bit set
  );

  clk_wiz_preproc_inst : clk_wiz_preproc
  port map(
    -- Clock out ports
    clk_out1 => clk_260_mhz,
    -- Status and control signals
    reset    => async_rst_i,
    locked   => adc_FCOlck_o,
    -- Clock in ports
    clk_in1  => clk_to_logic
  );
  ---- ADC DATA INPUTS

  --process to register data_from_IDDR_FE to data_to_deserializer
  process (clk_to_logic)
  begin
    if rising_edge(clk_to_logic) then
      frame_delayed_to_deser <= frame_delayed_from_iddr;
      data_to_des_RE <= data_from_IDDR_RE;
      data_to_des_FE <= data_from_IDDR_FE;
    end if;
  end process;

  -- Generate IBUFDS, IDELAYs, IDDR, deserializer, downsampler for ADC data inputs
  ADC_data : for i in 0 to (N - 1) generate

    -- IBUFDS: Differential Input Buffer
    --         Kintex-7
    IBUFDS_inst_data : IBUFDS
    generic map(
      DIFF_TERM    => FALSE, -- Differential Termination
      IBUF_LOW_PWR => FALSE, -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
      IOSTANDARD   => "LVDS_25")
    port map(
      O  => data_to_idelays(i), -- Buffer output
      I  => adc_data_p_i(i),    -- Diff_p buffer input (connect directly to top-level port)
      IB => adc_data_n_i(i)     -- Diff_n buffer input (connect directly to top-level port)
    );

    -- IDELAY: instantiate idelay_wrapper
    IDELAYE2_inst_data : entity work.idelay_wrapper(arch)
      port map(
        async_rst_i => async_rst_i,
        data_i      => data_to_idelays(i),
        data_o      => data_to_iddr(i),
        clk_i       => delay_refclk_i,
        ld_i        => delay_data_ld_i(i),
        input_i     => delay_data_input_i((5 * (i + 1) - 1) downto (5 * i)),
        output_o    => delay_data_output_o((5 * (i + 1) - 1) downto (5 * i))
      );

    -- IDDR: Double Data Rate Input Register with Set, Reset
    --       and Clock Enable.
    --       Kintex-7
    IDDR_inst_data : IDDR
    generic map(
      DDR_CLK_EDGE => "SAME_EDGE_PIPELINED", -- "OPPOSITE_EDGE", "SAME_EDGE"
      -- or "SAME_EDGE_PIPELINED"
      INIT_Q1      => '0',                   -- Initial value of Q1: '0' or '1'
      INIT_Q2      => '0',                   -- Initial value of Q2: '0' or '1'
      SRTYPE       => "ASYNC")               -- Set/Reset type: "SYNC" or "ASYNC"
    port map(
      Q1 => data_from_IDDR_RE(i), -- 1-bit output for positive edge of clock
      Q2 => data_from_IDDR_FE(i), -- 1-bit output for negative edge of clock
      C  => clk_to_iddr,          -- 1-bit clock input
      CE => '1',                  -- 1-bit clock enable input
      D  => data_to_iddr(i),      -- 1-bit DDR data input
      R  => async_rst_i,          -- 1-bit reset
      S  => '0'                   -- 1-bit set
    );

    --instantiate deserializer
    deserializer_data : entity work.deserializer(arch)
      generic map(
        RES_ADC => RES_ADC
      )
      port map(
        adc_clk_i => clk_to_logic,
        rst_i     => async_rst_i,
        data_RE_i => data_to_des_RE(i),
        data_FE_i => data_to_des_FE(i),
        frame_i   => frame_delayed_to_deser,
        data_o    => data_adc_o(i),
        d_valid_o => valid_from_deser(i)
      );

  end generate ADC_data;

  clk_260_mhz_o <= clk_260_mhz;
  clk_455_mhz_o <= clk_to_logic;
  valid_adc_o <= valid_from_deser(0);
end arch; -- arch
