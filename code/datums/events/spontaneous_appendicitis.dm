/datum/event/spontaneous_appendicitis
	id = "spontaneous_appendicitis"
	name = "Spontaneous Appendicitis"
	description = "A random person will suddenly get appendicitis"

	mtth = 3 HOURS
	difficulty = 25

/datum/event/spontaneous_appendicitis/check_conditions()
	. = SSevents.triggers.living_players_count >= 5 && SSevents.triggers.roles_count["Medical"]

/datum/event/spontaneous_appendicitis/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Medical"] * (18 MINUTES))
	. = max(1 HOUR, .)

/datum/event/spontaneous_appendicitis/on_fire()
	for(var/mob/living/carbon/human/H in shuffle(GLOB.living_mob_list_))
		if(H.client && H.stat != DEAD)
			var/obj/item/organ/internal/appendix/A = H.internal_organs_by_name[BP_APPENDIX]
			if(!istype(A) || A?.inflamed)
				continue
			A.inflamed = TRUE
			A.update_icon()
			break
