/mob/living/simple_animal/corgi
	hud_type = /datum/hud/corgi

/datum/hud/corgi/FinalizeInstantiation()
	infodisplay = list()
	static_inventory = list()

	mymob.pullin = new /atom/movable/screen()
	mymob.pullin.icon = 'icons/hud/mob/screen_corgi.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_construct_pull
	static_inventory += mymob.pullin

	mymob.fire = new /atom/movable/screen()
	mymob.fire.icon = 'icons/hud/mob/screen_corgi.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.name = "fire"
	mymob.fire.screen_loc = ui_fire
	infodisplay += mymob.fire

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
