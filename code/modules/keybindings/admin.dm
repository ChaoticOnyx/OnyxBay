/datum/keybinding/admin
	category = CATEGORY_ADMIN

/datum/keybinding/admin/can_use(client/user)
	return !!user.holder

/datum/keybinding/admin/modchat
	hotkey_keys = list("F5")
	name = "msay"
	full_name = "ModChat"
	description = "Talk with other admins."

/datum/keybinding/admin/modchat/down(client/user)
	user.get_mod_say()
	return TRUE

/datum/keybinding/admin/list_players
	hotkey_keys = list("F6")
	name = "list_players"
	full_name = "List Players"
	description = "Opens up the list players panel"

/datum/keybinding/admin/list_players/down(client/user)
	user.player_panel_new()
	return TRUE

/datum/keybinding/admin/view_tickets
	hotkey_keys = list("F7")
	name = "view_tickets"
	full_name = "Tickets"
	description = "View TIckets"

/datum/keybinding/admin/view_tickets/down(client/user)
	user.view_tickets()
	return TRUE

/datum/keybinding/admin/banpanel
	hotkey_keys = list("F8")
	name = "banpanel"
	full_name = "Banning Panel"
	description = "Banning Panel for badmins."

/datum/keybinding/admin/banpanel/down(client/user)
	user.DB_ban_panel()
	return TRUE

/datum/keybinding/admin/asay
	hotkey_keys = list("F9")
	name = "asay"
	full_name = "Admin Say"
	description = "Secret chat for admins."

/datum/keybinding/admin/asay/down(client/user)
	user.get_admin_say()
	return TRUE

/datum/keybinding/admin/aghost
	hotkey_keys = list("F10")
	name = "aghost"
	full_name = "Aghost"
	description = "Spooky scary pedalique ghost."

/datum/keybinding/admin/aghost/down(client/user)
	user.admin_ghost()
	return TRUE

/datum/keybinding/admin/buildmode
	hotkey_keys = list("F11")
	name = "buildmode"
	full_name = "Buildmode (self)"
	description = "Toggles buildmode."

/datum/keybinding/admin/buildmode/down(client/user)
	user.togglebuildmodeself()
	return TRUE

/datum/keybinding/admin/deadmin
	hotkey_keys = list("None")
	name = "deadmin"
	full_name = "De-Admin"
	description = "Shed your admin powers"

/datum/keybinding/admin/deadmin/down(client/user)
	user.deadmin_self()
	return TRUE

/datum/keybinding/admin/readmin
	hotkey_keys = list("None")
	name = "readmin"
	full_name = "Re-Admin"
	description = "Regain your admin powers"

/datum/keybinding/admin/readmin/down(client/user)
	user.readmin_self()
	return TRUE

/client/proc/get_admin_say()
	var/msg = input(src, null, "asay \"text\"") as text|null
	cmd_admin_say(msg)

/client/proc/get_mod_say()
	var/msg = input(src, null, "msay \"text\"") as text
	get_mod_say(msg)
