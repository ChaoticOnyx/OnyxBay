GLOBAL_LIST_INIT(all_ui_styles, list(
	"Minimalist"   	= 'icons/hud/style/minimalist.dmi',
	"Midnight"     	= 'icons/hud/style/midnight.dmi',
	"Orange"       	= 'icons/hud/style/orange.dmi',
	"White"       	= 'icons/hud/style/white.dmi',
	"Goon"          = 'icons/hud/style/goon.dmi',
	"Old"          	= 'icons/hud/style/old.dmi',
	"Old-noborder"  = 'icons/hud/style/old-noborder.dmi'
))

/proc/ui_style2icon(ui_style)
	return GLOB.all_ui_styles[ui_style] || GLOB.all_ui_styles[GLOB.all_ui_styles[1]]

/client/proc/update_ui()
	if(!usr.hud_used) // usr's a new_player, s'too early to update things
		return

	var/list/icons = usr.hud_used.static_inventory + usr.hud_used.toggleable_inventory
	icons.Add(usr.zone_sel)
	icons.Add(usr.gun_setting_icon)
	icons.Add(usr.item_use_icon)
	icons.Add(usr.gun_move_icon)
	icons.Add(usr.radio_use_icon)

	var/icon/ic = GLOB.all_ui_styles[prefs.UI_style]

	for(var/atom/movable/screen/I in icons)
		if(I.name in list(I_HELP, I_HURT, I_DISARM, I_GRAB))
			I.icon = ic
			continue
		I.icon = ic
		I.color = prefs.UI_style_color
		I.alpha = prefs.UI_style_alpha
