set project_origin "../"
set project_work  "work"
set project_name "WasmFpgaEngine"
set project_part "xc7a100tcsg324-1"
set project_src  "src"
set project_resources "resources"
set project_ip "ip"
set project_tb "tb"
set project_package "package"

proc printMessage {outMsg} {
    puts " --------------------------------------------------------------------------------"
    puts " -- $outMsg"
    puts " --------------------------------------------------------------------------------"
}

printMessage "Project: ${project_name}   Part: ${project_part}   Source Folder: ${project_src}"

# Create project
printMessage "Create the Vivado project"
create_project ${project_name} ${project_work} -part ${project_part} -force

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Set project properties
set obj [current_project]
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "${project_work}/${project_name}.cache/ip" -objects $obj
set_property -name "part" -value ${project_part} -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_FIFO XPM_MEMORY" -objects $obj
set_property -name "xsim.array_display_limit" -value "64" -objects $obj

# Need to enable VHDL 2008
set_param project.enableVHDL2008 1

#------------------------------------------------------------------------
printMessage "Set IP repository paths"

set obj [get_filesets sources_1]

set_property "ip_repo_paths" "[file normalize "${project_origin}/vivado-bus-abstraction-wb"]" $obj

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

#------------------------------------------------------------------------
printMessage "Include VHDL files into project"

if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

set obj [get_filesets sources_1]
set files_vhd [list \
 [file normalize "${project_src}/WasmFpgaEngine.vhd" ]\
 [file normalize "${project_src}/WasmFpgaEnginePackage.vhd" ]\
 [file normalize "${project_src}/WasmFpgaModuleProxy.vhd" ]\
 [file normalize "${project_src}/WasmFpgaStoreProxy.vhd" ]\
 [file normalize "${project_src}/WasmFpgaStackProxy.vhd" ]\
 [file normalize "${project_src}/WasmFpgaMemoryProxy.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_engine_header.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_engine_wishbone.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_store_header.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_store_wishbone.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_stack_header.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_stack_wishbone.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_bus_header.vhd" ]\
 [file normalize "${project_resources}/wasm_fpga_bus_wishbone.vhd" ]\
 [file normalize "${project_src}/instructions/End.vhd" ]\
 [file normalize "${project_src}/instructions/Nop.vhd" ]\
 [file normalize "${project_src}/instructions/Drop.vhd" ]\
 [file normalize "${project_src}/instructions/Select.vhd" ]\
 [file normalize "${project_src}/instructions/Unreachable.vhd" ]\
 [file normalize "${project_src}/instructions/I32Load.vhd" ]\
 [file normalize "${project_src}/instructions/I32Store.vhd" ]\
 [file normalize "${project_src}/instructions/I32Ctz.vhd" ]\
 [file normalize "${project_src}/instructions/I32Clz.vhd" ]\
 [file normalize "${project_src}/instructions/I32Const.vhd" ]\
 [file normalize "${project_src}/instructions/I32Add.vhd" ]\
 [file normalize "${project_src}/instructions/I32Sub.vhd" ]\
 [file normalize "${project_src}/instructions/I32And.vhd" ]\
 [file normalize "${project_src}/instructions/I32Mul.vhd" ]\
 [file normalize "${project_src}/instructions/I32Divs.vhd" ]\
 [file normalize "${project_src}/instructions/I32Divu.vhd" ]\
 [file normalize "${project_src}/instructions/I32Rems.vhd" ]\
 [file normalize "${project_src}/instructions/I32Remu.vhd" ]\
 [file normalize "${project_src}/instructions/I32Or.vhd" ]\
 [file normalize "${project_src}/instructions/I32Xor.vhd" ]\
 [file normalize "${project_src}/instructions/I32Rotl.vhd" ]\
 [file normalize "${project_src}/instructions/I32Rotr.vhd" ]\
 [file normalize "${project_src}/instructions/I32Shl.vhd" ]\
 [file normalize "${project_src}/instructions/I32Shrs.vhd" ]\
 [file normalize "${project_src}/instructions/I32Shru.vhd" ]\
 [file normalize "${project_src}/instructions/I32Popcnt.vhd" ]\
 [file normalize "${project_src}/instructions/I32Eqz.vhd" ]\
 [file normalize "${project_src}/instructions/I32Eq.vhd" ]\
 [file normalize "${project_src}/instructions/I32Ne.vhd" ]\
 [file normalize "${project_src}/instructions/I32Lts.vhd" ]\
 [file normalize "${project_src}/instructions/I32Ltu.vhd" ]\
 [file normalize "${project_src}/instructions/I32Ges.vhd" ]\
 [file normalize "${project_src}/instructions/I32Geu.vhd" ]\
 [file normalize "${project_src}/instructions/I32Gts.vhd" ]\
 [file normalize "${project_src}/instructions/I32Gtu.vhd" ]\
 [file normalize "${project_src}/instructions/I32Les.vhd" ]\
 [file normalize "${project_src}/instructions/I32Leu.vhd" ]\
 [file normalize "${project_src}/instructions/LocalGet.vhd" ]\
 [file normalize "${project_src}/instructions/LocalSet.vhd" ]\
 [file normalize "${project_package}/component.xml" ]\
]
add_files -norecurse -fileset $obj $files_vhd

foreach i $files_vhd {
    set file_obj [get_files -of_objects [get_filesets sources_1] [file tail [list $i]]]
    set_property -name "file_type" -value "VHDL" -objects $file_obj
}

set file "${project_package}/component.xml"
set file [file normalize $file]
set file_obj [get_files -of_objects [get_filesets sources_1] [list "*$file"]]
set_property -name "file_type" -value "IP-XACT" -objects $file_obj

#------------------------------------------------------------------------
printMessage "Add IP cores needed by synthesis..."

set files [list \
 "[file normalize "${project_ip}/WasmFpgaMultiplier32Bit/WasmFpgaMultiplier32Bit.xci"]"\
 "[file normalize "${project_ip}/WasmFpgaDivider32BitUnsigned/WasmFpgaDivider32BitUnsigned.xci"]"\
 "[file normalize "${project_ip}/WasmFpgaDivider32BitSigned/WasmFpgaDivider32BitSigned.xci"]"\
]
add_files -fileset sources_1 $files

set obj [get_filesets sources_1]
set_property -name "top" -value "WasmFpgaEngine" -objects $obj
set_property -name "top_auto_set" -value "0" -objects $obj
set_property -name "top_file" -value "${project_src}/WasmFpgaEngine.vhd" -objects $obj

#------------------------------------------------------------------------
printMessage "Adding simulation files..."

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset object
set obj [get_filesets sim_1]
set files [list \
 "[file normalize "${project_tb}/tb_WasmFpgaEngine.vhd"]"\
 "[file normalize "${project_tb}/tb_FileIo.vhd"]"\
 "[file normalize "${project_tb}/tb_pkg_helper.vhd"]"\
 "[file normalize "${project_tb}/tb_pkg.vhd"]"\
 "[file normalize "${project_tb}/tb_std_logic_1164_additions.vhd"]"\
 "[file normalize "${project_tb}/tb_Types.vhd"]"\
 "[file normalize "${project_tb}/tb_WbRam.vhd"]"\
 "[file normalize "${project_origin}/wasm-fpga-store/src/WasmFpgaStore.vhd"]"\
 "[file normalize "${project_origin}/wasm-fpga-stack/src/WasmFpgaStack.vhd"]"\
 "[file normalize "${project_origin}/wasm-fpga-bus/src/WasmFpgaBus.vhd"]"\
]
add_files -norecurse -fileset $obj $files

foreach i $files {
    set file_obj [get_files -of_objects [get_filesets sim_1] [list $i]]
    set_property "file_type" "VHDL" $file_obj
}

#------------------------------------------------------------------------
printMessage "Add IP cores needed by simulation..."

set files [list \
 "[file normalize "${project_ip}/WasmFpgaTestBenchRam/WasmFpgaTestBenchRam.xci"]"\
]

add_files -fileset sim_1 $files

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property "top" "tb_WasmFpgaEngine" $obj

#------------------------------------------------------------------------
printMessage "Adding constraint files..."

#------------------------------------------------------------------------
close_project -verbose

#------------------------------------------------------------------------
printMessage "Project: ${project_name}   Part: ${project_part}   Source Folder: ${project_src}"
