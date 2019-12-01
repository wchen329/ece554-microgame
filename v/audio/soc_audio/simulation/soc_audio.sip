set_global_assignment -entity "soc_audio" -library "lib_soc_audio" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "soc_audio" -library "lib_soc_audio" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "soc_audio" -library "lib_soc_audio" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_soc_audio" -name SPD_FILE [file join $::quartus(sip_path) "../soc_audio.spd"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "../../soc_audio.qsys"]

set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "soc_audio.v"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_audio_bit_counter.v"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_audio_in_deserializer.v"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_audio_out_serializer.v"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_clock_edge.v"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_sync_fifo.v"]
set_global_assignment -library "lib_soc_audio" -name MISC_FILE [file join $::quartus(sip_path) "submodules/soc_audio_audio_0.v"]
