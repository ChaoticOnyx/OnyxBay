/obj/structure/barricade
	name = "barricade"
	desc = "This space is blocked off by a barricade."

	icon = 'icons/obj/structures.dmi'
	icon_state = "barricade"

	anchored = TRUE
	density = TRUE

	atom_flags = ATOM_FLAG_CLIMBABLE
	turf_height_offset = 3 // It looks so shitty I dunno what offset to use. 3 will go for now I guess.

	var/health = 100
	var/maxhealth = 100
	var/material/material


/obj/structure/barricade/Initialize(material_name)
	. = ..()

	if(!material_name)
		material_name = MATERIAL_WOOD

	var/material = get_material_by_name(material_name)
	if(!material)
		return INITIALIZE_HINT_QDEL

	_apply_material(material)


/obj/structure/barricade/proc/_apply_material(material/new_material)
	material = new_material

	name = "[material.display_name] barricade"
	desc = "This space is blocked off by a barricade made of [material.display_name]."

	color = material.icon_colour

	maxhealth = material.integrity
	health = maxhealth


/obj/structure/barricade/Destroy()
	material = null
	return ..()


/obj/structure/barricade/get_material()
	return material


/obj/structure/barricade/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.species?.can_shred(H))
			shake_animation(stime = 1)
			H.do_attack_animation(src)
			H.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
			visible_message(SPAN("warning", "\The [user] slashes at [src]!"))
			playsound(src.loc, 'sound/weapons/slash.ogg', 100, 1)
			take_damage(rand(7.5, 12.5))
			return
	return ..()

/obj/structure/barricade/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/stack))
		var/obj/item/stack/D = W
		if(D.get_material_name() != material.name)
			return //hitting things with the wrong type of stack usually doesn't produce messages, and probably doesn't need to.
		if(health < maxhealth)
			if(D.get_amount() < 1)
				to_chat(user, SPAN("warning", "You need one sheet of [material.display_name] to repair \the [src]."))
				return
			visible_message(SPAN("notice", "[user] begins to repair \the [src]."))
			if(do_after(user, 20, src) && health < maxhealth)
				if(D.use(1))
					health = maxhealth
					visible_message(SPAN("notice", "[user] repairs \the [src]."))
				return
		return
	else
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		switch(W.damtype)
			if("fire")
				take_damage(W.force)
				return
			if("brute")
				user.do_attack_animation(src)
				visible_message(SPAN_DANGER("\The [user] attacks \the [src] with \the [W]!"))
				playsound(src, 'sound/effects/metalhit2.ogg', rand(50, 75), 1, -1)
				take_damage(W.force*0.75)
				return
		..()

/obj/structure/barricade/proc/take_damage(damage)
	health -= damage
	if(health <= 0)
		visible_message(SPAN("danger", "\The [src] is smashed apart!"))
		dismantle()

/obj/structure/barricade/proc/dismantle()
	material.place_dismantled_product(get_turf(src))
	qdel(src)
	return

/obj/structure/barricade/ex_act(severity)
	switch(severity)
		if(1.0)
			visible_message("<span class='danger'>\The [src] is blown apart!</span>")
			qdel(src)
			return
		if(2.0)
			src.health -= 25
			if (src.health <= 0)
				visible_message("<span class='danger'>\The [src] is blown apart!</span>")
				dismantle()
			return

/obj/structure/barricade/CanPass(atom/movable/mover, turf/target) //So bullets will fly over and stuff.
	if(istype(mover) && mover.pass_flags & PASS_FLAG_TABLE)
		return TRUE
	return FALSE
