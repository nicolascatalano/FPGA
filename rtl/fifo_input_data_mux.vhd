library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;

entity fifo_input_data_mux is
  generic (
    NUM_CHANNELS : integer := 16;
    RES_ADC      : integer := 14
  );
  port (
    sys_clk_i                    : in std_logic;
    sys_rst_i                    : in std_logic;

    -- Mux control
    data_mux_sel_i               : in std_logic_vector(2 downto 0);

    -- Data from preprocessing logic
    data_preproc_i               : in std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    data_preproc_valid_i         : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    -- Raw data from deserializer
    data_raw_i                   : in std_logic_vector(RES_ADC * NUM_CHANNELS - 1 downto 0);
    data_raw_valid_i             : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    -- Postproc counter
    postproc_counter_i           : in std_logic_vector(32 - 1 downto 0);

    -- Data source mux
    data_mux_data_source_i       : in std_logic_vector(16 * NUM_CHANNELS - 1 downto 0);
    data_mux_data_source_valid_i : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    -- Data band mixer
    data_band_mixer_i            : in std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    data_band_mixer_valid_i      : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    -- Data band filter
    data_band_filter_i           : in std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    data_band_filter_valid_i     : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    -- Channel mixer for debug
    data_channel_mixer_i         : in std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    data_channel_mixer_valid_i   : in std_logic_vector(NUM_CHANNELS - 1 downto 0);

    -- Output data
    data_o                       : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    data_valid_o                 : out std_logic
  );

end entity fifo_input_data_mux;

architecture arch of fifo_input_data_mux is
  signal data_raw_shift_reg : std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
  signal data_raw_toggle_reg : std_logic;
begin

  aproc_data_mux : process (sys_clk_i, sys_rst_i)
  begin
    if sys_rst_i = '1' then
      data_valid_o <= '0';
      data_raw_toggle_reg <= '0';
      elsif rising_edge(sys_clk_i) then

      data_valid_o <= '0';

      case data_mux_sel_i is
        when "000" => --disabled
          data_valid_o <= '0';
        when "001" => --preprocessing data
        if (data_preproc_valid_i(0) = '1') then
          data_o <= data_preproc_i;
          data_valid_o <= '1';
        end if;
        when "010" => --postproc counter
        if (data_preproc_valid_i(0) = '1') then
          for i in 0 to NUM_CHANNELS - 1 loop
            data_o(32 * (i + 1) - 1 downto 32 * i) <= postproc_counter_i;
          end loop;
          data_valid_o <= '1';
        end if;
        when "011" => -- raw data. Group by two to fit in FIFO input
          if (data_raw_valid_i(0) = '1')then
            for i in 0 to NUM_CHANNELS - 1 loop
              data_raw_shift_reg(32 * (i + 1) - 1 downto 16 * (2 * i + 1)) <= data_raw_shift_reg(16 * (2 * i + 1) - 1 downto 32 * i);
              data_raw_shift_reg(16 * (2 * i + 1) - 1 downto 32 * i) <= "00" & data_raw_i(RES_ADC * (i + 1) - 1 downto RES_ADC * i);
            end loop;
            data_raw_toggle_reg <= not data_raw_toggle_reg;
            if (data_raw_toggle_reg = '1') then
              data_o <= data_raw_shift_reg;
              data_valid_o <= '1';
            end if;
          end if;
        when "100" => -- data source mux
          if (data_mux_data_source_valid_i(0) = '1') then
            for i in 0 to NUM_CHANNELS - 1 loop
              data_o(32 * (i + 1) - 1 downto 32 * i) <= data_mux_data_source_i(16 * (i + 1) - 1 downto 16 * i) & data_mux_data_source_i(16 * (i + 1) - 1 downto 16 * i);
            end loop;
            data_valid_o <= '1';
          end if;
        when "101" => -- band mixer
          if (data_band_mixer_valid_i(0) = '1') then
            data_o <= data_band_mixer_i;
            data_valid_o <= '1';
          end if;
        when "110" => -- band filter
          if (data_band_filter_valid_i(0) = '1') then
            data_o <= data_band_filter_i;
            data_valid_o <= '1';
          end if;
        when "111" => -- channel mixer
          if (data_channel_mixer_valid_i(0) = '1') then
            data_o <= data_channel_mixer_i;
            data_valid_o <= '1';
          end if;
        when others =>
          data_valid_o <= '0';
      end case;
    end if;
  end process aproc_data_mux;

end architecture arch;
