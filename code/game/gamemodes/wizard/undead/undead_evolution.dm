var/list/undead_powers = typesof(/datum/power/undead) - /datum/power/undead

/datum/spell/undead/undead_evolution
	name = "Undead Evolution"
	desc = "Undead Evolution"
	feedback = "" /// IDK WHAT IT DOES, TODO: understand var/feedback
	school = "necromancy"
	var/spell_type = null
	spell_flags = INCLUDEUSER

/datum/spell/undead/choose_targets(mob/user)
	return user

/datum/spell/undead/undead_evolution/cast(mob/target, mob/user)
	//target.add_spell(new spell_type)
	//target.remove_spell(src)
	var/datum/wizard/undead = user.mind.wizard
	undead.tgui_interact(usr)

/datum/wizard/undead/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/wizard/undead/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Undead", "Undead Evolution")
		ui.open()

/datum/wizard/undead/tgui_static_data(mob/user)
	if(!undead_powerinstances.len)
		for(var/datum/power/undead/power in undead_powers)
			undead_powerinstances += new power

	var/list/data = list()
	data["powers"] = list()
	for(var/datum/power/undead/power in undead_powerinstances)
		var/list/obj_data = list()
		obj_data["name"] = power.name
		obj_data["icon"] = power.icon
		obj_data["description"] = power.desc
		obj_data["price"] = power.price
		obj_data["owned"] = power.owned

		data["powers"] += list(obj_data)

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
