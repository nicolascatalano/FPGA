library ieee;
use ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity SistAdq_top is
  port (
    FIXED_IO_0_mio      : inout std_logic_vector (53 downto 0);
    FIXED_IO_0_ps_clk   : inout std_logic;
    FIXED_IO_0_ps_porb  : inout std_logic;
    FIXED_IO_0_ps_srstb : inout std_logic;
    adc_DCO1_i_clk_n    : in std_logic;
    adc_DCO1_i_clk_p    : in std_logic;
    adc_DCO2_i_clk_n    : in std_logic;
    adc_DCO2_i_clk_p    : in std_logic;
    adc_FCO1_i_v_n      : in std_logic;
    adc_FCO1_i_v_p      : in std_logic;
    adc_FCO2_i_v_n      : in std_logic;
    adc_FCO2_i_v_p      : in std_logic;
    adc_data_i_v_n      : in std_logic_vector (15 downto 0);
    adc_data_i_v_p      : in std_logic_vector (15 downto 0);
    adc_sclk_o          : out std_logic;
    adc_sdio_o          : out std_logic;
    adc_ss1_o           : out std_logic;
    adc_ss2_o           : out std_logic;
    dout0_o             : out std_logic;
    dout1_o             : out std_logic;
    ext_trigger_i       : in std_logic;
    fmc_present_i       : in std_logic;
    led_green_o         : out std_logic;
    led_red_o           : out std_logic;
    vadj_en_o           : out std_logic
  );
end SistAdq_top;

architecture rtl of SistAdq_top is
  constant N : integer := 16;
  signal ps_clk : std_logic;
  signal ps_rst : std_logic;
  signal ps_rst_n : std_logic;
  --AXI interface
  signal axi4l_control_awaddr : std_logic_vector(32 - 1 downto 0);
  signal axi4l_control_awprot : std_logic_vector(2 downto 0);
  signal axi4l_control_awvalid : std_logic;
  signal axi4l_control_awready : std_logic;
  signal axi4l_control_wdata : std_logic_vector(32 - 1 downto 0);
  signal axi4l_control_wstrb : std_logic_vector((32/8) - 1 downto 0);
  signal axi4l_control_wvalid : std_logic;
  signal axi4l_control_wready : std_logic;
  signal axi4l_control_bresp : std_logic_vector(1 downto 0);
  signal axi4l_control_bvalid : std_logic;
  signal axi4l_control_bready : std_logic;
  signal axi4l_control_araddr : std_logic_vector(32 - 1 downto 0);
  signal axi4l_control_arprot : std_logic_vector(2 downto 0);
  signal axi4l_control_arvalid : std_logic;
  signal axi4l_control_arready : std_logic;
  signal axi4l_control_rdata : std_logic_vector(32 - 1 downto 0);
  signal axi4l_control_rresp : std_logic_vector(1 downto 0);
  signal axi4l_control_rvalid : std_logic;
  signal axi4l_control_rready : std_logic;

  --AXI interface for preprocessing regs
  signal axi4l_preproc_awaddr : std_logic_vector(32 - 1 downto 0);
  signal axi4l_preproc_awprot : std_logic_vector(2 downto 0);
  signal axi4l_preproc_awvalid : std_logic;
  signal axi4l_preproc_awready : std_logic;
  signal axi4l_preproc_wdata : std_logic_vector(32 - 1 downto 0);
  signal axi4l_preproc_wstrb : std_logic_vector((32/8) - 1 downto 0);
  signal axi4l_preproc_wvalid : std_logic;
  signal axi4l_preproc_wready : std_logic;
  signal axi4l_preproc_bresp : std_logic_vector(1 downto 0);
  signal axi4l_preproc_bvalid : std_logic;
  signal axi4l_preproc_bready : std_logic;
  signal axi4l_preproc_araddr : std_logic_vector(32 - 1 downto 0);
  signal axi4l_preproc_arprot : std_logic_vector(2 downto 0);
  signal axi4l_preproc_arvalid : std_logic;
  signal axi4l_preproc_arready : std_logic;
  signal axi4l_preproc_rdata : std_logic_vector(32 - 1 downto 0);
  signal axi4l_preproc_rresp : std_logic_vector(1 downto 0);
  signal axi4l_preproc_rvalid : std_logic;
  signal axi4l_preproc_rready : std_logic;

  --AXI interface for delay regs
  signal axi4l_delay_araddr : std_logic_vector (31 downto 0);
  signal axi4l_delay_arprot : std_logic_vector (2 downto 0);
  signal axi4l_delay_arready : std_logic_vector (0 to 0);
  signal axi4l_delay_arvalid : std_logic_vector (0 to 0);
  signal axi4l_delay_awaddr : std_logic_vector (31 downto 0);
  signal axi4l_delay_awprot : std_logic_vector (2 downto 0);
  signal axi4l_delay_awready : std_logic_vector (0 to 0);
  signal axi4l_delay_awvalid : std_logic_vector (0 to 0);
  signal axi4l_delay_bready : std_logic_vector (0 to 0);
  signal axi4l_delay_bresp : std_logic_vector (1 downto 0);
  signal axi4l_delay_bvalid : std_logic_vector (0 to 0);
  signal axi4l_delay_rdata : std_logic_vector (31 downto 0);
  signal axi4l_delay_rready : std_logic_vector (0 to 0);
  signal axi4l_delay_rresp : std_logic_vector (1 downto 0);
  signal axi4l_delay_rvalid : std_logic_vector (0 to 0);
  signal axi4l_delay_wdata : std_logic_vector (31 downto 0);
  signal axi4l_delay_wready : std_logic_vector (0 to 0);
  signal axi4l_delay_wstrb : std_logic_vector (3 downto 0);
  signal axi4l_delay_wvalid : std_logic_vector (0 to 0);

  signal adc_FCO1lck : std_logic;
  signal adc_FCO2lck : std_logic;

  signal delay_locked : std_logic;
  signal delay_data_ld : std_logic_vector((N - 1) downto 0);
  signal delay_data_input : std_logic_vector((5 * N - 1) downto 0);
  signal delay_data_output : std_logic_vector((5 * N - 1) downto 0);
  signal delay_frame1_ld : std_logic;
  signal delay_frame1_input : std_logic_vector((5 - 1) downto 0);
  signal delay_frame1_output : std_logic_vector((5 - 1) downto 0);
  signal delay_frame2_ld : std_logic;
  signal delay_frame2_input : std_logic_vector((5 - 1) downto 0);
  signal delay_frame2_output : std_logic_vector((5 - 1) downto 0);

begin

  adc_control_wrapper_inst : entity work.adc_control_wrapper
    generic map(
      -- Core ID and version
      USER_CORE_ID_VER => X"20260223",
      N                => 16,          --number of ADC channels
      N1               => 14,          --number of ADC channels in receiver 1
      N2               => 2,           --number of ADC channels in receiver 2
      RES_ADC          => 14,          --ADC bit resolution
      FIFO_EMPTY_VAL   => X"CAFECAFE", --output value when attempting to read from empty FIFO
      N_tr_b           => 10           --bits for downsampler treshold register
    )
    port map(
      ps_clk_i                => ps_clk,
      ps_rst_n_i              => ps_rst_n,
      --AXI interface
      s_axi4l_control_awaddr  => axi4l_control_awaddr(9 downto 0),
      s_axi4l_control_awprot  => axi4l_control_awprot,
      s_axi4l_control_awvalid => axi4l_control_awvalid,
      s_axi4l_control_awready => axi4l_control_awready,
      s_axi4l_control_wdata   => axi4l_control_wdata,
      s_axi4l_control_wstrb   => axi4l_control_wstrb,
      s_axi4l_control_wvalid  => axi4l_control_wvalid,
      s_axi4l_control_wready  => axi4l_control_wready,
      s_axi4l_control_bresp   => axi4l_control_bresp,
      s_axi4l_control_bvalid  => axi4l_control_bvalid,
      s_axi4l_control_bready  => axi4l_control_bready,
      s_axi4l_control_araddr  => axi4l_control_araddr(9 downto 0),
      s_axi4l_control_arprot  => axi4l_control_arprot,
      s_axi4l_control_arvalid => axi4l_control_arvalid,
      s_axi4l_control_arready => axi4l_control_arready,
      s_axi4l_control_rdata   => axi4l_control_rdata,
      s_axi4l_control_rresp   => axi4l_control_rresp,
      s_axi4l_control_rvalid  => axi4l_control_rvalid,
      s_axi4l_control_rready  => axi4l_control_rready,

      --AXI interface for preprocessing regs
      s_axi4l_preproc_awaddr  => axi4l_preproc_awaddr(5 downto 0),
      s_axi4l_preproc_awprot  => axi4l_preproc_awprot,
      s_axi4l_preproc_awvalid => axi4l_preproc_awvalid,
      s_axi4l_preproc_awready => axi4l_preproc_awready,
      s_axi4l_preproc_wdata   => axi4l_preproc_wdata,
      s_axi4l_preproc_wstrb   => axi4l_preproc_wstrb,
      s_axi4l_preproc_wvalid  => axi4l_preproc_wvalid,
      s_axi4l_preproc_wready  => axi4l_preproc_wready,
      s_axi4l_preproc_bresp   => axi4l_preproc_bresp,
      s_axi4l_preproc_bvalid  => axi4l_preproc_bvalid,
      s_axi4l_preproc_bready  => axi4l_preproc_bready,
      s_axi4l_preproc_araddr  => axi4l_preproc_araddr(5 downto 0),
      s_axi4l_preproc_arprot  => axi4l_preproc_arprot,
      s_axi4l_preproc_arvalid => axi4l_preproc_arvalid,
      s_axi4l_preproc_arready => axi4l_preproc_arready,
      s_axi4l_preproc_rdata   => axi4l_preproc_rdata,
      s_axi4l_preproc_rresp   => axi4l_preproc_rresp,
      s_axi4l_preproc_rvalid  => axi4l_preproc_rvalid,
      s_axi4l_preproc_rready  => axi4l_preproc_rready,

      --external reset for peripherals
      rst_peripherals_i       => ps_rst,

      --ADC signals
      adc_DCO1_p_i            => adc_DCO1_i_clk_p,
      adc_DCO1_n_i            => adc_DCO1_i_clk_n,
      adc_DCO2_p_i            => adc_DCO2_i_clk_p,
      adc_DCO2_n_i            => adc_DCO2_i_clk_n,
      adc_FCO1_p_i            => adc_FCO1_i_v_p,
      adc_FCO1_n_i            => adc_FCO1_i_v_n,
      adc_FCO2_p_i            => adc_FCO2_i_v_p,
      adc_FCO2_n_i            => adc_FCO2_i_v_n,
      adc_data_p_i            => adc_data_i_v_p,
      adc_data_n_i            => adc_data_i_v_n,
      adc_FCO1lck_o           => adc_FCO1lck,
      adc_FCO2lck_o           => adc_FCO2lck,

      --downsampler control signals
      treshold_value_i => (others => '0'),
      treshold_ld_i           => '0',

      --delay control signals
      delay_locked_o          => delay_locked,
      delay_data_ld_i         => delay_data_ld,
      delay_data_input_i      => delay_data_input,
      delay_data_output_o     => delay_data_output,
      delay_frame1_ld_i       => delay_frame1_ld,
      delay_frame1_input_i    => delay_frame1_input,
      delay_frame1_output_o   => delay_frame1_output,
      delay_frame2_ld_i       => delay_frame2_ld,
      delay_frame2_input_i    => delay_frame2_input,
      delay_frame2_output_o   => delay_frame2_output,

      --external trigger signal
      ext_trigger_i           => ext_trigger_i
    );

  delay_control_inst : entity work.delay_control
    generic map(
      N => 16 --number of ADC signals present
    )
    port map(
      S_AXI_ACLK            => ps_clk,
      S_AXI_ARESETN         => ps_rst_n,
      S_AXI_AWADDR          => axi4l_delay_awaddr(9 downto 0),
      S_AXI_AWPROT          => axi4l_delay_awprot,
      S_AXI_AWVALID         => axi4l_delay_awvalid(0),
      S_AXI_AWREADY         => axi4l_delay_awready(0),
      S_AXI_WDATA           => axi4l_delay_wdata,
      S_AXI_WSTRB           => axi4l_delay_wstrb,
      S_AXI_WVALID          => axi4l_delay_wvalid(0),
      S_AXI_WREADY          => axi4l_delay_wready(0),
      S_AXI_BRESP           => axi4l_delay_bresp,
      S_AXI_BVALID          => axi4l_delay_bvalid(0),
      S_AXI_BREADY          => axi4l_delay_bready(0),
      S_AXI_ARADDR          => axi4l_delay_araddr(9 downto 0),
      S_AXI_ARPROT          => axi4l_delay_arprot,
      S_AXI_ARVALID         => axi4l_delay_arvalid(0),
      S_AXI_ARREADY         => axi4l_delay_arready(0),
      S_AXI_RDATA           => axi4l_delay_rdata,
      S_AXI_RRESP           => axi4l_delay_rresp,
      S_AXI_RVALID          => axi4l_delay_rvalid(0),
      S_AXI_RREADY          => axi4l_delay_rready(0),
      delay_locked1_i       => delay_locked,
      delay_data_ld_o       => delay_data_ld,
      delay_data_input_o    => delay_data_input,
      delay_data_output_i   => delay_data_output,
      delay_frame1_ld_o     => delay_frame1_ld,
      delay_frame1_input_o  => delay_frame1_input,
      delay_frame1_output_i => delay_frame1_output,
      delay_frame2_ld_o     => delay_frame2_ld,
      delay_frame2_input_o  => delay_frame2_input,
      delay_frame2_output_i => delay_frame2_output
    );

  ps_axi_spi_bd_wrapper_inst : entity work.ps_axi_spi_bd_wrapper
    port map(
      FIXED_IO_0_mio             => FIXED_IO_0_mio,
      FIXED_IO_0_ps_clk          => FIXED_IO_0_ps_clk,
      FIXED_IO_0_ps_porb         => FIXED_IO_0_ps_porb,
      FIXED_IO_0_ps_srstb        => FIXED_IO_0_ps_srstb,
      adc_FCO1lock_i             => adc_FCO1lck,
      adc_FCO2lock_i             => adc_FCO2lck,
      adc_sclk_o                 => adc_sclk_o,
      adc_sdio_o                 => adc_sdio_o,
      adc_ss1_o                  => adc_ss1_o,
      adc_ss2_o                  => adc_ss2_o,
      dout0_o                    => dout0_o,
      dout1_o                    => dout1_o,
      fmc_present_i              => fmc_present_i,
      led_green_o                => led_green_o,
      led_red_o                  => led_red_o,
      m_axi4l_control_araddr     => axi4l_control_araddr,
      m_axi4l_control_arprot     => axi4l_control_arprot,
      m_axi4l_control_arready(0) => axi4l_control_arready,
      m_axi4l_control_arvalid(0) => axi4l_control_arvalid,
      m_axi4l_control_awaddr     => axi4l_control_awaddr,
      m_axi4l_control_awprot     => axi4l_control_awprot,
      m_axi4l_control_awready(0) => axi4l_control_awready,
      m_axi4l_control_awvalid(0) => axi4l_control_awvalid,
      m_axi4l_control_bready(0)  => axi4l_control_bready,
      m_axi4l_control_bresp      => axi4l_control_bresp,
      m_axi4l_control_bvalid(0)  => axi4l_control_bvalid,
      m_axi4l_control_rdata      => axi4l_control_rdata,
      m_axi4l_control_rready(0)  => axi4l_control_rready,
      m_axi4l_control_rresp      => axi4l_control_rresp,
      m_axi4l_control_rvalid(0)  => axi4l_control_rvalid,
      m_axi4l_control_wdata      => axi4l_control_wdata,
      m_axi4l_control_wready(0)  => axi4l_control_wready,
      m_axi4l_control_wstrb      => axi4l_control_wstrb,
      m_axi4l_control_wvalid(0)  => axi4l_control_wvalid,
      m_axi4l_delay_araddr       => axi4l_delay_araddr,
      m_axi4l_delay_arprot       => axi4l_delay_arprot,
      m_axi4l_delay_arready      => axi4l_delay_arready,
      m_axi4l_delay_arvalid      => axi4l_delay_arvalid,
      m_axi4l_delay_awaddr       => axi4l_delay_awaddr,
      m_axi4l_delay_awprot       => axi4l_delay_awprot,
      m_axi4l_delay_awready      => axi4l_delay_awready,
      m_axi4l_delay_awvalid      => axi4l_delay_awvalid,
      m_axi4l_delay_bready       => axi4l_delay_bready,
      m_axi4l_delay_bresp        => axi4l_delay_bresp,
      m_axi4l_delay_bvalid       => axi4l_delay_bvalid,
      m_axi4l_delay_rdata        => axi4l_delay_rdata,
      m_axi4l_delay_rready       => axi4l_delay_rready,
      m_axi4l_delay_rresp        => axi4l_delay_rresp,
      m_axi4l_delay_rvalid       => axi4l_delay_rvalid,
      m_axi4l_delay_wdata        => axi4l_delay_wdata,
      m_axi4l_delay_wready       => axi4l_delay_wready,
      m_axi4l_delay_wstrb        => axi4l_delay_wstrb,
      m_axi4l_delay_wvalid       => axi4l_delay_wvalid,
      m_axi4l_preproc_araddr     => axi4l_preproc_araddr,
      m_axi4l_preproc_arprot     => axi4l_preproc_arprot,
      m_axi4l_preproc_arready(0) => axi4l_preproc_arready,
      m_axi4l_preproc_arvalid(0) => axi4l_preproc_arvalid,
      m_axi4l_preproc_awaddr     => axi4l_preproc_awaddr,
      m_axi4l_preproc_awprot     => axi4l_preproc_awprot,
      m_axi4l_preproc_awready(0) => axi4l_preproc_awready,
      m_axi4l_preproc_awvalid(0) => axi4l_preproc_awvalid,
      m_axi4l_preproc_bready(0)  => axi4l_preproc_bready,
      m_axi4l_preproc_bresp      => axi4l_preproc_bresp,
      m_axi4l_preproc_bvalid(0)  => axi4l_preproc_bvalid,
      m_axi4l_preproc_rdata      => axi4l_preproc_rdata,
      m_axi4l_preproc_rready(0)  => axi4l_preproc_rready,
      m_axi4l_preproc_rresp      => axi4l_preproc_rresp,
      m_axi4l_preproc_rvalid(0)  => axi4l_preproc_rvalid,
      m_axi4l_preproc_wdata      => axi4l_preproc_wdata,
      m_axi4l_preproc_wready(0)  => axi4l_preproc_wready,
      m_axi4l_preproc_wstrb      => axi4l_preproc_wstrb,
      m_axi4l_preproc_wvalid(0)  => axi4l_preproc_wvalid,
      ps_clk_o                   => ps_clk,
      ps_rst_n_o(0)              => ps_rst_n,
      ps_rst_o(0)                => ps_rst,
      vadj_en_o                  => vadj_en_o
    );

end architecture rtl;
