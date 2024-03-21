/mob/living/simple_animal/construct
	hud_type = /datum/hud/construct

/datum/hud/construct/FinalizeInstantiation()
	var/constructtype

	if(istype(mymob, /mob/living/simple_animal/construct/armoured) || istype(mymob, /mob/living/simple_animal/construct/behemoth))
		constructtype = "juggernaut"
	else if(istype(mymob, /mob/living/simple_animal/construct/builder))
		constructtype = "artificer"
	else if(istype(mymob, /mob/living/simple_animal/construct/wraith))
		constructtype = "wraith"
	else if(istype(mymob, /mob/living/simple_animal/construct/harvester))
		constructtype = "harvester"

	if(!constructtype)
		return

	infodisplay = list()
	static_inventory = list()

	mymob.pullin = new /atom/movable/screen()
	mymob.pullin.icon = 'icons/hud/mob/screen_construct.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.SetName("pull")
	mymob.pullin.screen_loc = ui_construct_pull
	static_inventory += mymob.pullin

	mymob.fire = new /atom/movable/screen()
	mymob.fire.icon = 'icons/hud/mob/screen_construct.dmi'
	mymob.fire.icon_state = "fire0"
	mymob.fire.SetName("fire")
	mymob.fire.screen_loc = ui_construct_fire
	infodisplay += mymob.fire

	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/hud/mob/screen_construct.dmi'
	mymob.healths.icon_state = "[constructtype]_health0"
	mymob.healths.SetName("health")
	mymob.healths.screen_loc = ui_construct_health
	infodisplay += mymob.healths

	mymob.purged = new /atom/movable/screen()
	mymob.purged.icon = 'icons/hud/mob/screen_construct.dmi'
	mymob.purged.icon_state = "purge0"
	mymob.purged.SetName("purged")
	mymob.purged.screen_loc = ui_construct_purge
	infodisplay += mymob.purged

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.icon = 'icons/hud/mob/screen_construct.dmi'
	mymob.zone_sel.ClearOverlays()
	mymob.zone_sel.AddOverlays(image('icons/hud/common/screen_zone_sel.dmi', "[mymob.zone_sel.selecting]"))
	static_inventory += mymob.zone_sel
