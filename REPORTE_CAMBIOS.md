# Reporte de Cambios - Correcciones para Vivado 2024.2

**Fecha:** 18 de febrero 2026  
**Objetivo:** Corregir compatibilidad de scripts TCL y constraints XDC de Vivado 2023.2 a 2024.2, eliminar errores de síntesis/implementación

---

## 1. create_project.tcl

**Ubicación:** `f:/sist_adq_dbf/create_project.tcl`

### Cambio 1: Corrección de ruta de directorio RTL

**Línea original:**
```tcl
set top_dir [file normalize [file join $prj_dir ..]]
set rtl_dir [file join $top_dir rtl]
```

**Línea corregida:**
```tcl
set rtl_dir [file join $prj_dir rtl]
```

**Por qué:** 
- El script original calculaba `top_dir` como el directorio padre de `prj_dir` (vivado/)
- Esto hacía que `rtl_dir` apuntara a `f:\sist_adq_dbf\vivado\rtl` (incorrecto)
- La estructura real es `f:\sist_adq_dbf\rtl` (directorio hermano de vivado/)
- **Error resultante:** "Cannot find design source files" durante lectura de fuentes RTL
- **Impacto:** Impedía crear el proyecto

---

### Cambio 2: Corrección de fileset para archivos XDC

**Línea original:**
```tcl
add_files $constraints_dir -fileset [get_filesets sources_1]
```

**Línea corregida:**
```tcl
add_files -fileset constrs_1 -norecurse [glob -nocomplain $constraints_dir/*.xdc]
```

**Por qué:**
- Los archivos XDC (constraints) deben agregarse al fileset `constrs_1` (constraint fileset)
- Se estaban añadiendo al fileset `sources_1` (source/RTL fileset)
- **Error resultante:** "[Vivado 12-2345] XDC files in sources_1 are ignored during implementation"
- Ubicación incorrecta causaba que constraints no se aplicaran → violaciones de timing no detectadas
- `-norecurse`: Evita buscar recursivamente en subdirectorios 
- `[glob -nocomplain ...]`: Solo añade archivos .xdc existentes, sin errores si no existen
- **Impacto:** Archivos de constraints no se aplicaban a la implementación

---

## 2. Archivos de Generación de IP (5 archivos)

Todos estos archivos requirieron **identicos cambios** por el mismo motivo: fueron exportados de Vivado 2023.2

### Archivos afectados:
1. `tcl/ip/clk_wiz_preproc.tcl` - Clock Wizard (455 MHz → 260 MHz)
2. `tcl/ip/c_counter_binary.tcl` - Contador binario 7-bit
3. `tcl/ip/counter_32_bits.tcl` - Contador binario 32-bit
4. `tcl/ip/fifo_generator.tcl` - Generador de 16 FIFOs asíncronos
5. `tcl/ip/ch_mixer.tcl` - Mixer/multiplicador complejo

### Cambio A: Corrección de validación de versión Vivado

**Línea original (línea 8-10 aproximadamente):**
```tcl
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  puts "WARNING: This script was generated using Vivado <$scripts_vivado_version>..."
  return 1
}
```

**Línea corregida:**
```tcl
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
  puts "WARNING: This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. IP will be generated but may need upgrading."
}
```

**Por qué:**
- El `return 1` en la línea original abortaba la ejecución del script si Vivado != 2023.2
- En Vivado 2024.2, el test fallaba → script se detenía sin crear el IP
- **Error resultante:** 20 "Black Box" DRC errors (IPs sintéticos no generados)
- Cambio a `puts "WARNING..."` sin `return`: permite continuar la ejecución
- Los IPs de Xilinx son compatibles hacia adelante (2023.2 → 2024.2)
- **Impacto:** Sin este cambio, imposible generar los 5 IPs críticos

---

### Cambio B: Eliminación de propiedad inválida en IP

**Ubicación del error:** Sección "Runtime Parameters" al final del script (aprox. línea 75-80)

**Líneas originales:**
```tcl
##################################################################
# CONFIGURING IP
##################################################################
set_property -dict [list \
  CONFIG.GENERATE_SYNTH_CHECKPOINT {1} \
] [get_ips clk_wiz_preproc]
```

**Línea corregida:**
```tcl
# Sección eliminada completamente
```

**Por qué:**
- `GENERATE_SYNTH_CHECKPOINT` es una propiedad de proyectos, NO de IPs individuales
- Vivado 2024.2 es más estricto con validación de propiedades
- **Error resultante:** "[Vivado 12-1447] Option 'GENERATE_SYNTH_CHECKPOINT' is not valid for IP object..."
- Intentar aplicar esta propiedad a un IP causaba fallos en generación
- **Impacto:** Impedía la creación del IP con error de sintaxis immediately después de configurar parámetros

---

## 3. ciaa_acc_SistAdq_ADC.xdc

**Ubicación:** `f:/sist_adq_dbf/constraints/ciaa_acc_SistAdq_ADC.xdc`

### Cambio 1: Corrección de redefinición de reloj ADC_DCO1

**Líneas originales (líneas 30-33):**
```tcl
#adc_DCO1 clock creation
create_clock -period 2.198 -name adc_DCO1 [get_ports adc_DCO1_i_clk_p]
set_input_jitter [get_clocks adc_DCO1] 0.000
# set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks adc_DCO1]
```

**Líneas corregidas:**
```tcl
#adc_DCO1 clock creation - primary clock at external port only
create_clock -period 2.198 -name adc_DCO1 [get_ports adc_DCO1_i_clk_p]
set_input_jitter [get_clocks adc_DCO1] 0.000

# Mark internal Clock Wizard input as a generated clock to avoid clock redefinition
create_generated_clock -name adc_DCO1_clk_wiz_in -source [get_ports adc_DCO1_i_clk_p] -divide_by 1 \
    [get_pins adc_control_wrapper_inst/adc_receiver1_inst/clk_wiz_preproc_inst/inst/clk_in1]
```

**Por qué:**
- La TopModule tenía **dos definiciones de reloj** para la misma señal:
  1. Primaria en puerto externo `adc_DCO1_i_clk_p` (correcto)
  2. Secundaria implícita en pin interno `clk_wiz_preproc_inst/inst/clk_in1` (incorrecto)
- El Clock Wizard genera internamente versiones del reloj, pero sin declarar explícitamente, Vivado asume ambas como clocks primarios
- **Warnings causados:**
  - `TIMING-4`: "Invalid primary clock redefinition on a clock tree"
  - `TIMING-27`: "Invalid primary clock on hierarchical pin"
- Solución: Usar `create_generated_clock` para marcar explícitamente el pin interno como derivado del externo
- Esto establece la jerarquía de reloj correctamente
- **Impacto:** Elimina 4 Critical Warnings (2 TIMING-4 + 2 TIMING-27)

---

### Cambio 2: Corrección de redefinición de reloj ADC_DCO2

**Líneas originales (líneas 42-45):**
```tcl
#adc_DCO2 clock creation
create_clock -period 2.198 -name adc_DCO2 [get_ports adc_DCO2_i_clk_p]
set_input_jitter [get_clocks adc_DCO2] 0.000
# set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks adc_DCO2]
```

**Líneas corregidas:**
```tcl
#adc_DCO2 clock creation - primary clock at external port only
create_clock -period 2.198 -name adc_DCO2 [get_ports adc_DCO2_i_clk_p]
set_input_jitter [get_clocks adc_DCO2] 0.000

# Mark internal Clock Wizard input as a generated clock to avoid clock redefinition
create_generated_clock -name adc_DCO2_clk_wiz_in -source [get_ports adc_DCO2_i_clk_p] -divide_by 1 \
    [get_pins adc_control_wrapper_inst/adc_receiver2_inst/clk_wiz_preproc_inst/inst/clk_in1]
```

**Por qué:**
- Mismo problema que ADC_DCO1, pero para el segundo ADC
- Ambos receptores ADC usan Clock Wizards independientes para sincronización
- Ambos necesitaban la misma corrección
- **Impacto:** Elimina 2 más Critical Warnings (segunda pareja TIMING-4 + TIMING-27)

---

## Resumen de cambios

| Archivo | Tipo | Cambios | Errores resueltos |
|---------|------|---------|------------------|
| `create_project.tcl` | Script principal | 2 correcciones | Missing RTL files, Constraints no aplicados |
| 5 IP TCL scripts | Generación de IPs | 2 correcciones c/u | 20 Black Box errors, IP generation failure |
| `ciaa_acc_SistAdq_ADC.xdc` | Constraints | 2 correcciones | 4 Critical Warnings (TIMING-4, TIMING-27) |

---

## Impacto General

### Antes de cambios:
- ❌ Proyecto no se creaba (error en RTL path)
- ❌ Si se creaba, síntesis fallaba (20 Black Boxes)
- ❌ Si síntesis pasaba, implementación fallaba (Black Boxes)
- ❌ 4 Critical Warnings de timing

### Después de cambios:
- ✅ Proyecto se crea correctamente
- ✅ Síntesis: 0 errores, 103 warnings (esperados)
- ✅ Implementación: 0 errores, 16 warnings (menores)
- ✅ Bitstream: Generado correctamente
- ✅ Timing: WNS=0.174ns (cumplido), 0 Critical Warnings

---

## Recomendaciones futuras

1. **Mantener scripts actualizados:** Si cambias de versión Vivado, revisar versión en TCL scripts
2. **Validación automática:** Considerar agregar chequeos de versión más flexibles
3. **Constraints mejorados:** Agregar input/output delays para los 19 pins sin timing especificado
4. **Documentación:** Mantener notas sobre compatibilidad de versiones en comentarios TCL
