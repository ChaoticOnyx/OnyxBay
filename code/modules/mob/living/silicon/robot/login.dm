/mob/living/silicon/robot/Login()
	..()
	regenerate_icons()
	update_hud()

	show_laws(0)

	if(!icon_chosen)
		choose_hull(module_hulls)
