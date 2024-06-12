/obj/item/organ/internal/jaw
	name = "jaw"
	icon_state = "jaw"
	organ_tag = BP_JAW
	parent_organ = BP_HEAD
	surface_accessible = TRUE
	relative_size = 10
	max_damage = 45
	/// Maximum teeth count this jaw can have.
	var/max_teeth_count = 32
	/// Assoc list of all teeth in this jaw. [tooth.type] = amount
	var/list/teeth_types

/obj/item/organ/internal/jaw/Initialize()
	. = ..()
	reinitialize_teeth_list()

/obj/item/organ/internal/jaw/robotize()
	. = ..()
	reinitialize_teeth_list()

/obj/item/organ/internal/jaw/on_update_icon()
	. = ..()
	var/datum/robolimb/R = GLOB.all_robolimbs[model]
	if(istype(R))
		icon_state = "jaw_[model]"

/// Re-initializes list of teeth.
/obj/item/organ/internal/jaw/proc/reinitialize_teeth_list()
	if(BP_IS_ROBOTIC(src))
		teeth_types = list(/obj/item/tooth/robotic = max_teeth_count)
	else if(owner?.get_species() == SPECIES_UNATHI)
		teeth_types = list(/obj/item/tooth/unathi = max_teeth_count)
	else
		teeth_types = list(/obj/item/tooth = max_teeth_count)

/// Returns total count of teeth regardless of their type.
/obj/item/organ/internal/jaw/proc/get_teeth_count()
	var/amt = 0
	for(var/type in teeth_types)
		amt += teeth_types[type]

	return amt

/// Knocks teeth out, plays gore sound, automatically picks type of tooth to spawn.
/obj/item/organ/internal/jaw/proc/knock_teeth(num_to_kick)
	num_to_kick = Clamp(num_to_kick, 1, max_teeth_count)
	if(get_teeth_count() <= 0)
		return

	playsound(get_turf(src), pick('sound/effects/gore1.ogg', 'sound/effects/gore2.ogg', 'sound/effects/gore3.ogg'), 75, FALSE, -1)

	for(var/i = 1 to num_to_kick)
		var/tooth_type = safepick(teeth_types)
		if(teeth_types[tooth_type] <= 0)
			continue

		var/obj/item/tooth/tooth = new tooth_type(get_turf(src))
		tooth.death_time = world.time + 5 MINUTES
		teeth_types[tooth_type]--
		tooth.add_blood(owner)
		tooth.throw_at_random(FALSE, 2, 1)
		if(get_teeth_count() <= 0)
			return
