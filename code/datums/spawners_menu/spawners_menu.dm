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
	for(var/spawner in GLOB.mob_spawners)
		var/list/obj_data = list()
		obj_data["name"] = spawner
		obj_data["origin"] = ""
		obj_data["directives"] = ""
		obj_data["conditions"] = ""
		obj_data["amount_left"] = 0
		for(var/spawner_atom as anything in GLOB.mob_spawners[spawner])
			if(!obj_data["origin"])
				if(istype(spawner_atom, /obj/effect/mob_spawn/ghost_role))
					var/obj/effect/mob_spawn/ghost_role/mob_spawner = spawner_atom
					if(!mob_spawner.allow_spawn(user, TRUE))
						continue
					obj_data["origin"] = mob_spawner.you_are_text
					obj_data["directives"] = mob_spawner.flavour_text
					obj_data["conditions"] = mob_spawner.important_text
				else
					var/atom/atom_spawner = spawner_atom
					obj_data["origin"] = atom_spawner.desc
			obj_data["amount_left"] += 1

		if(obj_data["amount_left"] > 0)
			data["spawners"] += list(obj_data)

	return data

/datum/spawners_menu/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/group_name = params["name"]
	if(!group_name || !(group_name in GLOB.mob_spawners))
		return
	if(!length(GLOB.mob_spawners[group_name]))
		return

	var/list/chosen_spawners = GLOB.mob_spawners[group_name]
	for(var/mob_spawner in chosen_spawners)
		var/obj/effect/mob_spawn/ghost_role/role_spawner = mob_spawner
		if(!istype(role_spawner))
			break
		if(role_spawner.allow_spawn(owner, TRUE))
			continue
		chosen_spawners -= role_spawner

	if(!length(chosen_spawners))
		return

	var/atom/chosen_spawner = pick(chosen_spawners)
	switch(action)
		if("jump")
			owner.ManualFollow(chosen_spawner)
			return TRUE
		if("spawn")
			owner.ManualFollow(chosen_spawner)
			ui.close()
			chosen_spawner.attack_ghost(owner)
			return TRUE
