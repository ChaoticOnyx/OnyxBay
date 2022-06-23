

/var/all_ui_styles = list(
	"Goon"			= 'icons/mob/screen/goon.dmi',
	"Midnight"     	= 'icons/mob/screen/midnight.dmi',
	"Orange"       	= 'icons/mob/screen/orange.dmi',
	"old"          	= 'icons/mob/screen/old.dmi',
	"White"        	= 'icons/mob/screen/white.dmi',
	"old-noborder" 	= 'icons/mob/screen/old-noborder.dmi',
	"minimalist"   	= 'icons/mob/screen/minimalist.dmi'
)

/proc/ui_style2icon(ui_style)
	if(ui_style in all_ui_styles)
		return all_ui_styles[ui_style]
	return all_ui_styles["White"]


/client/proc/update_ui()
	if(!usr.hud_used) // usr's a new_player, s'too early to update things
		return
	var/list/icons = usr.hud_used.adding + usr.hud_used.other + usr.hud_used.hotkeybuttons
	icons.Add(usr.zone_sel)
	icons.Add(usr.gun_setting_icon)
	icons.Add(usr.item_use_icon)
	icons.Add(usr.gun_move_icon)
	icons.Add(usr.radio_use_icon)

	var/icon/ic = all_ui_styles[prefs.UI_style]

	for(var/obj/screen/I in icons)
		if(I.name in list(I_HELP, I_HURT, I_DISARM, I_GRAB))
			continue
		I.icon = ic
		I.color = prefs.UI_style_color
		I.alpha = prefs.UI_style_alpha
