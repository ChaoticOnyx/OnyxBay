///jar
/obj/item/reagent_containers/vessel/jar
	name = "empty jar"
	desc = "A jar. You're not sure what it's supposed to hold."
	force = 6.0
	mod_weight = 0.65
	mod_reach = 0.25
	mod_handy = 0.5
	icon_state = "jar"
	item_state = "beaker"
	center_of_mass = "x=15;y=8"
	unacidable = TRUE
	lid_type = null
	brittle = TRUE

/obj/item/reagent_containers/vessel/jar/on_reagent_change()
	if (reagents.reagent_list.len > 0)
		icon_state ="jar_what"
		SetName("jar of something")
		desc = "You can't really tell what this is."
	else
		icon_state = initial(icon_state)
		SetName(initial(name))
		desc = "A jar. You're not sure what it's supposed to hold."
		return
