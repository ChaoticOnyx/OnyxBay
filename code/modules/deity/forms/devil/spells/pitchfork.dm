/datum/action/cooldown/spell/summon_pitchfork
	name = "Summon Pitchfork"
	desc = "Steal a random item from the victim's backpack."
	button_icon_state = "devil_pitchfork"

	cooldown_time = 0 SECONDS
	/// Weakref to our pitchfork as it is deleted on summon
	var/weakref/summoned_pitchfork
	/// Type to summon
	var/summon_type = /obj/item/material/twohanded/pitchfork

/datum/action/cooldown/spell/summon_pitchfork/cast()
	var/mob/living/carbon/human/H = owner
	ASSERT(H)

	var/obj/item/material/twohanded/D = summoned_pitchfork?.resolve()
	if(istype(D))
		qdel(D)

	var/turf/owner_turf = get_turf(H)
	ASSERT(owner_turf)
	D = new summon_type(owner_turf)
	summoned_pitchfork = weakref(D)
	H.pick_or_drop(D, owner_turf)

/datum/action/cooldown/spell/summon_pitchfork/Destroy()
	var/obj/item/material/twohanded/D = summoned_pitchfork?.resolve()
	if(istype(D))
		qdel(D)

	summoned_pitchfork = null
	return ..()

/obj/item/material/twohanded/pitchfork
	name = "pitchfork"
	desc = "pitchfork."
	icon_state = "infernal_pitchfork"
	item_state = "infernal_pitchfork"
	base_icon = "infernal_pitchfork"
	force_divisor = 0.5
	unwielded_force_divisor = 0.2
	sharp = TRUE
	edge = TRUE
	armor_penetration = 40
	w_class = ITEM_SIZE_HUGE
	mod_handy_w = 1.2
	mod_weight_w = 2.0
	mod_reach_w = 1.5
	mod_handy_u = 0.4
	mod_weight_u = 1.5
	mod_reach_u = 1.0
	slot_flags = SLOT_BACK
	force_wielded = 30
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	applies_material_colour = 0
	unbreakable = TRUE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
