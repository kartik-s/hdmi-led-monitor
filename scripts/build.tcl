set origin_dir [file dirname [file normalize [info script]]]
open_project "$origin_dir/../build/hdmi_led_display/hdmi_led_display.xpr"
reset_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 2
wait_on_run impl_1
if { [get_property PROGRESS [get_runs impl_1]] ne "100%" } {
    error "Implementation failed; see build/hdmi_led_display/hdmi_led_display.runs/impl_1/runme.log"
}
