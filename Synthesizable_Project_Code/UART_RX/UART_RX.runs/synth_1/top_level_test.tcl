# 
# Synthesis run script generated by Vivado
# 

set TIME_start [clock seconds] 
proc create_report { reportName command } {
  set status "."
  append status $reportName ".fail"
  if { [file exists $status] } {
    eval file delete [glob $status]
  }
  send_msg_id runtcl-4 info "Executing : $command"
  set retval [eval catch { $command } msg]
  if { $retval != 0 } {
    set fp [open $status w]
    close $fp
    send_msg_id runtcl-5 warning "$msg"
  }
}
create_project -in_memory -part xc7a100tcsg324-1

set_param project.singleFileAddWarning.threshold 0
set_param project.compositeFile.enableAutoGeneration 0
set_param synth.vivado.isSynthRun true
set_property webtalk.parent_dir C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.cache/wt [current_project]
set_property parent.project_path C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.xpr [current_project]
set_property default_lib xil_defaultlib [current_project]
set_property target_language VHDL [current_project]
set_property ip_output_repo c:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.cache/ip [current_project]
set_property ip_cache_permissions {read write} [current_project]
read_vhdl -library xil_defaultlib {
  C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.srcs/sources_1/new/MEM.vhd
  C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.srcs/sources_1/imports/Desktop/UART_RX.vhd
  C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.srcs/sources_1/new/UART_TX.vhd
  C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.srcs/sources_1/new/top_level_test.vhd
}
# Mark all dcp files as not used in implementation to prevent them from being
# stitched into the results of this synthesis run. Any black boxes in the
# design are intentionally left as such for best results. Dcp files will be
# stitched into the design at a later time, either when this synthesis run is
# opened, or when it is stitched into a dependent implementation run.
foreach dcp [get_files -quiet -all -filter file_type=="Design\ Checkpoint"] {
  set_property used_in_implementation false $dcp
}
read_xdc C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.srcs/constrs_1/imports/new/Constraints.xdc
set_property used_in_implementation false [get_files C:/Users/Eric/Documents/Xilinx/ECE2120_Final_Project_Image_Edge_Detection/Synthesizable_Project_Code/UART_RX/UART_RX.srcs/constrs_1/imports/new/Constraints.xdc]

set_param ips.enableIPCacheLiteLoad 0
close [open __synthesis_is_running__ w]

synth_design -top top_level_test -part xc7a100tcsg324-1


# disable binary constraint mode for synth run checkpoints
set_param constraints.enableBinaryConstraints false
write_checkpoint -force -noxdef top_level_test.dcp
create_report "synth_1_synth_report_utilization_0" "report_utilization -file top_level_test_utilization_synth.rpt -pb top_level_test_utilization_synth.pb"
file delete __synthesis_is_running__
close [open __synthesis_is_complete__ w]
