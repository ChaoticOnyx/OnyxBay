/mob/living/deity
	var/self_click_cooldown = 30
	var/last_click = 0

	var/static/radial_buildings = image(icon = 'icons/hud/screen_spells.dmi', icon_state = "const_pylon")
	var/static/radial_phenomena = image(icon = 'icons/hud/screen_spells.dmi', icon_state = "wiz_fireball")
	var/static/radial_boons = image(icon = 'icons/hud/screen_spells.dmi', icon_state = "master_open")

	var/static/list/radial_options = list("Buildings" = radial_buildings, "Phenomena" = radial_phenomena, "Boons" = radial_boons)

	var/datum/radial_menu/radial_menu

/mob/living/deity/Destroy()
	QDEL_NULL(radial_menu)
	return ..()

/mob/living/deity/ClickOn(atom/A, params)
	var/list/modifiers = params2list(params)

	if(modifiers["middle"])
		show_radial(A)
		return

	if(A == src)
		tgui_interact(src)
		return

	else if(istype(A, /obj/structure/deity))
		var/obj/structure/deity/struct = A
		struct.deity_click(src)
		return

	else if(istype(selected_power))
		selected_power.manifest(A, src)

/mob/living/deity/proc/show_radial(atom/A)
	if(!form)
		return

	var/datum/deity_power/choice
	var/category = deity_radial_menu(usr, A, radial_options)
	switch(category)
		if("Buildings")
			choice = deity_radial_menu(usr, A, form.buildables)
		if("Phenomena")
			choice = deity_radial_menu(usr, A, form.phenomena)
		if("Boons")
			choice = deity_radial_menu(usr, A, form.boons)

	set_selected_power(choice, form.phenomena)

/mob/living/deity/proc/deity_radial_menu(user, atom/anchor, list/choices)
	QDEL_NULL(radial_menu)
	radial_menu = new
	radial_menu.anchor = anchor
	radial_menu.check_screen_border(user)
	radial_menu.set_choices(choices)
	radial_menu.show_to(user)
	radial_menu.wait(user, anchor)
	var/answer = radial_menu.selected_choice
	QDEL_NULL(radial_menu)
	return answer

/mob/living/deity/proc/self_click()
	return
