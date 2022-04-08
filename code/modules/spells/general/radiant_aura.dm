/datum/spell/radiant_aura
	name = "Radiant aura"
	desc = "Form a protective layer of light around you, making you immune to laser fire."
	school = "transmutation"
	feedback = "ra"
	invocation_type = SPI_EMOTE
	invocation = "conjures a sphere of fire around themselves."
	school = "conjuration"
	charge_max = 300
	cooldown_min = 150
	level_max = list(SP_TOTAL = 2, SP_SPEED = 2, SP_POWER = 0)
	cast_sound = 'sound/effects/snap.ogg'
	duration = 150
	icon_state = "gen_immolate"

/datum/spell/radiant_aura/choose_targets()
	return list(holder)

/datum/spell/radiant_aura/cast(list/targets, mob/user)
	var/obj/aura/radiant_aura/A = new(user)
	QDEL_IN(A,duration)
