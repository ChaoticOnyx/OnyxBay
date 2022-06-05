/mob/living/carbon/alien/diona
	hud_type = /datum/hud/diona

/datum/hud/diona/FinalizeInstantiation()

	adding = list()
	other = list()

	var/obj/screen/using

	using = new /obj/screen()
	using.SetName("mov_intent")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_diona.dmi'
	using.icon_state = (mymob.m_intent == M_RUN ? "running" : "walking")
	using.screen_loc = ui_acti
	adding += using
	move_intent = using

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_diona.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.SetName("health")
	mymob.healths.screen_loc = ui_alien_health

	mymob.fire = new /obj/screen()
	mymob.fire.icon = 'icons/mob/screen1_diona.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.SetName("fire")
	mymob.fire.screen_loc = ui_fire

	mymob.client.screen = list()
	mymob.client.screen += list(mymob.healths, mymob.fire)
	mymob.client.screen += adding + other
