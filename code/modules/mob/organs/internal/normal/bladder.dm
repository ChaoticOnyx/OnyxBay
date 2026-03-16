/obj/item/organ/internal/bladder
	name = "bladder"
	desc = "Water's transitional station on its way between glass and porcelain."
	icon_state = "bladder"
	dead_icon = "bladder"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_BLADDER
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 45
	max_damage = 70
	relative_size = 25
	var/datum/reagents/stored
	var/waste_to_spawn = 0

/obj/item/organ/internal/bladder/Initialize()
	. = ..()
	if(config.health.simulate_digestion)
		stored = new /datum/reagents(HYDRATION_LIMIT, src)

/obj/item/organ/internal/bladder/Destroy()
	QDEL_NULL(stored)
	. = ..()

/obj/item/organ/internal/bladder/robotize()
	..()
	SetName("liquid waste storage")
	icon_state = "bladder-prosthetic"
	dead_icon = "bladder-prosthetic-br"

/obj/item/organ/internal/bladder/proc/get_fullness()
	return stored.total_volume + waste_to_spawn

/obj/item/organ/internal/bladder/proc/rupture()
	if(owner)
		owner.custom_pain("Your feel a burst of sudden, excruciating pain in your groin!", 30)
	// TODO: Abdominal cavity here
	return

/obj/item/organ/internal/bladder/take_internal_damage(amount, silent = FALSE, is_traumatic = FALSE)
	var/oldbroken = is_broken()
	. = ..()
	if(owner && !owner.stat)
		if(!oldbroken && is_broken())
			rupture()

/obj/item/organ/internal/bladder/think()
	..()

	if(!owner)
		return

	if(isundead(owner))
		return

	// Simulation disabled. We still kinda keep track of fullness just for ruptures and abdominal leaks.
	if(!config.health.simulate_digestion)
		waste_to_spawn = max(0, waste_to_spawn - (DEFAULT_THIRST_FACTOR * 2.0))
	// Simulation enabled. Only spawning things once in a while for performance reasons.
	else if(waste_to_spawn >= 2.5)
		stored.add_reagent(/datum/reagent/water, waste_to_spawn * 0.8)
		stored.add_reagent(/datum/reagent/urates, waste_to_spawn * 0.2)
		waste_to_spawn = 0

		// Bladderal bleeding. We have no normal way to empty the bladder if simulate_digestion is off.
		if(is_broken() || (is_bruised() && prob(20)))
			if(!owner.should_have_organ(BP_HEART))
				owner.reagents.trans_to_holder(stored, waste_to_spawn * 0.2)

			if(owner.vessel.get_reagent_amount(/datum/reagent/blood) < waste_to_spawn * 0.2)
				return

			// Make sure virus/etc data is up to date
			var/datum/reagent/blood/our = owner.get_blood(owner.vessel)
			our.sync_to(owner)
			owner.vessel.trans_to_holder(stored, waste_to_spawn * 0.2)

		if(!owner.stat)
			var/fullness = (stored.total_volume / HYDRATION_LIMIT) * 100
			if(fullness >= 100)
				if(prob(50))
					owner.custom_pain("You feel like your bladder is about to burst!", 1)
			else if(fullness >= 85)
				if(prob(10))
					to_chat(owner, SPAN("warning", "Your feel like your bladder is full."))
			else if(fullness >= 70)
				if(prob(3))
					to_chat(owner, SPAN("notice", "You feel like you could visit a restroom."))
