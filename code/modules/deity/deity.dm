GLOBAL_LIST_INIT(deity_forms, list(); for(var/form in subtypesof(/datum/deity_form)) deity_forms.Add(new form))

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

	var/list/followers = list()

	var/self_click_cooldown = 30
	var/last_click = 0

	var/static/radial_buildings = image(icon = 'icons/hud/screen_spells.dmi', icon_state = "const_pylon")
	var/static/radial_phenomena = image(icon = 'icons/hud/screen_spells.dmi', icon_state = "wiz_fireball")
	var/static/radial_boons = image(icon = 'icons/hud/screen_spells.dmi', icon_state = "master_open")

	var/static/list/radial_options = list("Buildings" = radial_buildings, "Phenomena" = radial_phenomena, "Boons" = radial_boons)

	var/datum/radial_menu/radial_menu

	var/datum/deity_form/form

/mob/living/deity/Initialize()
	. = ..()
	deity_net = new /datum/visualnet/cultnet()
	eyeobj = new /mob/observer/eye/cult(get_turf(src), deity_net)
	eyeobj.possess(src)
	eyeobj.visualnet.add_source(eyeobj)
	eyeobj.visualnet.add_source(src)
	GLOB.raw_vis_tracker.add_tracked_mind(mind)

/mob/living/deity/Destroy()
	eyeobj.release(src)
	QDEL_NULL(eyeobj)
	QDEL_NULL(deity_net)
	QDEL_NULL(radial_menu)
	QDEL_NULL(form)
	followers.Cut()
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
	if(!form)
		return FALSE

	return form.take_charge(user, charge)

/mob/living/deity/say(message, datum/language/speaking = null, verb = "says", alt_name = "")
	if(!..())
		return FALSE

	to_chat(src, SPAN_NOTICE("Broadcasting message to all followers..."))
	for(var/m in followers)
		var/datum/mind/mind = m
		to_chat(mind.current, SPAN_OCCULT("<font size='3'>[message]</font>"))

/// A generic proc to add a follower. Self-explanatory.
/mob/living/deity/proc/add_follower(mob/living/L)
	if(L.mind && !(L.mind in GLOB.godcult.current_antagonists))
		followers.Add(L.mind)
		if(form)
			to_chat(L, SPAN_NOTICE("[form.join_message][src]"))
		deity_net.add_source(L)
		return GLOB.godcult.add_antagonist_mind(L.mind, ignore_role = TRUE, deity = src)

	else
		return FALSE

/// Similar to the previous proc but does the opposite
/mob/living/deity/proc/remove_follower(mob/living/L)
	if(L.mind && (L.mind in followers))
		followers.Remove(L.mind)
		if(form)
			to_chat(L, SPAN_NOTICE("[form.leave_message][src]"))
		deity_net.remove_source(L)
		//if(L.mind in GLOB.godcult.current_antagonists)
		//	GLOB.godcult.remove_cultist(L.mind, src)

/mob/living/deity/proc/get_followers_nearby(atom/target, dist)
	. = list()
	for(var/datum/mind/M in followers)
		if(M.current && get_dist(target, M.current) <= dist)
			. += M.current

/datum/deity_power/phenomena/conversion
	name = "Conversion"
	desc = "Ask a non-follower to convert to your cult. This is completely voluntary."

/datum/deity_power/phenomena/conversion/manifest(mob/living/target, mob/living/deity/D)
	if(!..())
		return FALSE

	if(!target.mind)
		return FALSE

	if(tgui_alert(target, D.form.conversion_text, "Convert?", list("Yes","No")) == "Yes")
		return D.add_follower(target)

/mob/living/deity/proc/set_form(new_form)
	if(form)
		return FALSE

	for(var/datum/deity_form/form_ in GLOB.deity_forms)
		if(form_.name != new_form)
			continue

		form = new form_.type(src)

	form.setup_form(src)

	return TRUE

/mob/living/deity/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)

	if(modifiers["middle"])
		show_radial(A)
		return

	if(A == src)
		tgui_interact(src)
		return

	else if(istype(A, /obj/structure/deity))
		var/obj/structure/deity/struct = A
		struct.deity_click(src)
		return

	else if(istype(selected_power))
		selected_power.manifest(A, src)

/mob/living/deity/proc/show_radial(atom/A)
	if(!form)
		return

	var/datum/deity_power/choice
	var/category = deity_radial_menu(usr, A, radial_options)
	switch(category)
		if("Buildings")
			choice = deity_radial_menu(usr, A, form.buildables)
		if("Phenomena")
			choice = deity_radial_menu(usr, A, form.phenomena)
		if("Boons")
			choice = deity_radial_menu(usr, A, form.boons)

	set_selected_power(choice, form.phenomena)

/mob/living/deity/proc/deity_radial_menu(user, atom/anchor, list/choices)
	QDEL_NULL(radial_menu)
	radial_menu = new
	radial_menu.anchor = anchor
	radial_menu.check_screen_border(user)
	radial_menu.set_choices(choices)
	radial_menu.show_to(user)
	radial_menu.wait(user, anchor)
	var/answer = radial_menu.selected_choice
	QDEL_NULL(radial_menu)
	return answer

/mob/living/deity/proc/self_click()
	return
