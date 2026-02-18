library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity dsp_dds_compiler_controller is
  generic (
    DATA_WIDTH         : natural := 32;
    DIVIDE_CLK_FREQ_BY : integer := 4);
  port (
    aclk          : in std_logic;
    rst_ni        : in std_logic;
    s_axis_tdata  : in std_logic_vector(DATA_WIDTH - 1 downto 0);
    s_axis_tvalid : in std_logic;
    s_axis_tready : out std_logic;
    m_axis_tdata  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
    m_axis_tvalid : out std_logic
  );
end entity dsp_dds_compiler_controller;

architecture rtl of dsp_dds_compiler_controller is
  signal counter_reg : std_logic_vector(7 downto 0);
  signal m_axis_tdata_reg : std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal m_axis_tvalid_reg : std_logic;
begin
  process (aclk)
  begin
    if rising_edge(aclk) then
      if (rst_ni = '0') then
        m_axis_tdata_reg <= (others => '0');
        m_axis_tvalid_reg <= '0';
        counter_reg <= (others => '0');
        s_axis_tready <= '0';
      else
        s_axis_tready <= '0';
        m_axis_tvalid_reg <= '0';
        counter_reg <= counter_reg + 1;
        if (counter_reg = std_logic_vector(to_unsigned(DIVIDE_CLK_FREQ_BY, 8) - 1)) then
          counter_reg <= (others => '0');
          if s_axis_tvalid = '1' then
            s_axis_tready <= '1';
            m_axis_tdata_reg <= s_axis_tdata;
            m_axis_tvalid_reg <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
  m_axis_tdata <= m_axis_tdata_reg;
  m_axis_tvalid <= m_axis_tvalid_reg;
end rtl;
