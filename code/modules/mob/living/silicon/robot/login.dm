/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	update_hud()

	show_laws(0)

	var/hotkey_mode = client.get_preference_value("DEFAULT_HOTKEY_MODE")
	if(hotkey_mode == GLOB.PREF_YES)
		winset(src, null, "mainwindow.macro=borghotkeymode hotkey_toggle.is-checked=true input.focus=false input.background-color=#F0F0F0")
	else
		winset(src, null, "mainwindow.macro=borgmacro hotkey_toggle.is-checked=false input.focus=true input.background-color=#d3b5b5")


	// Forces synths to select an icon relevant to their module
	if(!icon_selected)
		choose_hull(icon_selection_tries, module_hulls)
