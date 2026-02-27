/mob/living/carbon/larva
	bubble_icon = "alien"
	hud_type = /datum/hud/larva

/datum/hud/larva/FinalizeInstantiation()
	infodisplay = list()
	static_inventory = list()

	var/atom/movable/screen/using

	using = new /atom/movable/screen()
	using.SetName("mov_intent")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_larva.dmi'
	using.icon_state = (mymob.m_intent == M_RUN ? "running" : "walking")
	using.screen_loc = ui_acti
	static_inventory += using
	move_intent = using

	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/hud/mob/screen_larva.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.SetName("health")
	mymob.healths.screen_loc = ui_alien_health
	infodisplay += mymob.healths

	mymob.fire = new /atom/movable/screen()
	mymob.fire.icon = 'icons/hud/mob/screen_larva.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.SetName("fire")
	mymob.fire.screen_loc = ui_fire
	infodisplay += mymob.fire
