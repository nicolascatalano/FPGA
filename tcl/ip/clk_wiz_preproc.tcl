##################################################################
# CHECK VIVADO VERSION
##################################################################

set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  puts "WARNING: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. IP will be generated but may need upgrading."
}

##################################################################
# START
##################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source clk_wiz_preproc.tcl
# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
  create_project CIAA_SistAdq_x16 ciaa_sistadq_x16_proj -part xc7z030fbg676-2
  set_property BOARD_PART www.proyecto-ciaa.com.ar:ciaa-acc:part0:1.0 [current_project]
  set_property target_language VHDL [current_project]
  set_property simulator_language Mixed [current_project]
}

##################################################################
# CHECK IPs
##################################################################

set bCheckIPs 1
set bCheckIPsPassed 1
if { $bCheckIPs == 1 } {
  set list_check_ips { xilinx.com:ip:clk_wiz:* }
  set list_ips_missing ""
  common::send_msg_id "IPS_TCL-1001" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

  foreach ip_vlnv $list_check_ips {
  set ip_obj [get_ipdefs -all $ip_vlnv]
  if { $ip_obj eq "" } {
    lappend list_ips_missing $ip_vlnv
    }
  }

  if { $list_ips_missing ne "" } {
    catch {common::send_msg_id "IPS_TCL-105" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
    set bCheckIPsPassed 0
  }
}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "IPS_TCL-102" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 1
}

##################################################################
# CREATE IP clk_wiz_preproc
##################################################################

set clk_wiz_preproc [create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name clk_wiz_preproc]

# User Parameters
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {21.97} \
  CONFIG.CLKOUT1_JITTER {120.593} \
  CONFIG.CLKOUT1_PHASE_ERROR {109.791} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {260} \
  CONFIG.CLKOUT1_REQUESTED_PHASE {180} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {15.000} \
  CONFIG.MMCM_CLKIN1_PERIOD {2.198} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {3.750} \
  CONFIG.MMCM_CLKOUT0_PHASE {180.000} \
  CONFIG.MMCM_DIVCLK_DIVIDE {7} \
  CONFIG.PRIM_IN_FREQ {455} \
] [get_ips clk_wiz_preproc]

##################################################################

