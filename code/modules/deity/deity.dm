GLOBAL_LIST_INIT(deity_forms, list(); for(var/form in subtypesof(/datum/deity_form)) deity_forms.Add(new form))
#define DEITY_PUNISH_COOLDOWN 15 SECONDS
#define DEITY_REWARD_COOLDOWN 15 SECONDS

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

	var/next_reward_act = 0
	var/next_punish_act = 0

/mob/living/deity/Initialize()
	. = ..()
	deity_net = new /datum/visualnet/cultnet()
	eyeobj = new /mob/observer/eye/cult(get_turf(src), deity_net)
	deity_net.add_source(src)
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

/mob/living/deity/Login()
	. = ..()
	GLOB.raw_vis_tracker.add_tracked_mind(mind)

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
/mob/living/deity/proc/add_follower(mob/living/L, evolution_prefab)
	if(L.mind && !(L.mind in GLOB.godcult.current_antagonists))
		followers.Add(L.mind)
		form?.on_follower_add(L.mind)
		if(form)
			to_chat(L, SPAN_NOTICE("[form.join_message][src]"))
		deity_net.add_source(L)
		return GLOB.godcult.add_antagonist_mind(L.mind, ignore_role = TRUE, deity = src, evo_holder = evolution_prefab)

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
			//GLOB.godcult.remove_cultist(L.mind, src)

/mob/living/deity/proc/get_followers_nearby(atom/target, dist)
	. = list()
	for(var/datum/mind/M in followers)
		if(M.current && get_dist(target, M.current) <= dist)
			. += M.current

/datum/deity_power/phenomena/conversion
	name = "Conversion"
	desc = "Ask a non-follower to convert to your cult. This is completely voluntary."

/datum/deity_power/phenomena/conversion/manifest(mob/living/target, mob/living/deity/D, evolution_prefab)
	if(!..())
		return FALSE

	if(!target.mind)
		return FALSE

	if((target.mind in GLOB.godcult.current_antagonists) || (target.mind in GLOB.deity.current_antagonists))
		return FALSE

	if(istype(target.mind?.deity))
		return FALSE

	if(tgui_alert(target, D.form.conversion_text, "Convert?", list("Yes","No")) == "Yes")
		return D.add_follower(target, evolution_prefab)

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

	if(istype(selected_power) && !selected_power.can_switch)
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
	var/answer = radial_menu?.selected_choice
	QDEL_NULL(radial_menu)
	return answer

/mob/living/deity/proc/self_click()
	return

/mob/living/deity/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Deity", name)
		ui.open()

/mob/living/deity/tgui_state()
	return GLOB.tgui_always_state

/mob/living/deity/tgui_data(mob/user)
	var/list/data = list(
		"forms" = list(),
		"followers" = list(),
		"buildings" = list(),
		"points" = form?.knowledge_points,
	)

	data["user"] = list(
		"form" = form?.type,
		"name" = user.name,
		"points" = form?.knowledge_points,
		"punishCooldown" = next_punish_act >= world.time,
		"rewardCooldown" = next_reward_act >= world.time,
	)

	for(var/datum/deity_form/form in GLOB.deity_forms)
		var/icon/form_icon = new /icon("icon" = 'icons/mob/deity.dmi', "icon_state" = form.form_state)
		var/list/form_data = list(
			"name" = form.name,
			"icon" = icon2base64html(form_icon),
			"desc" = form.desc,
		)

		data["forms"] += list(form_data)

	data["items"] = list()
	for(var/datum/deity_power/power in form?.buildables)
		var/list/building_data = list(
			"name" = power._get_name(),
			"icon" = icon2base64html(power._get_image()),
			"desc" = power.desc,
			"type" = power.type
		)

		data["items"] += list(building_data)

	data["evolutionItems"] = list()
	for(var/datum/evolution_category/cat in form?.evo_holder.evolution_categories)
		var/list/cat_data = list(
			"name" = cat.name
		)

		for(var/datum/evolution_package/pack in cat.items)
			var/list/pack_data = list(
				"name" = pack.name,
				"desc" = pack.desc,
				"path" = pack.type,
				"cost" = pack.cost,
				"icon" = pack.icon,
				"tier" = pack.tier,
				"purchased" = pack.purchased,
				"unlocked" = pack.check_unlocked(form?.evo_holder),
				"unlocked_by" = pack.unlocked_by,
			)
			cat_data["packages"] += list(pack_data)

		data["evolutionItems"] += list(cat_data)

	data["followers"] = list()
	for(var/datum/mind/M in followers)
		var/list/follower_data = list(
			"name" = M.name,
			"stat" = M.current?.stat,
			"ref" = "\ref[M]"
		)

		data["followers"] += list(follower_data)

	return data

/mob/living/deity/tgui_act(action, params)
	. = ..()
	if(.)
		return

	switch(action)
		if("choose_form")
			set_form(params["path"])
			return TRUE

		if("select_building")
			set_selected_power(text2path(params["building_type"]), form.buildables)
			return TRUE

		if("select_boon")
			set_selected_power(text2path(params["building_type"]), form.boons)
			return TRUE

		if("select_phenomenon")
			set_selected_power(text2path(params["building_type"]), form.phenomena)
			return TRUE

		if("reward_follower")
			reward_follower(params["ref"])
			return TRUE

		if("punish_follower")
			punish_follower(params["ref"])
			return TRUE

		if("evolve")
			evolve_deity(text2path(params["pack_name"]))
			return TRUE

/mob/living/proc/evolve_deity(package_type)
	var/datum/evolution_holder/evo_holder
	if(isdeity(src))
		var/mob/living/deity/deity = src
		evo_holder = deity.form?.evo_holder
	if(ishuman(src))
		evo_holder = mind.godcultist?.evo_holder

	var/datum/evolution_package/package
	for(var/datum/evolution_category/cat in evo_holder.evolution_categories)
		package = locate(package_type) in cat.items
		if(istype(package))
			break

	if(!istype(package))
		return

	if(locate(package_type) in evo_holder.unlocked_packages)
		return

	package.evolve(src)

/mob/living/deity/proc/reward_follower(follower_ref = null)
	if(isnull(follower_ref))
		return

	var/datum/mind/M = locate(follower_ref) in followers
	var/mob/living/carbon/current = M?.current
	if(!istype(current))
		return

	next_reward_act = world.time + DEITY_REWARD_COOLDOWN

	current.adjustBruteLoss(-15)
	current.adjustFireLoss(-15)
	current.adjustToxLoss(-15)
	current.adjustOxyLoss(-15)
	current.adjustBrainLoss(-5)
	current.updatehealth()
	to_chat(current, SPAN_NOTICE("You feel a rush of pleasant energy!"))

/mob/living/deity/proc/punish_follower(follower_ref = null)
	if(isnull(follower_ref))
		return

	var/datum/mind/M = locate(follower_ref) in followers
	var/mob/living/carbon/current = M?.current
	if(!istype(current))
		return

	next_punish_act = world.time + DEITY_PUNISH_COOLDOWN

	var/turf/lightning_source = get_step(get_step(current, NORTH), NORTH)
	lightning_source.Beam(current, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(get_turf(current), 'sound/magic/sound_magic_lightningbolt.ogg', 50, TRUE)
	var/burn_damage = current.electrocute_act(40, src, def_zone = pick(BP_ALL_LIMBS))
	if(burn_damage > 15 && current.can_feel_pain())
		current.emote(pick("scream", "scream_long"))

/mob/living/deity/verb/choose_form()
	set name = "Deity Menu"
	set category = "Godhood"

	tgui_interact(src)

/mob/living/deity/proc/open_building_menu()
	tgui_interact(src)
