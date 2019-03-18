set_global_assignment -entity "clk_buffer" -library "lib_clk_buffer" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "clk_buffer" -library "lib_clk_buffer" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "clk_buffer" -library "lib_clk_buffer" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_clk_buffer" -name SPD_FILE [file join $::quartus(sip_path) "clk_buffer.spd"]
set_global_assignment -library "lib_clk_buffer" -name MISC_FILE [file join $::quartus(sip_path) "../clk_buffer.qsys"]

set_global_assignment -library "lib_clk_buffer" -name MISC_FILE [file join $::quartus(sip_path) "sim/clk_buffer.vhd"]
set_global_assignment -library "lib_clk_buffer" -name MISC_FILE [file join $::quartus(sip_path) "altclkctrl_181/sim/clk_buffer_altclkctrl_181_4ev4gqi.vhd"]
