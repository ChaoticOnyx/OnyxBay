/*
	W	I	P
*/

/mob/living/typhon/
	proc
		Drain(var/mob/living/carbon/human/target in view(1) - src)
			set name = "Drain"
			set desc = "Drain life from a lifeform and produce 3 mimcs."
			set category = "Abilities"

			if (!istype(target, /mob/living/carbon/human))
				return

			playsound(src, pick(src.sounds["ondrain"]), 20, 1)
			to_chat(src, "You trying to drain life from [target].")
			to_chat(target, "[src] trying to drain your life!")

			if (!do_after(src, 20, target, 0, 1))
				return

			playsound(src, pick(src.sounds["drain"]), 20, 1)
			to_chat(src, "You have drained life from [target]!")

			target.ChangeToHusk()

			if (target.should_have_organ(BP_HEART))
				target.vessel.add_reagent(/datum/reagent/blood, target.species.blood_volume - target.vessel.total_volume)

			for (var/o in target.organs)
				var/obj/item/organ/organ = o
				organ.vital = 0

				if (!BP_IS_ROBOTIC(organ))
					organ.rejuvenate(1)
					organ.max_damage *= 3
					organ.min_broken_damage = Floor(organ.max_damage * 0.75)

			target.stat = DEAD
			target.switch_from_living_to_dead_mob_list()

			for (var/i = 0, i < 3, i++)
				new /mob/living/typhon/mimic(src.loc)
