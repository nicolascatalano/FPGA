#!/usr/bin/tclsh
# Script para generar el proyecto completo y el bitstream
# Uso: vivado -mode batch -source build_bitstream.tcl

set project_dir "f:/sist_adq_dbf"
cd $project_dir

puts "\n=========================================="
puts "PASO 1: Creando proyecto desde cero"
puts "==========================================\n"

# Ejecutar script de creación
source create_project.tcl

puts "\n=========================================="
puts "PASO 2: Abriendo proyecto"
puts "==========================================\n"

open_project vivado/sist_adq_dbf.xpr

puts "\n=========================================="
puts "PASO 3: Actualizando IPs"
puts "==========================================\n"

# Actualizar IPs si es necesario
set ips [get_ips -quiet]
if {[llength $ips] > 0} {
    puts "IPs encontrados: [llength $ips]"
    foreach ip $ips {
        set ip_name [get_property NAME $ip]
        set ip_locked [get_property IS_LOCKED $ip]
        if {$ip_locked} {
            puts "  - Actualizando IP: $ip_name"
            upgrade_ip $ip
        } else {
            puts "  - IP OK: $ip_name"
        }
    }
} else {
    puts "No se encontraron IPs"
}

puts "\n=========================================="
puts "PASO 4: Generando Block Designs"
puts "==========================================\n"

set bd_files [get_files -quiet *.bd]
if {[llength $bd_files] > 0} {
    puts "Block Designs encontrados: [llength $bd_files]"
    foreach bd $bd_files {
        set bd_name [file tail $bd]
        puts "  - Generando outputs para: $bd_name"
        generate_target all [get_files $bd]
    }
} else {
    puts "No se encontraron Block Designs"
}

puts "\n=========================================="
puts "PASO 5: Verificando proyecto"
puts "==========================================\n"

set top_module [get_property top [current_fileset]]
puts "Top module: $top_module"

set vhdl_files [llength [get_files -quiet *.vhd]]
puts "Archivos VHDL: $vhdl_files"

set xdc_files [llength [get_files -quiet *.xdc]]
puts "Archivos XDC: $xdc_files"

puts "\n=========================================="
puts "PASO 6: Ejecutando Síntesis"
puts "==========================================\n"

reset_run synth_1
launch_runs synth_1 -jobs 4
wait_on_run synth_1

set synth_status [get_property STATUS [get_runs synth_1]]
set synth_progress [get_property PROGRESS [get_runs synth_1]]
puts "Estado de síntesis: $synth_status ($synth_progress)"

if {[string match "*Complete!*" $synth_status]} {
    puts "✓ Síntesis completada exitosamente"
    
    puts "\n=========================================="
    puts "PASO 7: Ejecutando Implementación"
    puts "==========================================\n"
    
    launch_runs impl_1 -jobs 4
    wait_on_run impl_1
    
    set impl_status [get_property STATUS [get_runs impl_1]]
    set impl_progress [get_property PROGRESS [get_runs impl_1]]
    puts "Estado de implementación: $impl_status ($impl_progress)"
    
    if {[string match "*Complete!*" $impl_status]} {
        puts "✓ Implementación completada exitosamente"
        
        puts "\n=========================================="
        puts "PASO 8: Generando Bitstream"
        puts "==========================================\n"
        
        launch_runs impl_1 -to_step write_bitstream -jobs 4
        wait_on_run impl_1
        
        set bit_file "vivado/sist_adq_dbf.runs/impl_1/SistAdq_top.bit"
        if {[file exists $bit_file]} {
            set bit_size [file size $bit_file]
            puts "\n=========================================="
            puts "✓✓✓ ÉXITO ✓✓✓"
            puts "==========================================\n"
            puts "Bitstream generado: $bit_file"
            puts "Tamaño: [expr $bit_size / 1024] KB"
            puts "\n=========================================="
        } else {
            puts "\n✗ ERROR: No se generó el archivo .bit"
        }
    } else {
        puts "\n✗ ERROR en implementación: $impl_status"
    }
} else {
    puts "\n✗ ERROR en síntesis: $synth_status"
}

puts "\nScript completado.\n"
