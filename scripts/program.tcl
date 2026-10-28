set origin_dir [file dirname [file normalize [info script]]]
open_hw_manager
connect_hw_server
open_hw_target
set dev [lindex [get_hw_devices xc7z020*] 0]
set_property PROGRAM.FILE "$origin_dir/../build/hdmi_led_display/hdmi_led_display.runs/impl_1/design_1_wrapper.bit" $dev
program_hw_devices $dev
