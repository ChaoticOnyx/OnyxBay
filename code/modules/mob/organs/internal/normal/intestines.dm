/obj/item/organ/internal/intestines
	name = "intestines"
	desc = "A few meters of sausage casing."
	gender = PLURAL
	icon_state = "intestines"
	dead_icon = "intestines"
	w_class = ITEM_SIZE_NORMAL
	organ_tag = BP_INTESTINES
	parent_organ = BP_GROIN
	min_bruised_damage = 25
	min_broken_damage = 60
	max_damage = 90
	relative_size = 60
	var/datum/reagents/metabolism/digested
	var/next_processing = 0
	var/waste_stored = 0 // We store it as a number for performance and simplicity, only spawning a reagent when absolutely needed.
	var/waste_capacity = STOMACH_FULLNESS_CAP

/obj/item/organ/internal/intestines/Destroy()
	QDEL_NULL(digested)
	. = ..()

/obj/item/organ/internal/intestines/Initialize()
	. = ..()
	digested = new /datum/reagents/metabolism(2.4 LITERS, owner ? owner : null, CHEM_DIGEST)
	if(!digested.my_atom)
		digested.my_atom = src

/obj/item/organ/internal/intestines/robotize()
	..()
	SetName("digestion unit")
	icon_state = "intestines-prosthetic"
	dead_icon = "intestines-prosthetic-br"

/obj/item/organ/internal/intestines/removed(mob/living/user, drop_organ = TRUE, detach = TRUE)
	. = ..()
	digested.my_atom = src
	digested.parent = null

/obj/item/organ/internal/intestines/replaced()
	. = ..()
	digested.my_atom = owner
	digested.parent = owner

/obj/item/organ/internal/intestines/proc/store_item(obj/item/I)
	if(QDELETED(I))
		return
	I.forceMove(src)

/obj/item/organ/internal/intestines/proc/get_fullness()
	var/ret = waste_stored
	for(var/obj/item/I in contents)
		if(I == food_organ)
			continue
		ret += get_storage_cost() * 15
	return (ret / waste_capacity) * 100

/obj/item/organ/internal/intestines/proc/rupture()
	if(owner)
		owner?.custom_pain("Your feel a burst of sudden, excruciating pain in your guts!", 30)
	// TODO: Abdominal cavity here
	return

// This call needs to be split out to make sure that all the ingested things are metabolised
// before the process call is made on any of the other organs
/obj/item/organ/internal/intestines/proc/metabolize()
	if(is_usable())
		digested.metabolize()
	else
		digested.metabolize(TRUE)

/obj/item/organ/internal/intestines/take_internal_damage(amount, silent = FALSE, is_traumatic = FALSE)
	var/oldbroken = is_broken()
	. = ..()
	if(owner && !owner.stat)
		if(!oldbroken && is_broken())
			rupture()

/obj/item/organ/internal/intestines/think()
	..()

	if(!owner)
		return

	if(isundead(owner))
		return

	if(world.time > next_processing)
		next_processing = world.time + 5 SECONDS

		// Ruptured intestines, chance to send stuff into the abdominal cavity.
		if(contents.len > 1 && is_broken() && prob((damage - min_broken_damage) / 10))
			for(var/obj/item/I in contents)
				if(I == food_organ)
					continue
				// TODO: Abdominal cavity here
			owner.custom_pain("Your guts cramp agonizingly!", 20)
			// TODO: Waste to the abdominal cavity here

		// Simulation disabled, let's just despawn food chunks and decrease waste. Non-edible items will be waiting for a surgeon though.
		if(!config.health.simulate_digestion)
			for(var/obj/item/I in contents)
				if(I == food_organ)
					continue
				if(!istype(I, /obj/item/reagent_containers))
					continue
				qdel(I)
			waste_stored = clamp(waste_stored - 1, 0, waste_capacity)

		// Simulation enabled, warning the owner if needed.
		else if(!owner.stat)
			var/fullness = get_fullness()
			if(fullness >= 100)
				if(prob(50))
					owner.custom_pain("You feel like your guts are about to burst!", 1)
			else if(fullness >= 80)
				if(prob(10))
					to_chat(owner, SPAN("warning", "Your feel like your guts are full."))
			else if(fullness >= 60)
				if(prob(3))
					to_chat(owner, SPAN("notice", "You feel like you could visit a restroom."))
