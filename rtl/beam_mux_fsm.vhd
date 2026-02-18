library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity beam_mux_fsm is
  generic (
    DATA_LENGTH : integer := 32);
  port (
    clk_i         : in std_logic;
    rst_ni        : in std_logic;
    s_axis_tdata  : in std_logic_vector(DATA_LENGTH - 1 downto 0);
    s_axis_tvalid : in std_logic;
    beams_data_i  : in std_logic_vector(32 * 5 - 1 downto 0);
    m_axis_tdata  : out std_logic_vector(DATA_LENGTH - 1 downto 0);
    m_axis_tvalid : out std_logic;
    m_axis_tuser  : out std_logic_vector(2 downto 0);
    beam_data_o   : out std_logic_vector(32 - 1 downto 0)
  );
end beam_mux_fsm;

architecture rtl of beam_mux_fsm is
  type state_type is (FIRST_BEAM, SECOND_BEAM, THIRD_BEAM, FOURTH_BEAM, FIFTH_BEAM);
  signal state : state_type := FIRST_BEAM;

  signal s_axis_tdata_reg : std_logic_vector(DATA_LENGTH - 1 downto 0);
  signal s_axis_tvalid_reg : std_logic;
  signal tuser_reg : std_logic_vector(2 downto 0);
  signal beam_data_reg : std_logic_vector(32 - 1 downto 0);
begin
  fsm : process (clk_i, rst_ni)
  begin
    if rst_ni = '0' then
      state <= FIRST_BEAM;
    elsif rising_edge(clk_i) then
      case state is
        when FIRST_BEAM =>
          s_axis_tvalid_reg <= '0';
          if s_axis_tvalid = '1' then
            state <= FIRST_BEAM;
            s_axis_tdata_reg <= s_axis_tdata;
            s_axis_tvalid_reg <= '1';
            tuser_reg <= "000";
            beam_data_reg <= beams_data_i(32 * 1 - 1 downto 32 * 0);
            state <= SECOND_BEAM;
          end if;
        when SECOND_BEAM =>
          tuser_reg <= "001";
          beam_data_reg <= beams_data_i(32 * 2 - 1 downto 32 * 1);
          state <= THIRD_BEAM;
        when THIRD_BEAM =>
          tuser_reg <= "010";
          beam_data_reg <= beams_data_i(32 * 3 - 1 downto 32 * 2);
          state <= FOURTH_BEAM;
        when FOURTH_BEAM =>
          tuser_reg <= "011";
          beam_data_reg <= beams_data_i(32 * 4 - 1 downto 32 * 3);
          state <= FIFTH_BEAM;
        when FIFTH_BEAM =>
          tuser_reg <= "100";
          beam_data_reg <= beams_data_i(32 * 5 - 1 downto 32 * 4);
          state <= FIRST_BEAM;
        when others =>
          state <= FIRST_BEAM;
      end case;
    end if;
  end process;

  m_axis_tdata <= s_axis_tdata_reg;
  m_axis_tvalid <= s_axis_tvalid_reg;
  m_axis_tuser <= tuser_reg;
  beam_data_o <= beam_data_reg;
end rtl;
