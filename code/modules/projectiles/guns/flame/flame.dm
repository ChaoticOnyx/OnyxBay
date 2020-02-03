//Generalized Fire Proc.
/atom/proc/flamer_fire_act()
	return


//////////////////////////////////////////////////////////////////////////////////////////////////
//Create a flame sprite object. Doesn't work like regular fire, ie. does not affect atmos or heat
/obj/flamer_fire
	name = "fire"
	desc = "Ouch!"
	anchored = TRUE
	mouse_opacity = 0
	icon = 'icons/effects/fire.dmi'
	icon_state = "3"
	var/ligth_color = "#ed9200"
	layer = BELOW_OBJ_LAYER
	var/firelevel = 12 //Tracks how much "fire" there is. Basically the timer of how long the fire burns
	var/burnlevel = 10 //Tracks how HOT the fire is. This is basically the heat level of the fire and determines the temperature.

/obj/flamer_fire/Initialize(mapload, fire_lvl, burn_lvl, fire_stacks = 0, fire_damage = 0)
	. = ..()

	if(fire_lvl)
		firelevel = fire_lvl
	if(burn_lvl)
		burnlevel = burn_lvl
	if(fire_stacks || fire_damage)
		for(var/mob/living/C in get_turf(src))
			C.flamer_fire_act(fire_stacks)
			if(C.IgniteMob())
				C.visible_message("<span class='danger'>[C] bursts into flames!</span>")

	START_PROCESSING(SSobj, src)

/obj/flamer_fire/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/flamer_fire/Crossed(mob/living/M) //Only way to get it to reliable do it when you walk into it.
	if(istype(M))
		M.flamer_fire_crossed(burnlevel, firelevel)


// override this proc to give different walking-over-fire effects
/mob/living/proc/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	adjust_fire_stacks(burnlevel) //Make it possible to light them on fire later.
	if (prob(firelevel + 2*fire_stacks)) //the more soaked in fire you are, the likelier to be ignited
		IgniteMob()
	to_chat(src, "<span class='danger'>You are burned!</span>")

/mob/living/carbon/human/flamer_fire_crossed(burnlevel, firelevel, fire_mod = 1)
	if(istype(wear_suit, /obj/item/clothing/suit))
		return
	. = ..()

/obj/flamer_fire/proc/updateicon()
	var/light_intensity = 3
	switch(firelevel)
		if(1 to 9)
			light_intensity = 2
		if(10 to 25)
			light_intensity = 4
		if(25 to INFINITY) //Change luminosity based on the fire's intensity
			light_intensity = 6
	set_light(light_intensity, null, light_color)

/obj/flamer_fire/Process()
	var/turf/T = loc
	firelevel = max(0, firelevel)
	if(!istype(T)) //Is it a valid turf?
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
	return

// override this proc to give different idling-on-fire effects
/mob/living/flamer_fire_act(burnlevel, firelevel, turf/T)
	adjust_fire_stacks(burnlevel) //If i stand in the fire i deserve all of this. Also Napalm stacks quickly.
	T.hotspot_expose((T20C*2) + 380, 500)
	if(prob(firelevel))
		IgniteMob()
	to_chat(src, "<span class='warning'>You are burned!</span>")
