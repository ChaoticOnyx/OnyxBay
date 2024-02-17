/datum/godcultist
	var/mob/living/deity/linked_deity
	var/mob/living/godcultist
	/// A universal counter to track progress e.t.c.
	var/points = 0

/datum/godcultist/New(mob/living/player, mob/living/deity)
	. = ..()
	godcultist = player
	linked_deity = deity

/datum/godcultist/Destroy()
	linked_deity = null
	godcultist = null
	return ..()

/datum/godcultist/proc/add_points(amount)
	points += amount

/datum/godcultist/sintouched/proc/remove_points(amount)
	points -= amount

/datum/godcultist/sintouched/proc/set_cpoints(amount)
	points = amount
