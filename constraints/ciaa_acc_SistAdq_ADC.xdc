# ----------------------------------------------------------------------------------
# -- Company:  Instituto Balseiro
# -- Engineer: José Quinteros
# --
# -- Design Name:
# -- Module Name:
# -- Project Name:
# -- Target Devices:
# -- Tool Versions:
# -- Description: ADC data signals constraints file for CIAA-ACC acquisition system project
# --
# -- Dependencies: None.
# --
# -- Revision: 2020-11-15
# -- Additional Comments: Can be regenerated using Fpga/tools/x-special/XDC_Generator.ipynb
# ----------------------------------------------------------------------------------

# remove all input delays. Timing for inputs is hanzled with IDELAY calibration process
# ----------------------------------------------------------------------------
# FMC HPC - Bank 12 and 13 (VCCO_HR: VADJ)
# ----------------------------------------------------------------------------

#adc_DCO1- @bank13
set_property IOSTANDARD LVDS_25 [get_ports adc_DCO1_i_clk_n]
#adc_DCO1+ @bank13
set_property PACKAGE_PIN AD20 [get_ports adc_DCO1_i_clk_p]
set_property PACKAGE_PIN AD21 [get_ports adc_DCO1_i_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_DCO1_i_clk_p]

#adc_DCO1 clock creation - primary clock at external port only
create_clock -period 2.198 -name adc_DCO1 [get_ports adc_DCO1_i_clk_p]
set_input_jitter [get_clocks adc_DCO1] 0.000

# Mark internal Clock Wizard input as a generated clock to avoid clock redefinition
create_generated_clock -name adc_DCO1_clk_wiz_in -source [get_ports adc_DCO1_i_clk_p] -divide_by 1 \
    [get_pins adc_control_wrapper_inst/adc_receiver1_inst/clk_wiz_preproc_inst/inst/clk_in1]

#adc_DCO2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports adc_DCO2_i_clk_n]
#adc_DCO2+ @bank13
set_property PACKAGE_PIN AC12 [get_ports adc_DCO2_i_clk_p]
set_property PACKAGE_PIN AD11 [get_ports adc_DCO2_i_clk_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_DCO2_i_clk_p]

#adc_DCO2 clock creation - primary clock at external port only
create_clock -period 2.198 -name adc_DCO2 [get_ports adc_DCO2_i_clk_p]
set_input_jitter [get_clocks adc_DCO2] 0.000

# Mark internal Clock Wizard input as a generated clock to avoid clock redefinition
create_generated_clock -name adc_DCO2_clk_wiz_in -source [get_ports adc_DCO2_i_clk_p] -divide_by 1 \
    [get_pins adc_control_wrapper_inst/adc_receiver2_inst/clk_wiz_preproc_inst/inst/clk_in1]

# adc_FCO1- @bank13
set_property IOSTANDARD LVDS_25 [get_ports adc_FCO1_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -min -add_delay 0.499 [get_ports adc_FCO1_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -max -add_delay 0.599 [get_ports adc_FCO1_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO1] -min -add_delay 0.499 [get_ports adc_FCO1_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO1] -max -add_delay 0.599 [get_ports adc_FCO1_i_v_n]

# adc_FCO1+ @bank13
set_property PACKAGE_PIN Y18 [get_ports adc_FCO1_i_v_p]
set_property PACKAGE_PIN AA18 [get_ports adc_FCO1_i_v_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_FCO1_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -min -add_delay 0.499 [get_ports adc_FCO1_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -max -add_delay 0.599 [get_ports adc_FCO1_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO1] -min -add_delay 0.499 [get_ports adc_FCO1_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO1] -max -add_delay 0.599 [get_ports adc_FCO1_i_v_p]

# adc_FCO2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports adc_FCO2_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports adc_FCO2_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports adc_FCO2_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports adc_FCO2_i_v_n]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports adc_FCO2_i_v_n]

# adc_FCO2+ @bank12
set_property PACKAGE_PIN AE11 [get_ports adc_FCO2_i_v_p]
set_property PACKAGE_PIN AF10 [get_ports adc_FCO2_i_v_n]
set_property IOSTANDARD LVDS_25 [get_ports adc_FCO2_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports adc_FCO2_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports adc_FCO2_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports adc_FCO2_i_v_p]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports adc_FCO2_i_v_p]

# adc_D_A1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[0]}]

# adc_D_A1+ @bank12
set_property PACKAGE_PIN AC13 [get_ports {adc_data_i_v_p[0]}]
set_property PACKAGE_PIN AD13 [get_ports {adc_data_i_v_n[0]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[0]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[0]}]

# adc_D_A2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[1]}]

# adc_D_A2+ @bank12
set_property PACKAGE_PIN AE10 [get_ports {adc_data_i_v_p[1]}]
set_property PACKAGE_PIN AD10 [get_ports {adc_data_i_v_n[1]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[1]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[1]}]

# adc_D_B1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[2]}]

# adc_D_B1+ @bank12
set_property PACKAGE_PIN Y10 [get_ports {adc_data_i_v_p[2]}]
set_property PACKAGE_PIN AA10 [get_ports {adc_data_i_v_n[2]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[2]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[2]}]

# adc_D_B2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[3]}]

# adc_D_B2+ @bank12
set_property PACKAGE_PIN AB11 [get_ports {adc_data_i_v_p[3]}]
set_property PACKAGE_PIN AB10 [get_ports {adc_data_i_v_n[3]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[3]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[3]}]

# adc_D_C1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[4]}]

# adc_D_C1+ @bank12
set_property PACKAGE_PIN Y12 [get_ports {adc_data_i_v_p[4]}]
set_property PACKAGE_PIN Y11 [get_ports {adc_data_i_v_n[4]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[4]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[4]}]

# adc_D_C2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[5]}]

# adc_D_C2+ @bank12
set_property PACKAGE_PIN W13 [get_ports {adc_data_i_v_p[5]}]
set_property PACKAGE_PIN Y13 [get_ports {adc_data_i_v_n[5]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[5]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[5]}]

# adc_D_D1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[6]}]

# adc_D_D1+ @bank12
set_property PACKAGE_PIN W16 [get_ports {adc_data_i_v_p[6]}]
set_property PACKAGE_PIN W15 [get_ports {adc_data_i_v_n[6]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[6]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[6]}]

# adc_D_D2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[7]}]

# adc_D_D2+ @bank12
set_property PACKAGE_PIN Y17 [get_ports {adc_data_i_v_p[7]}]
set_property PACKAGE_PIN AA17 [get_ports {adc_data_i_v_n[7]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[7]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[7]}]

# adc_D_E1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[8]}]

# adc_D_E1+ @bank12
set_property PACKAGE_PIN AE12 [get_ports {adc_data_i_v_p[8]}]
set_property PACKAGE_PIN AF12 [get_ports {adc_data_i_v_n[8]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[8]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[8]}]

# adc_D_E2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[9]}]

# adc_D_E2+ @bank12
set_property PACKAGE_PIN Y16 [get_ports {adc_data_i_v_p[9]}]
set_property PACKAGE_PIN Y15 [get_ports {adc_data_i_v_n[9]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[9]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[9]}]

# adc_D_F1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[10]}]

# adc_D_F1+ @bank12
set_property PACKAGE_PIN AE13 [get_ports {adc_data_i_v_p[10]}]
set_property PACKAGE_PIN AF13 [get_ports {adc_data_i_v_n[10]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[10]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[10]}]

# adc_D_F2- @bank13
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[11]}]

# adc_D_F2+ @bank13
set_property PACKAGE_PIN AC23 [get_ports {adc_data_i_v_p[11]}]
set_property PACKAGE_PIN AC24 [get_ports {adc_data_i_v_n[11]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[11]}]
# set_input_delay -clock [get_clocks adc_DCO1] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[11]}]

# adc_D_G1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[12]}]

# adc_D_G1+ @bank12
set_property PACKAGE_PIN AA13 [get_ports {adc_data_i_v_p[12]}]
set_property PACKAGE_PIN AA12 [get_ports {adc_data_i_v_n[12]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[12]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[12]}]

# adc_D_G2- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[13]}]

# adc_D_G2+ @bank12
set_property PACKAGE_PIN AA15 [get_ports {adc_data_i_v_p[13]}]
set_property PACKAGE_PIN AA14 [get_ports {adc_data_i_v_n[13]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[13]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[13]}]

# adc_D_H1- @bank12
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[14]}]

# adc_D_H1+ @bank12
set_property PACKAGE_PIN AB12 [get_ports {adc_data_i_v_p[14]}]
set_property PACKAGE_PIN AC11 [get_ports {adc_data_i_v_n[14]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[14]}]
# set_input_delay -clock [get_clocks adc_DCO2] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[14]}]

# adc_D_H2- @bank13
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_n[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_n[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_n[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -min -add_delay 0.499 [get_ports {adc_data_i_v_n[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -max -add_delay 0.599 [get_ports {adc_data_i_v_n[15]}]

# adc_D_H2+ @bank13
set_property PACKAGE_PIN W18 [get_ports {adc_data_i_v_p[15]}]
set_property PACKAGE_PIN W19 [get_ports {adc_data_i_v_n[15]}]
set_property IOSTANDARD LVDS_25 [get_ports {adc_data_i_v_p[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -min -add_delay 0.499 [get_ports {adc_data_i_v_p[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -clock_fall -max -add_delay 0.599 [get_ports {adc_data_i_v_p[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -min -add_delay 0.499 [get_ports {adc_data_i_v_p[15]}]
# set_input_delay -clock [get_clocks adc_DCO1] -max -add_delay 0.599 [get_ports {adc_data_i_v_p[15]}]

#Terminacion diferencial
#set_property DIFF_TERM TRUE [get_ports adc_DCO*_i_clk_*]
#set_property DIFF_TERM TRUE [get_ports adc_FCO*_i_v_*]
#set_property DIFF_TERM TRUE [get_ports adc_data_i_v_*[*]]
