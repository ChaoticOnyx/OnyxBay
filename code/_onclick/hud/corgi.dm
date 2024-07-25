/mob/living/simple_animal/corgi
	hud_type = /datum/hud/corgi

/datum/hud/corgi/FinalizeInstantiation()
	infodisplay = list()
	static_inventory = list()

	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/hud/mob/screen_corgi.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_health
	infodisplay += mymob.healths

	mymob.oxygen = new /atom/movable/screen()
	mymob.oxygen.icon = 'icons/hud/mob/screen_corgi.dmi'
	mymob.oxygen.icon_state = "oxy0"
	mymob.oxygen.name = "oxygen"
	mymob.oxygen.screen_loc = ui_oxygen
	infodisplay += mymob.oxygen

	mymob.toxin = new /atom/movable/screen()
	mymob.toxin.icon = 'icons/hud/mob/screen_corgi.dmi'
	mymob.toxin.icon_state = "tox0"
	mymob.toxin.name = "toxin"
	mymob.toxin.screen_loc = ui_toxin
	infodisplay += mymob.toxin
