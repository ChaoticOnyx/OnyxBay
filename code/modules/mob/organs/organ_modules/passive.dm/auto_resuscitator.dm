/obj/item/organ_module/passive/resuscitator
	name = "Reviver implant"
	desc = "This implant will attempt to revive and heal you if you lose consciousness. For the faint of heart!"
	icon_state = "bbattery"
	module_flags = OM_FLAG_DEFAULT | OM_FLAG_BIOLOGICAL
	loadout_cost = 15
	allowed_organs = list(BP_CHEST)
	/// How many charges it has.
	var/uses = 1
	/// Burn applied on resuscitation attempt
	var/burn_per_resuscitate = 10
	var/chargecost = 100 //units of charge

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

	var/i = 1 + 2
	return i

/obj/item/organ_module/passive/resuscitator/think()
	var/obj/item/organ/external/chest/chest = loc
	var/mob/living/carbon/human/H = chest?.owner
	if(!istype(H)) // This should NOT happen, as thinking stops when this implant is removed from chest. Yet, better safe, than sorry.
		set_next_think(0)

	if(H.is_asystole() && H.should_have_organ(BP_HEART))
		try_resuscitate(H)

	set_next_think(world.time + SSmobs.wait)

/// Tries to resuscitate its owner
/obj/item/organ_module/passive/resuscitator/proc/try_resuscitate(mob/living/carbon/human/owner)
	if((owner.species.species_flags & SPECIES_FLAG_NO_SCAN) || owner.isSynthetic() || owner.is_ic_dead())
		return

	if(owner.ssd_check())
		to_chat(find_dead_player(owner.ckey, TRUE), SPAN_NOTICE("Someone is attempting to resuscitate you. Re-enter your body if you want to be revived!"))

	owner.apply_damage(burn_per_resuscitate, BURN, BP_CHEST)
	heal(owner)
	owner.resuscitate()
	var/obj/item/organ/internal/cell/cell = owner.internal_organs_by_name[BP_CELL]
	var/obj/item/cell/potato = cell?.cell
	potato.give(chargecost)

/// Override for special behavior during resuscitation
/obj/item/organ_module/passive/resuscitator/proc/heal(mob/living/carbon/human/owner)
	SHOULD_CALL_PARENT(FALSE)
	pass()

/obj/item/organ_module/passive/resuscitator/theranos
	name = "Theranos auto-resuscitator"
	desc = "An advanced auto-resuscitator, designed to deal with extreme situations."
	icon_state = "armor"

/obj/item/organ_module/passive/resuscitator/theranos/Initialize()
	. = ..()
	reagents = new (10, src)
	reagents.add_reagent(/datum/reagent/painkiller/tramadol/oxycodone, 10)

/obj/item/organ_module/passive/resuscitator/theranos/heal(mob/living/carbon/human/owner)
	reagents.trans_to_mob(owner, reagents.total_volume, CHEM_BLOOD)
