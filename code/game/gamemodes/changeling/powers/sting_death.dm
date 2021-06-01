
/mob/proc/prepare_changeling_death_sting()
	set category = "Changeling"
	set name = "Death Sting (40)"
	set desc = "Causes spasms to death."
	if(is_regenerating())
		return
	change_ctate(/datum/click_handler/changeling/changeling_death_sting)
	return

/mob/proc/changeling_death_sting(mob/living/carbon/human/T)
	var/mob/living/carbon/human/target = changeling_sting(/mob/proc/prepare_changeling_death_sting, T, 40, TRUE)
	if(!target)
		return FALSE
	to_chat(target, "<span class='danger'>You feel a small prick and your chest becomes tight.</span>")
	target.make_jittery(400)
	if(target.reagents)
		spawn(10 SECONDS)
			target.reagents.add_reagent(/datum/reagent/toxin/cyanide, 1)
		spawn(20 SECONDS)
			target.reagents.add_reagent(/datum/reagent/toxin/cyanide, 1)
		spawn(30 SECONDS)
			target.reagents.add_reagent(/datum/reagent/toxin/cyanide, 3)
	feedback_add_details("changeling_powers","DTHS")
	return TRUE
