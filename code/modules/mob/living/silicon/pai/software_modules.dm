/datum/pai_software
	// Name for the software. This is used as the button text when buying or opening/toggling the software
	var/name = "pAI software module"
	// RAM cost; pAIs start with 100 RAM, spending it on programs
	var/ram_cost = 0
	// ID for the software. This must be unique
	var/id = ""
	// Whether this software is a toggle or not
	// Toggled software should override toggle() and is_active()
	// Non-toggled software should override on_ui_interact() and Topic()
	var/toggle = 1
	// Whether pAIs should automatically receive this module at no cost
	var/default = 0

	var/req_one_accesses = list()

	proc/on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		return

	proc/toggle(mob/living/silicon/pai/user)
		return

	proc/is_active(mob/living/silicon/pai/user)
		return 0

	proc/on_purchase(mob/living/silicon/pai/user)
		return

/datum/pai_software/directives
	name = "Directives"
	ram_cost = 0
	id = "directives"
	toggle = 0
	default = 1

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]

		data["master"] = user.master
		data["dna"] = user.master_dna
		data["prime"] = user.pai_law0
		data["supplemental"] = user.pai_laws

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_directives.tmpl", "pAI Directives", 450, 600)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

	Topic(href, href_list)
		var/mob/living/silicon/pai/P = usr
		if(!istype(P)) return

		if(href_list["getdna"])
			var/mob/living/M = P.loc
			var/count = 0

			// Find the carrier
			while(!istype(M, /mob/living))
				if(!M || !M.loc || count > 6)
					//For a runtime where M ends up in nullspace (similar to bluespace but less colourful)
					to_chat(src, "You are not being carried by anyone!")
					return 0
				M = M.loc
				count++

			// Check the carrier
			var/answer = input(M, "[P] is requesting a DNA sample from you. Will you allow it to confirm your identity?", "[P] Check DNA", "No") in list("Yes", "No")
			if(answer == "Yes")
				var/turf/T = get_turf_or_move(P.loc)
				for (var/mob/v in viewers(T))
					v.show_message("<span class='notice'>[M] presses \his thumb against [P].</span>", 3, "<span class='notice'>[P] makes a sharp clicking sound as it extracts DNA material from [M].</span>", 2)
				var/datum/dna/dna = M.dna
				to_chat(P, "<font color = red><h3>[M]'s UE string : [dna.unique_enzymes]</h3></font>")
				if(dna.unique_enzymes == P.master_dna)
					to_chat(P, "<b>DNA is a match to stored Master DNA.</b>")
				else
					to_chat(P, "<b>DNA does not match stored Master DNA.</b>")
			else
				to_chat(P, "[M] does not seem like \he is going to provide a DNA sample willingly.")
			return 1

/datum/pai_software/reader
	name = "Card Reader"
	ram_cost = 0
	id = "cardreader"
	toggle = 0
	default = 1

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]

		data["toggle"] = user.reader_on
		data["checkdna"] = user.reader_dna_check
		data["authname"] = "[user.card_registered_name] ([user.card_assignment])"

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_card_reader.tmpl", "Card Reader", 450, 350)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

	Topic(href, href_list)
		var/mob/living/silicon/pai/P = usr
		if(!istype(P)) return

		if(href_list["toggle"])
			P.reader_on = !P.reader_on
			return 1
		else if(href_list["check_dna"])
			P.reader_dna_check = !P.reader_dna_check
			return 1
		else if(href_list["drop"])
			P.idcard.access = list()
			P.card_registered_name = ""
			P.card_assignment = ""
			P.silicon_radio.recalculateChannels(P)
			return 1
		if(href_list["nowindow"])
			return 1

/datum/pai_software/radio_config
	name = "Radio Configuration"
	ram_cost = 0
	id = "radio"
	toggle = 0
	default = 1

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui = null, force_open = 1)
		user.silicon_radio.attack_self(user)

	Topic(href, href_list)
		var/mob/living/silicon/pai/P = usr
		if(!istype(P)) return

		P.silicon_radio.Topic(href, href_list)
		return 1

/datum/pai_software/crew_manifest
	name = "Crew Manifest"
	ram_cost = 5
	id = "manifest"
	toggle = 0

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]
		// This is dumb, but NanoUI breaks if it has no data to send
		data["manifest"] = nano_crew_manifest()

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_manifest.tmpl", "Crew Manifest", 450, 600)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

/datum/pai_software/messenger
	name = "Digital Messenger"
	ram_cost = 5
	id = "messenger"
	toggle = 0

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]

		data["receiver_off"] = user.pda.toff
		data["ringer_off"] = user.pda.message_silent
		data["current_ref"] = null
		data["current_name"] = user.current_pda_messaging

		var/pdas[0]
		if(!user.pda.toff)
			for(var/obj/item/device/pda/P in sortAtom(PDAs))
				if(!P.owner || P.toff || P == user.pda || P.hidden) continue
				var/pda[0]
				pda["name"] = "[P]"
				pda["owner"] = "[P.owner]"
				pda["ref"] = "\ref[P]"
				if(P.owner == user.current_pda_messaging)
					data["current_ref"] = "\ref[P]"
				pdas[++pdas.len] = pda

		data["pdas"] = pdas

		var/messages[0]
		if(user.current_pda_messaging)
			for(var/index in user.pda.tnote)
				if(index["owner"] != user.current_pda_messaging)
					continue
				var/msg[0]
				var/sent = index["sent"]
				msg["sent"] = sent ? 1 : 0
				msg["target"] = index["owner"]
				msg["message"] = index["message"]
				messages[++messages.len] = msg

		data["messages"] = messages

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_messenger.tmpl", "Digital Messenger", 450, 600)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

	Topic(href, href_list)
		var/mob/living/silicon/pai/P = usr
		if(!istype(P)) return

		if(!isnull(P.pda))
			if(href_list["toggler"])
				P.pda.toff = href_list["toggler"] != "1"
				return 1
			else if(href_list["ringer"])
				P.pda.message_silent = href_list["ringer"] != "1"
				return 1
			else if(href_list["select"])
				var/s = href_list["select"]
				if(s == "*NONE*")
					P.current_pda_messaging = null
				else
					P.current_pda_messaging = s
				return 1
			else if(href_list["target"])
				if(P.silence_time)
					return alert("Communications circuits remain uninitialized.")

				var/target = locate(href_list["target"])
				if(target)
					P.pda.create_message(P, target, 1)
				else
					return alert("Failed to send message: the recipient could not be reached.")
				return 1

/datum/pai_software/messenger/on_purchase(mob/living/silicon/pai/user)
	if(user && !user.pda)
		user.pda = new(user)
		user.pda.set_owner_rank_job(text("[]", user), "Personal Assistant")

/datum/pai_software/door_jack
	name = "Door Jack"
	ram_cost = 30
	id = "door_jack"
	toggle = 0

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]

		data["cable"] = user.cable != null
		data["machine"] = user.cable && (user.cable.machine != null)
		data["inprogress"] = user.hackdoor != null
		data["progress_a"] = round(user.hackprogress / 10)
		data["progress_b"] = user.hackprogress % 10
		data["aborted"] = user.hack_aborted

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_doorjack.tmpl", "Door Jack", 300, 150)
			ui.set_initial_data(data)
			ui.open()
			ui.set_auto_update(1)

	Topic(href, href_list)
		var/mob/living/silicon/pai/P = usr
		if(!istype(P)) return

		if(href_list["jack"])
			if(P.cable && P.cable.machine)
				P.hackdoor = P.cable.machine
				P.hackloop()
			return 1
		else if(href_list["cancel"])
			P.hackdoor = null
			return 1
		else if(href_list["cable"])
			var/turf/T = get_turf_or_move(P.loc)
			P.hack_aborted = 0
			P.cable = new /obj/item/weapon/pai_cable(T)
			for(var/mob/M in viewers(T))
				M.show_message("<span class='warning'>A port on [P] opens to reveal [P.cable], which promptly falls to the floor.</span>", 3,
				               "<span class='warning'>You hear the soft click of something light and hard falling to the ground.</span>", 2)
			return 1

/mob/living/silicon/pai/proc/hackloop()
	var/turf/T = get_turf_or_move(src.loc)
	for(var/mob/living/silicon/ai/AI in GLOB.player_list)
		if(T.loc)
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress in [T.loc].</b></font>")
		else
			to_chat(AI, "<font color = red><b>Network Alert: Brute-force encryption crack in progress. Unable to pinpoint location.</b></font>")
	var/obj/machinery/door/D = cable.machine
	if(!istype(D))
		hack_aborted = 1
		hackprogress = 0
		cable.machine = null
		hackdoor = null
		return
	while(hackprogress < 1000)
		if(cable && cable.machine == D && cable.machine == hackdoor && get_dist(src, hackdoor) <= 1)
			hackprogress = min(hackprogress+rand(1, 20), 1000)
		else
			hack_aborted = 1
			hackprogress = 0
			hackdoor = null
			return
		if(hackprogress >= 1000)
			hackprogress = 0
			D.open()
			cable.machine = null
			return
		sleep(10)			// Update every second

/datum/pai_software/atmosphere_sensor
	name = "Atmosphere Sensor"
	ram_cost = 5
	id = "atmos_sense"
	toggle = 0

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]

		var/turf/T = get_turf_or_move(user.loc)
		if(!T)
			data["reading"] = 0
			data["pressure"] = 0
			data["temperature"] = 0
			data["temperatureC"] = 0
			data["gas"] = list()
		else
			var/datum/gas_mixture/env = T.return_air()
			data["reading"] = 1
			var/pres = env.return_pressure() * 10
			data["pressure"] = "[round(pres/10)].[pres%10]"
			data["temperature"] = round(env.temperature)
			data["temperatureC"] = round(env.temperature-T0C)

			var/t_moles = env.total_moles
			var/gases[0]
			for(var/g in env.gas)
				var/gas[0]
				gas["name"] = gas_data.name[g]
				gas["percent"] = round((env.gas[g] / t_moles) * 100)
				gases[++gases.len] = gas
			data["gas"] = gases

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_atmosphere.tmpl", "Atmosphere Sensor", 350, 300)
			ui.set_initial_data(data)
			ui.open()

/datum/pai_software/sec_hud
	name = "Security HUD"
	ram_cost = 20
	id = "sec_hud"
	req_one_accesses = list(access_security)

	toggle(mob/living/silicon/pai/user)
		user.secHUD = !user.secHUD

	is_active(mob/living/silicon/pai/user)
		return user.secHUD

/datum/pai_software/med_hud
	name = "Medical HUD"
	ram_cost = 20
	id = "med_hud"

	toggle(mob/living/silicon/pai/user)
		user.medHUD = !user.medHUD

	is_active(mob/living/silicon/pai/user)
		return user.medHUD

/datum/pai_software/translator
	name = "Universal Translator"
	ram_cost = 35
	id = "translator"
	var/list/languages = list(LANGUAGE_UNATHI, LANGUAGE_SIIK_MAAS, LANGUAGE_SKRELLIAN, LANGUAGE_EAL, LANGUAGE_INDEPENDENT, LANGUAGE_SPACER, LANGUAGE_LUNAR)

	toggle(mob/living/silicon/pai/user)
		// 	Sol Common, Tradeband and Gutter are added with New() and are therefore the current default, always active languages
		user.translator_on = !user.translator_on
		if(user.translator_on)
			for(var/language in languages)
				user.add_language(language)
		else
			for(var/language in languages)
				user.remove_language(language)

	is_active(mob/living/silicon/pai/user)
		return user.translator_on

/datum/pai_software/signaller
	name = "Remote Signaller"
	ram_cost = 5
	id = "signaller"
	toggle = 0

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		var/data[0]

		data["frequency"] = format_frequency(user.sradio.frequency)
		data["code"] = user.sradio.code

		ui = SSnano.try_update_ui(user, user, id, ui, data, force_open)
		if(!ui)
			// Don't copy-paste this unless you're making a pAI software module!
			ui = new(user, user, id, "pai_signaller.tmpl", "Signaller", 320, 150)
			ui.set_initial_data(data)
			ui.open()

	Topic(href, href_list)
		var/mob/living/silicon/pai/P = usr
		if(!istype(P)) return

		if(href_list["send"])
			P.sradio.send_signal("ACTIVATE")
			for(var/mob/O in hearers(1, P.loc))
				O.show_message(text("\icon[] *beep* *beep*", P), 3, "*beep* *beep*", 2)
			return 1

		else if(href_list["freq"])
			var/new_frequency = (P.sradio.frequency + text2num(href_list["freq"]))
			if(new_frequency < PUBLIC_LOW_FREQ || new_frequency > PUBLIC_HIGH_FREQ)
				new_frequency = sanitize_frequency(new_frequency)
			P.sradio.set_frequency(new_frequency)
			return 1

		else if(href_list["code"])
			P.sradio.code += text2num(href_list["code"])
			P.sradio.code = round(P.sradio.code)
			P.sradio.code = min(100, P.sradio.code)
			P.sradio.code = max(1, P.sradio.code)
			return 1

/datum/pai_software/subsystem
	var/nano_module

	on_ui_interact(mob/living/silicon/pai/user, datum/nanoui/ui=null, force_open=1)
		user.open_subsystem(nano_module)

	on_purchase(mob/living/silicon/pai/user)
		user.init_subsystem(nano_module)

/datum/pai_software/subsystem/power_monitor
	nano_module = /datum/nano_module/power_monitor

	name = "Power Monitoring"
	ram_cost = 10
	id = "power_monitor"
	req_one_accesses = list(access_engine_equip)
	toggle = 0

/datum/pai_software/subsystem/rcon
	nano_module = /datum/nano_module/rcon

	name = "RCON Remote Control"
	ram_cost = 10
	id = "rcon"
	req_one_accesses = list(access_engine_equip)
	toggle = 0

/datum/pai_software/subsystem/supermatter_monitor
	nano_module = /datum/nano_module/supermatter_monitor

	name = "Supermatter Monitoring"
	ram_cost = 10
	id = "supermatter_monitor"
	req_one_accesses = list(access_engine_equip)
	toggle = 0

/datum/pai_software/subsystem/atmos_control
	nano_module = /datum/nano_module/atmos_control

	name = "Atmosphere Control"
	ram_cost = 20
	id = "atmos_control"
	req_one_accesses = list(access_atmospherics)
	toggle = 0

/datum/pai_software/subsystem/crew_monitor
	nano_module = /datum/nano_module/crew_monitor

	name = "Crew Monitor"
	ram_cost = 10
	id = "crew_monitor"
	req_one_accesses = list(access_security, access_medical)
	toggle = 0

/datum/pai_software/subsystem/digitalwarrant
	nano_module = /datum/nano_module/digitalwarrant

	name = "Warrant Assistant"
	ram_cost = 20
	id = "digitalwarrant"
	req_one_accesses = list(access_security)
	toggle = 0

/datum/pai_software/subsystem/supply
	nano_module = /datum/nano_module/supply

	name = "Cargo Management program"
	ram_cost = 20
	id = "supply"
	req_one_accesses = list(access_cargo)
	toggle = 0

/datum/pai_software/subsystem/computer_ntnetmonitor
	nano_module = /datum/nano_module/computer_ntnetmonitor

	name = "NTNet Diagnostics and Monitoring"
	ram_cost = 20
	id = "ntnetmonitor"
	req_one_accesses = list(access_network)
	toggle = 0

/datum/pai_software/subsystem/shields_monitor
	nano_module = /datum/nano_module/shields_monitor

	name = "Shield Generators Monitoring"
	ram_cost = 10
	id = "shields_monitor"
	req_one_accesses = list(access_engine_equip)
	toggle = 0

/datum/pai_software/subsystem/secrecords
	nano_module = /datum/nano_module/records/security

	name = "Security Records"
	ram_cost = 10
	id = "secrecords"
	req_one_accesses = list(access_security)
	toggle = 0

/datum/pai_software/subsystem/medrecords
	nano_module = /datum/nano_module/records/medical

	name = "Medical Records"
	ram_cost = 10
	id = "medrecords"
	req_one_accesses = list(access_medical)
	toggle = 0
