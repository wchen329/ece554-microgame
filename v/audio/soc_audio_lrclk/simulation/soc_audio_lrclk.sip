set_global_assignment -entity "soc_audio_lrclk" -library "lib_soc_audio_lrclk" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "soc_audio_lrclk" -library "lib_soc_audio_lrclk" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "soc_audio_lrclk" -library "lib_soc_audio_lrclk" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_soc_audio_lrclk" -name SPD_FILE [file join $::quartus(sip_path) "../soc_audio_lrclk.spd"]
set_global_assignment -library "lib_soc_audio_lrclk" -name MISC_FILE [file join $::quartus(sip_path) "../../soc_audio_lrclk.qsys"]

set_global_assignment -library "lib_soc_audio_lrclk" -name MISC_FILE [file join $::quartus(sip_path) "soc_audio_lrclk.v"]
set_global_assignment -library "lib_soc_audio_lrclk" -name MISC_FILE [file join $::quartus(sip_path) "submodules/soc_audio_lrclk_intel_up_avalon_audio_clks_0.v"]
