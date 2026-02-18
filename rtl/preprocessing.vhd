library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity preprocessing is
  generic (
    RES_ADC      : integer := 14;
    NUM_CHANNELS : integer := 16
  );
  port (
    sys_clk_i               : in std_logic;
    async_rst_i             : in std_logic;
    data_adc_i              : in std_logic_vector(RES_ADC * NUM_CHANNELS - 1 downto 0);
    valid_adc_i             : in std_logic;

    --preprocessing signals
    data_source_sel_i       : in std_logic_vector(1 downto 0);
    ch_1_freq_i             : in std_logic_vector(31 downto 0);
    ch_1_freq_valid_i       : in std_logic;
    ch_1_sign_i             : in std_logic;
    ch_1_sign_valid_i       : in std_logic;

    ch_2_freq_i             : in std_logic_vector(31 downto 0);
    ch_2_freq_valid_i       : in std_logic;
    ch_2_sign_i             : in std_logic;
    ch_2_sign_valid_i       : in std_logic;

    ch_3_freq_i             : in std_logic_vector(31 downto 0);
    ch_3_freq_valid_i       : in std_logic;
    ch_3_sign_i             : in std_logic;
    ch_3_sign_valid_i       : in std_logic;

    ch_4_freq_i             : in std_logic_vector(31 downto 0);
    ch_4_freq_valid_i       : in std_logic;
    ch_4_sign_i             : in std_logic;
    ch_4_sign_valid_i       : in std_logic;

    ch_5_freq_i             : in std_logic_vector(31 downto 0);
    ch_5_freq_valid_i       : in std_logic;
    ch_5_sign_i             : in std_logic;
    ch_5_sign_valid_i       : in std_logic;

    local_osc_freq_i        : in std_logic_vector(31 downto 0);
    local_osc_freq_valid_i  : in std_logic;

    --output signals
    data_ch_filter_o        : out std_logic_vector(32 * NUM_CHANNELS * 5 - 1 downto 0);
    valid_ch_filter_o       : out std_logic_vector(NUM_CHANNELS * 5 - 1 downto 0);
    data_mux_data_source_o  : out std_logic_vector(16 * NUM_CHANNELS - 1 downto 0);
    valid_mux_data_source_o : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_band_mixer_o       : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    valid_band_mixer_o      : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_band_filter_o      : out std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
    valid_band_filter_o     : out std_logic_vector(NUM_CHANNELS - 1 downto 0);
    data_channel_mixer_o    : out std_logic_vector(32 * 5 * NUM_CHANNELS - 1 downto 0);
    valid_channel_mixer_o   : out std_logic_vector(NUM_CHANNELS * 5 - 1 downto 0)
  );
end preprocessing;
architecture arch of preprocessing is

  component preprocessing_setup_bd is
    port (
      adc_clk_0                 : in std_logic;
      adc_rst_ni_0              : in std_logic;
      s_axis_freq_config_tdata  : in std_logic_vector (31 downto 0);
      s_axis_freq_config_tvalid : in std_logic;
      data_band_sel_osc         : out std_logic_vector (31 downto 0);
      control_in_0              : in std_logic_vector (1 downto 0);
      m_axis_tvalid_mux_o_0     : out std_logic_vector (15 downto 0);
      m_axis_tdata_mux_o        : out std_logic_vector (255 downto 0);
      s_axis_adc_tdata          : in std_logic_vector (255 downto 0);
      s_axis_adc_tvalid         : in std_logic
    );
  end component preprocessing_setup_bd;

  component band_processing_bd is
    port (
      adc_clk_0          : in std_logic;
      adc_rst_ni_0       : in std_logic;
      band_mixer_data_o  : out std_logic_vector (31 downto 0);
      band_mixer_valid_o : out std_logic;
      band_osc_in        : in std_logic_vector (31 downto 0);
      data_out           : out std_logic_vector (31 downto 0);
      valid_out          : out std_logic;
      valid_mux_in       : in std_logic;
      data_mux_in        : in std_logic_vector (15 downto 0)
    );
  end component band_processing_bd;

  component beam_osc_bd is
    port (
      adc_clk_0 : in STD_LOGIC;
      adc_rst_ni_0 : in STD_LOGIC;
      config_sign_data_0 : in STD_LOGIC;
      config_sign_valid_0 : in STD_LOGIC;
      m_axis_tdata_out_0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
      s_axis_config_tdata_0 : in STD_LOGIC_VECTOR ( 31 downto 0 );
      s_axis_config_tvalid_0 : in STD_LOGIC
    );
    end component beam_osc_bd;

  component ch_mixer
    port (
      aclk               : in std_logic;
      aresetn            : in std_logic;
      s_axis_a_tvalid    : in std_logic;
      s_axis_a_tdata     : in std_logic_vector(31 downto 0);
      s_axis_b_tvalid    : in std_logic;
      s_axis_b_tdata     : in std_logic_vector(31 downto 0);
      m_axis_dout_tvalid : out std_logic;
      m_axis_dout_tdata  : out std_logic_vector(31 downto 0)
    );
  end component;

  component ch_filter_bd is
    port (
      adc_clk_0       : in std_logic;
      data_in_0       : in std_logic_vector (31 downto 0);
      valid_in_0      : in std_logic;
      axis_out_tdata  : out std_logic_vector (31 downto 0);
      axis_out_tvalid : out std_logic
    );
  end component ch_filter_bd;
  component beam_handler_bd is
    port (
      sys_clk_i           : in std_logic;
      arst_ni             : in std_logic;
      beams_data_in       : in std_logic_vector (159 downto 0);
      band_data_in        : in std_logic_vector (31 downto 0);
      band_valid_in       : in std_logic;
      beam_filter_data_o  : out std_logic_vector (159 downto 0);
      beam_filter_valid_o : out std_logic_vector (4 downto 0);
      beam_mixers_data_o  : out std_logic_vector (159 downto 0);
      beam_mixers_valid_o : out std_logic_vector (4 downto 0)
    );
  end component beam_handler_bd;
  --reset n signal
  signal async_rst_n : std_logic;

  signal data_adc_resized : std_logic_vector(16 * NUM_CHANNELS - 1 downto 0);
  signal valid_adc_reg : std_logic;

  --preprocessing setup signals
  signal data_band_sel_osc : std_logic_vector(31 downto 0);
  signal m_axis_tdata_mux : std_logic_vector(16 * NUM_CHANNELS - 1 downto 0);
  signal m_axis_tvalid_mux : std_logic_vector(NUM_CHANNELS - 1 downto 0);

  --band processing signals
  signal band_mixer_data : std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
  signal band_mixer_valid : std_logic_vector(NUM_CHANNELS - 1 downto 0);
  signal band_filter_data : std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);
  signal band_filter_valid : std_logic_vector(NUM_CHANNELS - 1 downto 0);

  --channel oscillator signals
  -- signal ch_osc_data : std_logic_vector(32 - 1 downto 0);
  -- signal ch_osc_out_ffs : std_logic_vector(32 * NUM_CHANNELS - 1 downto 0);

  --channel mixer signals
  signal beam_mixer_data : std_logic_vector(32 * NUM_CHANNELS * 5 - 1 downto 0);
  signal beam_mixer_valid : std_logic_vector(NUM_CHANNELS * 5 - 1 downto 0);

  --channel filter signals
  signal beam_filter_data : std_logic_vector(32 * NUM_CHANNELS * 5 - 1 downto 0);
  signal beam_filter_valid : std_logic_vector(NUM_CHANNELS * 5 - 1 downto 0);

  --beams signals
  signal beams_data : std_logic_vector(32 * 5 - 1 downto 0);

  signal beam_osc_sign_vec : std_logic_vector(5 - 1 downto 0);
  signal beam_osc_sign_valid_vec : std_logic_vector(5 - 1 downto 0);
  signal beam_freq_vec : std_logic_vector(32 * 5 - 1 downto 0);
  signal beam_freq_valid_vec : std_logic_vector(5 - 1 downto 0);

begin
  --reset n signal
  async_rst_n <= not(async_rst_i);
  --resize adc input to 16 bits
  resizer_proc : process (sys_clk_i, async_rst_i)
  begin
    if (async_rst_i = '1') then
      valid_adc_reg <= '0';
    elsif rising_edge(sys_clk_i) then
      for i in 0 to NUM_CHANNELS - 1 loop
        data_adc_resized(16 * (i + 1) - 1 downto 16 * i) <= std_logic_vector(resize(signed(data_adc_i(RES_ADC * (i + 1) - 1 downto RES_ADC * i)), 16));
      end loop;
      valid_adc_reg <= valid_adc_i;
    end if;

  end process;

  --preprocessing setup
  preprocessing_setup_bd_i : preprocessing_setup_bd
  port map(
    adc_clk_0                 => sys_clk_i,
    adc_rst_ni_0              => async_rst_n,
    control_in_0              => data_source_sel_i,
    data_band_sel_osc         => data_band_sel_osc,
    m_axis_tdata_mux_o        => m_axis_tdata_mux,
    m_axis_tvalid_mux_o_0     => m_axis_tvalid_mux,
    s_axis_adc_tdata          => data_adc_resized,
    s_axis_adc_tvalid         => valid_adc_reg,
    s_axis_freq_config_tdata  => local_osc_freq_i,
    s_axis_freq_config_tvalid => local_osc_freq_valid_i
  );
  loop_band_processing : for i in 0 to NUM_CHANNELS - 1 generate
    --band processing
    band_processing_bd_i : band_processing_bd
    port map(
      adc_clk_0          => sys_clk_i,
      adc_rst_ni_0       => async_rst_n,
      band_mixer_data_o  => band_mixer_data(32 * (i + 1) - 1 downto 32 * i),
      band_mixer_valid_o => band_mixer_valid(i),
      band_osc_in        => data_band_sel_osc,
      data_mux_in        => m_axis_tdata_mux(16 * (i + 1) - 1 downto 16 * i),
      data_out           => band_filter_data(32 * (i + 1) - 1 downto 32 * i),
      valid_mux_in       => m_axis_tvalid_mux(i),
      valid_out          => band_filter_valid(i)
    );

    beam_handler_bd_i : component beam_handler_bd
      port map(
        sys_clk_i           => sys_clk_i,
        arst_ni             => async_rst_n,
        beams_data_in       => beams_data,
        band_data_in        => band_filter_data(32 * (i + 1) - 1 downto 32 * i),
        band_valid_in       => band_filter_valid(i),
        beam_mixers_data_o  => beam_mixer_data(32 * 5 * (i + 1) - 1 downto 32 * 5 * i),
        beam_mixers_valid_o => beam_mixer_valid(5 * (i + 1) - 1 downto 5 * i),
        beam_filter_data_o  => beam_filter_data(32 * 5 * (i + 1) - 1 downto 32 * 5 * i),
        beam_filter_valid_o => beam_filter_valid(5 * (i + 1) - 1 downto 5 * i)
      );

      -- register ch_osc_data
      -- process (sys_clk_i)
      -- begin
      --   if rising_edge(sys_clk_i) then
      --     ch_osc_out_ffs((32 * (i + 1) - 1) downto (32 * i)) <= ch_osc_data;
      --   end if;
      -- end process;

    end generate loop_band_processing;

    loop_5_beam_osc : for i in 0 to 4 generate
      --channel oscillator
      beam_osc_bd_i : beam_osc_bd
      port map(
        adc_clk_0              => sys_clk_i,
        adc_rst_ni_0           => async_rst_n,
        config_sign_data_0     => beam_osc_sign_vec(i),
        config_sign_valid_0    => beam_osc_sign_valid_vec(i),
        m_axis_tdata_out_0     => beams_data(32 * (i + 1) - 1 downto 32 * i),
        s_axis_config_tdata_0  => beam_freq_vec(32 * (i + 1) - 1 downto 32 * i),
        s_axis_config_tvalid_0 => beam_freq_valid_vec(i)
      );
    end generate loop_5_beam_osc;
    --map signals to vector positions
    beam_osc_sign_vec(0) <= ch_1_sign_i;
    beam_osc_sign_vec(1) <= ch_2_sign_i;
    beam_osc_sign_vec(2) <= ch_3_sign_i;
    beam_osc_sign_vec(3) <= ch_4_sign_i;
    beam_osc_sign_vec(4) <= ch_5_sign_i;

    beam_osc_sign_valid_vec(0) <= ch_1_sign_valid_i;
    beam_osc_sign_valid_vec(1) <= ch_2_sign_valid_i;
    beam_osc_sign_valid_vec(2) <= ch_3_sign_valid_i;
    beam_osc_sign_valid_vec(3) <= ch_4_sign_valid_i;
    beam_osc_sign_valid_vec(4) <= ch_5_sign_valid_i;

    beam_freq_vec(31 downto 0) <= ch_1_freq_i;
    beam_freq_vec(63 downto 32) <= ch_2_freq_i;
    beam_freq_vec(95 downto 64) <= ch_3_freq_i;
    beam_freq_vec(127 downto 96) <= ch_4_freq_i;
    beam_freq_vec(159 downto 128) <= ch_5_freq_i;

    beam_freq_valid_vec(0) <= ch_1_freq_valid_i;
    beam_freq_valid_vec(1) <= ch_2_freq_valid_i;
    beam_freq_valid_vec(2) <= ch_3_freq_valid_i;
    beam_freq_valid_vec(3) <= ch_4_freq_valid_i;
    beam_freq_valid_vec(4) <= ch_5_freq_valid_i;

    --map output signals
    data_ch_filter_o <= beam_filter_data;
    valid_ch_filter_o <= beam_filter_valid;
    data_mux_data_source_o <= m_axis_tdata_mux;
    valid_mux_data_source_o <= m_axis_tvalid_mux;
    data_band_mixer_o <= band_mixer_data;
    valid_band_mixer_o <= band_mixer_valid;
    data_band_filter_o <= band_filter_data;
    valid_band_filter_o <= band_filter_valid;
    data_channel_mixer_o <= beam_mixer_data;
    valid_channel_mixer_o <= beam_mixer_valid;

  end architecture arch;
