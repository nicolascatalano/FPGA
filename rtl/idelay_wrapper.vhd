----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Wrapper for IDELAY primitive
--
-- Dependencies: None.
--
-- Revision: 2020-09-29
-- Additional Comments:
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity idelay_wrapper is
  port (
    async_rst_i : in std_logic;

    data_i      : in std_logic;
    data_o      : out std_logic;
    clk_i       : in std_logic;
    ld_i        : in std_logic;
    input_i     : in std_logic_vector((5 - 1) downto 0);
    output_o    : out std_logic_vector((5 - 1) downto 0)
  );
end idelay_wrapper;

architecture arch of idelay_wrapper is
  --Xilinx attributes
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of clk_i : signal is "xilinx.com:signal:clock:1.0 clk_i CLK";
  attribute X_INTERFACE_INFO of async_rst_i : signal is "xilinx.com:signal:reset:1.0 async_rst_i RST";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of async_rst_i : signal is "POLARITY ACTIVE_HIGH";

  attribute IODELAY_GROUP : string;
  attribute IODELAY_GROUP of IDELAYE2_inst : label is "Reception_Delays";

begin
  -- IDELAYE2: Input Fixed or Variable Delay Element
  --           Kintex-7
  -- Xilinx HDL Language Template, version 2019.1

  IDELAYE2_inst : IDELAYE2
  generic map(
    CINVCTRL_SEL          => "FALSE",    -- Enable dynamic clock inversion (FALSE, TRUE)
    DELAY_SRC             => "IDATAIN",  -- Delay input (IDATAIN, DATAIN)
    HIGH_PERFORMANCE_MODE => "TRUE",     -- Reduced jitter ("TRUE"), Reduced power ("FALSE")
    IDELAY_TYPE           => "VAR_LOAD", -- FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
    IDELAY_VALUE          => 0,          -- Input delay tap setting (0-31)
    PIPE_SEL              => "FALSE",    -- Select pipelined mode, FALSE, TRUE
    REFCLK_FREQUENCY      => 200.0,      -- IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
    SIGNAL_PATTERN        => "DATA"      -- DATA, CLOCK input signal
  )
  port map(
    CNTVALUEOUT => output_o,   -- 5-bit output: Counter value output
    DATAOUT     => data_o,     -- 1-bit output: Delayed data output
    C           => clk_i,      -- 1-bit input: Clock input
    CE          => '0',        -- 1-bit input: Active high enable increment/decrement input
    CINVCTRL    => '0',        -- 1-bit input: Dynamic clock inversion input
    CNTVALUEIN  => input_i,    -- 5-bit input: Counter value input
    DATAIN      => '0',        -- 1-bit input: Internal delay data input
    IDATAIN     => data_i,     -- 1-bit input: Data input from the I/O
    INC         => '0',        -- 1-bit input: Increment / Decrement tap delay input
    LD          => ld_i,       -- 1-bit input: Load IDELAY_VALUE input
    LDPIPEEN    => '0',        -- 1-bit input: Enable PIPELINE register to load data input
    REGRST      => async_rst_i -- 1-bit input: Active-high reset tap-delay input
  );

  -- End of IDELAYE2_inst instantiation
end arch; -- arch
