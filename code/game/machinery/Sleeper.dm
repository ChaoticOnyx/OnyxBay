/obj/machinery/capsule/sleeper
	name = "sleeper"
	desc = "A fancy bed with built-in injectors, a dialysis machine, and a limited health scanner."
	clicksound = 'sound/machines/buttonbeep.ogg'
	clickvol = 30
	idle_power_usage = 15
	active_power_usage = 200
	beepsounds = SFX_BEEP_MEDICAL
	component_types = list(
		/obj/item/circuitboard/sleeper,
		/obj/item/stock_parts/manipulator,
		/obj/item/stock_parts/capacitor,
		/obj/item/stock_parts/scanning_module,
		/obj/item/reagent_containers/syringe = 2,
		/obj/item/reagent_containers/vessel/beaker/large
	)

	var/available_chemicals = list()
	var/list/possible_chemicals = list(list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Paracetamol" = /datum/reagent/painkiller/paracetamol, "Dylovene" = /datum/reagent/dylovene, "Dexalin" = /datum/reagent/dexalin),
										list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Tramadol" = /datum/reagent/painkiller/tramadol, "Dylovene" = /datum/reagent/dylovene, "Dexalin" = /datum/reagent/dexalin, "Kelotane" = /datum/reagent/kelotane),
										list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Tramadol" = /datum/reagent/painkiller/tramadol, "Dylovene" = /datum/reagent/dylovene, "Hyronalin" = /datum/reagent/hyronalin, "Dexalin Plus" = /datum/reagent/dexalinp, "Kelotane" = /datum/reagent/kelotane, "Bicaridine" = /datum/reagent/bicaridine),
										list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Tramadol" = /datum/reagent/painkiller/tramadol, "Dylovene" = /datum/reagent/dylovene, "Arithrazine" = /datum/reagent/arithrazine, "Dexalin Plus" = /datum/reagent/dexalinp, "Dermaline" = /datum/reagent/dermaline, "Bicaridine" = /datum/reagent/bicaridine, "Peridaxon" = /datum/reagent/peridaxon))

	var/obj/item/reagent_containers/vessel/beaker = null
	var/filtering = FALSE
	var/pump
	var/list/possible_stasis = list(list(1, 2, 5),
									list(1, 2, 5, 10),
									list(1, 2, 5, 10, 15),
									list(1, 2, 5, 10, 15, 20))
	var/stasis_settings = list()
	var/stasis = 1
	var/freeze // Statis-upgrade

/obj/machinery/capsule/sleeper/update_icon()
	if(panel_open)
		icon_state = "sleeper_1"
		return
	icon_state = "sleeper_[occupant ? "1" : "0"]"

/obj/machinery/capsule/sleeper/_examine_text(mob/user)
	. = ..()
	if (user.Adjacent(src))
		if (beaker)
			. += "\nIt is loaded with a beaker."

/obj/machinery/capsule/sleeper/Process()
	..()

	if(filtering > 0)
		if(beaker)
			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				var/pumped = 0
				for(var/datum/reagent/x in occupant.reagents.reagent_list)
					occupant.reagents.trans_to_obj(beaker, 3)
					pumped++
				if(ishuman(occupant))
					occupant.vessel.trans_to_obj(beaker, pumped + 1)
		else
			toggle_filter()
	if(pump > 0)
		if(beaker && istype(occupant))
			if(beaker.reagents.total_volume < beaker.reagents.maximum_volume)
				var/datum/reagents/ingested = occupant.get_ingested_reagents()
				if(ingested)
					for(var/datum/reagent/x in ingested.reagent_list)
						ingested.trans_to_obj(beaker, 3)
		else
			toggle_pump()

	if(iscarbon(occupant) && stasis > 1)
		occupant.SetStasis(stasis)

/obj/machinery/capsule/sleeper/RefreshParts()
	..()
	freeze = 0
	var/drugs = 0
	var/scanning = 0

	for(var/obj/item/stock_parts/P in component_parts)
		if(ismanipulator(P))
			drugs += P.rating
		else if(isscanner(P))
			scanning += P.rating
		else if(iscapacitor(P))
			freeze += P.rating

	available_chemicals = possible_chemicals[round((drugs + scanning) / 2)]
	if(emagged)
		available_chemicals += list("Lexorin" = /datum/reagent/lexorin)

	stasis_settings = possible_stasis[freeze]

	beaker = locate(/obj/item/reagent_containers/vessel/beaker) in component_parts

/obj/machinery/capsule/sleeper/attack_hand(mob/user)
	..()
	ui_interact(user)

/obj/machinery/capsule/sleeper/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, datum/topic_state/state = GLOB.outside_state)
	var/data[0]

	data["power"] = stat & (NOPOWER|BROKEN) ? 0 : 1

	var/list/reagents = list()
	for(var/T in available_chemicals)
		var/list/reagent = list()
		reagent["name"] = T
		if(occupant && occupant.reagents)
			reagent["amount"] = occupant.reagents.get_reagent_amount(T)
		reagents += list(reagent)
	data["reagents"] = reagents.Copy()

	if(occupant)
		var/scan = medical_scan_results(occupant)
		scan = replacetext(scan,"'notice'","'white'")
		scan = replacetext(scan,"'warning'","'average'")
		scan = replacetext(scan,"'danger'","'bad'")
		data["occupant"] =scan
	else
		data["occupant"] = 0
	if(beaker)
		data["beaker"] = beaker.reagents.get_free_space()
	else
		data["beaker"] = -1
	data["filtering"] = filtering
	data["pump"] = pump
	data["emagged"] = emagged
	data["locked"] = locked
	data["stasis"] = stasis
	data["freeze"] = freeze

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sleeper.tmpl", "Sleeper UI", 600, 600, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/capsule/sleeper/OnTopic(user, href_list)
	if(href_list["eject"])
		go_out()
		return TOPIC_REFRESH
	if(href_list["beaker"])
		remove_beaker()
		return TOPIC_REFRESH
	if(href_list["filter"])
		if(filtering != text2num(href_list["filter"]))
			toggle_filter()
			return TOPIC_REFRESH
	if(href_list["pump"])
		if(filtering != text2num(href_list["pump"]))
			toggle_pump()
			return TOPIC_REFRESH
	if(href_list["locked"])
		if(filtering != text2num(href_list["locked"]))
			toggle_lock()
			return TOPIC_REFRESH
	if(href_list["chemical"] && href_list["amount"])
		if(occupant && occupant.stat != DEAD)
			if(href_list["chemical"] in available_chemicals) // Your hacks are bad and you should feel bad
				inject_chemical(user, href_list["chemical"], text2num(href_list["amount"]))
				return TOPIC_REFRESH
	if(href_list["stasis"])
		var/nstasis = text2num(href_list["stasis"])
		if(stasis != nstasis && (nstasis in stasis_settings))
			stasis = text2num(href_list["stasis"])
			return TOPIC_REFRESH

/obj/machinery/capsule/sleeper/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/capsule/sleeper/emp_act(severity)
	if(filtering)
		toggle_filter()

	..(severity)

/obj/machinery/capsule/sleeper/emag_act(remaining_charges, mob/user)
	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, loc)

	if(!emagged)
		playsound(src.loc, 'sound/effects/computer_emag.ogg', 25)
		to_chat(user, SPAN_DANGER("You short out safety system turning it off."))
		emagged = TRUE
		available_chemicals += list("Lexorin" = /datum/reagent/lexorin)
		spark_system.start()
		playsound(src.loc, SFX_SPARK, 50, 1)
		return TRUE

	..(remaining_charges, user)

/obj/machinery/capsule/sleeper/proc/toggle_filter()
	if(!occupant || !beaker)
		filtering = FALSE
		return
	to_chat(occupant, SPAN_WARNING("You feel like your blood is being sucked away."))
	filtering = !filtering

/obj/machinery/capsule/sleeper/proc/toggle_pump()
	if(!occupant || !beaker)
		pump = FALSE
		return
	to_chat(occupant, SPAN_WARNING("You feel a tube jammed down your throat."))
	pump = !pump

/obj/machinery/capsule/sleeper/proc/remove_beaker()
	if(beaker)
		beaker.dropInto(loc)
		beaker = null
		toggle_filter()
		toggle_pump()
		for(var/obj/item/reagent_containers/vessel/beaker/A in component_parts)
			component_parts -= A

/obj/machinery/capsule/sleeper/proc/inject_chemical(mob/living/user, chemical_name, amount)
	if(stat & (BROKEN|NOPOWER))
		return

	var/chemical_type = available_chemicals[chemical_name]
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chemical_type) + amount <= 20)
			use_power_oneoff(amount * CHEM_SYNTH_ENERGY)
			occupant.reagents.add_reagent(chemical_type, amount)
			to_chat(user, "[occupant_name] now has [occupant.reagents.get_reagent_amount(chemical_type)] unit\s of [chemical_name] in their bloodstream.")
		else
			to_chat(user, "[occupant_name] has too many chemicals.")
	else
		to_chat(user, "There's no suitable occupant in \the [src].")
