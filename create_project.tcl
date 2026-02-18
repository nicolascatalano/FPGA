set prj_name sist_adq_dbf
set part_num xc7z030fbg676-2

set prj_dir [file dirname [info script]]
set constraints_dir [file join $prj_dir constraints]
set tcl_dir [file join $prj_dir tcl]
set rtl_dir [file join $prj_dir rtl]

# Create project
create_project $prj_name vivado -part $part_num

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set_property -dict [list \
    board_part www.proyecto-ciaa.com.ar:ciaa-acc:part0:1.0 \
    platform.board_id ciaa-acc \
    default_lib xil_defaultlib \
    part $part_num \
    simulator_language Mixed \
    target_language VHDL \
    enable_vhdl_2008 1 \
    xpm_libraries {XPM_CDC XPM_FIFO XPM_MEMORY} \
] [current_project]

# add all RTL files, set VHDL 2008
add_files $rtl_dir -fileset [get_filesets sources_1]

# add all constraints files
add_files -fileset constrs_1 -norecurse [glob -nocomplain $constraints_dir/*.xdc]

# add IPs and BDs
set ip_list [glob -nocomplain $tcl_dir/ip/*]
foreach ip $ip_list {
    source $ip
}
set bd_list [glob -nocomplain $tcl_dir/bd/*]
foreach ip $bd_list {
    source $ip
    close_bd_design [get_bd_designs]
}

# set top module
set_property top SistAdq_top [get_filesets sources_1]