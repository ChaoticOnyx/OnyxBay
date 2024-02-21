
/datum/changeling_power
	var/name = "Power"
	var/desc = "Get the Power!"
	var/text_activate = "We use some power."

	var/icon = 'icons/hud/screen_spells.dmi'
	var/icon_state = "ling_open"

	var/chems_drain = 0 // Chemicals drain while active
	var/power_processing = FALSE
	var/active = FALSE

	var/required_chems = 0 // Chemicals required to use the ability
	var/required_dna = 0   // DNA required to use the ability
	var/max_genome_damage = 100 // Can't use the ability if genome damage is higher than this
	var/max_stat = CONSCIOUS // In what state we can use the ability
	var/allow_stasis = FALSE // Whether we can use the ability while in stasis
	var/allow_lesser = FALSE // Can we use this ability while not in a human form?

	var/mob/my_mob = null
	var/datum/changeling/changeling

/datum/changeling_power/New(mob/_M)
	..()
	if(!_M?.mind?.changeling)
		qdel(src) // Something's terribly wrong, aborting.
		return
	my_mob = _M
	changeling = _M.mind.changeling
	changeling.available_powers.Add(src)
	update()

/datum/changeling_power/Destroy()
	deactivate()
	my_mob?.ability_master.remove_ability(my_mob.ability_master.get_ability_by_changeling_power(src))
	changeling?.available_powers.Remove(src)

	my_mob = null
	changeling = null
	return ..()

/datum/changeling_power/proc/update()
	if(!my_mob.ability_master.get_ability_by_changeling_power(src))
		my_mob.ability_master.add_changeling_power(src)
	update_required_chems()
	update_recursive_enhancement()

/datum/changeling_power/proc/update_screen_button()
	var/atom/movable/screen/ability/changeling_power/CP = my_mob.ability_master.get_ability_by_changeling_power(src)
	CP?.update_icon()

/datum/changeling_power/proc/check_incapacitated(_max_stat, _allow_stasis)
	if(!_max_stat)
		_max_stat = max_stat
	if(!_allow_stasis)
		_allow_stasis = allow_stasis
	return changeling.is_incapacitated(_max_stat, _allow_stasis)

/datum/changeling_power/proc/is_usable(no_message = FALSE)
	. = FALSE

	if(!my_mob?.mind)
		return

	if(!my_mob.mind.changeling)
		to_world_log("[my_mob] has the changeling verb ([src]) but is not a changeling.")
		return

	if(!changeling)
		to_world_log("[my_mob] has the changeling verb ([src]), but it's missing a changeling reference.")
		return

	if(!allow_lesser && !ishuman(my_mob))
		if(!no_message)
			to_chat(my_mob, SPAN("changeling", "Our current body is incapable of doing this."))
		return

	if(changeling.is_incapacitated(max_stat, allow_stasis, no_message)) // Using this instead of check_incapacitated for less overhead.
		return

	if(changeling.absorbed_dna.len < required_dna)
		if(!no_message)
			to_chat(my_mob, SPAN("changeling", "We require at least <b>[required_dna]</b> samples of compatible DNA."))
		return

	if(changeling.chem_charges < required_chems)
		if(!no_message)
			to_chat(my_mob, SPAN("changeling", "We require at least <b>[required_chems]</b> units of chemicals to do that!"))
		return

	if(changeling.genome_damage > max_genome_damage)
		if(!no_message)
			to_chat(my_mob, SPAN("changeling", "Our genomes are still reassembling. We need time to recover first."))
		return

	return TRUE

/datum/changeling_power/proc/use_chems(amount)
	if(!amount)
		amount = required_chems
	changeling.chem_charges -= amount // Intentionally allowing it to drop beyond 0 in some edge cases with delayed abilities.

/datum/changeling_power/proc/use()
	activate()
	return

/datum/changeling_power/proc/activate()
	if(!is_usable())
		return FALSE
	active = TRUE
	return TRUE

/datum/changeling_power/proc/deactivate()
	active = FALSE
	return TRUE

/datum/changeling_power/proc/update_required_chems()
	return

/datum/changeling_power/proc/update_recursive_enhancement()
	return changeling.recursive_enhancement

// Passive powers
/datum/changeling_power/passive
	name = "Passive Power"
	power_processing = FALSE

/datum/changeling_power/passive/update()
	..()
	activate()

/datum/changeling_power/passive/activate()
	if(power_processing)
		set_next_think(world.time) // We just start thinking straight away.

/datum/changeling_power/passive/deactivate()
	if(power_processing)
		set_next_think(0) // We just start thinking straight away.


// Toggle-able powers
/datum/changeling_power/toggled
	name = "Toggled Power"
	power_processing = TRUE
	var/text_deactivate = "We stop using some power."
	var/text_nochems = "We stop using some power because we run out of chemicals."

/datum/changeling_power/toggled/use()
	active ? deactivate(FALSE) : activate()

/datum/changeling_power/toggled/activate()
	. = ..()
	if(!.)
		return
	to_chat(my_mob, SPAN("changeling", text_activate))
	if(power_processing)
		set_next_think(world.time)
	update_screen_button()

/datum/changeling_power/toggled/deactivate(no_message = TRUE)
	. = ..()
	if(!.)
		return
	if(!no_message)
		to_chat(my_mob, SPAN("changeling", text_deactivate))
	if(power_processing)
		set_next_think(0)
	update_screen_button()

/datum/changeling_power/toggled/think()
	if(check_incapacitated())
		deactivate()
		return FALSE
	if(chems_drain)
		use_chems(chems_drain)
		if(changeling.chem_charges <= 0)
			if(my_mob)
				to_chat(my_mob, SPAN("changeling", text_nochems))
				deactivate()
				update_screen_button()
				return FALSE
	set_next_think(world.time + 1 SECOND)
	return TRUE


// Powers relied on spawning items
/datum/changeling_power/item
	name = "Item Power"
	var/power_item_type

/datum/changeling_power/item/proc/create_item(item_type, loud = TRUE)
	if(!is_usable())
		return FALSE

	if(!ishuman(my_mob))
		return FALSE

	var/mob/living/carbon/human/H = my_mob

	if(H.l_hand && H.r_hand)
		to_chat(H, SPAN("changeling", "Our hands are full."))
		return FALSE

	var/obj/item/I = new item_type(H)
	H.pick_or_drop(I)

	use_chems(required_chems)
	if(loud)
		playsound(H, 'sound/effects/blob/blobattack.ogg', 30, 1)

	return TRUE


// Stings and stuff
/datum/changeling_power/toggled/sting
	name = "Sting Power"
	power_processing = FALSE

/datum/changeling_power/toggled/sting/New()
	..()
	text_activate = "We prepare [name]."
	text_deactivate = "We unprepare [name]."

/datum/changeling_power/toggled/sting/update_required_chems()
	if(changeling.boost_sting_range)
		required_chems = initial(required_chems) + 20
	else
		required_chems = initial(required_chems)
	update_screen_button()

/datum/changeling_power/toggled/sting/activate()
	changeling.deactivate_stings()
	var/datum/click_handler/changeling/sting/C = my_mob.PushClickHandler(/datum/click_handler/changeling/sting)
	if(!istype(C))
		return
	C.sting = src
	to_chat(my_mob, SPAN("changeling", text_activate))
	active = TRUE
	update_screen_button()

/datum/changeling_power/toggled/sting/deactivate(no_message = TRUE)
	active = FALSE
	var/datum/click_handler/changeling/sting/C = my_mob.GetClickHandler()
	if(istype(C) && C.sting == src)
		my_mob.PopClickHandler()
	if(!no_message)
		to_chat(my_mob, SPAN("changeling", text_deactivate))
	update_screen_button()

/datum/changeling_power/toggled/sting/proc/can_reach(mob/M)
	if(M.loc == my_mob.loc)
		return TRUE // target and my_mob are in the same thing
	if(!isturf(my_mob.loc) || !isturf(M.loc))
		to_chat(my_mob, SPAN("changeling", "We cannot reach \the [M] with a sting!"))
		return FALSE // One is inside, the other is outside something.
	var/sting_range = changeling.boost_sting_range ? 2 : 1
	// Maximum queued turfs set to 25; I don't *think* anything raises sting_range above 2, but if it does the 25 may need raising
	if(!AStar(my_mob.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, max_nodes = 25, max_node_depth = sting_range)) // If we can't find a path, fail
		to_chat(my_mob, SPAN("changeling", "We cannot find a path to sting \the [M] by!"))
		return FALSE
	return TRUE

/datum/changeling_power/toggled/sting/proc/sting_target(mob/living/carbon/human/target, loud = FALSE)
	if(!target)
		return

	if(!is_usable())
		return

	if(!can_reach(target))
		return

	// Thing thing is a temporary work around. TODO: We should definitely implement zone selecting for simple animals.
	var/obj/item/organ/external/target_limb
	if(my_mob.zone_sel)
		target_limb = target.get_organ(my_mob.zone_sel.selecting)
		if(!target_limb)
			to_chat(my_mob, SPAN("changeling", "[target] is missing the limb we are targeting."))
			return
	else if(!target.has_any_exposed_bodyparts())
		to_chat(my_mob, SPAN("changeling", "[target] doesn't seem to have any exposed bodyparts for us to sting."))
		return

	deactivate()
	use_chems(required_chems)

	if(loud)
		my_mob.visible_message(SPAN("danger", "[my_mob] fires an organic shard into [target]!"))
	else
		to_chat(my_mob, SPAN("changeling", "We stealthily sting [target] with a [name]."))

	if(target_limb)
		for(var/obj/item/clothing/clothes in list(target.head, target.wear_mask, target.wear_suit, target.w_uniform, target.gloves, target.shoes))
			if(istype(clothes) && (clothes.body_parts_covered & target_limb.body_part) && (clothes.item_flags & ITEM_FLAG_THICKMATERIAL))
				to_chat(my_mob, SPAN("changeling", "[target]'s armor has protected them."))
				return //thick clothes will protect from the sting

	if(target.isSynthetic() || (target_limb && BP_IS_ROBOTIC(target_limb)))
		return

	if(!target.mind || !target.mind.changeling)	//T will be affected by the sting
		if(target_limb?.can_feel_pain())
			target.flash_pain(75)
			to_chat(target, SPAN("danger", "Your [target_limb.name] hurts."))
		return TRUE
	return
