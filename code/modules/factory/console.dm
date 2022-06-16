// One console to rule everybody
/obj/machinery/factory_console
	name = "Factory Control Console"
	desc = "It's machinery used to control factory."

	anchored = 1
	density = 1

	icon_state = "autolathe"
	layer = BELOW_OBJ_LAYER

	active_power_usage = 200

	clicksound = 'sound/effects/using/console/press2.ogg'
	clickvol = 30

	var/list/weakref/machines = list()
	var/weakref/selected_machine
	var/machine_message
	var/datum/browser/factory_menu

// TODO: Initialize proc, connect to area machines list and seek for factory machines, than add them to our list
/obj/machinery/factory_console/Initialize()
	. = ..()
	var/turf/T = get_turf(src)
	var/area/A = T?.loc
	if(istype(A))
		for(var/obj/machinery/factory/F in GLOB.machines)
			var/turf/T_machine = get_turf(F)
			var/area/machine_area = T_machine?.loc
			if(!istype(machine_area) || machine_area != A)
				continue
			machines.Add(weakref(F))

/obj/machinery/factory_console/attack_hand(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	show_factory_menu(user)
	factory_menu.open()

// Fuck this shit, kill me please. TODO: replace this shit with TGUI, add some icons for cans etc
/obj/machinery/factory_console/proc/show_factory_menu(mob/user)
	add_fingerprint(user)
	if(stat & (NOPOWER|BROKEN) || !Adjacent(user))
		user.unset_machine()
		return

	var/name_machines = ""
	var/actions_machines = ""

	for(var/weakref/ref in machines)
		var/obj/machinery/factory/F = ref.resolve()
		if(!istype(F))
			continue
		name_machines += "<th>[F.name]</th>"
		actions_machines += "<tr>"
		var/list/actions = F.get_actions()
		for(var/action in actions)
			actions_machines += "<td><a href='?src=\ref[src];select_machine=\ref[F]'>Select machine</a><BR><a href='?src=\ref[src];on_action_machine=\ref[F];[action]=1'>[actions[action]]</a></td>"
		actions_machines += "</tr>"

	// var/dat = "<head><meta charset=\"utf-8\"></head><body>"
	var/dat = "<a href='?src=\ref[src];update_machines=1'>Update machines list</a><BR>"
	if(selected_machine)
		var/obj/machinery/factory/F = selected_machine.resolve()
		if(istype(F))
			dat += "\The [F] reports:<BR>[F.get_status_message()]"
		else
			selected_machine = FALSE

	if(length(machines))
		dat += "<table border=\"1\"><caption>Machines</caption><tr>[name_machines]</tr>[actions_machines]</table>"
	dat += "</body>"

	user.set_machine(src)
	if(!factory_menu || factory_menu.user != user)
		factory_menu = new /datum/browser(user, "disposal", "<B>[src]</B>", 260, 410)
		factory_menu.set_content(dat)
	else
		factory_menu.set_content(dat)
		factory_menu.update()
	return


/obj/machinery/factory_console/OnTopic(mob/user, href_list)
	. = TOPIC_REFRESH
	if(!CanPhysicallyInteract(user))
		return

	if(href_list["update_machines"])
		machines.Cut()
		var/turf/T = get_turf(src)
		var/area/A = T?.loc
		if(istype(A))
			for(var/obj/machinery/factory/F in GLOB.machines)
				var/turf/T_machine = get_turf(F)
				var/area/machine_area = T_machine?.loc
				if(!istype(machine_area) || machine_area != A)
					continue
				machines.Add(weakref(F))

	if(href_list["select_machine"])
		var/obj/machinery/factory/F = locate(href_list["select_machine"])
		selected_machine = weakref(F)
		to_chat(user, "You have selected \the [F] and now \the [src] will display its status.")

	if(href_list["on_action_machine"])
		var/obj/machinery/factory/F = locate(href_list["on_action_machine"])
		if(!istype(F))
			return
		if(!(weakref(F) in machines))
			return
		machine_message = F.process_action(user, href_list, src)

	// if(href_list["price_list"])
	// 	// TODO: connect to factory subsystem and get prices for things

	// if(href_list["retrieve_money"])
	// 	// TODO: get an account from ID card and add 100 credits.

	if(. == TOPIC_REFRESH)
		attack_hand(user)
