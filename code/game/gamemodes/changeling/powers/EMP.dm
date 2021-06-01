
/mob/proc/prepare_changeling_bioelectrogenesis()
	set category = "Changeling"
	set name = "Bioelectrogenesis (20)"
	set desc = "We create an electromagnetic pulse against synthetics."
	if(is_regenerating())
		return
	change_ctate(/datum/click_handler/changeling/changeling_bioelectrogenesis)
	return

/mob/proc/changeling_bioelectrogenesis(mob/living/T)
	var/datum/changeling/changeling = changeling_power(20)
	if(!changeling)
		return
	if(T in orange(1, src))
		empulse(T.loc, 1, 1)
		changeling.chem_charges -= 20
	else
		to_chat(src, "<span class='warning'>Too Far</span>")
	return
