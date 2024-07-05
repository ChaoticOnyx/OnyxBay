/// This var h
/obj/var/oldificated = FALSE

/obj/proc/make_old(change_looks = TRUE)
	color = pick("#996633", "#663300", "#666666")
	light_color = color
	if(change_looks)
		name = pick("old ", "expired ", "dirty ") + initial(name)
		desc += pick(" Warranty has expired.", " The inscriptions on this thing were erased by time.", " Looks completely wasted.")

	germ_level = pick(80, 110, 160)
	for(var/obj/item/sub_item in contents)
		sub_item.make_old()

	update_icon()
	oldificated = TRUE

/obj/item/make_old()
	..()
	siemens_coefficient += 0.3
	update_icon()

/obj/item/storage/make_old()
	var/del_count = rand(0, LAZYLEN(contents))
	for(var/i = 1 to del_count)
		var/removed_item = pick(contents)
		contents -= removed_item
		qdel(removed_item)
	if(prob(75))
		storage_slots = max(LAZYLEN(contents), max(0, storage_slots - pick(2, 2, 2, 3, 3, 4)))
	if(prob(75))
		max_storage_space = max_storage_space / 2
	return ..()

/obj/item/reagent_containers/make_old()
	for(var/datum/reagent/R in reagents.reagent_list)
		R.volume = rand(0, R.volume)
	reagents.add_reagent(/datum/reagent/toxin, rand(0, 10))
	return ..()

/obj/item/clothing/make_old()
	if(prob(50))
		slowdown_general += pick(0, 0.2, 0.2, 0.5, 0.5, 1, 1.5)
	if(prob(75))
		armor["melee"] = armor["melee"] / 2
		armor["bullet"] = armor["bullet"] / 2
		armor["laser"] = armor["laser"] / 2
		armor["energy"] = armor["energy"] / 2
		armor["bomb"] = armor["bomb"] / 2
		armor["bio"] = armor["bio"] / 2
	if(prob(25))
		permeability_coefficient = 02
	if(prob(25))
		siemens_coefficient = 2
	if(prob(25))
		heat_protection = 0
	if(prob(25))
		cold_protection = 0
	if(prob(35))
		contaminate()
	if(prob(75))
		generate_blood_overlay()
		add_dirt_cover(pick(GLOB.dirt_overlays))
	return ..()
