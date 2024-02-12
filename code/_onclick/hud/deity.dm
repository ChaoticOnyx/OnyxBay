/mob/living/deity
	hud_type = /datum/hud/deity

/datum/hud/deity/FinalizeInstantiation(ui_style = 'icons/hud/style/midnight.dmi')
	static_inventory = list()

	var/atom/movable/screen/intent/deity/intent = new()
	intent.sync_to_mob(mymob)
	action_intent = intent
	static_inventory += action_intent

/atom/movable/screen/intent/deity
	var/list/desc_screens = list()
	screen_loc = "EAST-5:122,SOUTH:8"

/atom/movable/screen/intent/deity/New()
	..()
	AddOverlays(image('icons/hud/screen_phenomena.dmi', icon_state = "hud", pixel_x = -138, pixel_y = -1))

/atom/movable/screen/intent/deity/proc/sync_to_mob(mob)
	var/mob/living/deity/D = mob
	for(var/i in 1 to D.control_types.len)
		var/atom/movable/screen/S = new()
		S.SetName(null) //Don't want them to be able to actually right click it.
		S.mouse_opacity = 0
		S.icon_state = "blank"
		desc_screens[D.control_types[i]] = S
		S.maptext_width = 128
		S.screen_loc = screen_loc
		//This sets it up right. Trust me.
		S.maptext_y = 33/2*i - i*i/2 - 10
		D.client.screen += S
		S.maptext_x = -125

	update_text()

/atom/movable/screen/intent/deity/proc/update_text()
	if(!istype(usr, /mob/living/deity))
		return
	var/mob/living/deity/D = usr
	for(var/i in D.control_types)
		var/atom/movable/screen/S = desc_screens[i]
		var/datum/phenomena/P = D.intent_phenomenas[intent][i]
		if(P)
			S.maptext = "<span style='font-size:7pt;font-family:Impact'><font color='#3C3612'>[P.name]</font></span>"
		else
			S.maptext = null

/atom/movable/screen/intent/deity/Click(location, control, params)
	..()
	update_text()
