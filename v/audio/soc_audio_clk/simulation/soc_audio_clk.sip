set_global_assignment -entity "soc_audio_clk" -library "lib_soc_audio_clk" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "soc_audio_clk" -library "lib_soc_audio_clk" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "soc_audio_clk" -library "lib_soc_audio_clk" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_soc_audio_clk" -name SPD_FILE [file join $::quartus(sip_path) "../soc_audio_clk.spd"]
set_global_assignment -library "lib_soc_audio_clk" -name MISC_FILE [file join $::quartus(sip_path) "../../soc_audio_clk.qsys"]

set_global_assignment -library "lib_soc_audio_clk" -name MISC_FILE [file join $::quartus(sip_path) "soc_audio_clk.v"]
set_global_assignment -library "lib_soc_audio_clk" -name MISC_FILE [file join $::quartus(sip_path) "submodules/soc_audio_clk_audio_pll_0.v"]
set_global_assignment -library "lib_soc_audio_clk" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_avalon_reset_from_locked_signal.v"]
set_global_assignment -library "lib_soc_audio_clk" -name MISC_FILE [file join $::quartus(sip_path) "submodules/soc_audio_clk_audio_pll_0_audio_pll.vo"]
