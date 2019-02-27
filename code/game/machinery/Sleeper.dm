/obj/machinery/sleeper
	name = "sleeper"
	desc = "A fancy bed with built-in injectors, a dialysis machine, and a limited health scanner."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper_0"
	density = 1
	anchored = 1
	clicksound = 'sound/machines/buttonbeep.ogg'
	clickvol = 30
	var/mob/living/carbon/human/occupant = null
	var/list/possible_chemicals = list(list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Paracetamol" = /datum/reagent/paracetamol, "Dylovene" = /datum/reagent/dylovene, "Dexalin" = /datum/reagent/dexalin),
										list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Tramadol" = /datum/reagent/tramadol, "Dylovene" = /datum/reagent/dylovene, "Dexalin" = /datum/reagent/dexalin, "Kelotane" = /datum/reagent/kelotane),
										list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Tramadol" = /datum/reagent/tramadol, "Dylovene" = /datum/reagent/dylovene, "Hyronalin" = /datum/reagent/hyronalin, "Dexalin Plus" = /datum/reagent/dexalinp, "Kelotane" = /datum/reagent/kelotane, "Bicaridine" = /datum/reagent/bicaridine),
										list("Inaprovaline" = /datum/reagent/inaprovaline, "Soporific" = /datum/reagent/soporific, "Tramadol" = /datum/reagent/tramadol, "Dylovene" = /datum/reagent/dylovene, "Arithrazine" = /datum/reagent/arithrazine, "Dexalin Plus" = /datum/reagent/dexalinp, "Dermaline" = /datum/reagent/dermaline, "Bicaridine" = /datum/reagent/bicaridine, "Peridaxon" = /datum/reagent/peridaxon))
	var/available_chemicals = list()
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/filtering = 0
	var/pump
	var/list/possible_stasis = list(list(1, 2, 5),
									list(1, 2, 5, 10),
									list(1, 2, 5, 10, 15),
									list(1, 2, 5, 10, 15, 20))
	var/stasis_settings = list()
	var/stasis = 1
	var/freeze // Statis-upgrade

	var/locked = 0

	use_power = 1
	idle_power_usage = 15
	active_power_usage = 200 //builtin health analyzer, dialysis machine, injectors.

/obj/machinery/sleeper/verb/eject()
	set src in oview(1)
	set category = "Object"
	set name = "Eject Sleeper"

	if (usr.stat != 0)
		return
	src.go_out()
	add_fingerprint(usr)
	return

/obj/machinery/sleeper/Initialize()
	. = ..()
	component_parts = list(
		new /obj/item/weapon/circuitboard/sleeper(src),
		new /obj/item/weapon/stock_parts/manipulator(src),
		new /obj/item/weapon/stock_parts/capacitor(src),
		new /obj/item/weapon/stock_parts/scanning_module(src),
		new /obj/item/weapon/stock_parts/console_screen(src),
		new /obj/item/weapon/reagent_containers/syringe(src),
		new /obj/item/weapon/reagent_containers/syringe(src),
		new /obj/item/weapon/reagent_containers/glass/beaker/large(src))
	RefreshParts()

/obj/machinery/sleeper/examine(mob/user)
	. = ..()
	if (. && user.Adjacent(src))
		if (beaker)
			to_chat(user, "It is loaded with a beaker.")
		if(occupant)
			occupant.examine(user)

/obj/machinery/sleeper/Process()
	if(stat & (NOPOWER|BROKEN))
		return

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

/obj/machinery/sleeper/update_icon()
	if(panel_open)
		icon_state = "sleeper_1"
		return

	icon_state = "sleeper_[occupant ? "1" : "0"]"

/obj/machinery/sleeper/RefreshParts()
	..()
	freeze = 0
	var/drugs = 0
	var/scanning = 0

	for(var/obj/item/weapon/stock_parts/P in component_parts)
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

	beaker = locate(/obj/item/weapon/reagent_containers/glass/beaker) in component_parts

/obj/machinery/sleeper/attack_hand(var/mob/user)
	if(..())
		return 1
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return

	ui_interact(user)

/obj/machinery/sleeper/ui_interact(var/mob/user, var/ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1, var/datum/topic_state/state = GLOB.outside_state)
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

	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "sleeper.tmpl", "Sleeper UI", 600, 600, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/sleeper/CanUseTopic(user)
	if(panel_open)
		return
	if(user == occupant)
		to_chat(usr, "<span class='warning'>You can't reach the controls from the inside.</span>")
		return STATUS_CLOSE
	return ..()

/obj/machinery/sleeper/OnTopic(user, href_list)
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
		if(stasis != nstasis && nstasis in stasis_settings)
			stasis = text2num(href_list["stasis"])
			return TOPIC_REFRESH

/obj/machinery/sleeper/attack_ai(var/mob/user)
	return attack_hand(user)

/obj/machinery/sleeper/attackby(var/obj/item/I, var/mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		add_fingerprint(user)
		if(!beaker)
			beaker = I
			user.drop_item()
			I.forceMove(src)
			component_parts += I
			user.visible_message("<span class='notice'>\The [user] adds \a [I] to \the [src].</span>", "<span class='notice'>You add \a [I] to \the [src].</span>")
		else
			to_chat(user, "<span class='warning'>\The [src] has a beaker already.</span>")
			return
	if(occupant && panel_open && istype(I,/obj/item/weapon/crowbar))
		occupant.loc = get_turf(src)
		occupant = null
		update_use_power(1)
		update_icon()
		toggle_filter()
	if(default_deconstruction_screwdriver(user, I))
		return
	if(default_deconstruction_crowbar(user, I))
		return
	if(default_part_replacement(user, I))
		return

	if(istype(I, /obj/item/grab))
		if(!ismob(I:affecting))
			return
		for(var/mob/living/carbon/slime/M in range(1,I:affecting))
			if(M.Victim == I:affecting)
				to_chat(usr, "[I:affecting:name] will not fit into the sleeper because they have a slime latched onto their head.")
				return
		if(!check_compatibility(I:affecting, user))
			return
		visible_message("<span class='notice'>\The [user] starts placing \the [I:affecting] into \the [src].</span>", "<span class='notice'>You start placing \the [I:affecting] into \the [src].</span>")

		if(do_after(user, 20, src))
			if(occupant) //If somebody's got into the [src] while we were trying to stuff somebody in.
				to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
				return
			I:affecting.stop_pulling()
			if(I:affecting.client)
				I:affecting.client.perspective = EYE_PERSPECTIVE
				I:affecting.client.eye = src
			I:affecting.forceMove(src)
			update_use_power(2)
			occupant = I:affecting
			update_icon()
			qdel(I)
			return
		else
			return
	..()

/obj/machinery/sleeper/proc/check_compatibility(var/mob/target, var/mob/user)
	if(!istype(user) || !istype(target))
		return FALSE
	if(!CanMouseDrop(target, user))
		return FALSE
	if(occupant)
		to_chat(user, "<span class='warning'>The scanner is already occupied!</span>")
		return FALSE
	if(target.abiotic())
		to_chat(user, "<span class='warning'>The subject cannot have abiotic items on.</span>")
		return FALSE
	if(target.buckled)
		to_chat(user, "<span class='warning'>Unbuckle the subject before attempting to move them.</span>")
		return FALSE
	return TRUE

/obj/machinery/sleeper/MouseDrop_T(var/mob/target, var/mob/user)
	if(!CanMouseDrop(target, user))
		return
	if(!istype(target))
		return
	if(target.buckled)
		to_chat(user, "<span class='warning'>Unbuckle the subject before attempting to move them.</span>")
		return
	if(!check_compatibility(target, user))
		return
	go_in(target, user)

/obj/machinery/sleeper/relaymove(var/mob/user)
	..()
	go_out()

/obj/machinery/sleeper/emp_act(var/severity)
	if(filtering)
		toggle_filter()

	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(occupant)
		go_out()

	if(!emagged && prob(10))
		emag_act()

	..(severity)

/obj/machinery/sleeper/emag_act(var/remaining_charges, var/mob/user)

	var/datum/effect/effect/system/spark_spread/spark_system = new /datum/effect/effect/system/spark_spread()
	spark_system.set_up(5, 0, src.loc)

	if(!emagged)
		to_chat(user, "<span class='danger'>You short out safety system turning it off.</span>")
		emagged = 1
		available_chemicals += list("Lexorin" = /datum/reagent/lexorin)
		spark_system.start()
		playsound(src.loc, "sparks", 50, 1)
		return 1
	if(locked)
		to_chat(user, "<span class='danger'>You short out locking system.</span>")
		toggle_lock()
		spark_system.start()
		playsound(src.loc, "sparks", 50, 1)
		return 1

/obj/machinery/sleeper/proc/toggle_filter()
	if(!occupant || !beaker)
		filtering = 0
		return
	to_chat(occupant, "<span class='warning'>You feel like your blood is being sucked away.</span>")
	filtering = !filtering

/obj/machinery/sleeper/proc/toggle_pump()
	if(!occupant || !beaker)
		pump = 0
		return
	to_chat(occupant, "<span class='warning'>You feel a tube jammed down your throat.</span>")
	pump = !pump

/obj/machinery/sleeper/proc/toggle_lock()
	if(!occupant)
		locked = 0
		return
	to_chat(occupant, "<span class='warning'>You hear a quiet click as the locking bolts [locked ? "go up" : "drop down"].</span>")
	locked = !locked

/obj/machinery/sleeper/proc/go_in(var/mob/M, var/mob/user)
	if(!M)
		return
	if(stat & (BROKEN|NOPOWER))
		return
	if(occupant)
		to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
		return
	if(panel_open)
		to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
		return
	if(M == user)
		visible_message("\The [user] starts climbing into \the [src].")
	else
		visible_message("\The [user] starts putting [M] into \the [src].")

	if(do_after(user, 20, src))
		if(occupant)
			to_chat(user, "<span class='warning'>\The [src] is already occupied.</span>")
			return
		M.stop_pulling()
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.forceMove(src)
		update_use_power(2)
		occupant = M
		update_icon()

/obj/machinery/sleeper/proc/go_out()
	if(!occupant)
		return
	if(locked)
		return
	if(occupant.client)
		occupant.client.eye = occupant.client.mob
		occupant.client.perspective = MOB_PERSPECTIVE
	occupant.dropInto(loc)
	occupant = null
	for(var/atom/movable/A in src) // In case an object was dropped inside or something
		if(locate(A) in component_parts)
			continue
		A.dropInto(loc)
	update_use_power(1)
	update_icon()
	toggle_filter()

/obj/machinery/sleeper/proc/remove_beaker()
	if(beaker)
		beaker.dropInto(loc)
		beaker = null
		toggle_filter()
		toggle_pump()
		for(var/obj/item/weapon/reagent_containers/glass/beaker/A in component_parts)
			component_parts -= A

/obj/machinery/sleeper/proc/inject_chemical(var/mob/living/user, var/chemical_name, var/amount)
	if(stat & (BROKEN|NOPOWER))
		return

	var/chemical_type = available_chemicals[chemical_name]
	if(occupant && occupant.reagents)
		if(occupant.reagents.get_reagent_amount(chemical_type) + amount <= 20)
			use_power(amount * CHEM_SYNTH_ENERGY)
			occupant.reagents.add_reagent(chemical_type, amount)
			to_chat(user, "Occupant now has [occupant.reagents.get_reagent_amount(chemical_type)] unit\s of [chemical_name] in their bloodstream.")
		else
			to_chat(user, "The subject has too many chemicals.")
	else
		to_chat(user, "There's no suitable occupant in \the [src].")
