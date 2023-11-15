/mob/observer/ghost
	hud_type = /datum/hud/ghost

/datum/hud/ghost/FinalizeInstantiation(ui_style = 'icons/hud/style/midnight.dmi', ui_color = "#ffffff", ui_alpha = 255)
	static_inventory = list()

	var/obj/screen/using

	using = new /obj/screen/ghost/ghost_arena_menu()
	static_inventory += using

	using = new /obj/screen/ghost/spawners_menu()
	static_inventory += using

	using = new /obj/screen/ghost/follow()
	static_inventory += using

	using = new /obj/screen/ghost/reenter_corpse()
	static_inventory += using

	using = new /obj/screen/ghost/teleport()
	static_inventory += using

	using = new /obj/screen/ghost/move_up()
	static_inventory += using

	using = new /obj/screen/ghost/move_down()
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

/obj/screen/ghost
	icon_state = "template"
	/// The `icon_state` used during button overlay generation.
	var/ghost_icon_state

/obj/screen/ghost/New(loc, ...)
	update_icon()
	return ..()

/obj/screen/ghost/on_update_icon()
	ClearOverlays()
	LAZYADD(overlays, image('icons/hud/screen_ghost.dmi', icon_state = ghost_icon_state))

/obj/screen/ghost/ghost_arena_menu
	name = "Ghost arena menu"
	ghost_icon_state = "spawners"
	screen_loc = ui_ghost_arena_menu

/obj/screen/ghost/ghost_arena_menu/Click(location, control, params)
	var/mob/observer/ghost/G = usr
	G.open_ghost_arena_menu()

/obj/screen/ghost/spawners_menu
	name = "Spawners Menu"
	ghost_icon_state = "spawners"
	screen_loc = ui_ghost_spawners_menu

/obj/screen/ghost/spawners_menu/Click(location, control, params)
	var/mob/observer/ghost/G = usr
	G.open_spawners_menu()

/obj/screen/ghost/follow
	name = "Follow"
	ghost_icon_state = "follow"
	screen_loc = ui_ghost_follow

/obj/screen/ghost/follow/Click(location, control, params)
	var/mob/observer/ghost/G = usr
	G.follow()

/obj/screen/ghost/reenter_corpse
	name = "Re-enter corpse"
	ghost_icon_state = "reenter_corpse"
	screen_loc = ui_ghost_reenter_corpse

/obj/screen/ghost/reenter_corpse/Click(location, control, params)
	var/mob/observer/ghost/G = usr
	G.reenter_corpse()

/obj/screen/ghost/teleport
	name = "Teleport"
	ghost_icon_state = "teleport"
	screen_loc = ui_ghost_teleport

/obj/screen/ghost/teleport/Click(location, control, params)
	var/mob/observer/ghost/G = usr
	G.dead_tele()

/obj/screen/ghost/move_up
	name = "Move Up"
	ghost_icon_state = "move_up"
	screen_loc = ui_ghost_move_up

/obj/screen/ghost/move_up/Click(location, control, params)
	var/mob/M = usr
	M.up()

/obj/screen/ghost/move_down
	name = "Move Down"
	ghost_icon_state = "move_down"
	screen_loc = ui_ghost_move_down

/obj/screen/ghost/move_down/Click(location, control, params)
	var/mob/M = usr
	M.down()
