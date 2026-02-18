# resets: until all resets are properly synchronized, treat them all as async
set_false_path -from [get_pins adc_control_wrapper_inst/data_control_inst/async_rst_o_reg/C]
set_false_path -from [get_pins {ps_axi_spi_bd_wrapper_inst/ps_axi_spi_bd_i/reset_fast/U0/PR_OUT_DFF[0].FDRE_PER/C}]

# deserializer CDC
# pulse synchronizer uses 2 clocks. Data should be available before that
set deserializer_max_delay [expr 2*1e3/260]
set_max_delay \
    -datapath_only \
    -from [get_pins adc_control_wrapper_inst/adc_receiver*_inst/ADC_data[*].deserializer_data/out_reg_reg[*]/C] \
    -to [get_pins adc_control_wrapper_inst/data_handler_inst/debug_control_loop[*].sampler_data/dout_reg_reg[*]/D] $deserializer_max_delay

# false path to pulse synchronizer
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/pulse_sync_data/dest_pulse_reg_reg[0]/D]

# preprocessing registers CDC
# false path to synchronizers
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/fifo_input_mux_sel_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/data_source_sel_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/ch_*_freq_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/ch_*_freq_sync_inst/valid_sync_inst/dest_pulse_reg_reg[0]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/ch_*_sign_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/ch_*_sign_sync_inst/valid_sync_inst/dest_pulse_reg_reg[0]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/local_osc_freq_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/local_osc_freq_sync_inst/valid_sync_inst/dest_pulse_reg_reg[0]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/beam_select_sync_inst/sync_data_reg0_reg[*]/D]


# fifo registers CDC
# false path to synchronizers
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/fifo_loop[*].fifo_*_sync_inst/dest_level_reg_reg[0]/D]

# debug control registers CDC
# false path to synchronizers
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/debug_enable_sync_inst/dest_level_reg_reg[0]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/debug_control_sync_inst/sync_data_reg0_reg[*]/D]
set_false_path -to [get_pins adc_control_wrapper_inst/data_handler_inst/debug_w2w1_sync_inst/sync_data_reg0_reg[*]/D]

