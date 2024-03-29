/datum/spell/targeted/pumping_out_blood
	name = "Pumping out blood"
	desc = "Drain the victim's blood."

	invocation_type = SPI_NONE

	spell_flags = SELECTABLE
	range = 1
	max_targets = 1

	charge_max = 900
	delay_reduc = 100

	compatible_mobs = list(/mob/living/carbon/human)

	icon_state = "vamp_blood_pump"

	cast_sound = 'sound/effects/squelch2.ogg'

/datum/spell/targeted/pumping_out_blood/cast(list/targets, mob/user)
	for(var/mob/living/carbon/human/H in targets)
		if (!istype(H) || H.isSynthetic() || H.species.species_flags & SPECIES_FLAG_NO_BLOOD)
			to_chat(user, SPAN("warning", "[H] is not a creature you can drain useful blood from."))
			return

		if (H.stat == DEAD)
			to_chat(user, SPAN("warning", "The blood [H] seems tainted."))
			return

		if(!in_range(H, user))
			to_chat(user, "<span class='warning'>That was not so bright of you.</span>")
			return

		if(!H.vessel.get_reagent_amount(/datum/reagent/blood))
			to_chat(user, SPAN("danger", "[H] has no more blood left to give."))
			return

		to_chat(H, SPAN("warning", FONT_LARGE("You feel like you are plunging into a nightmare, from which horror is even frozen on your face.")))
		playsound(user.loc, 'sound/effects/drain_blood.ogg', 50, 1)

		if(!H.stunned)
			H.Stun(170)
		if(do_after(user, 150, H))
			H.vessel.remove_reagent(/datum/reagent/blood, 100)
			var/datum/spell/aoe_turf/conjure/slug/T = user.ability_master.get_ability_by_spell_name("Born slug")
			if(T)
				T.charge_counter++
