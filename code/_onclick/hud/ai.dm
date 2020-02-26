var/obj/screen/ai

/mob/living/silicon/ai
	hud_type = /datum/hud/ai

/datum/hud/ai/FinalizeInstantiation()

	adding = list()
	other = list()

	var/obj/screen/using

//AI core

	using = new /obj/screen()
	using.SetName("AI core")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "ai_core"
	using.screen_loc = ui_ai_core
	adding += using

//AI Core Display

	using = new /obj/screen()
	using.SetName("Set AI Core Display")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "set_ai_core_display"
	using.screen_loc = ui_ai_core_display
	adding += using

//AI Status

	using = new /obj/screen()
	using.SetName("AI Status")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "ai_status"
	using.screen_loc = ui_ai_status
	adding += using

//Change Hologram

	using = new /obj/screen()
	using.SetName("Change Hologram")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "change_hologram"
	using.screen_loc = ui_ai_change_hologram
	adding += using

//Camera list

	using = new /obj/screen()
	using.SetName("Show Camera List")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "camera"
	using.screen_loc = ui_ai_camera_list
	adding += using

//Track

	using = new /obj/screen()
	using.SetName("Track With Camera")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "track"
	using.screen_loc = ui_ai_track_with_camera
	adding += using


//Camera light

	using = new /obj/screen()
	using.SetName("Toggle Camera Light")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "camera_light"
	using.screen_loc = ui_ai_camera_light
	adding += using

//Crew Manifest


	using = new /obj/screen()
	using.SetName("Crew Manifest")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "manifest"
	using.screen_loc = ui_ai_crew_manifest
	adding += using

//Announcement

	using = new /obj/screen()
	using.SetName("Make Announcement")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "announcement"
	using.screen_loc = ui_ai_announcement
	adding += using

//Shuttle

	using = new /obj/screen()
	using.SetName("Call Emergency Shuttle")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "call_shuttle"
	using.screen_loc = ui_ai_shuttle
	adding += using

//Laws

	using = new /obj/screen()
	using.SetName("State Laws")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "state_laws"
	using.screen_loc = ui_ai_state_laws
	adding += using

//Medical/Security sensors

	using = new /obj/screen()
	using.SetName("Sensor Augmentation")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "ai_sensor"
	using.screen_loc = ui_ai_sensor
	adding += using

//Take Image

	using = new /obj/screen()
	using.SetName("Take Image")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "take_picture"
	using.screen_loc = ui_ai_take_picture
	adding += using

//View Images

	using = new /obj/screen()
	using.SetName("View Images")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "view_images"
	using.screen_loc = ui_ai_view_images
	adding += using

//Delete Image

	using = new /obj/screen()
	using.SetName("Delete Image")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "del_images"
	using.screen_loc = ui_ai_del_picture
	adding += using

//Store Camera Location

	using = new /obj/screen()
	using.SetName("Store Camera Location")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "store_camera_location"
	using.screen_loc = ui_ai_scl
	adding += using

//Goto Camera Location

	using = new /obj/screen()
	using.SetName("Goto Camera Location")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "goto_camera_location"
	using.screen_loc = ui_ai_gcl
	adding += using

//Delete Camera Location

	using = new /obj/screen()
	using.SetName("Delete Camera Location")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "delete_camera_location"
	using.screen_loc = ui_ai_dcl
	adding += using

//PDA Ringer

	using = new /obj/screen()
	using.SetName("Toggle Ringer")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "pda_ringer"
	using.screen_loc = ui_ai_pda_ringer
	adding += using

//PDA Send Message

	using = new /obj/screen()
	using.SetName("Send Message")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "pda_send"
	using.screen_loc = ui_ai_pda_send
	adding += using

//PDA Log

	using = new /obj/screen()
	using.SetName("Show Message Log")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "pda_log"
	using.screen_loc = ui_ai_pda_log
	adding += using

//PDA Toggle Sender/Receiver

	using = new /obj/screen()
	using.SetName("Toggle Sender/Receiver")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "pda_receive"
	using.screen_loc = ui_ai_pda_sr
	adding += using

//Multitool Mode

	using = new /obj/screen()
	using.SetName("Toggle Multitool Mode")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "toggle_multitool_mode"
	using.screen_loc = ui_ai_multitool
	adding += using

//Shutdown

	using = new /obj/screen()
	using.SetName("Toggle Shutdown")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "shutdown"
	using.screen_loc = ui_ai_shutdown
	adding += using

//Power Override

	using = new /obj/screen()
	using.SetName("Toggle Power Override")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "override"
	using.screen_loc = ui_ai_override
	adding += using

//Radio Settings

	using = new /obj/screen()
	using.SetName("Radio Settings")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_ai.dmi'
	using.icon_state = "radio_settings"
	using.screen_loc = ui_ai_radio
	adding += using

	mymob.client.screen = list()
	mymob.client.screen += adding + other
