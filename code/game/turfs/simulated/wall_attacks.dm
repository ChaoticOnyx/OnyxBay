//Interactions
/turf/simulated/wall/proc/toggle_open(mob/user)

	if(can_open == WALL_OPENING)
		return

	if(density)
		can_open = WALL_OPENING
		//flick("[material.icon_base]fwall_opening", src)
		sleep(15)
		set_density(0)
		set_opacity(0)
		blocks_air = ZONE_BLOCKED
		update_icon()
		update_air()
		set_light(0)
		src.blocks_air = 0
		set_opacity(0)
		for(var/turf/simulated/turf in loc)
			SSair.mark_for_update(turf)
	else
		can_open = WALL_OPENING
		//flick("[material.icon_base]fwall_closing", src)
		set_density(1)
		set_opacity(1)
		blocks_air = AIR_BLOCKED
		update_icon()
		update_air()
		sleep(15)
		set_light(0.4, 0.1, 1)
		src.blocks_air = 1
		set_opacity(1)
		shove_everything()
		for(var/turf/simulated/turf in loc)
			SSair.mark_for_update(turf)

	can_open = WALL_CAN_OPEN
	update_icon()

/turf/simulated/wall/proc/update_air()
	if(!SSair)
		return

	for(var/turf/simulated/turf in loc)
		update_thermal(turf)
		SSair.mark_for_update(turf)


/turf/simulated/wall/proc/update_thermal(turf/simulated/source)
	if(istype(source))
		if(density && opacity)
			source.thermal_conductivity = WALL_HEAT_TRANSFER_COEFFICIENT
		else
			source.thermal_conductivity = initial(source.thermal_conductivity)



/turf/simulated/wall/proc/fail_smash(mob/user)
	to_chat(user, SPAN("danger","You smash against \the [src]!"))
	take_damage(rand(25,75))

/turf/simulated/wall/proc/success_smash(mob/user)
	to_chat(user, SPAN("danger","You smash through \the [src]!"))
	user.do_attack_animation(src)
	spawn(1)
		dismantle_wall(1)

/turf/simulated/wall/proc/try_touch(mob/user, rotting)

	if(rotting)
		if(reinf_material)
			to_chat(user, SPAN("danger","\The [reinf_material.display_name] feels porous and crumbly."))
		else
			to_chat(user, SPAN("danger","\The [material.display_name] crumbles under your touch!"))
			dismantle_wall()
			return 1

	if(!can_open)
		if(user.a_intent == I_HURT)
			user.visible_message(SPAN("danger","\The [user] bangs against \the [src]!"),
								 SPAN("danger","You bang against \the [src]!"),
								 "You hear a banging sound.")
			user.do_attack_animation(src)
		else
			to_chat(user, SPAN("notice","You push \the [src], but nothing happens."))
		playsound(src, hitsound, 25, 1)
	else
		to_chat(user, SPAN("notice","You push \the [src] and it retracts."))
		toggle_open(user)
	return 0


/turf/simulated/wall/attack_hand(mob/user)
	add_fingerprint(user)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if((MUTATION_HULK in user.mutations) || (MUTATION_STRONG in user.mutations))
		if (rotting || !prob(material.hardness))
			success_smash(user)
		else
			fail_smash(user)
			return 1

	try_touch(user, rotting)

/turf/simulated/wall/attack_generic(mob/user, damage, attack_message, wallbreaker)
	if(!istype(user))
		return

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/rotting = (locate(/obj/effect/overlay/wallrot) in src)
	if(!damage || !wallbreaker)
		try_touch(user, rotting)
		return

	if(rotting)
		return success_smash(user)

	if(reinf_material)
		if(damage >= max(material.hardness,reinf_material.hardness))
			return success_smash(user)
	else if(wallbreaker == 2 || damage >= material.hardness)
		return success_smash(user)
	return fail_smash(user)

/turf/simulated/wall/attackby(obj/item/W as obj, mob/user as mob)
	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	if (!user.IsAdvancedToolUser())
		to_chat(user, SPAN("warning", FEEDBACK_YOU_LACK_DEXTERITY))
		return

	//get the user's location
	if(!istype(user.loc, /turf))	return	//can't do this stuff whilst inside objects and such

	if(W)
		if(W.get_temperature_as_from_ignitor())
			burn(W.get_temperature_as_from_ignitor())

	if(locate(/obj/effect/overlay/wallrot) in src)
		if(isWelder(W))
			var/obj/item/weldingtool/WT = W
			if(!WT.use_tool(src, user, amount = 1))
				return

			to_chat(user, SPAN("notice","You burn away the fungi with \the [WT]."))
			playsound(src, 'sound/items/Welder.ogg', 10, 1)
			for(var/obj/effect/overlay/wallrot/WR in src)
				qdel(WR)
			return
		else if(!is_sharp(W) && W.force >= 10 || W.force >= 20)
			to_chat(user, SPAN("notice","\The [src] crumbles away under the force of your [W.name]."))
			src.dismantle_wall(1)
			return

	//THERMITE related stuff. Calls src.thermitemelt() which handles melting simulated walls and the relevant effects
	if(thermite)
		if(isWelder(W))
			var/obj/item/weldingtool/WT = W
			if(!WT.use_tool(src, user, amount = 1))
				return

			thermitemelt(user)
			return

		else if(istype(W, /obj/item/gun/energy/plasmacutter))
			thermitemelt(user)
			return

		else if( istype(W, /obj/item/melee/energy/blade) )
			var/obj/item/melee/energy/blade/EB = W

			EB.spark_system.start()
			to_chat(user, SPAN("notice","You slash \the [src] with \the [EB]; the thermite ignites!"))
			playsound(src, SFX_SPARK, 50, 1)
			playsound(src, 'sound/weapons/blade1.ogg', 50, 1)

			thermitemelt(user)
			return

	var/turf/T = user.loc	//get user's location for delay checks

	if(damage && isWelder(W))
		var/obj/item/weldingtool/WT = W
		to_chat(user, SPAN("notice","You start repairing the damage to [src]."))
		if(!WT.use_tool(src, user, delay = max(5, damage / 5), amount = 5))
			return

		if(QDELETED(src) || !user)
			return

		to_chat(user, SPAN("notice","You finish repairing the damage to [src]."))
		take_damage(-damage)
		return

	// Basic dismantling.
	if(isnull(construction_stage) || !reinf_material)

		var/cut_delay = 60 + material.cut_delay
		var/dismantle_verb
		var/dismantle_sound

		if(isWelder(W))
			var/obj/item/weldingtool/WT = W
			to_chat(user, SPAN("notice", "You begin cutting through the outer plating."))

			if(!WT.use_tool(src, user, cut_delay * 0.7, 5))
				return

			if(QDELETED(src) || !user)
				return

			to_chat(user, SPAN("notice","You remove the outer plating."))
			dismantle_wall()
			user.visible_message(SPAN("warning","\The [src] was torn open by [user]!"))
			return

		else if(istype(W,/obj/item/melee/energy/blade))
			dismantle_sound = "spark"
			dismantle_verb = "slicing"
			cut_delay *= 0.5
		else if(istype(W, /obj/item/pickaxe/drill))
			var/obj/item/pickaxe/drill/D = W
			dismantle_verb = D.drill_verb
			dismantle_sound = D.drill_sound
			cut_delay -= D.digspeed

		if(dismantle_verb)

			to_chat(user, SPAN("notice", "You begin [dismantle_verb] through the outer plating."))
			if(dismantle_sound)
				playsound(src, dismantle_sound, 100, 1)

			if(cut_delay<0)
				cut_delay = 0

			if(!do_after(user, cut_delay, src, luck_check_type = LUCK_CHECK_ENG))
				return

			to_chat(user, SPAN("notice","You remove the outer plating."))
			dismantle_wall()
			user.visible_message(SPAN("warning","\The [src] was torn open by [user]!"))
			return

	//Reinforced dismantling.
	else
		switch(construction_stage)
			if(6)
				if(isWirecutter(W))
					playsound(src, 'sound/items/Wirecutter.ogg', 100, 1)
					construction_stage = 5
					new /obj/item/stack/rods( src )
					to_chat(user, SPAN("notice","You cut the outer grille."))
					update_icon()
					return
			if(5)
				if(isScrewdriver(W))
					to_chat(user, SPAN("notice","You begin removing the support lines."))
					playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
					if(!do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG) || !istype(src, /turf/simulated/wall) || construction_stage != 5)
						return
					construction_stage = 4
					update_icon()
					to_chat(user, SPAN("notice", "You remove the support lines."))
					return
				else if( istype(W, /obj/item/stack/rods) )
					var/obj/item/stack/O = W
					if(O.get_amount()>0)
						O.use(1)
						construction_stage = 6
						update_icon()
						to_chat(user, SPAN("notice", "You replace the outer grille."))
						return
			if(4)
				if(isWelder(W))
					var/obj/item/weldingtool/WT = W
					if(!WT.use_tool(src, user, amount = 1))
						return

					to_chat(user, SPAN("notice","You begin slicing through the metal cover."))
					if(!WT.use_tool(src, user, delay = 6 SECONDS, amount = 5) || !istype(src, /turf/simulated/wall) || construction_stage != 4)
						return

					if(QDELETED(src))
						return

					construction_stage = 3
					update_icon()
					to_chat(user, SPAN("notice","You press firmly on the cover, dislodging it."))
					return

				else if (istype(W, /obj/item/gun/energy/plasmacutter))
					to_chat(user, SPAN("notice","You begin slicing through the metal cover."))
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					if(!do_after(user, 60, src, luck_check_type = LUCK_CHECK_ENG) || !istype(src, /turf/simulated/wall) || construction_stage != 4)
						return

					if(QDELETED(src))
						return

					to_chat(user, SPAN("notice","You press firmly on the cover, dislodging it."))
					construction_stage = 3
					update_icon()
					return

			if(3)
				if(isCrowbar(W))
					to_chat(user, SPAN("notice","You struggle to pry off the cover."))
					playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
					if(!do_after(user, 100, src, luck_check_type = LUCK_CHECK_ENG) || !istype(src, /turf/simulated/wall) || construction_stage != 3)
						return
					construction_stage = 2
					update_icon()
					to_chat(user, SPAN("notice","You pry off the cover."))
					return
			if(2)
				if(isWrench(W))
					to_chat(user, SPAN("notice","You start loosening the anchoring bolts which secure the support rods to their frame."))
					playsound(src, 'sound/items/Ratchet.ogg', 100, 1)
					if(!do_after(user, 40, src, luck_check_type = LUCK_CHECK_ENG) || !istype(src, /turf/simulated/wall) || construction_stage != 2)
						return
					construction_stage = 1
					update_icon()
					to_chat(user, SPAN("notice","You remove the bolts anchoring the support rods."))
					return
			if(1)
				if(isWelder(W))
					var/obj/item/weldingtool/WT = W
					to_chat(user, SPAN("notice","You begin slicing through the support rods."))
					if(!WT.use_tool(src, user, delay = 7 SECONDS, amount = 5) || !istype(src, /turf/simulated/wall) || construction_stage != 1)
						return

					if(QDELETED(src))
						return

					construction_stage = 0
					update_icon()
					new /obj/item/stack/rods(src)
					to_chat(user, SPAN("notice","The support rods drop out as you cut them loose from the frame."))
					return

				else if(istype(W, /obj/item/gun/energy/plasmacutter))
					to_chat(user, SPAN("notice","You begin slicing through the support rods."))
					playsound(src, 'sound/items/Welder.ogg', 100, 1)
					if(!do_after(user, 70, src, luck_check_type = LUCK_CHECK_ENG) || !istype(src, /turf/simulated/wall) || construction_stage != 1)
						return

					if(QDELETED(src))
						return

					construction_stage = 0
					update_icon()
					new /obj/item/stack/rods(src)
					to_chat(user, SPAN("notice","The support rods drop out as you cut them loose from the frame."))
					return

			if(0)
				if(isCrowbar(W))
					to_chat(user, SPAN("notice","You struggle to pry off the outer sheath."))
					playsound(src, 'sound/items/Crowbar.ogg', 100, 1)
					if(!do_after(user, 100, src, luck_check_type = LUCK_CHECK_ENG) || !istype(src, /turf/simulated/wall) || !user || !W || !T )	return
					if(user.loc == T && user.get_active_hand() == W )
						to_chat(user, SPAN("notice","You pry off the outer sheath."))
						dismantle_wall(TRUE)
					return

	if(istype(W,/obj/item/frame))
		var/obj/item/frame/F = W
		F.try_build(src)
		return

	else if(!istype(W,/obj/item/construction/rcd) && !istype(W, /obj/item/reagent_containers))
		if(!W.force)
			return attack_hand(user)
		var/dam_threshhold = material.integrity
		if(reinf_material)
			dam_threshhold = ceil(max(dam_threshhold,reinf_material.integrity)/2)
		user.setClickCooldown(W.update_attack_cooldown())
		user.do_attack_animation(src)
		var/dam_prob = min(100, material.hardness*1.5)
		if(dam_prob < 100 && W.force > (dam_threshhold/10))
			visible_message(SPAN("danger","\The [user] attacks \the [src] with \the [W]!"))
			playsound(src, 'sound/effects/metalhit2.ogg', rand(50,75), 1, -1)
			take_damage(W.force)
		else
			visible_message(SPAN("danger","\The [user] attacks \the [src] with \the [W], but it bounces off!"))
			playsound(src, 'sound/effects/metalhit2.ogg', 20, 1, -1)
		return
