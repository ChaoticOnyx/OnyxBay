/obj/item/grenade/supermatter
	name = "supermatter grenade"
	icon_state = "banana"
	item_state = "emergency_engi"
	origin_tech = list(TECH_BLUESPACE = 5, TECH_MAGNET = 4, TECH_ENGINEERING = 5)
	arm_sound = 'sound/effects/3.wav'
	var/implode_at

/obj/item/grenade/supermatter/detonate()
	..()
	set_next_think(world.time)
	implode_at = world.time + 10 SECONDS
	update_icon()
	playsound(src, 'sound/effects/weapons/energy/wave.ogg', 100)

/obj/item/grenade/supermatter/update_icon()
	ClearOverlays()
	if(implode_at)
		AddOverlays(image(icon) = 'icons/obj/machines/power/fusion.dmi', icon_state = "emfield_s1")

/obj/item/grenade/supermatter/think()
	if(!isturf(loc))
		if(ismob(loc))
			var/mob/M = loc
			M.drop(src)
		forceMove(get_turf(src))
	playsound(src, 'sound/effects/supermatter.ogg', 100)
	supermatter_pull(src, world.view, STAGE_THREE)
	if(world.time > implode_at)
		explosion(loc, 0, 1, 3, 4)
		qdel(src)
		return

	set_next_think(world.time + 1 SECOND)
