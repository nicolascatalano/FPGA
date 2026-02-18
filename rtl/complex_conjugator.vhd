library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity complex_conjugator is
    generic (
        DATA_WIDTH : integer := 16
    );
    port (
        sys_clk_i         : in std_logic;
        sys_rst_ni        : in std_logic;
        s_axis_tdata_in   : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        s_axis_tvalid_in  : in std_logic;
        config_sign_data  : in std_logic;
        config_sign_valid : in std_logic;
        m_axis_tdata_out  : out std_logic_vector(DATA_WIDTH - 1 downto 0);
        m_axis_tvalid_out : out std_logic
    );
end complex_conjugator;

architecture rtl of complex_conjugator is
    signal m_axis_tdata_reg : std_logic_vector(DATA_WIDTH - 1 downto 0);
    signal m_axis_tvalid_reg : std_logic;
    signal config_sign_data_reg : std_logic;
begin
    process (sys_clk_i, sys_rst_ni)
    begin
        if (sys_rst_ni = '0') then
            m_axis_tdata_reg <= (others => '0');
            m_axis_tvalid_reg <= '0';
            config_sign_data_reg <= '0';
        elsif (rising_edge(sys_clk_i)) then

            if (config_sign_valid = '1') then
                config_sign_data_reg <= config_sign_data;
            end if;

            m_axis_tvalid_reg <= '0';
            if (s_axis_tvalid_in = '1') then
                if (config_sign_data_reg = '0') then
                    m_axis_tdata_reg <= s_axis_tdata_in;
                else
                    m_axis_tdata_reg <= std_logic_vector(resize((-1) * signed(s_axis_tdata_in(DATA_WIDTH - 1 downto DATA_WIDTH/2)), DATA_WIDTH/2)) & s_axis_tdata_in(DATA_WIDTH/2 - 1 downto 0);
                end if;
                m_axis_tvalid_reg <= '1';
            end if;
        end if;
    end process;

    m_axis_tdata_out <= m_axis_tdata_reg;
    m_axis_tvalid_out <= m_axis_tvalid_reg;
end rtl;
