/obj/machinery/computer/shuttle
	name = "Shuttle"
	desc = "For shuttle control."
	icon_keyboard = "tech_key"
	icon_screen = "shuttle"
	light_color = "#00ffff"
	var/auth_need = 3.0
	var/list/authorized = list()


/obj/machinery/computer/shuttle/attackby(obj/item/card/W, mob/user)
	if(stat & (BROKEN|NOPOWER))
		return

	if(!user)
		return

	var/datum/evacuation_controller/shuttle/evac_control = evacuation_controller
	if(!istype(evac_control))
		to_chat(user, SPAN("danger", "This console should not in use on this map. Please report this to a developer."))
		return

	if(evacuation_controller.has_evacuated())
		return

	if(istype(W, /obj/item/card/id) || istype(W, /obj/item/device/pda))
		var/obj/item/card/id/ID = W
		if(istype(W, /obj/item/device/pda))
			var/obj/item/device/pda/pda = W
			ID = pda.id

		if(!length(ID.access)) // no access
			to_chat(user, "The access level of [ID.registered_name]\'s card is not high enough. ")
			return

		if(!(access_heads in ID.access)) // doesn't have this access
			to_chat(user, "The access level of [ID.registered_name]\'s card is not high enough. ")
			return

		var/choice = alert(user, text("Would you like to (un)authorize a shortened launch time? [] authorization\s are still needed. Use abort to cancel all authorizations.", auth_need - length(authorized)), "Shuttle Launch", "Authorize", "Repeal", "Abort")
		if(evacuation_controller.is_prepared() && user.get_active_hand() != W)
			return

		switch(choice)
			if("Authorize")
				authorized.Remove(ID.registered_name)
				authorized.Add(ID.registered_name)

				if(auth_need - length(authorized) > 0)
					message_admins("[key_name_admin(user)] has authorized early shuttle launch")
					log_game("[user.ckey] has authorized early shuttle launch")
					to_world(text("<span class='notice'><b>Alert: [] authorizations needed until shuttle is launched early</b></span>", auth_need - length(authorized)))
				else
					message_admins("[key_name_admin(user)] has launched the shuttle")
					log_game("[user.ckey] has launched the shuttle early")
					to_world(SPAN("notice", "<b>Alert: Shuttle launch time shortened to 10 seconds!</b>"))
					evacuation_controller.set_launch_time(world.time+100)
					authorized.Cut()

			if("Repeal")
				authorized.Remove(ID.registered_name)
				to_world(text("<span class='notice'><b>Alert: [] authorizations needed until shuttle is launched early</b></span>", auth_need - length(authorized)))

			if("Abort")
				to_world(SPAN("notice", "<b>All authorizations to shortening time for shuttle launch have been revoked!</b>"))
				authorized.Cut()

	return

/obj/machinery/computer/shuttle/emag_act(remaining_charges, mob/user)
	if(emagged)
		return NO_EMAG_ACT

	if(evacuation_controller.is_prepared())
		return NO_EMAG_ACT

	var/choice = alert(user, "Would you like to launch the shuttle?", "Shuttle control", "Launch", "Cancel")

	if(evacuation_controller.is_prepared())
		return NO_EMAG_ACT // Classical post-alert recheck

	if(choice == "Launch")
		to_world(SPAN("notice", "<b>Alert: Shuttle launch time shortened to 10 seconds!</b>"))
		evacuation_controller.set_launch_time(world.time + 10 SECONDS)
		emagged = TRUE
		return 1

	return NO_EMAG_ACT
