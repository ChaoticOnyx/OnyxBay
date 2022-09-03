/datum/event2/spontaneous_appendicitis
	id = "spontaneous_appendicitis"
	name = "Spontaneous Appendicitis"
	description = "A random person will suddenly get appendicitis"

	mtth = 3 HOURS

/datum/event2/spontaneous_appendicitis/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Medical"] * (12 MINUTES))
	. = max(1 HOUR, .)

/datum/event2/spontaneous_appendicitis/on_fire()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list_))
		if(H.client && H.stat != DEAD)
			var/obj/item/organ/internal/appendix/A = H.internal_organs_by_name[BP_APPENDIX]
			if(!istype(A) || (A && A.inflamed))
				continue
			A.inflamed = 1
			A.update_icon()
			break
