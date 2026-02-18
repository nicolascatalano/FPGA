
################################################################
# This is a generated script based on design: band_processing_bd
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
# source band_processing_bd_script.tcl


# The design that will be created by this Tcl script contains the following
# module references:
# zero_padder, dsp_complex_gain

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
set design_name band_processing_bd

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
xilinx.com:ip:cmpy:*\
xilinx.com:ip:fir_compiler:*\
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
zero_padder\
dsp_complex_gain\
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


# Hierarchical cell: Band_filter_hier
proc create_hier_cell_Band_filter_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_Band_filter_hier() - Empty argument(s)!"}
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
  create_bd_pin -dir I -from 31 -to 0 data_in
  create_bd_pin -dir O -from 31 -to 0 m_axis_data_tdata
  create_bd_pin -dir O m_axis_data_tvalid
  create_bd_pin -dir I s_axis_data_tvalid

  # Create instance: Band_filter, and set properties
  # find .coe file
  set this_script_path [file dirname [info script]]
  set filters_dir [file normalize [file join $this_script_path .. .. filters]]
  set Band_filter [ create_bd_cell -type ip -vlnv xilinx.com:ip:fir_compiler Band_filter ]
  set_property -dict [list \
    CONFIG.Clock_Frequency {260} \
    CONFIG.CoefficientSource {COE_File} \
    CONFIG.Coefficient_File $filters_dir/bandpass.coe \
    CONFIG.Coefficient_Fractional_Bits {19} \
    CONFIG.Coefficient_Sets {1} \
    CONFIG.Coefficient_Sign {Signed} \
    CONFIG.Coefficient_Structure {Inferred} \
    CONFIG.Coefficient_Width {16} \
    CONFIG.ColumnConfig {3} \
    CONFIG.Data_Fractional_Bits {0} \
    CONFIG.Data_Width {16} \
    CONFIG.Decimation_Rate {8} \
    CONFIG.Filter_Architecture {Systolic_Multiply_Accumulate} \
    CONFIG.Filter_Type {Decimation} \
    CONFIG.Interpolation_Rate {1} \
    CONFIG.Number_Channels {1} \
    CONFIG.Number_Paths {2} \
    CONFIG.Output_Rounding_Mode {Truncate_LSBs} \
    CONFIG.Output_Width {16} \
    CONFIG.Quantization {Quantize_Only} \
    CONFIG.RateSpecification {Frequency_Specification} \
    CONFIG.Sample_Frequency {65} \
    CONFIG.Zero_Pack_Factor {1} \
  ] $Band_filter


  # Create instance: dsp_complex_gain_0, and set properties
  set block_name dsp_complex_gain
  set block_cell_name dsp_complex_gain_0
  if { [catch {set dsp_complex_gain_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $dsp_complex_gain_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.SHIFT_BY {2} $dsp_complex_gain_0


  # Create port connections
  connect_bd_net -net Band_filter_m_axis_data_tdata [get_bd_pins Band_filter/m_axis_data_tdata] [get_bd_pins m_axis_data_tdata]
  connect_bd_net -net Band_filter_m_axis_data_tvalid [get_bd_pins Band_filter/m_axis_data_tvalid] [get_bd_pins m_axis_data_tvalid]
  connect_bd_net -net Band_mixer_m_axis_dout_tdata [get_bd_pins data_in] [get_bd_pins dsp_complex_gain_0/data_in]
  connect_bd_net -net Band_mixer_m_axis_dout_tvalid [get_bd_pins s_axis_data_tvalid] [get_bd_pins Band_filter/s_axis_data_tvalid]
  connect_bd_net -net aclk_0_1 [get_bd_pins adc_clk] [get_bd_pins Band_filter/aclk]
  connect_bd_net -net dsp_complex_gain_0_data_out [get_bd_pins dsp_complex_gain_0/data_out] [get_bd_pins Band_filter/s_axis_data_tdata]

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
  set adc_clk_0 [ create_bd_port -dir I -type clk -freq_hz 260000000 adc_clk_0 ]
  set adc_rst_ni_0 [ create_bd_port -dir I adc_rst_ni_0 ]
  set band_mixer_data_o [ create_bd_port -dir O -from 31 -to 0 band_mixer_data_o ]
  set band_mixer_valid_o [ create_bd_port -dir O band_mixer_valid_o ]
  set band_osc_in [ create_bd_port -dir I -from 31 -to 0 band_osc_in ]
  set data_mux_in [ create_bd_port -dir I -from 15 -to 0 data_mux_in ]
  set data_out [ create_bd_port -dir O -from 31 -to 0 data_out ]
  set valid_mux_in [ create_bd_port -dir I valid_mux_in ]
  set valid_out [ create_bd_port -dir O valid_out ]

  # Create instance: Band_filter_hier
  create_hier_cell_Band_filter_hier [current_bd_instance .] Band_filter_hier

  # Create instance: Band_mixer, and set properties
  set Band_mixer [ create_bd_cell -type ip -vlnv xilinx.com:ip:cmpy Band_mixer ]
  set_property -dict [list \
    CONFIG.ARESETN {true} \
    CONFIG.BPortWidth {16} \
    CONFIG.FlowControl {NonBlocking} \
    CONFIG.MinimumLatency {5} \
    CONFIG.MultType {Use_LUTs} \
    CONFIG.OptimizeGoal {Resources} \
    CONFIG.OutputWidth {16} \
    CONFIG.RoundMode {Truncate} \
  ] $Band_mixer


  # Create instance: zero_padder_0, and set properties
  set block_name zero_padder
  set block_cell_name zero_padder_0
  if { [catch {set zero_padder_0 [create_bd_cell -type module -reference $block_name $block_cell_name] } errmsg] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "Unable to add referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   } elseif { $zero_padder_0 eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "Unable to referenced block <$block_name>. Please add the files for ${block_name}'s definition into the project."}
     return 1
   }
    set_property CONFIG.LSB_PADDING {false} $zero_padder_0


  # Create port connections
  connect_bd_net -net Band_filter_hier_m_axis_data_tdata [get_bd_pins Band_filter_hier/m_axis_data_tdata] [get_bd_ports data_out]
  connect_bd_net -net Band_filter_hier_m_axis_data_tvalid [get_bd_pins Band_filter_hier/m_axis_data_tvalid] [get_bd_ports valid_out]
  connect_bd_net -net Band_mixer_m_axis_dout_tdata [get_bd_pins Band_mixer/m_axis_dout_tdata] [get_bd_ports band_mixer_data_o] [get_bd_pins Band_filter_hier/data_in]
  connect_bd_net -net Band_mixer_m_axis_dout_tvalid [get_bd_pins Band_mixer/m_axis_dout_tvalid] [get_bd_ports band_mixer_valid_o] [get_bd_pins Band_filter_hier/s_axis_data_tvalid]
  connect_bd_net -net adc_clk_0_1 [get_bd_ports adc_clk_0] [get_bd_pins Band_filter_hier/adc_clk] [get_bd_pins Band_mixer/aclk]
  connect_bd_net -net adc_rst_ni_0_1 [get_bd_ports adc_rst_ni_0] [get_bd_pins Band_mixer/aresetn]
  connect_bd_net -net data_in_0_1 [get_bd_ports data_mux_in] [get_bd_pins zero_padder_0/data_in]
  connect_bd_net -net s_axis_a_tdata_0_1 [get_bd_ports band_osc_in] [get_bd_pins Band_mixer/s_axis_a_tdata]
  connect_bd_net -net s_axis_a_tvalid_0_1 [get_bd_ports valid_mux_in] [get_bd_pins Band_mixer/s_axis_a_tvalid] [get_bd_pins Band_mixer/s_axis_b_tvalid]
  connect_bd_net -net zero_padder_0_data_out [get_bd_pins zero_padder_0/data_out] [get_bd_pins Band_mixer/s_axis_b_tdata]

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


