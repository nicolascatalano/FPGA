--Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
----------------------------------------------------------------------------------
--Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
--Date        : Tue Oct 25 13:20:39 2022
--Host        : JIQdC-Emtech running 64-bit major release  (build 9200)
--Command     : generate_target ps_axi_spi_bd_wrapper.bd
--Design      : ps_axi_spi_bd_wrapper
--Purpose     : IP block netlist
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library UNISIM;
use UNISIM.VCOMPONENTS.all;
entity ps_axi_spi_bd_wrapper is
  port (
    FIXED_IO_0_mio          : inout std_logic_vector (53 downto 0);
    FIXED_IO_0_ps_clk       : inout std_logic;
    FIXED_IO_0_ps_porb      : inout std_logic;
    FIXED_IO_0_ps_srstb     : inout std_logic;
    adc_FCO1lock_i          : in std_logic;
    adc_FCO2lock_i          : in std_logic;
    adc_sclk_o              : out std_logic;
    adc_sdio_o              : out std_logic;
    adc_ss1_o               : out std_logic;
    adc_ss2_o               : out std_logic;
    dout0_o                 : out std_logic;
    dout1_o                 : out std_logic;
    fmc_present_i           : in std_logic;
    led_green_o             : out std_logic;
    led_red_o               : out std_logic;
    m_axi4l_control_araddr  : out std_logic_vector (31 downto 0);
    m_axi4l_control_arprot  : out std_logic_vector (2 downto 0);
    m_axi4l_control_arready : in std_logic_vector (0 to 0);
    m_axi4l_control_arvalid : out std_logic_vector (0 to 0);
    m_axi4l_control_awaddr  : out std_logic_vector (31 downto 0);
    m_axi4l_control_awprot  : out std_logic_vector (2 downto 0);
    m_axi4l_control_awready : in std_logic_vector (0 to 0);
    m_axi4l_control_awvalid : out std_logic_vector (0 to 0);
    m_axi4l_control_bready  : out std_logic_vector (0 to 0);
    m_axi4l_control_bresp   : in std_logic_vector (1 downto 0);
    m_axi4l_control_bvalid  : in std_logic_vector (0 to 0);
    m_axi4l_control_rdata   : in std_logic_vector (31 downto 0);
    m_axi4l_control_rready  : out std_logic_vector (0 to 0);
    m_axi4l_control_rresp   : in std_logic_vector (1 downto 0);
    m_axi4l_control_rvalid  : in std_logic_vector (0 to 0);
    m_axi4l_control_wdata   : out std_logic_vector (31 downto 0);
    m_axi4l_control_wready  : in std_logic_vector (0 to 0);
    m_axi4l_control_wstrb   : out std_logic_vector (3 downto 0);
    m_axi4l_control_wvalid  : out std_logic_vector (0 to 0);
    m_axi4l_delay_araddr    : out std_logic_vector (31 downto 0);
    m_axi4l_delay_arprot    : out std_logic_vector (2 downto 0);
    m_axi4l_delay_arready   : in std_logic_vector (0 to 0);
    m_axi4l_delay_arvalid   : out std_logic_vector (0 to 0);
    m_axi4l_delay_awaddr    : out std_logic_vector (31 downto 0);
    m_axi4l_delay_awprot    : out std_logic_vector (2 downto 0);
    m_axi4l_delay_awready   : in std_logic_vector (0 to 0);
    m_axi4l_delay_awvalid   : out std_logic_vector (0 to 0);
    m_axi4l_delay_bready    : out std_logic_vector (0 to 0);
    m_axi4l_delay_bresp     : in std_logic_vector (1 downto 0);
    m_axi4l_delay_bvalid    : in std_logic_vector (0 to 0);
    m_axi4l_delay_rdata     : in std_logic_vector (31 downto 0);
    m_axi4l_delay_rready    : out std_logic_vector (0 to 0);
    m_axi4l_delay_rresp     : in std_logic_vector (1 downto 0);
    m_axi4l_delay_rvalid    : in std_logic_vector (0 to 0);
    m_axi4l_delay_wdata     : out std_logic_vector (31 downto 0);
    m_axi4l_delay_wready    : in std_logic_vector (0 to 0);
    m_axi4l_delay_wstrb     : out std_logic_vector (3 downto 0);
    m_axi4l_delay_wvalid    : out std_logic_vector (0 to 0);
    m_axi4l_preproc_araddr  : out std_logic_vector (31 downto 0);
    m_axi4l_preproc_arprot  : out std_logic_vector (2 downto 0);
    m_axi4l_preproc_arready : in std_logic_vector (0 to 0);
    m_axi4l_preproc_arvalid : out std_logic_vector (0 to 0);
    m_axi4l_preproc_awaddr  : out std_logic_vector (31 downto 0);
    m_axi4l_preproc_awprot  : out std_logic_vector (2 downto 0);
    m_axi4l_preproc_awready : in std_logic_vector (0 to 0);
    m_axi4l_preproc_awvalid : out std_logic_vector (0 to 0);
    m_axi4l_preproc_bready  : out std_logic_vector (0 to 0);
    m_axi4l_preproc_bresp   : in std_logic_vector (1 downto 0);
    m_axi4l_preproc_bvalid  : in std_logic_vector (0 to 0);
    m_axi4l_preproc_rdata   : in std_logic_vector (31 downto 0);
    m_axi4l_preproc_rready  : out std_logic_vector (0 to 0);
    m_axi4l_preproc_rresp   : in std_logic_vector (1 downto 0);
    m_axi4l_preproc_rvalid  : in std_logic_vector (0 to 0);
    m_axi4l_preproc_wdata   : out std_logic_vector (31 downto 0);
    m_axi4l_preproc_wready  : in std_logic_vector (0 to 0);
    m_axi4l_preproc_wstrb   : out std_logic_vector (3 downto 0);
    m_axi4l_preproc_wvalid  : out std_logic_vector (0 to 0);
    ps_clk_o                : out std_logic;
    ps_rst_n_o              : out std_logic_vector (0 to 0);
    ps_rst_o                : out std_logic_vector (0 to 0);
    vadj_en_o               : out std_logic
  );
end ps_axi_spi_bd_wrapper;

architecture STRUCTURE of ps_axi_spi_bd_wrapper is
  component ps_axi_spi_bd is
    port (
      adc_sclk_o              : out std_logic;
      adc_sdio_o              : out std_logic;
      adc_ss1_o               : out std_logic;
      adc_ss2_o               : out std_logic;
      dout0_o                 : out std_logic;
      dout1_o                 : out std_logic;
      fmc_present_i           : in std_logic;
      led_green_o             : out std_logic;
      led_red_o               : out std_logic;
      vadj_en_o               : out std_logic;
      FIXED_IO_0_mio          : inout std_logic_vector (53 downto 0);
      FIXED_IO_0_ps_srstb     : inout std_logic;
      FIXED_IO_0_ps_clk       : inout std_logic;
      FIXED_IO_0_ps_porb      : inout std_logic;
      adc_FCO1lock_i          : in std_logic;
      adc_FCO2lock_i          : in std_logic;
      ps_rst_o                : out std_logic_vector (0 to 0);
      m_axi4l_preproc_awaddr  : out std_logic_vector (31 downto 0);
      m_axi4l_preproc_awprot  : out std_logic_vector (2 downto 0);
      m_axi4l_preproc_awvalid : out std_logic_vector (0 to 0);
      m_axi4l_preproc_awready : in std_logic_vector (0 to 0);
      m_axi4l_preproc_wdata   : out std_logic_vector (31 downto 0);
      m_axi4l_preproc_wstrb   : out std_logic_vector (3 downto 0);
      m_axi4l_preproc_wvalid  : out std_logic_vector (0 to 0);
      m_axi4l_preproc_wready  : in std_logic_vector (0 to 0);
      m_axi4l_preproc_bresp   : in std_logic_vector (1 downto 0);
      m_axi4l_preproc_bvalid  : in std_logic_vector (0 to 0);
      m_axi4l_preproc_bready  : out std_logic_vector (0 to 0);
      m_axi4l_preproc_araddr  : out std_logic_vector (31 downto 0);
      m_axi4l_preproc_arprot  : out std_logic_vector (2 downto 0);
      m_axi4l_preproc_arvalid : out std_logic_vector (0 to 0);
      m_axi4l_preproc_arready : in std_logic_vector (0 to 0);
      m_axi4l_preproc_rdata   : in std_logic_vector (31 downto 0);
      m_axi4l_preproc_rresp   : in std_logic_vector (1 downto 0);
      m_axi4l_preproc_rvalid  : in std_logic_vector (0 to 0);
      m_axi4l_preproc_rready  : out std_logic_vector (0 to 0);
      m_axi4l_control_awaddr  : out std_logic_vector (31 downto 0);
      m_axi4l_control_awprot  : out std_logic_vector (2 downto 0);
      m_axi4l_control_awvalid : out std_logic_vector (0 to 0);
      m_axi4l_control_awready : in std_logic_vector (0 to 0);
      m_axi4l_control_wdata   : out std_logic_vector (31 downto 0);
      m_axi4l_control_wstrb   : out std_logic_vector (3 downto 0);
      m_axi4l_control_wvalid  : out std_logic_vector (0 to 0);
      m_axi4l_control_wready  : in std_logic_vector (0 to 0);
      m_axi4l_control_bresp   : in std_logic_vector (1 downto 0);
      m_axi4l_control_bvalid  : in std_logic_vector (0 to 0);
      m_axi4l_control_bready  : out std_logic_vector (0 to 0);
      m_axi4l_control_araddr  : out std_logic_vector (31 downto 0);
      m_axi4l_control_arprot  : out std_logic_vector (2 downto 0);
      m_axi4l_control_arvalid : out std_logic_vector (0 to 0);
      m_axi4l_control_arready : in std_logic_vector (0 to 0);
      m_axi4l_control_rdata   : in std_logic_vector (31 downto 0);
      m_axi4l_control_rresp   : in std_logic_vector (1 downto 0);
      m_axi4l_control_rvalid  : in std_logic_vector (0 to 0);
      m_axi4l_control_rready  : out std_logic_vector (0 to 0);
      m_axi4l_delay_awaddr    : out std_logic_vector (31 downto 0);
      m_axi4l_delay_awprot    : out std_logic_vector (2 downto 0);
      m_axi4l_delay_awvalid   : out std_logic_vector (0 to 0);
      m_axi4l_delay_awready   : in std_logic_vector (0 to 0);
      m_axi4l_delay_wdata     : out std_logic_vector (31 downto 0);
      m_axi4l_delay_wstrb     : out std_logic_vector (3 downto 0);
      m_axi4l_delay_wvalid    : out std_logic_vector (0 to 0);
      m_axi4l_delay_wready    : in std_logic_vector (0 to 0);
      m_axi4l_delay_bresp     : in std_logic_vector (1 downto 0);
      m_axi4l_delay_bvalid    : in std_logic_vector (0 to 0);
      m_axi4l_delay_bready    : out std_logic_vector (0 to 0);
      m_axi4l_delay_araddr    : out std_logic_vector (31 downto 0);
      m_axi4l_delay_arprot    : out std_logic_vector (2 downto 0);
      m_axi4l_delay_arvalid   : out std_logic_vector (0 to 0);
      m_axi4l_delay_arready   : in std_logic_vector (0 to 0);
      m_axi4l_delay_rdata     : in std_logic_vector (31 downto 0);
      m_axi4l_delay_rresp     : in std_logic_vector (1 downto 0);
      m_axi4l_delay_rvalid    : in std_logic_vector (0 to 0);
      m_axi4l_delay_rready    : out std_logic_vector (0 to 0);
      ps_clk_o                : out std_logic;
      ps_rst_n_o              : out std_logic_vector (0 to 0)
    );
  end component ps_axi_spi_bd;
begin
  ps_axi_spi_bd_i : component ps_axi_spi_bd
    port map(
      FIXED_IO_0_mio(53 downto 0)         => FIXED_IO_0_mio(53 downto 0),
      FIXED_IO_0_ps_clk                   => FIXED_IO_0_ps_clk,
      FIXED_IO_0_ps_porb                  => FIXED_IO_0_ps_porb,
      FIXED_IO_0_ps_srstb                 => FIXED_IO_0_ps_srstb,
      adc_FCO1lock_i                      => adc_FCO1lock_i,
      adc_FCO2lock_i                      => adc_FCO2lock_i,
      adc_sclk_o                          => adc_sclk_o,
      adc_sdio_o                          => adc_sdio_o,
      adc_ss1_o                           => adc_ss1_o,
      adc_ss2_o                           => adc_ss2_o,
      dout0_o                             => dout0_o,
      dout1_o                             => dout1_o,
      fmc_present_i                       => fmc_present_i,
      led_green_o                         => led_green_o,
      led_red_o                           => led_red_o,
      m_axi4l_control_araddr(31 downto 0) => m_axi4l_control_araddr(31 downto 0),
      m_axi4l_control_arprot(2 downto 0)  => m_axi4l_control_arprot(2 downto 0),
      m_axi4l_control_arready(0)          => m_axi4l_control_arready(0),
      m_axi4l_control_arvalid(0)          => m_axi4l_control_arvalid(0),
      m_axi4l_control_awaddr(31 downto 0) => m_axi4l_control_awaddr(31 downto 0),
      m_axi4l_control_awprot(2 downto 0)  => m_axi4l_control_awprot(2 downto 0),
      m_axi4l_control_awready(0)          => m_axi4l_control_awready(0),
      m_axi4l_control_awvalid(0)          => m_axi4l_control_awvalid(0),
      m_axi4l_control_bready(0)           => m_axi4l_control_bready(0),
      m_axi4l_control_bresp(1 downto 0)   => m_axi4l_control_bresp(1 downto 0),
      m_axi4l_control_bvalid(0)           => m_axi4l_control_bvalid(0),
      m_axi4l_control_rdata(31 downto 0)  => m_axi4l_control_rdata(31 downto 0),
      m_axi4l_control_rready(0)           => m_axi4l_control_rready(0),
      m_axi4l_control_rresp(1 downto 0)   => m_axi4l_control_rresp(1 downto 0),
      m_axi4l_control_rvalid(0)           => m_axi4l_control_rvalid(0),
      m_axi4l_control_wdata(31 downto 0)  => m_axi4l_control_wdata(31 downto 0),
      m_axi4l_control_wready(0)           => m_axi4l_control_wready(0),
      m_axi4l_control_wstrb(3 downto 0)   => m_axi4l_control_wstrb(3 downto 0),
      m_axi4l_control_wvalid(0)           => m_axi4l_control_wvalid(0),
      m_axi4l_delay_araddr(31 downto 0)   => m_axi4l_delay_araddr(31 downto 0),
      m_axi4l_delay_arprot(2 downto 0)    => m_axi4l_delay_arprot(2 downto 0),
      m_axi4l_delay_arready(0)            => m_axi4l_delay_arready(0),
      m_axi4l_delay_arvalid(0)            => m_axi4l_delay_arvalid(0),
      m_axi4l_delay_awaddr(31 downto 0)   => m_axi4l_delay_awaddr(31 downto 0),
      m_axi4l_delay_awprot(2 downto 0)    => m_axi4l_delay_awprot(2 downto 0),
      m_axi4l_delay_awready(0)            => m_axi4l_delay_awready(0),
      m_axi4l_delay_awvalid(0)            => m_axi4l_delay_awvalid(0),
      m_axi4l_delay_bready(0)             => m_axi4l_delay_bready(0),
      m_axi4l_delay_bresp(1 downto 0)     => m_axi4l_delay_bresp(1 downto 0),
      m_axi4l_delay_bvalid(0)             => m_axi4l_delay_bvalid(0),
      m_axi4l_delay_rdata(31 downto 0)    => m_axi4l_delay_rdata(31 downto 0),
      m_axi4l_delay_rready(0)             => m_axi4l_delay_rready(0),
      m_axi4l_delay_rresp(1 downto 0)     => m_axi4l_delay_rresp(1 downto 0),
      m_axi4l_delay_rvalid(0)             => m_axi4l_delay_rvalid(0),
      m_axi4l_delay_wdata(31 downto 0)    => m_axi4l_delay_wdata(31 downto 0),
      m_axi4l_delay_wready(0)             => m_axi4l_delay_wready(0),
      m_axi4l_delay_wstrb(3 downto 0)     => m_axi4l_delay_wstrb(3 downto 0),
      m_axi4l_delay_wvalid(0)             => m_axi4l_delay_wvalid(0),
      m_axi4l_preproc_araddr(31 downto 0) => m_axi4l_preproc_araddr(31 downto 0),
      m_axi4l_preproc_arprot(2 downto 0)  => m_axi4l_preproc_arprot(2 downto 0),
      m_axi4l_preproc_arready(0)          => m_axi4l_preproc_arready(0),
      m_axi4l_preproc_arvalid(0)          => m_axi4l_preproc_arvalid(0),
      m_axi4l_preproc_awaddr(31 downto 0) => m_axi4l_preproc_awaddr(31 downto 0),
      m_axi4l_preproc_awprot(2 downto 0)  => m_axi4l_preproc_awprot(2 downto 0),
      m_axi4l_preproc_awready(0)          => m_axi4l_preproc_awready(0),
      m_axi4l_preproc_awvalid(0)          => m_axi4l_preproc_awvalid(0),
      m_axi4l_preproc_bready(0)           => m_axi4l_preproc_bready(0),
      m_axi4l_preproc_bresp(1 downto 0)   => m_axi4l_preproc_bresp(1 downto 0),
      m_axi4l_preproc_bvalid(0)           => m_axi4l_preproc_bvalid(0),
      m_axi4l_preproc_rdata(31 downto 0)  => m_axi4l_preproc_rdata(31 downto 0),
      m_axi4l_preproc_rready(0)           => m_axi4l_preproc_rready(0),
      m_axi4l_preproc_rresp(1 downto 0)   => m_axi4l_preproc_rresp(1 downto 0),
      m_axi4l_preproc_rvalid(0)           => m_axi4l_preproc_rvalid(0),
      m_axi4l_preproc_wdata(31 downto 0)  => m_axi4l_preproc_wdata(31 downto 0),
      m_axi4l_preproc_wready(0)           => m_axi4l_preproc_wready(0),
      m_axi4l_preproc_wstrb(3 downto 0)   => m_axi4l_preproc_wstrb(3 downto 0),
      m_axi4l_preproc_wvalid(0)           => m_axi4l_preproc_wvalid(0),
      ps_clk_o                            => ps_clk_o,
      ps_rst_n_o(0)                       => ps_rst_n_o(0),
      ps_rst_o(0)                         => ps_rst_o(0),
      vadj_en_o                           => vadj_en_o
    );
  end STRUCTURE;
