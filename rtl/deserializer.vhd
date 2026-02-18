----------------------------------------------------------------------------------
-- Company:  Instituto Balseiro
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Deserializer
--
-- Dependencies: None.
--
-- Revision: 2020-09-30
-- Additional Comments: Parallel data output will be synchronous to not(frame_i)
--
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity deserializer is
  generic (
    RES_ADC : integer := 14 --ADC resolution, can take values 14 or 12
  );
  port (
    adc_clk_i : in std_logic;
    rst_i     : in std_logic;

    data_RE_i : in std_logic;
    data_FE_i : in std_logic;
    frame_i   : in std_logic;

    data_o    : out std_logic_vector((14 - 1) downto 0);
    d_valid_o : out std_logic
  );
end deserializer;

architecture arch of deserializer is
  --Xilinx attributes
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of adc_clk_i : signal is "xilinx.com:signal:clock:1.0 adc_clk_i CLK";
  attribute X_INTERFACE_INFO of rst_i : signal is "xilinx.com:signal:reset:1.0 rst_i RST";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of adc_clk_i : signal is "ASSOCIATED_ASYNC_RESET rst_i";
  attribute X_INTERFACE_PARAMETER of rst_i : signal is "POLARITY ACTIVE_HIGH";

  --design signals
  -- signal d_reg, d_next     : std_logic_vector(13 downto 0) := (others => '0');
  -- signal out_reg, out_next : std_logic_vector(13 downto 0) := (others => '0');
  -- signal f_reg, f_next     : std_logic;
  -- signal zeros2            : std_logic_vector(1 downto 0) := (others => '0');

  signal d_reg : std_logic_vector(13 downto 0) := (others => '0');
  signal out_reg : std_logic_vector(13 downto 0) := (others => '0');
  signal f_reg : std_logic;
  signal zeros2 : std_logic_vector(1 downto 0) := (others => '0');
  signal valid_reg : std_logic := '0';

begin

  -- process (adc_clk_i)
  -- begin
  --   if (rst_i = '1') then
  --     d_reg   <= (others => '0');
  --     out_reg <= (others => '0');
  --     f_reg   <= '0';
  --   elsif (rising_edge(adc_clk_i)) then
  --     d_reg   <= d_next;
  --     out_reg <= out_next;
  --     f_reg   <= f_next;
  --   end if;
  -- end process;

  -- process (d_reg, f_reg, out_reg, data_RE_i, data_FE_i, frame_i)
  -- begin
  --   d_next <= d_reg(11 downto 0) & data_RE_i & data_FE_i;
  --   f_next <= frame_i;
  --   if (f_reg = '0' and frame_i = '1') then --rising edge del frame
  --     out_next <= d_reg;
  --   else
  --     out_next <= out_reg;
  --   end if;
  -- end process;

  -- data_o <= out_reg when (RES_ADC = 14) else
  --   zeros2 & out_reg(11 downto 0);

  --data is always valid
  --d_valid_o <= '1';

  process (adc_clk_i, rst_i)
  begin
    if (rst_i = '1') then
      d_reg <= (others => '0');
      out_reg <= (others => '0');
      f_reg <= '0';
      valid_reg <= '0';
    elsif (rising_edge(adc_clk_i)) then
      d_reg <= d_reg(11 downto 0) & data_RE_i & data_FE_i;
      --d_reg <= d_reg(11 downto 0) & data_FE_i & data_RE_i;
      f_reg <= frame_i;
      if (f_reg = '0' and frame_i = '1') then --rising edge del frame
        out_reg <= d_reg;
        valid_reg <= '1';
      else
        out_reg <= out_reg;
        valid_reg <= '0';
      end if;
    end if;
  end process;

  data_o <= out_reg when (RES_ADC = 14) else
    zeros2 & out_reg(11 downto 0);

  d_valid_o <= valid_reg;

end arch; -- arch
