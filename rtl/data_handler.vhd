library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.fifo_record_pkg.all;
use work.adc_receiver_def_pkg.all;

entity data_handler is
  generic (
    RES_ADC : integer := 14; --ADC resolution, can take values 14 or 12
    N1      : integer := 1;  --number of first instance data channels
    N2      : integer := 1   --number of second instance data channels
  );
  port (
    sys_clk_i              : in std_logic;
    async_rst_i            : in std_logic;
    fpga_clk_i             : in std_logic;
    clk_455_mhz_i          : in std_logic;

    --data input
    data_adc_i             : in adc_data_t((N1 + N2) - 1 downto 0);
    valid_adc_i            : in std_logic;
    --debug input
    debug_enable_i         : in std_logic;
    debug_control_i        : in std_logic_vector(((N1 + N2) * 4 - 1) downto 0);
    debug_w2w1_i           : in std_logic_vector((28 * (N1 + N2) - 1) downto 0);
    --preprocessing signals
    fifo_input_mux_sel_i   : in std_logic_vector(2 downto 0);
    data_source_sel_i      : in std_logic_vector(1 downto 0);

    ch_1_freq_i            : in std_logic_vector(31 downto 0);
    ch_1_freq_valid_i      : in std_logic;
    ch_1_sign_i            : in std_logic;
    ch_1_sign_valid_i      : in std_logic;

    ch_2_freq_i            : in std_logic_vector(31 downto 0);
    ch_2_freq_valid_i      : in std_logic;
    ch_2_sign_i            : in std_logic;
    ch_2_sign_valid_i      : in std_logic;

    ch_3_freq_i            : in std_logic_vector(31 downto 0);
    ch_3_freq_valid_i      : in std_logic;
    ch_3_sign_i            : in std_logic;
    ch_3_sign_valid_i      : in std_logic;

    ch_4_freq_i            : in std_logic_vector(31 downto 0);
    ch_4_freq_valid_i      : in std_logic;
    ch_4_sign_i            : in std_logic;
    ch_4_sign_valid_i      : in std_logic;

    ch_5_freq_i            : in std_logic_vector(31 downto 0);
    ch_5_freq_valid_i      : in std_logic;
    ch_5_sign_i            : in std_logic;
    ch_5_sign_valid_i      : in std_logic;

    local_osc_freq_i       : in std_logic_vector(31 downto 0);
    local_osc_freq_valid_i : in std_logic;

    beam_selector_i        : in std_logic_vector(2 downto 0);
    --output
    fifo_rst_i             : in std_logic;
    fifo_rd_en_i           : in std_logic_vector((N1 + N2 - 1) downto 0);
    fifo_out_o             : out fifo_out_vector_t((N1 + N2 - 1) downto 0)
  );
end data_handler;

architecture arch of data_handler is

  --component declarations
  component c_counter_binary
    port (
      CLK  : in std_logic;
      CE   : in std_logic;
      SCLR : in std_logic;
      Q    : out std_logic_vector(13 downto 0)
    );
  end component;

  COMPONENT counter_32_bits
  PORT (
    CLK : IN STD_LOGIC;
    CE : IN STD_LOGIC;
    SCLR : IN STD_LOGIC;
    Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
  );
  END COMPONENT;

  --FIFO generator declaration
  component fifo_generator
    port (
      rst           : in std_logic;
      wr_clk        : in std_logic;
      rd_clk        : in std_logic;
      din           : in std_logic_vector(31 downto 0);
      wr_en         : in std_logic;
      rd_en         : in std_logic;
      dout          : out std_logic_vector(31 downto 0);
      full          : out std_logic;
      overflow      : out std_logic;
      empty         : out std_logic;
      rd_data_count : out std_logic_vector(10 downto 0);
      prog_full     : out std_logic;
      wr_rst_busy   : out std_logic;
      rd_rst_busy   : out std_logic
    );
  end component;

  --signals
  signal data_both_adc : std_logic_vector(RES_ADC * (N1 + N2) - 1 downto 0);
  signal valid_both_adc : std_logic;
  signal data_joined_output : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_joined_output : std_logic;

  --sync signals
  signal valid_pulse_sync : std_logic;
  signal data_both_adc_sync : std_logic_vector(RES_ADC * (N1 + N2) - 1 downto 0);
  signal valid_adc_sync : std_logic_vector((N1 + N2) - 1 downto 0);

  signal fifo_input_mux_sel_sync : std_logic_vector(2 downto 0);
  signal data_source_sel_sync : std_logic_vector(1 downto 0);

  signal ch_1_freq_sync : std_logic_vector(31 downto 0);
  signal ch_1_freq_valid_sync : std_logic;
  signal ch_1_sign_sync : std_logic;
  signal ch_1_sign_valid_sync : std_logic;

  signal ch_2_freq_sync : std_logic_vector(31 downto 0);
  signal ch_2_freq_valid_sync : std_logic;
  signal ch_2_sign_sync : std_logic;
  signal ch_2_sign_valid_sync : std_logic;

  signal ch_3_freq_sync : std_logic_vector(31 downto 0);
  signal ch_3_freq_valid_sync : std_logic;
  signal ch_3_sign_sync : std_logic;
  signal ch_3_sign_valid_sync : std_logic;

  signal ch_4_freq_sync : std_logic_vector(31 downto 0);
  signal ch_4_freq_valid_sync : std_logic;
  signal ch_4_sign_sync : std_logic;
  signal ch_4_sign_valid_sync : std_logic;

  signal ch_5_freq_sync : std_logic_vector(31 downto 0);
  signal ch_5_freq_valid_sync : std_logic;
  signal ch_5_sign_sync : std_logic;
  signal ch_5_sign_valid_sync : std_logic;

  signal local_osc_freq_sync : std_logic_vector(31 downto 0);
  signal local_osc_freq_valid_sync : std_logic;

  signal beam_selector_sync : std_logic_vector(2 downto 0);

  --debug signals
  signal counter_ce_v : std_logic_vector(((N1 + N2) - 1) downto 0);
  signal debug_counter : std_logic_vector(13 downto 0);
  signal debug_counter_ce : std_logic;
  signal zerosN : std_logic_vector(((N1 + N2) - 1) downto 0) := (others => '0');

  signal debug_enable_sync : std_logic;
  signal debug_control_sync : std_logic_vector(((N1 + N2) * 4 - 1) downto 0);
  constant debug_control_width : integer := ((N1 + N2) * 4);
  signal debug_w2w1_sync : std_logic_vector((28 * (N1 + N2) - 1) downto 0);
  constant debug_w2w1_width : integer := (28 * (N1 + N2));

  signal postproc_counter : std_logic_vector(31 downto 0);

  --debug output
  signal data_from_debug : std_logic_vector(14 * (N1 + N2) - 1 downto 0);
  signal valid_from_debug : std_logic_vector(N1 + N2 - 1 downto 0);

  --signals from preproc
  signal data_ch_filter_from_preproc : std_logic_vector(32 * 5 * (N1 + N2) - 1 downto 0);
  signal valid_ch_filter_from_preproc : std_logic_vector(5 * (N1 + N2) - 1 downto 0);
  signal data_mux_data_source_from_preproc : std_logic_vector(16 * (N1 + N2) - 1 downto 0);
  signal valid_mux_data_source_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_band_mixer_from_preproc : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_band_mixer_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_band_filter_from_preproc : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_band_filter_from_preproc : std_logic_vector(N1 + N2 - 1 downto 0);
  signal data_channel_mixer_from_preproc : std_logic_vector(32 * 5 * (N1 + N2) - 1 downto 0);
  signal valid_channel_mixer_from_preproc : std_logic_vector(5 * (N1 + N2) - 1 downto 0);

  signal ch_1_sign_vec : std_logic_vector(0 downto 0);
  signal ch_1_sign_vec_sync : std_logic_vector(0 downto 0);
  signal ch_2_sign_vec : std_logic_vector(0 downto 0);
  signal ch_2_sign_vec_sync : std_logic_vector(0 downto 0);
  signal ch_3_sign_vec : std_logic_vector(0 downto 0);
  signal ch_3_sign_vec_sync : std_logic_vector(0 downto 0);
  signal ch_4_sign_vec : std_logic_vector(0 downto 0);
  signal ch_4_sign_vec_sync : std_logic_vector(0 downto 0);
  signal ch_5_sign_vec : std_logic_vector(0 downto 0);
  signal ch_5_sign_vec_sync : std_logic_vector(0 downto 0);

  signal beam_mixer_from_mux_data : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal beam_mixer_from_mux_valid : std_logic_vector(N1 + N2 - 1 downto 0);
  signal beam_from_mux_data : std_logic_vector(32 * (N1 + N2) - 1 downto 0);
  signal valid_beam_from_mux_data : std_logic_vector(N1 + N2 - 1 downto 0);

  -- synchronize signals from write_side of FIFO
  signal fifo_full : std_logic_vector((N1 + N2 - 1) downto 0);
  signal fifo_wr_rst_bsy : std_logic_vector((N1 + N2 - 1) downto 0);
  signal fifo_prog_full : std_logic_vector((N1 + N2 - 1) downto 0);
  signal fifo_overflow : std_logic_vector((N1 + N2 - 1) downto 0);

begin

  ch_1_sign_vec(0) <= ch_1_sign_i;
  ch_2_sign_vec(0) <= ch_2_sign_i;
  ch_3_sign_vec(0) <= ch_3_sign_i;
  ch_4_sign_vec(0) <= ch_4_sign_i;
  ch_5_sign_vec(0) <= ch_5_sign_i;
  ch_1_sign_sync <= ch_1_sign_vec_sync(0);
  ch_2_sign_sync <= ch_2_sign_vec_sync(0);
  ch_3_sign_sync <= ch_3_sign_vec_sync(0);
  ch_4_sign_sync <= ch_4_sign_vec_sync(0);
  ch_5_sign_sync <= ch_5_sign_vec_sync(0);

  --Begin signals sync
  pulse_sync_data : entity work.pulse_sync(arch)
    port map(
      src_clk_i  => clk_455_mhz_i,
      src_rst_i  => async_rst_i,
      dest_clk_i => sys_clk_i,
      dest_rst_i => async_rst_i,
      pulse_i    => valid_adc_i,
      pulse_o    => valid_pulse_sync
    );

  fifo_input_mux_sel_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 3
    )
    port map(
      src_data_i  => fifo_input_mux_sel_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => fifo_input_mux_sel_sync
    );

  data_source_sel_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 2
    )
    port map(
      src_data_i  => data_source_sel_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => data_source_sel_sync
    );

  ch_1_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_1_freq_i,
      src_valid_i => ch_1_freq_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_1_freq_sync,
      dst_valid_o => ch_1_freq_valid_sync
    );

  ch_1_sign_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 1
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_1_sign_vec,
      src_valid_i => ch_1_sign_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_1_sign_vec_sync,
      dst_valid_o => ch_1_sign_valid_sync
    );

  ch_2_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_2_freq_i,
      src_valid_i => ch_2_freq_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_2_freq_sync,
      dst_valid_o => ch_2_freq_valid_sync
    );

  ch_2_sign_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 1
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_2_sign_vec,
      src_valid_i => ch_2_sign_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_2_sign_vec_sync,
      dst_valid_o => ch_2_sign_valid_sync
    );

  ch_3_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_3_freq_i,
      src_valid_i => ch_3_freq_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_3_freq_sync,
      dst_valid_o => ch_3_freq_valid_sync
    );

  ch_3_sign_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 1
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_3_sign_vec,
      src_valid_i => ch_3_sign_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_3_sign_vec_sync,
      dst_valid_o => ch_3_sign_valid_sync
    );

  ch_4_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_4_freq_i,
      src_valid_i => ch_4_freq_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_4_freq_sync,
      dst_valid_o => ch_4_freq_valid_sync
    );

  ch_4_sign_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 1
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_4_sign_vec,
      src_valid_i => ch_4_sign_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_4_sign_vec_sync,
      dst_valid_o => ch_4_sign_valid_sync
    );

  ch_5_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_5_freq_i,
      src_valid_i => ch_5_freq_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_5_freq_sync,
      dst_valid_o => ch_5_freq_valid_sync
    );

  ch_5_sign_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 1
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => ch_5_sign_vec,
      src_valid_i => ch_5_sign_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => ch_5_sign_vec_sync,
      dst_valid_o => ch_5_sign_valid_sync
    );

  local_osc_freq_sync_inst : entity work.vector_valid_sync
    generic map(
      DATA_WIDTH => 32
    )
    port map(
      src_clk_i   => fpga_clk_i,
      src_rst_i   => async_rst_i,
      src_data_i  => local_osc_freq_i,
      src_valid_i => local_osc_freq_valid_i,
      dst_clk_i   => sys_clk_i,
      dst_data_o  => local_osc_freq_sync,
      dst_valid_o => local_osc_freq_valid_sync
    );

  beam_select_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => 3
    )
    port map(
      src_data_i  => beam_selector_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => beam_selector_sync
    );

  -- Instantiate synchronizers for debug signals
  debug_control_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => debug_control_width
    )
    port map(
      src_data_i  => debug_control_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => debug_control_sync
    );

  debug_w2w1_sync_inst : entity work.quasistatic_sync
    generic map(
      DATA_WIDTH => debug_w2w1_width
    )
    port map(
      src_data_i  => debug_w2w1_i,
      sys_clk_i   => sys_clk_i,
      sync_data_o => debug_w2w1_sync
    );

  debug_enable_sync_inst : entity work.level_sync
    port map(
      dest_clk_i => sys_clk_i,
      dest_rst_i => async_rst_i,
      level_i    => debug_enable_i,
      level_o    => debug_enable_sync
    );

  --End sgnals sync
  ---- BINARY COUNTER
  -- instantiate binary counter for debugging purposes
  binary_counter : c_counter_binary
  port map(
    CLK  => sys_clk_i,
    CE   => debug_counter_ce,
    SCLR => async_rst_i,
    Q    => debug_counter
  );
  --drive debug_counter_ce
  debug_counter_ce <= '1' when (counter_ce_v > zerosN) else
    '0';

  --instantiate debug control
  debug_control_loop : for i in 0 to (N1 + N2 - 1) generate

    sampler_data : entity work.sampler_with_ce(arch)
      generic map(
        N => RES_ADC
      )
      port map(
        clk        => sys_clk_i,
        rst_i      => async_rst_i,
        ce         => valid_pulse_sync,
        din        => data_adc_i(i),
        dout       => data_both_adc_sync(14 * (i + 1) - 1 downto 14 * i),
        dout_valid => valid_adc_sync(i)
      );
    deb_control_data : entity work.debug_control(arch)
      generic map(
        RES_ADC => RES_ADC
      )
      port map(
        clock_i         => sys_clk_i,
        rst_i           => async_rst_i,
        enable_i        => debug_enable_sync,
        control_i       => debug_control_sync(((4 * (i + 1)) - 1) downto (4 * i)),
        usr_w2w1_i      => debug_w2w1_sync(((28 * (i + 1)) - 1) downto (28 * i)),
        data_i          => data_both_adc_sync(14 * (i + 1) - 1 downto 14 * i),
        valid_i         => valid_adc_sync(i),

        counter_count_i => debug_counter,
        counter_ce_o    => counter_ce_v(i),

        data_o          => data_from_debug((14 * (i + 1) - 1) downto (14 * i)),
        valid_o         => valid_from_debug(i)
      );
  end generate debug_control_loop;

  --end debug control

  preprocessing_inst : entity work.preprocessing(arch)
    generic map(
      RES_ADC      => RES_ADC,
      NUM_CHANNELS => N1 + N2
    )
    port map(
      sys_clk_i               => sys_clk_i,
      async_rst_i             => async_rst_i,
      data_adc_i              => data_from_debug,
      valid_adc_i             => valid_from_debug(0),
      data_source_sel_i       => data_source_sel_sync,
      ch_1_freq_i             => ch_1_freq_sync,
      ch_1_freq_valid_i       => ch_1_freq_valid_sync,
      ch_1_sign_i             => ch_1_sign_sync,
      ch_1_sign_valid_i       => ch_1_sign_valid_sync,
      ch_2_freq_i             => ch_2_freq_sync,
      ch_2_freq_valid_i       => ch_2_freq_valid_sync,
      ch_2_sign_i             => ch_2_sign_sync,
      ch_2_sign_valid_i       => ch_2_sign_valid_sync,
      ch_3_freq_i             => ch_3_freq_sync,
      ch_3_freq_valid_i       => ch_3_freq_valid_sync,
      ch_3_sign_i             => ch_3_sign_sync,
      ch_3_sign_valid_i       => ch_3_sign_valid_sync,
      ch_4_freq_i             => ch_4_freq_sync,
      ch_4_freq_valid_i       => ch_4_freq_valid_sync,
      ch_4_sign_i             => ch_4_sign_sync,
      ch_4_sign_valid_i       => ch_4_sign_valid_sync,
      ch_5_freq_i             => ch_5_freq_sync,
      ch_5_freq_valid_i       => ch_5_freq_valid_sync,
      ch_5_sign_i             => ch_5_sign_sync,
      ch_5_sign_valid_i       => ch_5_sign_valid_sync,
      local_osc_freq_i        => local_osc_freq_sync,
      local_osc_freq_valid_i  => local_osc_freq_valid_sync,
      data_ch_filter_o        => data_ch_filter_from_preproc,
      valid_ch_filter_o       => valid_ch_filter_from_preproc,
      data_mux_data_source_o  => data_mux_data_source_from_preproc,
      valid_mux_data_source_o => valid_mux_data_source_from_preproc,
      data_band_mixer_o       => data_band_mixer_from_preproc,
      valid_band_mixer_o      => valid_band_mixer_from_preproc,
      data_band_filter_o      => data_band_filter_from_preproc,
      valid_band_filter_o     => valid_band_filter_from_preproc,
      data_channel_mixer_o    => data_channel_mixer_from_preproc,
      valid_channel_mixer_o   => valid_channel_mixer_from_preproc
    );

  beam_mixer_sel_mux_inst : entity work.beam_sel_mux(rtl)
    port map(
      sys_clk_i    => sys_clk_i,
      async_rst_i  => async_rst_i,
      control_i    => beam_selector_sync,
      beams_data_i => data_channel_mixer_from_preproc,
      beam_valid_i => valid_channel_mixer_from_preproc,
      beam_data_o  => beam_mixer_from_mux_data,
      beam_valid_o => beam_mixer_from_mux_valid
    );

  --beam sel mux
  beam_sel_mux_inst : entity work.beam_sel_mux(rtl)
    port map(
      sys_clk_i    => sys_clk_i,
      async_rst_i  => async_rst_i,
      control_i    => beam_selector_sync,
      beams_data_i => data_ch_filter_from_preproc,
      beam_valid_i => valid_ch_filter_from_preproc,
      beam_data_o  => beam_from_mux_data,
      beam_valid_o => valid_beam_from_mux_data
    );

  postproc_counter_inst : counter_32_bits
    PORT MAP (
      CLK => sys_clk_i,
      CE => valid_beam_from_mux_data(0),
      SCLR => async_rst_i,
      Q => postproc_counter
    );

  fifo_input_mux_inst : entity work.fifo_input_data_mux
    generic map(
      NUM_CHANNELS => N1 + N2,
      RES_ADC      => RES_ADC
    )
    port map(
      sys_clk_i                    => sys_clk_i,
      sys_rst_i                    => async_rst_i,
      -- Mux control
      data_mux_sel_i               => fifo_input_mux_sel_sync,
      -- Data from preprocessing logic
      data_preproc_i               => beam_from_mux_data,
      data_preproc_valid_i         => valid_beam_from_mux_data,
      -- Raw data from deserializer
      data_raw_i                   => data_from_debug,
      data_raw_valid_i             => valid_from_debug,
      -- Postproc counter
      postproc_counter_i           => postproc_counter,
      -- Data source mux
      data_mux_data_source_i       => data_mux_data_source_from_preproc,
      data_mux_data_source_valid_i => valid_mux_data_source_from_preproc,
      -- Band mixer
      data_band_mixer_i            => data_band_mixer_from_preproc,
      data_band_mixer_valid_i      => valid_band_mixer_from_preproc,
      -- Band filter
      data_band_filter_i           => data_band_filter_from_preproc,
      data_band_filter_valid_i     => valid_band_filter_from_preproc,
      -- Channel mixer
      data_channel_mixer_i         => beam_mixer_from_mux_data,
      data_channel_mixer_valid_i   => beam_mixer_from_mux_valid,
      -- Output data
      data_o                       => data_joined_output,
      data_valid_o                 => valid_joined_output
    );



  --instantiate FIFO
  fifo_loop : for i in 0 to (N1 + N2 - 1) generate
    --instantiate FIFO
    fifo_inst : fifo_generator
    port map(
      rst           => fifo_rst_i,
      wr_clk        => sys_clk_i,
      rd_clk        => fpga_clk_i,
      din           => data_joined_output((32 * (i + 1) - 1) downto (32 * i)),
      wr_en         => valid_joined_output,
      rd_en         => fifo_rd_en_i(i),
      dout          => fifo_out_o(i).data_out,
      full          => fifo_full(i),
      overflow      => fifo_overflow(i),
      empty         => fifo_out_o(i).empty,
      rd_data_count => fifo_out_o(i).rd_data_cnt,
      prog_full     => fifo_prog_full(i),
      wr_rst_busy   => fifo_wr_rst_bsy(i),
      rd_rst_busy   => fifo_out_o(i).rd_rst_bsy
    );

    fifo_full_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_full(i),
        level_o    => fifo_out_o(i).full
      );
    fifo_wr_rst_busy_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_wr_rst_bsy(i),
        level_o    => fifo_out_o(i).wr_rst_bsy
      );
    fifo_prog_full_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_prog_full(i),
        level_o    => fifo_out_o(i).prog_full
      );
    fifo_overflow_sync_inst : entity work.level_sync
      port map(
        dest_clk_i => fpga_clk_i,
        dest_rst_i => async_rst_i,
        level_i    => fifo_overflow(i),
        level_o    => fifo_out_o(i).overflow
      );
  end generate fifo_loop;
end arch;
