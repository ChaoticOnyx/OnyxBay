/proc/pick_closest_path(value, list/matches = get_fancy_list_of_atom_types())
	if (value == FALSE) //nothing should be calling us with a number, so this is safe
		value = input("Enter type to find (blank for all, cancel to cancel)", "Search for type") as null|text
		if (isnull(value))
			return
	value = trim(value)

	var/random = FALSE
	if(findtext(value, "?"))
		value = replacetext(value, "?", "")
		random = TRUE

	if(!isnull(value) && value != "")
		matches = filter_fancy_list(matches, value)

	if(matches.len == 0)
		return

	var/chosen
	if(matches.len == 1)
		chosen = matches[1]
	else if(random)
		chosen = pick(matches) || null
	else
		chosen = input("Select a type", "Pick Type", matches[1]) as null|anything in sort_list(matches)
	if(!chosen)
		return
	chosen = matches[chosen]
	return chosen

/client/proc/spawn_liquid()
	set category = "Debug"
	set name = "Spawn Liquid"

	var/choice
	var/valid_id
	while(!valid_id)
		choice = tgui_input_text(usr, "Enter the ID of the reagent you want to add.", "Search reagents")
		if(isnull(choice)) //Get me out of here!
			break
		if (!ispath(text2path(choice)))
			choice = pick_closest_path(choice, make_types_fancy(subtypesof(/datum/reagent)))
			if (ispath(choice))
				valid_id = TRUE
		else
			valid_id = TRUE
		if(!valid_id)
			to_chat(usr, SPAN_WARNING("A reagent with that ID doesn't exist!"))
	if(!choice)
		return
	var/volume = tgui_input_number(usr, "Volume:", "Choose volume")
	if(!volume)
		return
	var/turf/epicenter = get_turf(mob)
	epicenter.add_liquid(choice, volume)
	message_admins("[usr] ([usr.ckey]) spawned liquid at [epicenter.loc] ([choice] - [volume]).")
	log_admin("[key_name(usr)] spawned liquid at [epicenter.loc] ([choice] - [volume]).")
