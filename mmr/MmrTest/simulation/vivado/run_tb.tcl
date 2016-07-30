
#------------------------------------------------------------------------------
# Variables for Vivado tool flow, sim, synth and implememtation.
#------------------------------------------------------------------------------

set PROJ_NAME project_5_sim_flow
set PROJ_PATH C:/Users/a/arty
set PROJ_PART xc7a35ticsg324-1L
set PROJ_BRD  digilentinc.com:arty:part0:1.1

lappend design_files C:/Users/a/Dropbox/verilogBanks/v/example.v
lappend design_files C:/Users/a/Dropbox/verilogBanks/v/example_b1.v
lappend design_files C:/Users/a/Dropbox/verilogBanks/v/example_b0.v
lappend design_files C:/Users/a/Dropbox/verilogBanks/v/example_axi4_reg_if.v

lappend sim_files C:/Users/a/Dropbox/verilogBanks/tb_top.v

#------------------------------------------------------------------------------
# Runscript. Generally you should not need to modify commands.
#------------------------------------------------------------------------------
create_project ${PROJ_NAME} ${PROJ_PATH}/${PROJ_NAME} -part ${PROJ_PART} -force

set_property board_part ${PROJ_BRD} [current_project]

add_files -norecurse ${design_files}

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

set_property SOURCE_SET sources_1 [get_filesets sim_1]
add_files -fileset sim_1 -norecurse ${sim_files}

update_compile_order -fileset sim_1

launch_simulation

run all

add_files -fileset constrs_1 C:/Users/a/Dropbox/verilogBanks/cons.xdc
set_property target_constrs_file C:/Users/a/Dropbox/verilogBanks/cons.xdc [current_fileset -constrset]

launch_runs synth_1 -jobs 2 -verbose
wait_on_run synth_1

if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
   error "ERROR: synth_1 failed"
} else {
   launch_runs impl_1 -jobs 2 -verbose
   wait_on_run impl_1
   open_run impl_1
   report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose -max_paths 10 -input_pins -name timing_1
   report_cdc
   report_utilization
   report_datasheet
}

