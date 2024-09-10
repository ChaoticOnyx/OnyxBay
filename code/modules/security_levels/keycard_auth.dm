#define INACTIVE 0
#define CALL_ERT 1
#define GRANT_MAINT 2
#define REVOKE_MAINT 3
#define GRANT_NUCLEAR_CODE 4

/obj/machinery/keycard_auth
	name = "Keycard Authentication Device"
	desc = "This device is used to trigger functions which require more than one ID card to authenticate."
	icon = 'icons/obj/monitors.dmi'
	icon_state = "auth_off"

	// 3 vars here as booleans produce 4 relevant state:
	//  (!!auth_proxy)<<2 | (!!trigger_id)<<1 | (active_event != INACTIVE)
	// 000 -- Standby, waiting for an event to be selected
	// 001 -- Event selected, waiting for causer to swipe ID
	// 011 -- Causer waits for confirmation
	// 100 -- Wait for confirmer's ID
	var/active_event = INACTIVE
	var/event_reason = ""

	var/obj/machinery/keycard_auth/auth_proxy
	var/obj/item/card/id/trigger_id

	var/confirm_delay = 3 SECONDS

	var/mob/triggered_by = null
	var/mob/confirmed_by = null

	anchored = 1.0
	idle_power_usage = 2 WATTS
	active_power_usage = 6 WATTS
	power_channel = STATIC_ENVIRON

	/// Whether we have active thinking to call ert or not
	var/ert_context_thinking = FALSE

/obj/machinery/keycard_auth/Initialize()
	. = ..()
	add_think_ctx("call_ert_context", CALLBACK(src, nameof(.proc/call_ert)), 0)

/obj/machinery/keycard_auth/attack_ai(mob/user)
	to_chat(user, SPAN_WARNING("A firewall prevents you from interfacing with this device!"))
	return

/obj/machinery/keycard_auth/attackby(obj/item/W, mob/user)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, SPAN_WARNING("This device is not powered."))
		return

	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/id = W

		if (src.auth_proxy)
			if (src.auth_proxy.try_confirm(id, user))
				visible_message(SPAN_INFO("\The [src] blinks and displays a message: Confirmed."), range=2)
				src.reset()
			else
				visible_message(SPAN_WARNING("\The [src] blinks and displays a message: Unable to confirm the event with the same card."), range=2)
		else if (src.active_event == INACTIVE || src.trigger_id)
			visible_message(SPAN_NOTICE("\The [user] swipes \the [id] through \the [src], but nothing happens."))
		else if (!(access_keycard_auth in id.access))
			visible_message(SPAN_NOTICE("\The [user] swipes \the [id] through \the [src], but it's declined."))
		else
			visible_message(SPAN_NOTICE("\The [user] swipes \the [id] through \the [src] and it's accepted."))
			src.do_proxy(id, user)

/obj/machinery/keycard_auth/proc/do_proxy(obj/item/card/id/trigger_id, mob/triggerer)
	src.icon_state = "auth_on"
	src.trigger_id = trigger_id
	src.triggered_by = triggerer

	for(var/obj/machinery/keycard_auth/KA in world)
		if(KA == src)
			continue

		if (!KA.auth_proxy)
			KA.auth_proxy = src
			KA.icon_state = "auth_on"
			spawn(src.confirm_delay)
				if (KA.auth_proxy == src)
					KA.reset()

	sleep(src.confirm_delay)

	if (src.trigger_id)
		visible_message(SPAN_INFO("\The [src] blinks and displays a message: Confirmation failure."), range=2)

		src.reset()

/obj/machinery/keycard_auth/proc/try_confirm(obj/item/card/id/second_id, mob/confirmer)
	if (!src.trigger_id || src.trigger_id == second_id)
		return FALSE

	visible_message(SPAN_INFO("\The [src] blinks and displays a message: Confirmed."), range=2)
	log_game("[key_name(src.triggered_by)] triggered and [key_name(confirmer)] confirmed event [src.active_event]")
	message_admins("[key_name(src.triggered_by)] triggered and [key_name(confirmer)] confirmed event [src.active_event]", 1)

	src.cause_event()
	src.reset()

	return TRUE

//icon_state gets set everwhere besides here, that needs to be fixed sometime
/obj/machinery/keycard_auth/on_update_icon()
	if(stat & NOPOWER)
		icon_state = "auth_off"

/obj/machinery/keycard_auth/proc/reset()
	src.active_event = INACTIVE
	src.event_reason = ""
	src.icon_state = "auth_off"
	src.auth_proxy = null
	src.trigger_id = null
	src.triggered_by = null
	src.confirmed_by = null

/obj/machinery/keycard_auth/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		to_chat(user, "This device is not powered.")
		return
	if(!user.IsAdvancedToolUser())
		return 0
	if(src.trigger_id)
		to_chat(user, "This device is busy.")
		return

	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\"><h1>Keycard Authentication Device</h1>"

	dat += "This device is used to trigger some high security events. It requires the simultaneous swipe of two high-level ID cards."
	dat += "<br><hr><br>"

	if(src.active_event == INACTIVE)
		dat += "Select an event to trigger:<ul>"

		if(!config.gamemode.ert_admin_only)
			dat += "<li><A href='?src=\ref[src];triggerevent=[CALL_ERT]'>Emergency Response Team</A></li>"

		dat += "<li><A href='?src=\ref[src];triggerevent=[GRANT_MAINT]'>Grant Emergency Maintenance Access</A></li>"
		dat += "<li><A href='?src=\ref[src];triggerevent=[REVOKE_MAINT]'>Revoke Emergency Maintenance Access</A></li>"
		dat += "<li><A href='?src=\ref[src];triggerevent=[GRANT_NUCLEAR_CODE]'>Grant Nuclear Authorization Code</A></li>"
		dat += "</ul>"
		show_browser(user, dat, "window=keycard_auth;size=500x250")
	else
		var/event = "Standby"
		switch (src.active_event)
			if (CALL_ERT)
				event = "Call Emergency Response Team"
			if (GRANT_MAINT)
				event = "Grant Emergency Maintenance Access"
			if (REVOKE_MAINT)
				event = "Revoke Emergency Maintenance Access"
			if (GRANT_NUCLEAR_CODE)
				event = "Grant Nuclear Authorization Code"

		dat += "Please swipe your card to authorize the following event: <b>[event]</b>"
		if (src.event_reason)
			dat += "<br>Reason: [src.event_reason]<br>"
		dat += "<p><A href='?src=\ref[src];reset=1'>Back</A>"
		show_browser(user, dat, "window=keycard_auth;size=500x250")
	return

/obj/machinery/keycard_auth/CanUseTopic(mob/user, href_list)
	if(src.auth_proxy)
		to_chat(user, "This device is busy.")
		return STATUS_CLOSE
	if(!user.IsAdvancedToolUser())
		to_chat(user, FEEDBACK_YOU_LACK_DEXTERITY)
		return min(..(), STATUS_UPDATE)
	return ..()

/obj/machinery/keycard_auth/OnTopic(user, href_list)
	if(href_list["triggerevent"])
		src.active_event = text2num(href_list["triggerevent"])
		src.event_reason = ""

		if(src.active_event == CALL_ERT)
			event_reason = sanitize(input(user, "Enter call reason", "Call reason") as message, extra=FALSE)

		. = TOPIC_REFRESH

	if(href_list["reset"])
		src.active_event = INACTIVE
		src.event_reason = ""

		. = TOPIC_REFRESH

	if(is_admin(user) && href_list["approve_ert"])
		set_next_think_ctx("call_ert_context", 0)
		ert_context_thinking = FALSE
		call_ert()

	if(is_admin(user) && href_list["prohibit_ert"])
		set_next_think_ctx("call_ert_context", 0)
		ert_context_thinking = FALSE
		if(!((stat & BROKEN) || (!interact_offline && (stat & NOPOWER))))
			visible_message(SPAN_DANGER("\The [src] blinks red and displays the message: The request was rejected, contact the corporate supervisors for the reason of the rejection."), range=2)

	if(. == TOPIC_REFRESH)
		attack_hand(user)

	if(stat & (BROKEN|NOPOWER))
		return

/obj/machinery/keycard_auth/proc/cause_event()
	switch(src.active_event)
		if(GRANT_MAINT)
			make_maint_all_access()
			feedback_inc("alert_keycard_auth_maintGrant",1)
		if(REVOKE_MAINT)
			revoke_maint_all_access()
			feedback_inc("alert_keycard_auth_maintRevoke",1)
		if(CALL_ERT)
			if(ert_call_failure())
				return
			if(!ert_context_thinking)
				visible_message(SPAN_NOTICE("\The [src] displays the message: The request has been created and the process of transferring the request to the emergency response service has been started, the approximate waiting time for processing is 2 minutes."), range=2)
				set_next_think_ctx("call_ert_context", world.time + 2 MINUTES)
				ert_context_thinking = TRUE
				message_admins("An ERT call request was created with the reason:\n[src.event_reason].\nThis call will automatically be approved after 2 minutes. <A href='?src=\ref[src];approve_ert=1'>Approve</a>. <A href='?src=\ref[src];prohibit_ert=1'>Reject</a>.")
		if(GRANT_NUCLEAR_CODE)
			var/obj/machinery/nuclearbomb/nuke = locate(/obj/machinery/nuclearbomb/station) in world
			if(nuke)
				visible_message(SPAN_WARNING("\The [src] blinks and displays a message: The nuclear authorization code is [nuke.r_code]"), range=2)
			else
				visible_message(SPAN_WARNING("\The [src] blinks and displays a message: No self destruct terminal found."), range=2)
			feedback_inc("alert_keycard_auth_nukecode",1)

/obj/machinery/keycard_auth/proc/ert_call_failure()
	var/decl/security_state/security_state = decls_repository.get_decl(GLOB.using_map.security_state)
	if(security_state.current_security_level_is_lower_than(security_state.high_security_level)) // Allow admins to reconsider if the alert level is below High
		visible_message(SPAN_WARNING("\The [src] flashes red and displays a message: The emergency response team can only be called if the station is in emergency mode, high security level is mandatory."), range=2)
		return TRUE
	if(is_ert_blocked())
		visible_message(SPAN_WARNING("\The [src] blinks and displays a message: All emergency response teams are dispatched and can not be called at this time."), range=2)
		return TRUE
	return FALSE

/obj/machinery/keycard_auth/proc/call_ert()
	ert_context_thinking = FALSE
	if(ert_call_failure())
		return

	visible_message(SPAN_NOTICE("\The [src] displays the message: The request has been approved, the response team will be on facility shortly."), range=2)
	trigger_armed_response_team(TRUE, src.event_reason)
	feedback_inc("alert_keycard_auth_ert",1)

/obj/machinery/keycard_auth/proc/is_ert_blocked()
	if(config.gamemode.ert_admin_only) return 1
	return SSticker.mode && SSticker.mode.ert_disabled

var/global/maint_all_access = 0

/proc/make_maint_all_access()
	maint_all_access = 1
	to_world("<font size=4 color='red'>Attention!</font>")
	to_world("<font color='red'>The maintenance access requirement has been revoked on all airlocks.</font>")

/proc/revoke_maint_all_access()
	maint_all_access = 0
	to_world("<font size=4 color='red'>Attention!</font>")
	to_world("<font color='red'>The maintenance access requirement has been readded on all maintenance airlocks.</font>")

/obj/machinery/door/airlock/allowed(mob/M)
	if(maint_all_access && src.check_access_list(list(access_maint_tunnels)))
		return 1
	return ..(M)

#undef INACTIVE
#undef CALL_ERT
#undef GRANT_MAINT
#undef REVOKE_MAINT
#undef GRANT_NUCLEAR_CODE
