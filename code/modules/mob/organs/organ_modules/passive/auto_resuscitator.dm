/obj/item/organ_module/passive/resuscitator
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "bbattery"
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 0
	allowed_organs = list(BP_HEART)
	available_in_charsetup = TRUE
	augment_cost = 4
	cpu_load = 0
	origin_tech = list(TECH_BIO = 3)
	matter = list(
		MATERIAL_STEEL = 1000,
		MATERIAL_PLASTIC = 2000,
		MATERIAL_GLASS = 500
	)
	/// How many charges it has.
	var/uses = 1
	/// Whether the implant has already been spent.
	var/used = FALSE
	/// Burn applied on resuscitation attempt
	var/burn_per_resuscitate = 10
	var/chargecost = 100 //units of charge
	/// Reagents injected on resuscitation attempt.
	var/list/resuscitate_reagents = list(
		/datum/reagent/adrenaline = 15,
		/datum/reagent/tricordrazine = 30,
		/datum/reagent/dexalinp = 15,
		/datum/reagent/painkiller/tramadol = 15
	)

/obj/item/organ_module/passive/resuscitator/organ_installed()
	set_next_think(world.time + SSmobs.wait)

/obj/item/organ_module/passive/resuscitator/organ_removed()
	set_next_think(0)

/obj/item/organ_module/passive/resuscitator/post_install(obj/item/organ/E)
	set_next_think(world.time + SSmobs.wait)

/obj/item/organ_module/passive/resuscitator/post_removed(obj/item/organ/E)
	set_next_think(0)

/obj/item/organ_module/passive/resuscitator/emp_act(severity)
	. = ..()

	if(severity != 1)
		return
	var/obj/item/organ/internal/heart/heart = loc
	if(!istype(heart))
		return
	if(heart.pulse == PULSE_NONE)
		return
	heart.pulse = PULSE_NONE
	var/mob/living/carbon/human/H = heart.owner
	if(istype(H))
		to_chat(H, SPAN_DANGER("Your heart spasms and stops!"))

/obj/item/organ_module/passive/resuscitator/think()
	var/obj/item/organ/internal/heart/heart = loc
	var/mob/living/carbon/human/H = heart?.owner
	if(!istype(H)) // This should NOT happen, as thinking stops when this implant is removed from heart. Yet, better safe, than sorry.
		set_next_think(0)
		return

	if(H.is_asystole() && H.should_have_organ(BP_HEART))
		try_resuscitate(H)

	set_next_think(world.time + SSmobs.wait)

/// Tries to resuscitate its owner
/obj/item/organ_module/passive/resuscitator/proc/try_resuscitate(mob/living/carbon/human/owner)
	if((owner.species.species_flags & SPECIES_FLAG_NO_SCAN) || owner.isSynthetic() || owner.is_ic_dead())
		return
	if(uses <= 0 || used)
		return

	if(owner.ssd_check())
		to_chat(find_dead_player(owner.ckey, TRUE), SPAN_NOTICE("Your heart augmentetion tries to resuscitate you. Re-enter your body if you want to be revived!"))

	var/cpu_name = "CPU"
	var/obj/item/organ/external/head/head = owner.external_organs_by_name[BP_HEAD]
	if(istype(head))
		for(var/obj/item/organ_module/module in head.organ_modules)
			if(initial(module.module_type) == OM_TYPE_PROCESSOR)
				cpu_name = module.name
				break
	to_chat(owner, SPAN_NOTICE("[cpu_name] activates [initial(name)]."))
	sound_to(owner, sound('sound/voice/Hevsounds/flatline_medical.ogg', volume = 50))
	owner.visible_message(
		SPAN_NOTICE("[owner]'s chest rises up and down, as if something hit it from the inside."),
		null
	)

	owner.apply_damage(burn_per_resuscitate, BURN, BP_CHEST)
	heal(owner)
	if(owner.reagents && LAZYLEN(resuscitate_reagents))
		for(var/reagent_type in resuscitate_reagents)
			owner.reagents.add_reagent(reagent_type, resuscitate_reagents[reagent_type])
	owner.resuscitate()
	uses = 0
	used = TRUE
	SetName("[initial(name)] (used)")

/// Override for special behavior during resuscitation
/obj/item/organ_module/passive/resuscitator/proc/heal(mob/living/carbon/human/owner)
	SHOULD_CALL_PARENT(FALSE)
	return

/obj/item/organ_module/passive/resuscitator/theranos
	name = "Theranos auto-resuscitator"
	desc = "An advanced auto-resuscitator, designed to deal with extreme situations."
	icon_state = "armor"
	available_in_charsetup = TRUE
	augment_cost = 10
	cpu_load = 0
	allowed_roles = list(/datum/job/hos, /datum/job/captain, /datum/job/cmo, /datum/job/iaa, /datum/job/hop)
	origin_tech = list(TECH_BIO = 6, TECH_COMBAT = 6, TECH_ENGINEERING = 7, TECH_BLUESPACE = 4, TECH_PLASMA = 4)
	matter = list(
		MATERIAL_URANIUM = 50,
		MATERIAL_GOLD = 500,
		MATERIAL_DIAMOND = 500,
		MATERIAL_PLASTEEL = 1000
	)
	resuscitate_reagents = list(
		/datum/reagent/painkiller = 15,
		/datum/reagent/bicaridine = 30,
		/datum/reagent/dermaline = 15,
		/datum/reagent/dexalinp = 15,
		/datum/reagent/adrenaline = 15,
		/datum/reagent/rezadone = 20,
		/datum/reagent/peridaxon = 5
	)

/obj/item/organ_module/passive/resuscitator/theranos/Initialize()
	. = ..()
	reagents = new (10, src)
	reagents.add_reagent(/datum/reagent/painkiller/tramadol/oxycodone, 10)

/obj/item/organ_module/passive/resuscitator/theranos/heal(mob/living/carbon/human/owner)
	reagents.trans_to_mob(owner, reagents.total_volume, CHEM_BLOOD)
