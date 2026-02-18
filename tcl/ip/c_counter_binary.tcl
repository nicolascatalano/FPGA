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
# source c_counter_binary.tcl
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
  set list_check_ips { xilinx.com:ip:c_counter_binary:* }
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
# CREATE IP c_counter_binary
##################################################################

set c_counter_binary [create_ip -name c_counter_binary -vendor xilinx.com -library ip -module_name c_counter_binary]

# User Parameters
set_property -dict [list \
  CONFIG.CE {true} \
  CONFIG.Implementation {DSP48} \
  CONFIG.Output_Width {14} \
  CONFIG.SCLR {true} \
] [get_ips c_counter_binary]

##################################################################

