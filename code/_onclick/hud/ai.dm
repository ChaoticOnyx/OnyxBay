var/atom/movable/screen/ai

/mob/living/silicon/ai
	hud_type = /datum/hud/ai

/datum/hud/ai/FinalizeInstantiation()

	static_inventory = list()

	var/atom/movable/screen/using

//AI core

	using = new /atom/movable/screen()
	using.SetName("AI core")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	static_inventory += using

//AI Core Display

	using = new /atom/movable/screen()
	using.SetName("Set AI Core Display")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "set_ai_core_display"
	using.screen_loc = ui_ai_core_display
	static_inventory += using

//AI Status

	using = new /atom/movable/screen()
	using.SetName("AI Status")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "ai_status"
	using.screen_loc = ui_ai_status
	static_inventory += using

//Change Hologram

	using = new /atom/movable/screen()
	using.SetName("Change Hologram")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "change_hologram"
	using.screen_loc = ui_ai_change_hologram
	static_inventory += using

//Camera list

	using = new /atom/movable/screen()
	using.SetName("Show Camera List")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	static_inventory += using

//Track

	using = new /atom/movable/screen()
	using.SetName("Track With Camera")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	static_inventory += using


//Camera light

	using = new /atom/movable/screen()
	using.SetName("Toggle Camera Light")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	static_inventory += using

//Crew Manifest


	using = new /atom/movable/screen()
	using.SetName("Crew Manifest")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	static_inventory += using

//Announcement

	using = new /atom/movable/screen()
	using.SetName("Make Announcement")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	static_inventory += using

//Shuttle

	using = new /atom/movable/screen()
	using.SetName("Call Emergency Shuttle")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	static_inventory += using

//Laws

	using = new /atom/movable/screen()
	using.SetName("State Laws")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	static_inventory += using

//Medical/Security sensors

	using = new /atom/movable/screen()
	using.SetName("Sensor Augmentation")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_ai_sensor
	static_inventory += using

//Take Image

	using = new /atom/movable/screen()
	using.SetName("Take Image")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	static_inventory += using

//View Images

	using = new /atom/movable/screen()
	using.SetName("View Images")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	static_inventory += using

//Delete Image

	using = new /atom/movable/screen()
	using.SetName("Delete Image")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "del_images"
	using.screen_loc = ui_ai_del_picture
	static_inventory += using

//Store Camera Location

	using = new /atom/movable/screen()
	using.SetName("Store Camera Location")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "store_camera_location"
	using.screen_loc = ui_ai_scl
	static_inventory += using

//Goto Camera Location

	using = new /atom/movable/screen()
	using.SetName("Goto Camera Location")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "goto_camera_location"
	using.screen_loc = ui_ai_gcl
	static_inventory += using

//Delete Camera Location

	using = new /atom/movable/screen()
	using.SetName("Delete Camera Location")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "delete_camera_location"
	using.screen_loc = ui_ai_dcl
	static_inventory += using

//PDA Ringer

	using = new /atom/movable/screen()
	using.SetName("Toggle Ringer")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "pda_ringer"
	using.screen_loc = ui_ai_pda_ringer
	static_inventory += using

//PDA Send Message

	using = new /atom/movable/screen()
	using.SetName("Send Message")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	static_inventory += using

//PDA Log

	using = new /atom/movable/screen()
	using.SetName("Show Message Log")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "pda_log"
	using.screen_loc = ui_ai_pda_log
	static_inventory += using

//PDA Toggle Sender/Receiver

	using = new /atom/movable/screen()
	using.SetName("Toggle Sender/Receiver")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_sr
	static_inventory += using

//Multitool Mode

	using = new /atom/movable/screen()
	using.SetName("Toggle Multitool Mode")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "toggle_multitool_mode"
	using.screen_loc = ui_ai_multitool
	static_inventory += using

//Shutdown

	using = new /atom/movable/screen()
	using.SetName("Toggle Shutdown")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "shutdown"
	using.screen_loc = ui_ai_shutdown
	static_inventory += using

//Power Override

	using = new /atom/movable/screen()
	using.SetName("Toggle Power Override")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "override"
	using.screen_loc = ui_ai_override
	static_inventory += using

//Radio Settings

	using = new /atom/movable/screen()
	using.SetName("Radio Settings")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_ai.dmi'
	using.icon_state = "radio_settings"
	using.screen_loc = ui_ai_radio
	static_inventory += using
