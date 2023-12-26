/obj/screen/maptext
	screen_loc = "NORTH:14,WEST"
	plane = HUD_PLANE
	layer = HUD_BASE_LAYER
	maptext_height = 32
	maptext_width = 480
	var/last_word = null

/client/MouseEntered(object, location)
	..()
	if(!maptext_toggle)
		return
	if(istype(object, /atom) && !istype(object, /obj/screen/splash))
		var/atom/A = object
		if(mob.hud_used)
			var/obj_name = A.name
			if(mob.hud_used.maptext.last_word == obj_name)
				return
			obj_name = uppertext(obj_name)
			if(mob.mind.assigned_role == "Clown")
				mob.hud_used.maptext.maptext = "<font size=4 style=\"font: 'Comic Sans MS'; text-align: center; text-shadow: 1px 1px 2px black;\">[obj_name]</font>"
			else
				mob.hud_used.maptext.maptext = "<font size=4 style=\"font: 'Small Fonts'; text-align: center; text-shadow: 1px 1px 2px black;\">[obj_name]</font>"
			mob.hud_used.maptext.last_word = obj_name

/client
	var/maptext_toggle = TRUE
