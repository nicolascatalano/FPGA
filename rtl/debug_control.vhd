----------------------------------------------------------------------------------
-- Company: IB
-- Engineer: José Quinteros
--
-- Design Name:
-- Module Name:
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: FIFO input multiplexing for control and debugging
--
-- Dependencies:
--
-- Revision: 2020-11-19
-- Additional Comments:
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity debug_control is
  generic (
    RES_ADC : integer := 14
  );
  port (
    clock_i         : in std_logic;
    rst_i           : in std_logic;
    enable_i        : in std_logic;                                    --global enable
    control_i       : in std_logic_vector(3 downto 0);                 --multiplexer control
    usr_w2w1_i      : in std_logic_vector((2 * RES_ADC - 1) downto 0); --user constants
    data_i          : in std_logic_vector((RES_ADC - 1) downto 0);     --deserializer data
    valid_i         : in std_logic;                                    --deserializer trigger

    counter_count_i : in std_logic_vector((RES_ADC - 1) downto 0);
    counter_ce_o    : out std_logic;

    data_o          : out std_logic_vector((RES_ADC - 1) downto 0);
    valid_o         : out std_logic
  );
end debug_control;

architecture arch of debug_control is
  constant onesNbits : std_logic_vector((RES_ADC - 1) downto 0) := (others => '1');
  constant zerosNbits : std_logic_vector((RES_ADC - 1) downto 0) := (others => '0');

  constant midscaleShort : std_logic_vector(13 downto 0) := "10000000000000";
  constant sync_1x : std_logic_vector(13 downto 0) := "00000001111111";
  constant mix_freq : std_logic_vector(13 downto 0) := "10100001100111";

  signal out_reg : std_logic_vector((RES_ADC - 1) downto 0);
  signal valid_reg : std_logic;
  signal counter_ce_reg : std_logic;

  --Xilinx parameters
  attribute X_INTERFACE_INFO : string;
  attribute X_INTERFACE_INFO of counter_ce_o : signal is "xilinx.com:signal:clockenable:1.0 counter_ce_o CE";
  attribute X_INTERFACE_PARAMETER : string;
  attribute X_INTERFACE_PARAMETER of counter_ce_o : signal is "POLARITY ACTIVE_HIGH";

begin
  process (clock_i, rst_i)
  begin
    if (rst_i = '1') then
      valid_reg <= '0';
      counter_ce_reg <= '0';
    elsif (rising_edge(clock_i)) then
      valid_reg <= '0';
      counter_ce_reg <= '0';
      out_reg <= zerosNbits;
      if (enable_i = '1') then
        valid_reg <= valid_i;
        case control_i is
          when x"0" | x"3" =>
            out_reg <= zerosNbits;
          when x"1" | x"b" =>
            out_reg <= midscaleShort;
          when x"2" =>
            out_reg <= onesNbits;
          when x"8" =>
            out_reg <= usr_w2w1_i((RES_ADC - 1) downto 0);
          when x"9" =>
            out_reg <= usr_w2w1_i((2 * RES_ADC - 1) downto RES_ADC);
          when x"a" =>
            out_reg <= sync_1x;
          when x"c" =>
            out_reg <= mix_freq;
          when x"D" =>
            out_reg <= data_i;
          when x"F" =>
            out_reg <= counter_count_i;
            counter_ce_reg <= '1';
          when others =>
            out_reg <= zerosNbits;
        end case;
      end if;
    end if;
  end process;

  data_o <= out_reg;
  valid_o <= valid_reg;
  counter_ce_o <= counter_ce_reg;

end arch;
