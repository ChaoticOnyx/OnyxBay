/obj/item/organ/internal/kidneys
	name = "kidneys"
	gender = PLURAL
	icon_state = "kidneys"
	w_class = ITEM_SIZE_SMALL
	organ_tag = BP_KIDNEYS
	parent_organ = BP_GROIN
	min_bruised_damage = 20
	min_broken_damage = 40
	max_damage = 60
	relative_size = 25
	var/detox_efficiency = 0.25
	var/hydration_consumption = DEFAULT_THIRST_FACTOR

/obj/item/organ/internal/kidneys/robotize()
	. = ..()
	SetName("renal implants")
	icon_state = "kidneys-prosthetic"
	dead_icon = "kidneys-prosthetic-br"

/obj/item/organ/internal/kidneys/think()
	..()

	if(!owner)
		return

	if(isundead(owner))
		return

	detox_efficiency = 0.5
	if(status & ORGAN_DEAD) // Causes the body's natural toxic buildup to... build up.
		detox_efficiency *= -1
	else if(is_broken()) // Technically, ceases toxloss healing function. Lore-wise, still filters out the body's natural toxic buildup, but can't handle anything beyond that.
		detox_efficiency = 0
	else if(is_bruised()) // Halves the healing potential, we'll only get intoxicated when completely dehydrated.
		detox_efficiency *= 0.5

	else

/obj/item/organ/internal/kidneys/die()
	..()
	if(status & ORGAN_DEAD)
		detox_efficiency = -0.5

/obj/item/organ/internal/kidneys/proc/process_hydration()
	if(!owner)
		return

	if(isundead(owner))
		return

	var/dynamic_hydration_consumption = hydration_consumption

	for(var/datum/modifier/mod in owner.modifiers)
		if(!isnull(mod.metabolism_percent))
			dynamic_hydration_consumption *= mod.metabolism_percent

	switch(owner.hydration)
		if(HYDRATION_NONE)
			dynamic_hydration_consumption = 0
			take_internal_damage(0.1) // kidneys autoheal 0.1 damage each tick, so we effectively deal no damage here if kidneys are healthy.
		if(HYDRATION_NONE+0.01 to HYDRATION_LOW)
			dynamic_hydration_consumption *= 0.75
		if(HYDRATION_HIGH+0.01 to HYDRATION_SUPER)
			dynamic_hydration_consumption *= 1.25
		if(HYDRATION_SUPER+0.01 to INFINITY)
			dynamic_hydration_consumption *= 2.0

	owner.remove_hydration(dynamic_hydration_consumption)

	if(owner.should_have_organ(BP_BLADDER))
		var/obj/item/organ/internal/bladder/L = owner.internal_organs_by_name[BP_BLADDER]
		if(!L)
			// TODO: Abdominal cavity here.
			return
		L.waste_to_spawn += dynamic_hydration_consumption

