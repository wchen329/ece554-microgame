set_global_assignment -entity "soc_audio_cfg" -library "lib_soc_audio_cfg" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "soc_audio_cfg" -library "lib_soc_audio_cfg" -name IP_TOOL_VERSION "18.1"
set_global_assignment -entity "soc_audio_cfg" -library "lib_soc_audio_cfg" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_soc_audio_cfg" -name SPD_FILE [file join $::quartus(sip_path) "../soc_audio_cfg.spd"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "../../soc_audio_cfg.qsys"]

set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "soc_audio_cfg.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_serial_bus_controller.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_slow_clock_generator.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_dc2.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_d5m.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_lcm.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ltm.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_de1_soc.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_de2_115.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_de2i_150.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_de10_standard.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_audio.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_adv7180.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/altera_up_av_config_auto_init_ob_adv7181.v"]
set_global_assignment -library "lib_soc_audio_cfg" -name MISC_FILE [file join $::quartus(sip_path) "submodules/soc_audio_cfg_audio_and_video_config_0.v"]
