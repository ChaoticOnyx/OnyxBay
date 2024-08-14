/mob/observer/ghost/player
	hud_type = /datum/hud/ghost_player

/datum/hud/ghost_player/FinalizeInstantiation(ui_style = 'icons/hud/style/midnight.dmi', ui_color = "#ffffff", ui_alpha = 255)
	static_inventory = list()

	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/ghost_arena_menu()
	static_inventory += using

	using = new /atom/movable/screen/ghost/spawners_menu()
	static_inventory += using

	using = new /atom/movable/screen/ghost/reenter_corpse()
	static_inventory += using

/datum/hud/ghost/show_hud(hud_style = 0)
	. = ..()
	if(!.)
		return

	if(mymob.get_preference_value("GHOST_SEEHUD") == GLOB.PREF_YES)
		mymob.client.screen |= static_inventory
		mymob?.client?.update_ui()
	else
		mymob.client.screen -= static_inventory
