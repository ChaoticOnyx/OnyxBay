// UI menu navigation
#define HOME "home"
#define LIST "list"
#define ENTRY "entry"

/obj/machinery/disease2/isolator
	name = "pathogenic isolator"
	density = 1
	anchored = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "isolator"
	component_types = list(
		/obj/item/stock_parts/micro_laser = 3,
		/obj/item/circuitboard/isolator
	)

	var/isolating = 0
	var/state = HOME

	var/speed = 1

	var/datum/disease2/disease/virus2 = null
	var/datum/computer_file/data/virus_record/entry = null
	var/obj/item/reagent_containers/syringe/sample = null

/obj/machinery/disease2/isolator/Initialize()
	. = ..()
	RefreshParts()

/obj/machinery/disease2/isolator/update_icon()
	if (stat & (BROKEN|NOPOWER))
		icon_state = "isolator"
		return

	if (isolating)
		icon_state = "isolator_processing"
	else if (sample)
		icon_state = "isolator_in"
	else
		icon_state = "isolator"

/obj/machinery/disease2/isolator/attackby(obj/O, mob/user)
	if(isolating)
		to_chat(user, SPAN("notice", "\The [src] is busy. Please wait for completion of previous operation."))
		return 1
	if(sample)
		to_chat(user, SPAN("notice", "\The [src] is full. Please remove external items."))
		return 1
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

	if(!istype(O, /obj/item/reagent_containers/syringe))
		return

	var/obj/item/reagent_containers/syringe/S = O

	if(sample)
		to_chat(user, "\The [src] is already loaded.")
		return
	if(!user.drop(S, src))
		return
	sample = S
	user.visible_message("[user] adds \a [O] to \the [src]!", "You add \a [O] to \the [src]!")
	SSnano.update_uis(src)
	update_icon()
	attack_hand(user)

/obj/machinery/disease2/isolator/attack_hand(mob/user)
	if(stat & (NOPOWER|BROKEN)) return
	ui_interact(user)

/obj/machinery/disease2/isolator/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["syringe_inserted"] = !!sample
	data["isolating"] = isolating
	data["pathogen_pool"] = null
	data["state"] = state
	data["entry"] = entry
	data["can_print"] = (state != HOME || sample) && !isolating

	switch (state)
		if (HOME)
			if (sample)
				var/list/pathogen_pool[0]
				for(var/datum/reagent/blood/B in sample.reagents.reagent_list)
					var/list/virus = B.data["virus2"]
					for (var/ID in virus)
						var/datum/disease2/disease/V = virus[ID]
						var/datum/computer_file/data/virus_record/R = null
						if (ID in virusDB)
							R = virusDB[ID]

						var/weakref/W = B.data["donor"]
						var/mob/living/carbon/human/D = W.resolve()
						pathogen_pool.Add(list(list(\
							"name" = "[D ? D.get_species() : "Unidentified"] [B.name]", \
							"dna" = B.data["blood_DNA"], \
							"unique_id" = V.uniqueID, \
							"reference" = "\ref[V]", \
							"is_in_database" = !!R, \
							"record" = "\ref[R]")))

				if (pathogen_pool.len > 0)
					data["pathogen_pool"] = pathogen_pool

		if (LIST)
			var/list/db[0]
			for (var/ID in virusDB)
				var/datum/computer_file/data/virus_record/r = virusDB[ID]
				db.Add(list(list("name" = r.fields["name"], "record" = "\ref[r]")))

			if (db.len > 0)
				data["database"] = db

		if (ENTRY)
			if (entry)
				var/desc = entry.fields["description"]
				data["entry"] = list(\
					"name" = entry.fields["name"], \
					"description" = replacetext(desc, "\n", ""))

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "pathogenic_isolator.tmpl", src.name, 400, 500)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/disease2/isolator/Process()
	if (isolating > 0)
		isolating -= 1
		if (isolating == 0)
			if (virus2)
				var/obj/item/virusdish/d = new /obj/item/virusdish(src.loc)
				d.virus2 = virus2.getcopy()
				virus2 = null
				ping("\The [src] pings, \"Viral strain isolated.\"")

			SSnano.update_uis(src)
			update_icon()

/obj/machinery/disease2/isolator/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	speed = T/3

/obj/machinery/disease2/isolator/OnTopic(user, href_list)
	if (href_list["close"])
		SSnano.close_user_uis(user, src, "main")
		return TOPIC_HANDLED

	if (href_list[HOME])
		state = HOME
		return TOPIC_REFRESH

	if (href_list[LIST])
		state = LIST
		return TOPIC_REFRESH

	if (href_list[ENTRY])
		if (istype(locate(href_list["view"]), /datum/computer_file/data/virus_record))
			entry = locate(href_list["view"])

		state = ENTRY
		return TOPIC_REFRESH

	if (href_list["print"])
		print(user)
		return TOPIC_REFRESH

	if(!sample) return TOPIC_HANDLED

	if (href_list["isolate"])
		var/datum/disease2/disease/V = locate(href_list["isolate"])
		if (V)
			virus2 = V
			isolating = 20
			update_icon()
		return TOPIC_REFRESH

	if (href_list["eject"])
		sample.dropInto(loc)
		sample = null
		update_icon()
		return TOPIC_REFRESH

/obj/machinery/disease2/isolator/proc/print(mob/user)
	var/obj/item/paper/P = new /obj/item/paper(loc)

	switch (state)
		if (HOME)
			if (!sample) return
			P.SetName("paper - Patient Diagnostic Report")
			P.info = {"
				[virology_letterhead("Patient Diagnostic Report")]
				<center><small><font color='red'><b>CONFIDENTIAL MEDICAL REPORT</b></font></small></center><br>
				<large><u>Sample:</u></large> [sample.name]<br>
"}

			if (user)
				P.info += "<u>Generated By:</u> [user.name]<br>"

			P.info += "<hr>"

			for(var/datum/reagent/blood/B in sample.reagents.reagent_list)
				var/weakref/W = B.data["donor"]
				var/mob/living/carbon/human/D = W.resolve()
				P.info += "<large><u>[D ? D.get_species() : "Unidentified"] [B.name]:</u></large><br>[B.data["blood_DNA"]]<br>"

				var/list/virus = B.data["virus2"]
				P.info += "<u>Pathogens:</u> <br>"
				if (virus.len > 0)
					for (var/ID in virus)
						var/datum/disease2/disease/V = virus[ID]
						P.info += "[V.name()]<br>"
				else
					P.info += "None<br>"

			P.info += {"
			<hr>
			<u>Additional Notes:</u>&nbsp;
"}

		if (LIST)
			P.SetName("paper - Virus List")
			P.info = {"
				[virology_letterhead("Virus List")]
"}

			var/i = 0
			for (var/ID in virusDB)
				i++
				var/datum/computer_file/data/virus_record/r = virusDB[ID]
				P.info += "[i]. " + r.fields["name"]
				P.info += "<br>"

			P.info += {"
			<hr>
			<u>Additional Notes:</u>&nbsp;
"}

		if (ENTRY)
			P.SetName("paper - Viral Profile")
			P.info = {"
				[virology_letterhead("Viral Profile")]
				[entry.fields["description"]]
				<hr>
				<u>Additional Notes:</u>&nbsp;
"}

	state("The nearby computer prints out a report.")
