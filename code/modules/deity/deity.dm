GLOBAL_LIST_INIT(deity_forms, list(); for(var/form in subtypesof(/datum/god_form)) deity_forms.Add(new form))

/mob/living/deity
	name = "Deity"
	desc = ""
	icon = 'icons/mob/deity.dmi'
	icon_state = ""
	health = 200
	maxHealth = 200
	density = 0
	simulated = FALSE
	invisibility = 101
	universal_understand = TRUE
	see_in_dark = 15
	see_invisible = SEE_INVISIBLE_NOLIGHTING
	var/phase = DEITY_PHASE_ABSTRACT
	var/datum/visualnet/deity_net
	var/slot_active

/mob/living/deity/Initialize()
	. = ..()
	deity_net = new /datum/visualnet/cultnet()
	eyeobj = new /mob/observer/eye/cult(get_turf(src), deity_net)
	eyeobj.possess(src)
	eyeobj.visualnet.add_source(eyeobj)
	eyeobj.visualnet.add_source(src)

/mob/living/deity/Destroy()
	eyeobj.release(src)
	QDEL_NULL(eyeobj)
	QDEL_NULL(deity_net)
	return ..()

/mob/living/deity/update_sight()
	if (phase == DEITY_PHASE_ABSTRACT)
		sight = SEE_TURFS | SEE_MOBS | SEE_OBJS | SEE_SELF

	else if (stat == DEAD)
		update_dead_sight()
	else
		update_living_sight()

/// Followers can take charge using this proc, usually it damages them.
/mob/living/deity/proc/take_charge(mob/living/user, charge)
	if(form)
		return form.take_charge(user, charge)

/mob/living/deity/say(message, datum/language/speaking = null, verb = "says", alt_name = "")
	if(!..())
		return FALSE

	to_chat(src, SPAN_NOTICE("Broadcasting message to all followers..."))
	for(var/m in followers)
		var/datum/mind/mind = m
		to_chat(mind.current, SPAN_OCCULT("<font size='3'>[message]</font>"))
