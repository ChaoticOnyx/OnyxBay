/obj/structure/rocky
	name = "\improper Rocky"
	desc = "What?"

	icon_state = "rocky"
	icon = 'icons/obj/stationobjs.dmi'

	anchored = TRUE
	density = TRUE
	throwpass = TRUE

	var/max_health = 5000
	var/health = 5000

/obj/structure/rocky/Initialize()
	. = ..()
	update_icon()

/obj/structure/rocky/on_update_icon()
	if(health > max_health * 0.66)
		icon_state = "[initial(icon_state)]-0"
	else if(health > max_health * 0.33)
		icon_state = "[initial(icon_state)]-1"
	else
		icon_state = "[initial(icon_state)]-2"
	return

/obj/structure/rocky/examine(mob/user, infix)
	. = ..()

	if(health < max_health * 0.25)
		. += SPAN("warning", "He's heavily damaged!")
	else if(health < max_health * 0.5)
		. += SPAN("warning", "He's moderately damaged!")
	else if(health < max_health * 0.75)
		. += SPAN("warning", "He's showing signs of damage.")
	return

/obj/structure/rocky/attackby(obj/item/W, mob/user)
	W.set_cooldown()
	user.do_attack_animation(src)
	obj_attack_sound(W)
	shake_animation(stime = 2)
	if(W.force >= 5)
		user.visible_message(SPAN("danger", "\The [src] has been [pick(W.attack_verb)] with [W] by [user]!"))
		take_damage(W.force)
	else
		user.visible_message(SPAN("danger", "[user] hits \the [src] with \the [W], but it bounces off!"))
	return

/obj/structure/rocky/bullet_act(obj/item/projectile/Proj)
	if(Proj.original != src && !prob(50))
		visible_message(SPAN("warning", "[src] dodges \the [Proj]!"))
		return PROJECTILE_CONTINUE //pass through

	var/damage = Proj.get_structure_damage()
	if(!damage)
		return

	take_damage(damage)

	return ..()

/obj/structure/rocky/ex_act(severity)
	switch(severity)
		if(1.0)
			if(prob(50))
				defeated()
			else
				take_damage(max_health * 0.7)
			return
		if(2.0)
			take_damage(max_health * 0.4)
			return
		if(3.0)
			take_damage(max_health * 0.2)
			return
	return

/obj/structure/rocky/proc/take_damage(amt)
	if(!amt)
		return
	health -= amt
	if(health <= 0)
		defeated()
	else
		update_icon()
	return

/obj/structure/rocky/proc/defeated()
	visible_message(SPAN("warning", "[src] seizes up and falls limp, his eyes dead and lifeless..."))
	new /obj/effect/decal/cleanable/generic(loc)
	new /obj/effect/decal/cleanable/dirt(loc)
	new /obj/item/rocky_jr(loc)
	qdel_self()
	return


/obj/item/rocky_jr
	name = "\improper Rocky Junior"
	desc = "He looks happy. And, perhaps, a little murderous."
	icon = 'icons/obj/items.dmi'
	icon_state = "rocky_jr"
	item_state = "immovable_ball"
	force = 12.5
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 2.0
	mod_reach = 0.5
	mod_handy = 0.5
	throwforce = 20.0
	throw_range = 3
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 1)
	attack_verb = list("rocked", "stoned", "smashed", "smacked")
	unacidable = TRUE

/obj/item/rocky_jr/throw_impact(hit_atom, datum/thrownthing/TT)
	..()
	if(isliving(hit_atom) && prob(35))
		var/mob/living/L = hit_atom
		playsound(L.loc, GET_SFX(SFX_BANG), 50, 1, -1)
		L.Weaken(5)
