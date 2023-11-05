/datum/job/hos/cm
	title = "Colonial Marshal"
	supervisors = "the mayor"

/datum/job/hos/equip(mob/living/carbon/human/H)
	. = ..()
	if(.)
		H.implant_loyalty(H)

/datum/job/warden/sheriff
	title = "Sheriff"
	supervisors = "the colonial marshal"

/datum/job/officer/deputy
	title = "County Deputy"
	supervisors = "the sheriff"
	alt_titles = list("Town Deputy")
