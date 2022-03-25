/obj/item/organ/internal/heart/gland/blood
	abductor_hint = "pseudonuclear hemo-destabilizer. Periodically drains blood from surrounding peoples."
	cooldown_low = 1200
	cooldown_high = 1800
	uses = -1
	mind_control_uses = 3
	mind_control_duration = 1500
	var/datum/spell/aoe_turf/spell = new /datum/spell/aoe_turf/drain_blood()

/obj/item/organ/internal/heart/gland/blood/activate()
	if(!ishuman(owner) || !owner.dna.species)
		return
	var/mob/living/carbon/human/H = owner
	to_chat(H, SPAN_WARNING("You feel your blood heat up for a moment."))

	spell.cast(orange(4,owner),owner)
