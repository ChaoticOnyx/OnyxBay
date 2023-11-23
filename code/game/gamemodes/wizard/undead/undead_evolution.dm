var/list/undead_powers = typesof(/datum/power/undead) - /datum/power/undead

/datum/spell/undead/undead_evolution
	name = "Undead Evolution"
	desc = "Undead Evolution"
	feedback = "" /// IDK WHAT IT DOES, TODO: understand var/feedback
	school = "necromancy"
	var/spell_type = null
	spell_flags = INCLUDEUSER
	icon_state = "undead_evolution"

/datum/spell/undead/choose_targets(mob/user)
	return user

/datum/spell/undead/undead_evolution/cast(mob/target, mob/user)
	var/datum/wizard/undead = user.mind.wizard
	undead.tgui_interact(usr)

/datum/wizard/undead/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/wizard/undead/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Undead", "Undead Evolution")
		ui.open()

/datum/wizard/tgui_static_data(mob/user)
	var/static/icon/spell_background = new /icon('icons/hud/screen_spells.dmi', "const_spell_base")
	var/static/icon/spell_unlocked_background = new /icon('icons/hud/screen_spells.dmi', "const_spell_ready")

	return list(
		"icons" = list(
			"spell_background" = icon2base64html(spell_background),
			"spell_unlocked_background" = icon2base64html(spell_unlocked_background)
		)
	)

/datum/wizard/tgui_data(mob/user)
	var/datum/wizard/undead/undead = user.mind.wizard

	if(!undead.undead_powerinstances.len)
		return

	var/list/data = list(
		"powers" = list(),
		"points" = undead.growth
	)

	for(var/datum/power/undead/power in undead.undead_powerinstances)
		var/list/power_data = list(
			"name" = power.name,
			"icon" = icon2base64html(power.power_item_type),
			"description" = power.desc,
			"cost" = power.price
		)

		if(power in undead.purchased_powers)
			power_data["owned"] = TRUE
		else
			power_data["owned"] = FALSE

		data["powers"] += list(power_data)

	return data

/datum/wizard/undead/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("mutate")
			mutate(params["name"])
			return TRUE

/datum/wizard/undead/proc/mutate(power_name)
	var/datum/power/undead/PC
	for(var/datum/power/undead/P in powerinstances)
		if(P.name == power_name)
			PC = P
			break

	if(!PC)
		CRASH("Invalid power name [power_name]")

	if(PC in purchased_powers)
		to_chat(my_mob, SPAN("changeling", "We have already evolved this ability!"))
		return

	purchased_powers += PC
