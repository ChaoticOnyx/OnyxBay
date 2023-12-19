/datum/extension/deity_be_near
	expected_type = /obj/item
	var/keep_away_instead = FALSE
	var/mob/living/deity/connected_deity
	var/threshold_base = 6
	flags = EXTENSION_FLAG_IMMEDIATE

/datum/extension/deity_be_near/New(datum/holder, mob/living/deity/D)
	..()
	register_signal(holder, SIGNAL_MOVED, nameof(.proc/check_movement))
	connected_deity = D
	var/obj/O = holder
	O.desc += SPAN_WARNING("This item deals damage to its wielder the [keep_away_instead ? "closer" : "farther"] it is from a deity structure")

/datum/extension/deity_be_near/Destroy()
	unregister_signal(holder, SIGNAL_MOVED)
	return ..()

/datum/extension/deity_be_near/proc/check_movement()
	var/obj/item/I = holder
	if(!istype(I.loc, /mob/living))
		return

	var/min_dist = INFINITY
	for(var/s in connected_deity.buildings)
		var/dist = get_dist(holder, s)
		if(dist < min_dist)
			min_dist = dist

	if(min_dist > threshold_base)
		deal_damage(I.loc, round(min_dist/threshold_base))
	else if(keep_away_instead && min_dist < threshold_base)
		deal_damage(I.loc, round(threshold_base/min_dist))

/datum/extension/deity_be_near/proc/deal_damage(mob/living/victim, mult)
	return
