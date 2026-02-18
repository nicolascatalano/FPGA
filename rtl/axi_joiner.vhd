library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity axi_joiner is
  generic (
    DATA_LENGTH : integer := 32);
  port (
    clk_i         : in std_logic;
    s_axis_tdata  : in std_logic_vector(DATA_LENGTH - 1 downto 0);
    s_axis_tvalid : in std_logic;
    s_axis_tuser  : in std_logic_vector(2 downto 0);

    m_axis_tdata  : out std_logic_vector(DATA_LENGTH * 5 - 1 downto 0);
    m_axis_tvalid : out std_logic_vector(4 downto 0)
  );
end axi_joiner;

architecture rtl of axi_joiner is
begin
  process (clk_i)
  begin
    if rising_edge(clk_i) then
      m_axis_tvalid <= (others => '0');
      case s_axis_tuser is
        when "000" =>
          m_axis_tdata(DATA_LENGTH - 1 downto 0) <= s_axis_tdata;
          m_axis_tvalid(0) <= s_axis_tvalid;
        when "001" =>
          m_axis_tdata(DATA_LENGTH * 2 - 1 downto DATA_LENGTH) <= s_axis_tdata;
          m_axis_tvalid(1) <= s_axis_tvalid;
        when "010" =>
          m_axis_tdata(DATA_LENGTH * 3 - 1 downto DATA_LENGTH * 2) <= s_axis_tdata;
          m_axis_tvalid(2) <= s_axis_tvalid;
        when "011" =>
          m_axis_tdata(DATA_LENGTH * 4 - 1 downto DATA_LENGTH * 3) <= s_axis_tdata;
          m_axis_tvalid(3) <= s_axis_tvalid;
        when "100" =>
          m_axis_tdata(DATA_LENGTH * 5 - 1 downto DATA_LENGTH * 4) <= s_axis_tdata;
          m_axis_tvalid(4) <= s_axis_tvalid;
        when others =>
          m_axis_tdata <= (others => '0');
          m_axis_tvalid <= (others => '0');
      end case;
    end if;
  end process;
end rtl;
