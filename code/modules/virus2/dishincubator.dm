/obj/machinery/disease2/incubator/
	name = "pathogenic incubator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "incubator"
	var/obj/item/weapon/virusdish/dish
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/radiation = 0
	var/mutagen = 0

	var/on = 0
	var/power = 0

	var/foodsupply = 0
	var/toxins = 0

/obj/machinery/disease2/incubator/attackby(obj/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/reagent_containers/glass) || istype(O,/obj/item/weapon/reagent_containers/syringe))

		if(beaker)
			to_chat(user, "\The [src] is already loaded.")
			return

		beaker = O
		user.drop_item()
		O.loc = src

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SSnano.update_uis(src)

		src.attack_hand(user)
		return

	if(istype(O, /obj/item/weapon/virusdish))

		if(dish)
			to_chat(user, "The dish tray is aleady full!")
			return

		dish = O
		user.drop_item()
		O.loc = src

		user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
		SSnano.update_uis(src)

		src.attack_hand(user)

/obj/machinery/disease2/incubator/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN)) return
	ui_interact(user)

/obj/machinery/disease2/incubator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["chemicals_inserted"] = !!beaker
	data["dish_inserted"] = !!dish
	data["food_supply"] = foodsupply
	data["radiation"] = radiation
	data["mutagen"] = min(mutagen, 100)
	data["toxins"] = min(toxins, 100)
	data["on"] = on
	data["system_in_use"] = foodsupply > 0 || radiation > 0 || toxins > 0 || mutagen > 0
	data["chemical_volume"] = beaker ? beaker.reagents.total_volume : 0
	data["max_chemical_volume"] = beaker ? beaker.volume : 1
	data["virus"] = dish ? dish.virus2 : null
	data["growth"] = dish ? min(dish.growth, 100) : 0
	data["infection_rate"] = dish && dish.virus2 ? dish.virus2.infectionchance * 10 : 0
	data["analysed"] = dish && dish.analysed ? 1 : 0
	data["can_breed_virus"] = null
	data["blood_already_infected"] = null
	data["virus_blood_match_species"] = null
	data["beaker_has_no_blood"] =null

	if (beaker)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list

		if (B)
			if (!B.data["virus2"])
				B.data["virus2"] = list()

			var/list/virus = B.data["virus2"]
			for (var/ID in virus)
				data["blood_already_infected"] = virus[ID]
			if (dish && dish.analysed)
				var/beaker_species = B.data["species"]
				for (var/S in dish.virus2.affected_species)
					if (beaker_species == S)
						data["can_breed_virus"] = dish && dish.virus2
						data["virus_blood_match_species"] = TRUE
						break
		else
			data["beaker_has_no_blood"] = TRUE


	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "dish_incubator.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/disease2/incubator/Process()
	if(dish && on && dish.virus2)
		use_power_oneoff(50,EQUIP)
		if(!powered(EQUIP))
			on = 0
			icon_state = "incubator"

		if(foodsupply)
			foodsupply -= 1
			if(foodsupply > 50 && dish.growth >= 100 && dish.virus2.infectionchance < 50)
				if(prob(5))
					dish.virus2.infectionchance += 1
			if(dish.growth + 3 >= 100 && dish.growth < 100)
				ping("\The [src] pings, \"Sufficient viral growth density achieved.\"")
			dish.growth += 3
			SSnano.update_uis(src)

		if(radiation)
			if(radiation > 50 && prob(5))
				dish.virus2.majormutate()
				if(dish.info)
					dish.info = "OUTDATED : [dish.info]"
					dish.basic_info = "OUTDATED: [dish.basic_info]"
					dish.analysed = 0
				ping("\The [src] pings, \"Mutant viral strain detected.\"")
			else if(prob(5))
				dish.virus2.minormutate()
			radiation -= 1
			SSnano.update_uis(src)
		if(toxins)
			if(prob(5))
				dish.virus2.infectionchance -= 1
			if(toxins > 50 && prob(5))
				dish.virus2.stageshift()
				if(dish.info)
					dish.info = "OUTDATED : [dish.info]"
					dish.basic_info = "OUTDATED: [dish.basic_info]"
					dish.analysed = 0
				ping("\The [src] pings, \"The nucleotide sequence of virus has been displaced due to partial destruction.\"")
			if(toxins > 80)
				dish.growth = 0
				dish.virus2 = null
				ping("\The [src] pings, \"Virus sample has been destroyed\"")
			toxins -= 1
			SSnano.update_uis(src)
		if(mutagen)
			if(mutagen > 50 && prob(5))
				if(dish.virus2.mediummutate())
					ping("\The [src] pings, \"Mutant viral strain detected.\"")
					if(dish.info)
						dish.info = "OUTDATED : [dish.info]"
						dish.basic_info = "OUTDATED: [dish.basic_info]"
						dish.analysed = 0
			else if(prob(10))
				dish.virus2.minormutate()
			mutagen -= 1
			SSnano.update_uis(src)


	else if(!dish)
		on = 0
		icon_state = "incubator"
		SSnano.update_uis(src)

/obj/machinery/disease2/incubator/OnTopic(user, href_list)
	if (href_list["close"])
		SSnano.close_user_uis(user, src, "main")
		return TOPIC_HANDLED

	if (href_list["ejectchem"])
		if(beaker)
			beaker.dropInto(loc)
			beaker = null
		return TOPIC_REFRESH

	if (href_list["power"])
		if (dish)
			on = !on
			icon_state = on ? "incubator_on" : "incubator"
		return TOPIC_REFRESH

	if (href_list["ejectdish"])
		if(dish)
			dish.dropInto(loc)
			dish = null
		return TOPIC_REFRESH

	if (href_list["chem"])
		if(!beaker.reagents)
			return TOPIC_REFRESH
		if(beaker.reagents.has_reagent(/datum/reagent/nutriment/virus_food, 5) && foodsupply < 100)
			beaker.reagents.remove_reagent(/datum/reagent/nutriment/virus_food, 5)
			foodsupply = min(100, foodsupply + 10)
		if(beaker.reagents.has_reagent(/datum/reagent/radium, 5) && radiation < 100)
			beaker.reagents.remove_reagent(/datum/reagent/radium, 5)
			radiation = min(100, radiation + 10)
		if(mutagen < 100)
			for(var/datum/reagent/mutagen/T in beaker.reagents.reagent_list)
				if(T.volume >= 5)
					beaker.reagents.remove_reagent(/datum/reagent/mutagen, 5)
					mutagen = min(100, mutagen + 10)
		if(toxins < 100)
			for(var/datum/reagent/toxin/T in beaker.reagents.reagent_list)
				if(T.volume >= 5)
					beaker.reagents.remove_reagent(T.type, 5)
					toxins = min(100, toxins + T.strength)
		return TOPIC_REFRESH

	if (href_list["flush"])
		radiation = 0
		toxins = 0
		foodsupply = 0
		mutagen = 0
		return TOPIC_REFRESH

	if(href_list["virus"])
		if (!dish)
			return TOPIC_HANDLED

		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in beaker.reagents.reagent_list
		if (!B)
			return TOPIC_HANDLED

		if (!B.data["virus2"])
			B.data["virus2"] = list()

		var/list/virus = list("[dish.virus2.uniqueID]" = dish.virus2.getcopy())
		B.data["virus2"] += virus

		ping("\The [src] pings, \"Injection complete.\"")
		return TOPIC_REFRESH
