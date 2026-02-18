
################################################################
# This is a generated script based on design: preprocessing_setup_bd
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   common::send_gid_msg -ssname BD::TCL -id 2040 -severity "CRITICAL WARNING" "This script was generated using Vivado <$scripts_vivado_version> without IP versions in the create_bd_cell commands, but is now being run in <$current_vivado_version> of Vivado. There may have been changes to the IP between Vivado <$scripts_vivado_version> and <$current_vivado_version>, which could impact the functionality and configuration of the design."

}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source preprocessing_setup_bd_script.tcl


# The design that will be created by this Tcl script contains the following 
# module references:
# basic_counter, copy_vec_N_times, copy_vec_N_times, data_source_mux_generic, dsp_dds_compiler_controller

# Please add the sources of those modules before sourcing this Tcl script.

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xc7z030fbg676-2
   set_property BOARD_PART www.proyecto-ciaa.com.ar:ciaa-acc:part0:1.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name preprocessing_setup_bd

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
xilinx.com:ip:dds_compiler:*\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

##################################################################
# CHECK Modules
##################################################################
set bCheckModules 1
if { $bCheckModules == 1 } {
   set list_check_mods "\ 
basic_counter\
copy_vec_N_times\
copy_vec_N_times\
data_source_mux_generic\
dsp_dds_compiler_controller\
"

   set list_mods_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2020 -severity "INFO" "Checking if the following modules exist in the project's sources: $list_check_mods ."

   foreach mod_vlnv $list_check_mods {
      if { [can_resolve_reference $mod_vlnv] == 0 } {
         lappend list_mods_missing $mod_vlnv
      }
   }

   if { $list_mods_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2021 -severity "ERROR" "The following module(s) are not found in the project: $list_mods_missing" }
      common::send_gid_msg -ssname BD::TCL -id 2022 -severity "INFO" "Please add source files for the missing module(s) above."
      set bCheckIPsPassed 0
   }
}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: Local_osc_hier
proc create_hier_cell_Local_osc_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Local_osc_hier() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins

  # Create pins
  create_bd_pin -dir I -type clk adc_clk
  create_bd_pin -dir I adc_rst_ni
  create_bd_pin -dir O -from 15 -to 0 m_axis_tdata
  create_bd_pin -dir O m_axis_tvalid
  create_bd_pin -dir I -from 31 -to 0 s_axis_config_tdata_0
  create_bd_pin -dir I s_axis_config_tvalid_0

  # Create instance: Local_oscillator, and set properties
  set Local_oscillator [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler Local_oscillator ]
  set_property -dict [list \
    CONFIG.DATA_Has_TLAST {Not_Required} \
    CONFIG.DDS_Clock_Rate {260} \
    CONFIG.Frequency_Resolution {0.4} \
    CONFIG.Has_ARESETn {false} \
    CONFIG.Has_Phase_Out {false} \
    CONFIG.Has_TREADY {true} \
    CONFIG.Latency {13} \
    CONFIG.M_DATA_Has_TUSER {Not_Required} \
    CONFIG.Noise_Shaping {None} \
    CONFIG.Output_Frequency1 {0} \
    CONFIG.Output_Selection {Cosine} \
    CONFIG.Output_Width {16} \
    CONFIG.PINC1 {1001100110101101110000111101001} \
    CONFIG.Parameter_Entry {Hardware_Parameters} \
    CONFIG.Phase_Increment {Programmable} \
    CONFIG.Phase_Width {32} \
    CONFIG.S_PHASE_Has_TUSER {Not_Required} \
  ] $Local_oscillator


  # Create instance: dsp_dds_compiler_con_0, and set properties
  set block_name dsp_dds_compiler_controller
  set block_cell_name dsp_dds_compiler_con_0
  if { [catch {set dsp_dds_compiler_con_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dsp_dds_compiler_con_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DATA_WIDTH {16} $dsp_dds_compiler_con_0


  # Create interface connections
  connect_bd_intf_net -intf_net Local_oscillator_M_AXIS_DATA [get_bd_intf_pins Local_oscillator/M_AXIS_DATA] [get_bd_intf_pins dsp_dds_compiler_con_0/s_axis]

  # Create port connections
  connect_bd_net -net aclk_0_1 [get_bd_pins adc_clk] [get_bd_pins Local_oscillator/aclk] [get_bd_pins dsp_dds_compiler_con_0/aclk]
  connect_bd_net -net dsp_dds_compiler_con_0_m_axis_tdata [get_bd_pins dsp_dds_compiler_con_0/m_axis_tdata] [get_bd_pins m_axis_tdata]
  connect_bd_net -net dsp_dds_compiler_con_0_m_axis_tvalid [get_bd_pins dsp_dds_compiler_con_0/m_axis_tvalid] [get_bd_pins m_axis_tvalid]
  connect_bd_net -net rst_ni_0_1 [get_bd_pins adc_rst_ni] [get_bd_pins dsp_dds_compiler_con_0/rst_ni]
  connect_bd_net -net s_axis_config_tdata_0_1 [get_bd_pins s_axis_config_tdata_0] [get_bd_pins Local_oscillator/s_axis_config_tdata]
  connect_bd_net -net s_axis_config_tvalid_0_1 [get_bd_pins s_axis_config_tvalid_0] [get_bd_pins Local_oscillator/s_axis_config_tvalid]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  # Create interface ports

  # Create ports
  set adc_clk_0 [ create_bd_port -dir I -type clk adc_clk_0 ]
  set adc_rst_ni_0 [ create_bd_port -dir I adc_rst_ni_0 ]
  set control_in_0 [ create_bd_port -dir I -from 1 -to 0 control_in_0 ]
  set data_band_sel_osc [ create_bd_port -dir O -from 31 -to 0 data_band_sel_osc ]
  set m_axis_tdata_mux_o [ create_bd_port -dir O -from 255 -to 0 m_axis_tdata_mux_o ]
  set m_axis_tvalid_mux_o_0 [ create_bd_port -dir O -from 15 -to 0 m_axis_tvalid_mux_o_0 ]
  set s_axis_adc_tdata [ create_bd_port -dir I -from 255 -to 0 s_axis_adc_tdata ]
  set s_axis_adc_tvalid [ create_bd_port -dir I s_axis_adc_tvalid ]
  set s_axis_freq_config_tdata [ create_bd_port -dir I -from 31 -to 0 s_axis_freq_config_tdata ]
  set s_axis_freq_config_tvalid [ create_bd_port -dir I s_axis_freq_config_tvalid ]

  # Create instance: Band_selector_oscillator, and set properties
  set Band_selector_oscillator [ create_bd_cell -type ip -vlnv xilinx.com:ip:dds_compiler Band_selector_oscillator ]
  set_property -dict [list \
    CONFIG.Amplitude_Mode {Full_Range} \
    CONFIG.DATA_Has_TLAST {Not_Required} \
    CONFIG.DDS_Clock_Rate {260} \
    CONFIG.Frequency_Resolution {0.4} \
    CONFIG.Has_ARESETn {false} \
    CONFIG.Has_Phase_Out {false} \
    CONFIG.Has_TREADY {true} \
    CONFIG.Latency {9} \
    CONFIG.M_DATA_Has_TUSER {Not_Required} \
    CONFIG.Noise_Shaping {None} \
    CONFIG.Output_Frequency1 {0} \
    CONFIG.Output_Width {16} \
    CONFIG.PINC1 {1001000110111001000110111001001} \
    CONFIG.Parameter_Entry {Hardware_Parameters} \
    CONFIG.Phase_Increment {Fixed} \
    CONFIG.Phase_Width {32} \
    CONFIG.S_PHASE_Has_TUSER {Not_Required} \
  ] $Band_selector_oscillator


  # Create instance: Local_osc_hier
  create_hier_cell_Local_osc_hier [current_bd_instance .] Local_osc_hier

  # Create instance: basic_counter_0, and set properties
  set block_name basic_counter
  set block_cell_name basic_counter_0
  if { [catch {set basic_counter_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $basic_counter_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.DIVIDE_CLK_FREQ_BY {4} $basic_counter_0


  # Create instance: copy_counter_N_times, and set properties
  set block_name copy_vec_N_times
  set block_cell_name copy_counter_N_times
  if { [catch {set copy_counter_N_times [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $copy_counter_N_times eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DATA_WIDTH {16} \
    CONFIG.N {16} \
  ] $copy_counter_N_times


  # Create instance: copy_local_osc_N_times, and set properties
  set block_name copy_vec_N_times
  set block_cell_name copy_local_osc_N_times
  if { [catch {set copy_local_osc_N_times [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $copy_local_osc_N_times eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property -dict [list \
    CONFIG.DATA_WIDTH {16} \
    CONFIG.N {16} \
  ] $copy_local_osc_N_times


  # Create instance: data_source_mux_gene_0, and set properties
  set block_name data_source_mux_generic
  set block_cell_name data_source_mux_gene_0
  if { [catch {set data_source_mux_gene_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $data_source_mux_gene_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.VEC_LEN {16} $data_source_mux_gene_0


  # Create port connections
  connect_bd_net -net Band_selector_oscillator_m_axis_data_tdata [get_bd_pins Band_selector_oscillator/m_axis_data_tdata] [get_bd_ports data_band_sel_osc]
  connect_bd_net -net Local_osc_hier_m_axis_tdata [get_bd_pins Local_osc_hier/m_axis_tdata] [get_bd_pins copy_local_osc_N_times/s_axis_tdata_in]
  connect_bd_net -net Local_osc_hier_m_axis_tvalid [get_bd_pins Local_osc_hier/m_axis_tvalid] [get_bd_pins copy_local_osc_N_times/s_axis_tvalid_in]
  connect_bd_net -net adc_clk_0_2 [get_bd_ports adc_clk_0] [get_bd_pins Band_selector_oscillator/aclk] [get_bd_pins Local_osc_hier/adc_clk] [get_bd_pins basic_counter_0/clk_i] [get_bd_pins copy_counter_N_times/sys_clk_i] [get_bd_pins copy_local_osc_N_times/sys_clk_i] [get_bd_pins data_source_mux_gene_0/sys_clk_i]
  connect_bd_net -net adc_rst_ni_0_1 [get_bd_ports adc_rst_ni_0] [get_bd_pins Local_osc_hier/adc_rst_ni] [get_bd_pins basic_counter_0/rst_ni] [get_bd_pins copy_counter_N_times/sys_rst_ni] [get_bd_pins copy_local_osc_N_times/sys_rst_ni] [get_bd_pins data_source_mux_gene_0/sys_rst_ni]
  connect_bd_net -net adc_tdata_0_1 [get_bd_ports s_axis_adc_tdata] [get_bd_pins data_source_mux_gene_0/adc_tdata]
  connect_bd_net -net adc_tvalid_0_1 [get_bd_ports s_axis_adc_tvalid] [get_bd_pins data_source_mux_gene_0/adc_tvalid]
  connect_bd_net -net basic_counter_0_m_axis_tdata [get_bd_pins basic_counter_0/m_axis_tdata] [get_bd_pins copy_counter_N_times/s_axis_tdata_in]
  connect_bd_net -net basic_counter_0_m_axis_tvalid [get_bd_pins basic_counter_0/m_axis_tvalid] [get_bd_pins copy_counter_N_times/s_axis_tvalid_in]
  connect_bd_net -net control_in_0_1 [get_bd_ports control_in_0] [get_bd_pins data_source_mux_gene_0/control_in]
  connect_bd_net -net copy_counter_N_times_m_axis_tdata_out [get_bd_pins copy_counter_N_times/m_axis_tdata_out] [get_bd_pins data_source_mux_gene_0/counter_tdata]
  connect_bd_net -net copy_counter_N_times_m_axis_tvalid_out [get_bd_pins copy_counter_N_times/m_axis_tvalid_out] [get_bd_pins data_source_mux_gene_0/counter_tvalid]
  connect_bd_net -net copy_local_osc_N_times_m_axis_tdata_out [get_bd_pins copy_local_osc_N_times/m_axis_tdata_out] [get_bd_pins data_source_mux_gene_0/dds_compiler_tdata]
  connect_bd_net -net copy_local_osc_N_times_m_axis_tvalid_out [get_bd_pins copy_local_osc_N_times/m_axis_tvalid_out] [get_bd_pins data_source_mux_gene_0/dds_compiler_tvalid]
  connect_bd_net -net data_source_mux_gene_0_m_axis_tdata_o [get_bd_pins data_source_mux_gene_0/m_axis_tdata_o] [get_bd_ports m_axis_tdata_mux_o]
  connect_bd_net -net data_source_mux_gene_0_m_axis_tvalid_o [get_bd_pins data_source_mux_gene_0/m_axis_tvalid_o] [get_bd_ports m_axis_tvalid_mux_o_0] [get_bd_pins Band_selector_oscillator/m_axis_data_tready]
  connect_bd_net -net s_axis_config_tdata_0_1 [get_bd_ports s_axis_freq_config_tdata] [get_bd_pins Local_osc_hier/s_axis_config_tdata_0]
  connect_bd_net -net s_axis_config_tvalid_0_1 [get_bd_ports s_axis_freq_config_tvalid] [get_bd_pins Local_osc_hier/s_axis_config_tvalid_0]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


