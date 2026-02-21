//Generalized Fire Proc.
/atom/proc/flamer_fire_act()
	return


//////////////////////////////////////////////////////////////////////////////////////////////////
//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "fire"
	desc = "Damn it, Hot!"
	anchored = TRUE
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "real_fire"
	var/ligth_color = "#ed9200"
	layer = BELOW_OBJ_LAYER
	var/firelevel = 24 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 6 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.

/obj/flamer_fire/Initialize(mapload, fire_lvl, burn_lvl, fire_stacks = 0, fire_damage = 0)
	. = ..(mapload)

	if(fire_lvl)
		firelevel = fire_lvl
	if(burn_lvl)
		burnlevel = burn_lvl
	if(fire_stacks || fire_damage)
		for(var/mob/living/C in get_turf(src))
			C.flamer_fire_crossed(fire_stacks)
			if(C.IgniteMob())
				C.visible_message(SPAN_DANGER("[C] bursts into flames!"))

	set_next_think(world.time)

/obj/flamer_fire/Crossed(mob/living/M) //Only way to get it to reliable do it when you walk into it.
	if(istype(M))
		M.flamer_fire_crossed(burnlevel, firelevel)

// when you pass the turf with fire, obviously
/mob/living/proc/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	var/burn_damage = burnlevel
	adjust_fire_stacks(rand(1, burn_damage))
	if(!on_fire)
		IgniteMob()

/obj/flamer_fire/proc/updateicon()
	var/light_intensity = 3
	switch(firelevel)
		if(1 to 9)
			light_intensity = 2
		if(10 to 25)
			light_intensity = 4
		if(25 to INFINITY) //Change luminosity based on the fire's intensity
			light_intensity = 6
	set_light(0.7, 0.1, light_intensity, 2, light_color)

/obj/flamer_fire/think()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T) || istype(T, /turf/space)) //Is it a valid turf?
		qdel(src)
		return

	updateicon()

	if(!firelevel)
		qdel(src)
		return

	T.flamer_fire_act(burnlevel, firelevel, T)

	var/j = 0
	for(var/i in T)
		if(++j >= 11)
			break
		var/atom/A = i
		if(QDELETED(A)) //The destruction by fire of one atom may destroy others in the same turf.
			continue
		A.flamer_fire_act(burnlevel, firelevel, T)

	firelevel -= 2 //reduce the intensity by 2 per tick
	set_next_think(world.time + 1 SECOND)

/mob/living/simple_animal/flamer_fire_crossed(burnlevel)
	var/burn_damage = burnlevel*2.7 //kil dam spiders!!!!!!!!
	adjustFireLoss(rand(burn_damage*0.8, burn_damage*1.5))
	return

/mob/living/simple_animal/flamer_fire_act(burnlevel)
	var/burn_damage = burnlevel*2.3 //kil spiders that don't walking!11!1
	adjustFireLoss(rand(burn_damage*0.8, burn_damage*1.5))
	return

/obj/effect/vine/flamer_fire_act()
	die_off() //perfectly working if vines aren't broken
	return
