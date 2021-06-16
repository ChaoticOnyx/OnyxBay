/client/verb/ooc(message as text)
	set name = "OOC"
	set category = "OOC"

	if(src.mob && jobban_isbanned(src.mob, "OOC"))
		to_chat(src, "<span class='danger'>You have been banned from OOC.</span>")
		return

	var/sanitizedMessage = sanitize(message)
	mob.log_message("[key]: [sanitizedMessage]", INDIVIDUAL_OOC_LOG)
	communicate(/decl/communication_channel/ooc, src, sanitizedMessage)

/client/verb/looc(message as text)
	set name = "LOOC"
	set desc = "Local OOC, seen only by those in view. Remember: Just because you see someone that doesn't mean they see you."
	set category = "OOC"

	if(jobban_isbanned(src.mob, "LOOC"))
		to_chat(src, "<span class='danger'>You have been banned from LOOC.</span>")
		return

	sanitize_and_communicate(/decl/communication_channel/ooc/looc, src, message)

/client/verb/bot_token(token as text)
	set name = "Bot token"
	set category = "OOC"
	set desc = "Sends specific token to bot through webhook"

	webhook_send_token(key, token)

/client/verb/stop_all_sounds()
	set name = "Stop all sounds"
	set desc = "Stop all sounds that are currently playing."
	set category = "OOC"

	if(!mob)
		return

	sound_to(mob, sound(null))

/client/verb/fix_hotkeys()
	set name = "Fix hotkeys"
	set category = "OOC"

	if(!(isghost(mob) || isliving(mob)))
		return

	if(alert(usr, "Are you sure? You have to switch to the English keyboard layout first.\nWarning: This will close all open windows.", "Fix hotkeys", "Yes", "No") == "Yes")
		nuke_chat()
