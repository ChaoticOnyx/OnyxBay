/datum/grab/simple/control
	name = "controlling grab"
	shift = 0
	adjust_plane = FALSE

/datum/grab/simple/control/on_hit_help(obj/item/grab/G, atom/A, proximity)
	if(A == G.assailant)
		A = G.affecting
	if(isliving(G.affecting))
		var/mob/living/living_mob = G.affecting
		return living_mob.handle_rider_help_order(G.assailant, A, proximity)
	return FALSE

/datum/grab/simple/control/on_hit_disarm(obj/item/grab/G, atom/A, proximity)
	if(A == G.assailant)
		A = G.affecting
	if(isliving(G.affecting))
		var/mob/living/living_mob = G.affecting
		return living_mob.handle_rider_disarm_order(G.assailant, A, proximity)
	return FALSE

/datum/grab/simple/control/on_hit_grab(obj/item/grab/G, atom/A, proximity)
	if(A == G.assailant)
		A = G.affecting
	if(isliving(G.affecting))
		var/mob/living/living_mob = G.affecting
		return living_mob.handle_rider_grab_order(G.assailant, A, proximity)
	return FALSE

/datum/grab/simple/control/on_hit_harm(obj/item/grab/G, atom/A, proximity)
	if(A == G.assailant)
		A = G.affecting
	if(isliving(G.affecting))
		var/mob/living/living_mob = G.affecting
		return living_mob.handle_rider_harm_order(G.assailant, A, proximity)
	return FALSE

// Override these for mobs that will respond to instructions from a rider.
/mob/living/proc/handle_rider_harm_order(mob/user, atom/target, proximity)
	return FALSE

/mob/living/proc/handle_rider_grab_order(mob/user, atom/target, proximity)
	return FALSE

/mob/living/proc/handle_rider_disarm_order(mob/user, atom/target, proximity)
	return FALSE

/mob/living/proc/handle_rider_help_order(mob/user, atom/target, proximity)
	return FALSE
