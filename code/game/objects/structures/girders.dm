/obj/structure/girder
	icon_state = "girder"
	anchored = 1
	density = 1
	layer = BELOW_OBJ_LAYER
	w_class = ITEM_SIZE_NO_CONTAINER
	pull_slowdown = PULL_SLOWDOWN_HEAVY
	var/state = 0
	var/max_health = 150
	var/health = 150
	var/cover = 60 //how much cover the girder provides against projectiles.
	var/material/reinf_material
	var/reinforcing = 0

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = 0

/obj/structure/girder/examine(mob/user)
	. = ..()
	if(health <= 0.4 * max_health)
		. += "\n[SPAN("warning", "It's heavily damaged!")]"
	else if(health < max_health)
		. += "\n[SPAN("warning", "It's showing signs of damage.")]"

/obj/structure/girder/attack_generic(mob/user, damage, attack_message = "smashes apart", wallbreaker)
	if(!damage || !wallbreaker)
		return 0
	attack_animation(user)
	visible_message(SPAN("danger", "[user] [attack_message] the [src]!"))
	spawn(1) dismantle()
	return 1

/obj/structure/girder/bullet_act(obj/item/projectile/Proj)
	//Girders only provide partial cover. There's a chance that the projectiles will just pass through. (unless you are trying to shoot the girder)
	if(Proj.original != src && !prob(cover))
		return PROJECTILE_CONTINUE //pass through

	var/damage = Proj.get_structure_damage()
	if(!damage)
		return

	if(!istype(Proj, /obj/item/projectile/beam))
		damage *= 0.5 //non beams do reduced damage

	health -= damage
	..()
	if(health <= 0)
		dismantle()

	return

/obj/structure/girder/proc/reset_girder()
	anchored = 1
	cover = initial(cover)
	health = min(health,max_health)
	state = 0
	icon_state = initial(icon_state)
	reinforcing = 0
	if(reinf_material)
		reinforce_girder()

/obj/structure/girder/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W) && state == 0)
		if(anchored && !reinf_material)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user.visible_message(SPAN("notice", "[user] is disassembling \the [src]..."), \
					   	         SPAN("notice", "Now disassembling \the [src]..."))
			if(do_after(user,40,src))
				if(!src) return
				user.visible_message(SPAN("notice", "[user] dissasembled \the [src]!"), \
					        	     SPAN("notice", "You dissasembled \the [src]!"))
				dismantle()
		else if(!anchored)
			playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
			user.visible_message(SPAN("notice", "[user] is securing \the [src]..."), \
					   	         SPAN("notice", "Now securing \the [src]..."))
			if(do_after(user, 40,src))
				if(!src) return
				user.visible_message(SPAN("notice", "[user] secured \the [src]!"), \
					   	         	 SPAN("notice", "You secured \the [src]!"))
				reset_girder()

	else if((istype(W, /obj/item/weapon/gun/energy/plasmacutter) || (istype(W, /obj/item/weapon/melee/energy) && W.force > 20)) && user.a_intent == I_HELP)
		user.visible_message(SPAN("notice", "[user] is slicing apart \the [src]..."), \
				             SPAN("notice", "Now slicing apart \the [src]..."))
		if(do_after(user,30,src))
			if(!src) return
			user.visible_message(SPAN("notice", "[user] slices apart \the [src]!"), \
				             	 SPAN("notice", "You slice apart \the [src]!"))
			dismantle()

	else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		user.visible_message(SPAN("notice", "[user] drills through \the [src]!"), \
				             SPAN("notice", "You drill through \the [src]!"))
		dismantle()

	else if(isScrewdriver(W))
		if(state == 2)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			to_chat(user, SPAN("notice", "Now unsecuring support struts of \the [src]..."))
			if(do_after(user, 40, src))
				if(!src) return
				to_chat(user, SPAN("notice", "You unsecured support struts of \the [src]!"))
				state = 1
		else if(anchored && !reinf_material)
			playsound(src.loc, 'sound/items/Screwdriver.ogg', 100, 1)
			reinforcing = !reinforcing
			to_chat(user, SPAN("notice", "\The [src] can now be [reinforcing? "reinforced" : "constructed"]!"))

	else if(isWirecutter(W) && state == 1)
		playsound(src.loc, 'sound/items/Wirecutter.ogg', 100, 1)
		to_chat(user, SPAN("notice", "Now removing the support struts from \the [src]..."))
		if(do_after(user, 40, src))
			if(!src) return
			to_chat(user, SPAN("notice", "You removed the support struts from \the [src]!"))
			if(reinf_material)
				reinf_material.place_dismantled_product(get_turf(src))
				reinf_material = null

			reset_girder()

	else if(isCrowbar(W) && state == 0 && anchored)
		playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
		user.visible_message(SPAN("notice", "[user] is dislodging \the [src]..."), \
				             SPAN("notice", "Now dislodging \the [src]..."))
		if(do_after(user, 40, src))
			if(!src) return
			user.visible_message(SPAN("notice", "[user] dislodged \the [src]."), \
				                 SPAN("notice", "You dislodged \the [src]."))
			icon_state = "displaced"
			anchored = 0
			cover = 40

	else if(istype(W,/obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.isOn())
			return
		if(health == max_health)
			to_chat(user, SPAN("notice", "\The [src] is undamaged."))
			return
		if(!WT.remove_fuel(0,user))
			to_chat(user, SPAN("notice", "You need more welding fuel to complete this task."))
			return
		user.visible_message(SPAN("notice", "[user] is repairing the damage to \the [src]..."), \
				             SPAN("notice", "You start repairing the damage to \the [src]..."))
		playsound(src, 'sound/items/Welder.ogg', 100, 1)
		if(!do_after(user, max(5, health / 3), src) && WT && WT.isOn())
			return
		health = max_health
		user.visible_message(SPAN("notice", "[user] repairs \the [src]."), \
				             SPAN("notice", "You repair \the [src]."))

	else if(istype(W, /obj/item/stack/material))
		if(reinforcing && !reinf_material)
			if(!reinforce_with_material(W, user))
				return
		else
			if(!construct_wall(W, user))
				return

	else
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		obj_attack_sound(W)
		shake_animation(stime = 2)
		if(W.force >= 15)
			user.visible_message(SPAN("danger", "\The [src] has been [pick(W.attack_verb)] with [W] by [user]!"))
			health -= W.force
			if(health <= 0)
				visible_message(SPAN("danger", "\The [src] falls apart!"))
				dismantle()
		else
			user.visible_message(SPAN("danger", "[user] hits \the [src] with \the [W], but it bounces off!"))

/obj/structure/girder/proc/construct_wall(obj/item/stack/material/S, mob/user)
	if(S.get_amount() < 2)
		to_chat(user, SPAN("notice", "There isn't enough material here to construct a wall."))
		return 0

	var/material/M = name_to_material[S.default_type]
	if(!istype(M))
		return 0

	var/wall_fake
	add_hiddenprint(usr)

	if(M.integrity < 50)
		to_chat(user, SPAN("notice", "This material is too soft for use in wall construction."))
		return 0

	user.visible_message(SPAN("notice", "[user] is adding some planting to \the [src]..."), \
				    	 SPAN("notice", "You begin adding the plating..."))

	if(!do_after(user,40,src) || !S.use(2))
		return 1 //once we've gotten this far don't call parent attackby()

	if(anchored)
		user.visible_message(SPAN("notice", "[user] added some planting to \the [src]!"), \
				        	 SPAN("notice", "You added the plating!"))
	else
		user.visible_message(SPAN("notice", "[user] added some planting to \the [src]!"), \
				        	 SPAN("notice", "You create a false wall! Push on it to open or close the passage.")) // Some stealthy stuff
		wall_fake = 1

	var/turf/Tsrc = get_turf(src)
	Tsrc.ChangeTurf(/turf/simulated/wall)
	var/turf/simulated/wall/T = get_turf(src)
	T.set_material(M, reinf_material)
	if(wall_fake)
		T.can_open = 1
	T.add_hiddenprint(usr)
	qdel(src)
	return 1

/obj/structure/girder/proc/reinforce_with_material(obj/item/stack/material/S, mob/user) //if the verb is removed this can be renamed.
	if(reinf_material)
		to_chat(user, SPAN("notice", "\The [src] is already reinforced."))
		return 0

	if(S.get_amount() < 2)
		to_chat(user, SPAN("notice", "There isn't enough material here to reinforce the girder."))
		return 0

	var/material/M = name_to_material[S.default_type]
	if(!istype(M) || M.integrity < 50)
		to_chat(user, SPAN("notice", "You cannot reinforce \the [src] with that; it is too soft."))
		return 0

	user.visible_message(SPAN("notice", "[user] is reinforcing \the [src]..."), \
				    	 SPAN("notice", "Now reinforcing \the [src]..."))
	if (!do_after(user, 40,src) || !S.use(2))
		return 1 //don't call parent attackby() past this point
	user.visible_message(SPAN("notice", "[user] added reinforcement to \the [src]!"), \
				    	 SPAN("notice", "You added reinforcement to \the [src]!"))

	reinf_material = M
	reinforce_girder()
	return 1

/obj/structure/girder/proc/reinforce_girder()
	cover = 80
	max_health = 300
	health = 300
	state = 2
	icon_state = "reinforced"
	reinforcing = 0

/obj/structure/girder/proc/dismantle()
	new /obj/item/stack/gassembly(get_turf(src))
	qdel(src)

/obj/structure/girder/attack_hand(mob/user as mob)
	if(MUTATION_HULK in user.mutations)
		user.visible_message(SPAN("danger", "[user] smashes \the [src] apart!"), \
							 SPAN("danger", "You smash \the [src] apart!"))
		dismantle()
		return
	return ..()


/obj/structure/girder/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(30))
				dismantle()
			return
		if(3.0)
			if (prob(5))
				dismantle()
			return
		else
	return

/obj/structure/girder/cult
	name = "strange girder"
	desc = "This one is strange, looks like it is made from stone"
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	max_health = 250
	health = 250
	cover = 70

/obj/structure/girder/cult/dismantle()
	qdel(src)

/obj/structure/girder/cult/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		user.visible_message(SPAN("notice", "[user] is disassembling \the [src]..."), \
				   	         SPAN("notice", "Now disassembling \the [src]!"))
		if(do_after(user,40,src))
			if(!src) return
			user.visible_message(SPAN("notice", "[user] dissasembled \the [src]!"), \
				        	     SPAN("notice", "You dissasembled \the [src]!"))
			dismantle()

	else if((istype(W, /obj/item/weapon/gun/energy/plasmacutter) || (istype(W, /obj/item/weapon/melee/energy) && W.force > 20)) && user.a_intent == I_HELP)
		user.visible_message(SPAN("notice", "[user] is slicing apart \the [src]..."), \
				             SPAN("notice", "Now slicing apart \the [src]..."))
		if(do_after(user,30,src))
			if(!src) return
			user.visible_message(SPAN("notice", "[user] slices apart \the [src]!"), \
				             	 SPAN("notice", "You slice apart \the [src]!"))
		dismantle()

	else if(istype(W, /obj/item/weapon/pickaxe/diamonddrill))
		user.visible_message(SPAN("notice", "[user] drills through \the [src]!"), \
				             SPAN("notice", "You drill through \the [src]!"))
		new /obj/item/remains/human(get_turf(src))
		dismantle()
