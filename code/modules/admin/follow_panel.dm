/datum/follow_panel/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "FollowPanel", "Follow Panel")
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/follow_panel/tgui_data(mob/user)
	var/list/data = list(
		"targets" = list()
	)

	var/list/targets = get_follow_targets() || list()

	for(var/datum/follow_holder/H in targets)
		var/atom/movable/I = H.followed_instance
		var/mob/M = ismob(I) ? I : null
		var/turf/T = get_turf(I)

		var/list/target_data = list(
			"name" = I.name,
			"position" = list(I.loc.x, I.loc.y, I.loc.z),
			"area" = T?.loc?.name || "(nullspace)",
			"isGhost" = isghost(I),
			"isMob" = !!M,
			"hasClient" = !!I.get_client(),
			"ckey" = M?.ckey,
			"ref" = "\ref[I]"
		)

		data["targets"] += list(target_data)

	return data

/datum/follow_panel/tgui_act(action, params)
	. = ..()

	if(.)
		return

	if(!usr.has_admin_rights())
		return TRUE

	if(!isghost(usr))
		to_chat(usr, SPAN("warning", "Follow is usable only in a ghost form."))
		return TRUE

	var/mob/observer/ghost/G = usr

	switch(action)
		if("follow")
			ASSERT(params["ref"])
			var/atom/movable/T = locate(params["ref"])

			if(!T)
				to_chat(usr, SPAN("warning", "Target not found."))
				return TRUE

			G.ManualFollow(T)

			return TRUE

/datum/follow_panel/tgui_state(mob/user)
	return GLOB.tgui_always_state
