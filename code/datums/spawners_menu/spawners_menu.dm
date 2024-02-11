/datum/spawners_menu
	var/mob/observer/ghost/owner

/datum/spawners_menu/New(mob/observer/ghost/new_owner)
	if(!istype(new_owner))
		qdel(src)
	owner = new_owner

/datum/spawners_menu/Destroy()
	owner = null
	return ..()

/datum/spawners_menu/tgui_state(mob/user)
	return GLOB.tgui_observer_state

/datum/spawners_menu/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SpawnersMenu", "Spawners Menu")
		ui.open()

/datum/spawners_menu/tgui_static_data(mob/user)
	var/list/data = list()
	data["spawners"] = list()
	for(var/spawner_ref in GLOB.mob_spawners)
		var/obj/effect/mob_spawn/ghost_role/spawner_atom = GLOB.mob_spawners[spawner_ref]
		if(!spawner_atom.allow_spawn(user, TRUE))
			continue
		var/list/obj_data = list()
		obj_data["spawner_ref"] = spawner_ref
		obj_data["name"] = spawner_atom
		obj_data["origin"] = spawner_atom.you_are_text
		obj_data["directives"] = spawner_atom.flavour_text
		obj_data["conditions"] = spawner_atom.important_text
		obj_data["amount_left"] = spawner_atom.uses

		if(obj_data["amount_left"] > 0)
			data["spawners"] += list(obj_data)

	for(var/possessable_ref in GLOB.available_mobs_for_possess)
		var/list/obj_data = list()
		var/mob/possessable = GLOB.available_mobs_for_possess[possessable_ref]
		obj_data["spawner_ref"] = possessable_ref
		obj_data["name"] = possessable.name
		obj_data["origin"] = ""
		obj_data["directives"] = ""
		obj_data["conditions"] = ""
		obj_data["amount_left"] = 1
		data["spawners"] += list(obj_data)
	return data

/datum/spawners_menu/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/spawner_ref = params["spawner_ref"]
	if(!spawner_ref)
		return
	var/is_spawner_ghost_role = FALSE
	var/chosen_spawner
	if(spawner_ref in GLOB.mob_spawners)
		var/obj/effect/mob_spawn/ghost_role/spawner = GLOB.mob_spawners[spawner_ref]
		if(!istype(spawner))
			return
		if(!spawner.allow_spawn(owner, TRUE))
			return
		is_spawner_ghost_role = TRUE
		chosen_spawner = spawner
	else
		if(!(spawner_ref in GLOB.available_mobs_for_possess))
			return
		chosen_spawner = GLOB.available_mobs_for_possess[spawner_ref]

	switch(action)
		if("jump")
			owner.ManualFollow(chosen_spawner)
			return
		if("spawn")
			ui.close()
			if(is_spawner_ghost_role)
				handle_ghost_role(chosen_spawner)
			else
				handle_possesion(chosen_spawner)
			return

/datum/spawners_menu/proc/handle_ghost_role(_spawner)
	var/obj/effect/mob_spawn/ghost_role/spawner = _spawner
	owner.ManualFollow(spawner)
	spawner.attack_ghost(owner)
	return

/datum/spawners_menu/proc/handle_possesion(_possessable)
	var/mob/possessable = _possessable
	owner.ManualFollow(possessable)
	if(!("\ref[possessable]" in GLOB.available_mobs_for_possess))
		to_chat(owner, SPAN_NOTICE("Unnable to posses mob!"))
		return
	if(tgui_alert(owner, "Become [possessable.name]?","Possesing mob",list("Yes","No")) == "Yes")
		owner.try_to_occupy(possessable)
	return
