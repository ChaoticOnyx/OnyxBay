/mob/living/carbon/New()
	//setup reagent holders
	bloodstr = new /datum/reagents/metabolism(120, src, CHEM_BLOOD)
	touching = new /datum/reagents/metabolism(1000, src, CHEM_TOUCH)
	reagents = bloodstr

	if (!default_language && species_language)
		default_language = all_languages[species_language]
	..()

/mob/living/carbon/Destroy()
	QDEL_NULL(touching)
	bloodstr = null // We don't qdel(bloodstr) because it's the same as qdel(reagents)
	QDEL_NULL_LIST(internal_organs)
	QDEL_NULL_LIST(stomach_contents)
	QDEL_NULL_LIST(hallucinations)
	if(loc)
		for(var/mob/M in contents)
			M.dropInto(loc)
	else
		for(var/mob/M in contents)
			qdel(M)
	return ..()

/mob/living/carbon/rejuvenate(ignore_prosthetic_prefs = FALSE)
	bloodstr.clear_reagents()
	touching.clear_reagents()
	var/datum/reagents/R = get_ingested_reagents()
	if(istype(R))
		R.clear_reagents()
	nutrition = 400
	..()

/mob/living/carbon/Move(NewLoc, direct)
	. = ..()
	if(!.)
		return

	if(nutrition && stat != 2)
		nutrition -= min(nutrition, DEFAULT_HUNGER_FACTOR/10)
		if(m_intent == M_RUN)
			nutrition -= min(nutrition, DEFAULT_HUNGER_FACTOR/10)
	if((MUTATION_FAT in mutations) && m_intent == M_RUN && bodytemperature <= 360)
		bodytemperature += 2

	// Moving around increases germ_level faster
	if(germ_level < GERM_LEVEL_MOVE_CAP && prob(8))
		germ_level++

/mob/living/carbon/relaymove(mob/living/user, direction)
	if((user in src.stomach_contents) && istype(user))
		THROTTLE_SHARED(cooldown, 50, user.last_special)
		if(!cooldown)
			return

		src.visible_message("<span class='danger'>You hear something rumbling inside [src]'s stomach...</span>")
		var/obj/item/I = user.get_active_hand()
		var/dmg = (I && I.force) ? rand(round(I.force / 4), I.force) : rand(1, 6) //give a chance to creatures without hands
		if(istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			var/obj/item/organ/external/organ = H.get_organ(BP_GROIN)
			if (istype(organ))
				organ.take_external_damage(dmg, 0)
			H.updatehealth()
		else
			take_organ_damage(dmg)
		user.visible_message("<span class='danger'>[user] attacks [src]'s stomach wall!</span>")
		playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)

		if(prob(getBruteLoss() - 50))
			for(var/atom/movable/A in stomach_contents)
				A.loc = loc
				stomach_contents.Remove(A)
			gib()

/mob/living/carbon/gib()
	for(var/mob/M in src)
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.loc = src.loc
		for(var/mob/N in viewers(src, null))
			if(N.client)
				N.show_message(text("<span class='danger'>[M] bursts out of [src]!</span>"), 2)
	..()

/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon)) return
	if (ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/organ/external/temp = H.organs_by_name[BP_R_HAND]
		if (H.hand)
			temp = H.organs_by_name[BP_L_HAND]
		if(temp && !temp.is_usable())
			to_chat(H, "<span class='warning'>You can't use your [temp.name]</span>")
			return

	return

/mob/living/carbon/electrocute_act(shock_damage, obj/source, siemens_coeff = 1.0, def_zone = null)
	if(status_flags & GODMODE)
		return 0

	shock_damage = apply_shock(shock_damage, def_zone, siemens_coeff)

	if(!shock_damage)
		return 0

	stun_effect_act(agony_amount=shock_damage, def_zone=def_zone)

	playsound(loc, SFX_SPARK, 50, 1, -1)
	if (shock_damage > 15)
		src.visible_message(
			"<span class='warning'>[src] was electrocuted[source ? " by the [source]" : ""]!</span>", \
			"<span class='danger'>You feel a powerful shock course through your body!</span>", \
			"<span class='warning'>You hear a heavy electrical crack.</span>" \
		)
	else
		src.visible_message(
			"<span class='warning'>[src] was shocked[source ? " by the [source]" : ""].</span>", \
			"<span class='warning'>You feel a shock course through your body.</span>", \
			"<span class='warning'>You hear a zapping sound.</span>" \
		)

	switch(shock_damage)
		if(16 to 20)
			Stun(2)
		if(21 to 25)
			Weaken(2)
		if(26 to 25)
			Weaken(5)
		if(31 to INFINITY)
			Weaken(10) //This should work for now, more is really silly and makes you lay there forever

	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(5, 1, loc)
	s.start()

	return shock_damage

/mob/living/carbon/proc/apply_shock(shock_damage, def_zone, siemens_coeff = 1.0)
	shock_damage *= siemens_coeff
	if(shock_damage < 0.5)
		return 0
	if(shock_damage < 1)
		shock_damage = 1
	apply_damage(shock_damage, BURN, def_zone, used_weapon="Electrocution")

	return(shock_damage)

/mob/proc/swap_hand()
	return

/mob/living/carbon/swap_hand()
	src.hand = !( src.hand )
	if(hud_used.l_hand_hud_object && hud_used.r_hand_hud_object)
		if(hand)	//This being 1 means the left hand is in use
			hud_used.l_hand_hud_object.icon_state = "l_hand_active"
			hud_used.r_hand_hud_object.icon_state = "r_hand_inactive"
		else
			hud_used.l_hand_hud_object.icon_state = "l_hand_inactive"
			hud_used.r_hand_hud_object.icon_state = "r_hand_active"
	return

/mob/living/carbon/proc/activate_hand(selhand) //0 or "r" or "right" for right hand; 1 or "l" or "left" for left hand.

	if(istext(selhand))
		selhand = lowertext(selhand)

		if(selhand == "right" || selhand == "r")
			selhand = 0
		if(selhand == "left" || selhand == "l")
			selhand = 1

	if(selhand != src.hand)
		swap_hand()

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if(!is_asystole())
		if (on_fire)
			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			if (M.on_fire)
				M.visible_message(SPAN("warning", "[M] tries to pat out [src]'s flames, but to no avail!"),
								  SPAN("warning", "You try to pat out [src]'s flames, but to no avail! Put yourself out first!"))
			else
				M.visible_message(SPAN("warning", "[M] tries to pat out [src]'s flames!"),
								  SPAN("warning", "You try to pat out [src]'s flames! Hot!"))
				if(do_mob(M, src, 15))
					src.fire_stacks -= 0.5
					if (prob(10) && (M.fire_stacks <= 0))
						M.fire_stacks += 1
					M.IgniteMob()
					if (M.on_fire)
						M.visible_message(SPAN("danger", "The fire spreads from [src] to [M]!"),
										  SPAN("danger", "The fire spreads to you as well!"))
					else
						src.fire_stacks -= 0.5 //Less effective than stop, drop, and roll - also accounting for the fact that it takes half as long.
						if (src.fire_stacks <= 0)
							M.visible_message(SPAN("warning", "[M] successfully pats out [src]'s flames."),
											  SPAN("warning", "You successfully pat out [src]'s flames."))
							src.ExtinguishMob()
							src.fire_stacks = 0
		else
			var/t_him = "it"
			if (src.gender == MALE)
				t_him = "him"
			else if (src.gender == FEMALE)
				t_him = "her"
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)

			var/show_ssd
			var/mob/living/carbon/human/H = src
			if(istype(H)) show_ssd = H.species.show_ssd
			if(show_ssd && !client && !teleop)
				M.visible_message(SPAN("notice", "[M] shakes [src] trying to wake [t_him] up!"), \
								  SPAN("notice", "You shake [src], but they do not respond... Maybe they have S.S.D?"))
			else if(lying || src.sleeping)
				src.sleeping = max(0,src.sleeping-5)
				if(src.sleeping == 0)
					src.resting = 0
				M.visible_message(SPAN("notice", "[M] shakes [src] trying to wake [t_him] up!"), \
								  SPAN("notice", "You shake [src] trying to wake [t_him] up!"))
			else
				var/mob/living/carbon/human/hugger = M
				if(istype(hugger))
					hugger.species.hug(hugger,src)
				else
					M.visible_message(SPAN("notice", "[M] hugs [src] to make [t_him] feel better!"), \
									  SPAN("notice", "You hug [src] to make [t_him] feel better!"))
				if(M.fire_stacks >= (src.fire_stacks + 3))
					src.fire_stacks += 1
					M.fire_stacks -= 1
				if(M.on_fire)
					src.IgniteMob()

			if(stat != DEAD)
				AdjustParalysis(-3)
				AdjustStunned(-3)
				AdjustWeakened(-3)

			playsound(src.loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

/mob/living/carbon/proc/eyecheck()
	return 0

/mob/living/carbon/proc/get_ear_protection()
	return 0

/mob/living/carbon/flash_eyes(intensity = FLASH_PROTECTION_MODERATE, override_blindness_check = FALSE, affect_silicon = FALSE, visual = FALSE, type = /obj/screen/fullscreen/flash, effect_duration = 25)
	if(eyecheck() < intensity || override_blindness_check)
		return ..()

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0)
			H.gloves.germ_level = 0
		else
			if(!isnull(H.bloody_hands))
				H.bloody_hands = null
				H.update_inv_gloves(0)
			H.germ_level = 0
	update_icons()	//apply the now updated overlays to the mob

//Throwing stuff
/mob/proc/throw_item(atom/target)
	return

/mob/living/carbon/throw_item(atom/target)
	throw_mode_off()
	if(!isturf(loc))
		return
	if(stat || !target)
		return
	if(target.type == /obj/screen)
		return

	var/atom/movable/item = get_active_hand()

	if(!item)
		return

	if(!istype(item, /obj/item))
		return

	var/obj/item/I = item
	var/is_grab = istype(item, /obj/item/grab)
	if(!I.canremove && !is_grab)
		return

	var/throw_range = item.throw_range
	var/itemsize
	if(is_grab)
		var/obj/item/grab/G = item
		item = G.throw_held() // throw the person instead of the grab
		if(ismob(item))
			var/mob/M = item

			//limit throw range by relative mob size
			next_move = world.time + 15
			throw_range = round(M.throw_range * min(mob_size / M.mob_size, 1))
			itemsize = round(M.mob_size / 4)
			var/turf/start_T = get_turf(loc) //Get the start and target tile for the descriptors
			var/turf/end_T = get_turf(target)
			if(start_T && end_T && usr == src)
				var/start_T_descriptor = "<font color='#6b5d00'>[start_T] \[[start_T.x],[start_T.y],[start_T.z]\] ([start_T.loc])</font>"
				var/end_T_descriptor = "<font color='#6b4400'>[start_T] \[[end_T.x],[end_T.y],[end_T.z]\] ([end_T.loc])</font>"
				admin_attack_log(usr, M, "Threw the victim from [start_T_descriptor] to [end_T_descriptor].", "Was from [start_T_descriptor] to [end_T_descriptor].", "threw, from [start_T_descriptor] to [end_T_descriptor], ")
	else
		itemsize = I.w_class

	drop_from_inventory(item)
	if(!item || !isturf(item.loc))
		return

	//actually throw it!
	visible_message(SPAN("warning", "[src] has thrown [item]."), range = min(itemsize * 2, world.view))
	var/sfx_loudness = min(100, 5 + (itemsize * 5))
	playsound(src, SFX_THROWING, sfx_loudness, 1)

	if(!lastarea)
		lastarea = get_area(loc)
	if((istype(loc, /turf/space)) || (lastarea.has_gravity == FALSE))
		inertia_dir = get_dir(target, src)
		step(src, inertia_dir) // they're in space, move em in the opposite direction

	item.throw_at(target, throw_range, item.throw_speed, src)

/mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	var/temp_inc = max(min(BODYTEMP_HEATING_MAX*(1-get_heat_protection()), exposed_temperature - bodytemperature), 0)
	bodytemperature += temp_inc

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(buckled && ! istype(buckled, /obj/structure/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if (handcuffed)
		return 1
	return

/mob/living/carbon/u_equip(obj/item/W as obj)
	if(!W)	return 0

	else if (W == handcuffed)
		handcuffed = null
		update_inv_handcuffed()
		if(buckled && buckled.buckle_require_restraints)
			buckled.unbuckle_mob()
	else
	 ..()

	return

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		to_chat(usr, SPAN("warning", "You are already sleeping."))
		return
	if(alert(src,"You sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		usr.sleeping = 20 //Short nap

/mob/living/carbon/Bump(atom/movable/AM, yes)
	if(now_pushing || !yes)
		return
	..()
	if(istype(AM, /mob/living/carbon) && prob(10))
		src.spread_disease_to(AM, "Contact")

/mob/living/carbon/slip(slipped_on, stun_duration = 8)
	var/area/A = get_area(src)
	if(!A.has_gravity())
		return 0
	if(buckled)
		return 0
	if(weakened)
		return 0
	stop_pulling()
	to_chat(src, SPAN("warning", "You slipped on [slipped_on]!"))
	playsound(src.loc, 'sound/misc/slip.ogg', 50, 1, -3)
	Stun(Ceiling(stun_duration/3)) // At least 1 second of actual stun
	Weaken(stun_duration)
	return 1

/mob/living/carbon/slip_on_obj(obj/slipped_on, stun_duration = 8, slip_dist = 0)
	if(!slipped_on)
		return 0
	if(slip("the [slipped_on.name]", stun_duration))
		if(slip_dist && !slipped_on.anchored)
			slipped_on.throw_at(get_edge_target_turf(slipped_on, turn(dir, 180)), slip_dist, 1)
			for(var/i = 1 to slip_dist)
				step(src, dir)
			sleep(1)
		return 1
	return 0

/mob/living/carbon/proc/add_chemical_effect(effect, magnitude = 1)
	if(effect in chem_effects)
		chem_effects[effect] += magnitude
	else
		chem_effects[effect] = magnitude

/mob/living/carbon/proc/add_up_to_chemical_effect(effect, magnitude = 1)
	if(effect in chem_effects)
		chem_effects[effect] = max(magnitude, chem_effects[effect])
	else
		chem_effects[effect] = magnitude

/mob/living/carbon/get_default_language()
	if(default_language && can_speak(default_language))
		return default_language

	if(!species)
		return null
	return species.default_language ? all_languages[species.default_language] : null

/mob/living/carbon/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<meta charset=\"utf-8\">
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand  : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A> [((istype(wear_mask, /obj/item/clothing/mask) && istype(back, /obj/item/weapon/tank) && !( internal )) ? text(" <A href='?src=\ref[];item=internal'>Set Internal</A>", src) : "")]
	<BR>[(internal ? text("<A href='?src=\ref[src];item=internal'>Remove Internal</A>") : "")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];refresh=1'>Refresh</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	show_browser(user, dat, text("window=mob[];size=325x500", name))
	onclose(user, "mob[name]")
	return

/**
 *  Return FALSE if victim can't be devoured, DEVOUR_FAST if they can be devoured quickly, DEVOUR_SLOW for slow devour
 */
/mob/living/carbon/proc/can_devour(atom/movable/victim)
	if((MUTATION_FAT in mutations) && issmall(victim))
		return DEVOUR_FAST

	return FALSE

/mob/living/carbon/onDropInto(atom/movable/AM)
	for(var/e in stomach_contents)
		var/atom/movable/stomach_content = e
		if(stomach_content.contains(AM))
			if(can_devour(AM))
				stomach_contents += AM
				return null
			src.visible_message(SPAN("warning", "\The [src] regurgitates \the [AM]!"))
			return loc
	return ..()

/mob/living/carbon/update_living_sight()
	..()
	if(seeDarkness)
		set_see_in_dark(8)
		set_see_invisible(SEE_INVISIBLE_NOLIGHTING)
		if(species)
			sight = species.get_vision_flags(src)

/mob/living/carbon/proc/should_have_organ(organ_check)
	return 0

/mob/living/carbon/proc/has_limb(limb_check)
	return 0

/mob/living/carbon/proc/can_feel_pain(check_organ)
	if(isSynthetic())
		return 0
	return !(species && species.species_flags & SPECIES_FLAG_NO_PAIN)

/mob/living/carbon/proc/get_adjusted_metabolism(metabolism)
	return metabolism

/mob/living/carbon/proc/need_breathe()
	return

/mob/living/carbon/check_has_mouth()
	// carbon mobs have mouths by default
	// behavior of this proc for humans is overridden in human.dm
	return 1

/mob/living/carbon/proc/check_mouth_coverage()
	// carbon mobs do not have blocked mouths by default
	// overridden in human_defense.dm
	return null

/mob/living/carbon/proc/SetStasis(factor, source = "misc")
	if((species && (species.species_flags & SPECIES_FLAG_NO_SCAN)) || isSynthetic())
		return
	stasis_sources[source] = factor

/mob/living/carbon/proc/InStasis()
	if(!stasis_value)
		return FALSE
	return life_tick % stasis_value

// call only once per run of life
/mob/living/carbon/proc/UpdateStasis()
	stasis_value = 0
	if((species && (species.species_flags & SPECIES_FLAG_NO_SCAN)) || isSynthetic())
		return
	for(var/source in stasis_sources)
		stasis_value += stasis_sources[source]
	stasis_sources.Cut()

/mob/living/carbon/has_chem_effect(chem, threshold)
	return (chem_effects[chem] >= threshold)

/mob/living/carbon/get_sex()
	return species.get_sex(src)

/mob/living/carbon/proc/get_ingested_reagents()
	return reagents

/mob/living/carbon/rejuvenate(ignore_prosthetic_prefs = FALSE)
	. = ..()

	// And restore all organs...
	for(var/obj/item/organ/O in organs)
		O.rejuvenate(ignore_prosthetic_prefs)

/mob/living/carbon/proc/set_species()
	return FALSE
