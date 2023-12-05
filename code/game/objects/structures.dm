/obj/structure
	icon = 'icons/obj/structures.dmi'
	w_class = ITEM_SIZE_NO_CONTAINER
	pull_sound = SFX_PULL_WOOD
	pull_slowdown = PULL_SLOWDOWN_MEDIUM

	var/breakable
	var/parts

	var/height_offset = 0 //used for on_structure_offset mob animation

/obj/structure/Initialize()
	. = ..()
	if(height_offset && isturf(loc))
		var/turf/T = loc
		T.update_turf_height()

/obj/structure/Destroy()
	var/turf/T = get_turf(src)
	if(T)
		if(parts)
			new parts(loc)
		if(height_offset)
			set_height_offset(0)
	return ..()

/obj/structure/attack_hand(mob/user)
	..()
	if(breakable)
		if(MUTATION_HULK in user.mutations)
			user.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ))
			attack_generic(user,1,"smashes")
		else if(istype(user,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			if(H.species.can_shred(user))
				attack_generic(user,1,"slices")
	return ..()

/obj/structure/attack_tk()
	return

/obj/structure/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if(prob(50))
				qdel(src)
				return
		if(3.0)
			return

/obj/structure/blob_act()
	if(prob(50))
		qdel(src)

/obj/structure/attack_generic(mob/user, damage, attack_verb, wallbreaker)
	if(!breakable || !damage || !wallbreaker)
		return 0
	visible_message("<span class='danger'>[user] [attack_verb] the [src] apart!</span>")
	attack_animation(user)
	spawn(1) qdel(src)
	return 1

/obj/structure/proc/set_height_offset(new_val)
	if(height_offset == new_val)
		return
	height_offset = new_val
	var/turf/T = get_turf(src)
	if(T)
		T.update_turf_height()
