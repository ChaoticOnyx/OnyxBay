/datum/travevent/meteor/base/New()
	..()
	xvel=0
	yvel=0




/datum/travevent/meteor/base/Entered(var/datum/travevent/t)
	if(istype(t,/datum/travevent/ship/Luna))
		ticker.mode.check_win()
		t.xvel = 0
		t.yvel = 0
		loc.grid.Announce("Warning: Unkown vessels aproaching.")
		spawn(5)
			loc.grid.Announce("Warning: Communications and propulsion have been disabled.")


/datum/game_mode/hijack
	name = "Hijack"
	config_tag = "hijack"
	var/datum/travloc/baseloc

	var/const/traitors_possible = 4
	var/const/waittime_l = 600 // Lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 // Upper bound on time before intercept arrives (in tenths of seconds)
	uplink_welcome = "Syndicate Uplink Console:"
	uplink_items = {"/obj/item/weapon/storage/syndie_kit/imp_freedom:3:Freedom Implant, with injector;
	/obj/item/weapon/storage/syndie_kit/imp_compress:5:Compressed matter implant, with injector;/obj/item/weapon/storage/syndie_kit/imp_vfac:5:Viral factory implant, with injector;
	/obj/item/weapon/storage/syndie_kit/imp_explosive:6:Explosive implant, with injector;/obj/item/device/hacktool:4:Hacktool;
	/obj/item/clothing/under/chameleon:2:Chameleon Jumpsuit;/obj/item/weapon/gun/revolver:7:Revolver;
	/obj/item/weapon/ammo/a357:3:Revolver Ammo;/obj/item/weapon/card/emag:3:Electromagnetic card;
	/obj/item/weapon/card/id/syndicate:4:Fake ID;/obj/item/weapon/cloaking_device:5:Cloaking device;
	/obj/item/weapon/storage/emp_kit:4:Box of EMP grenades;/obj/item/device/powersink:5:Power sink;
	/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA cart;/obj/item/device/chameleon:4:Chameleon projector;
	/obj/item/weapon/sword:5:Energy sword;/obj/item/weapon/pen/sleepypen:4:Sleepy pen;
	/obj/item/weapon/gun/energy/crossbow:5:Energy crossbow;/obj/item/clothing/mask/gas/voice:3:Voice changer;
	/obj/item/weapon/aiModule/freeform:3:Freeform AI module;/obj/item/weapon/syndie/c4explosive:4:Low power explosive charge, with detonator);
	/obj/item/weapon/syndie/c4explosive/heavy:7:High (!) power explosive charge, with detonator;/obj/item/weapon/reagent_containers/pill/tox:2:Toxin Pill"}
	uplink_uses = 10
	var/num_players = 0

/datum/game_mode/hijack/announce()
	..()
//	world << "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!!</B>"

/datum/game_mode/hijack/pre_setup()

	var/list/possible_traitors = get_possible_traitors()

	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			num_players++

	var/r = rand(5)
	var/num_traitors = 1

	// Stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	if(traitor_scaling)
		num_traitors = max(1, min(round((num_players + r) / 7, 1), traitors_possible))
		log_game("Number of traitors: [num_traitors]")
		message_admins("Players counted: [num_players]  Number of traitors chosen: [num_traitors]")

	for(var/i = 0, i < num_traitors, i++)
		var/datum/mind/traitor = pick(possible_traitors)
		traitors += traitor
		possible_traitors.Remove(traitor)

	for(var/datum/mind/traitor in traitors)
		if(!traitor || !istype(traitor))
			traitors.Remove(traitor)
			continue
		if(istype(traitor))
			traitor.special_role = "hijacker"

	if(!traitors.len)
		return 0
	return 1

/datum/objective/stealship
	var/datum/travloc/baseloc

	New(var/datum/travloc/bloc)
		baseloc=bloc
		explanation_text = "Bring the ship to our base disguised as a meteor storm at [baseloc.x] - [baseloc.y]"




/datum/game_mode/hijack/check_finished()
	if((tgrid.Luna.loc==baseloc) || (main_shuttle.location==2))
		return 1
	else
		return 0


/datum/game_mode/hijack/post_setup()
	var/datum/travloc/t
	var/chosen
	while(!chosen)
		var/a = rand(20)
		var/b = rand(20)
		var/datum/travevent/Luna = tgrid.Luna
		var/datum/travloc/LOC = tgrid.grid[a][b]
		if(!LOC.contents.Find(Luna))
			t = tgrid.grid[a][b]
			chosen = 1
	var/datum/travevent/b = tgrid.MakeEvent(/datum/travevent/meteor/base,t.x,t.y)
	baseloc=b.loc

	for(var/datum/mind/traitor in traitors)
		var/datum/traitorinfo/info = new
		info.ckey = traitor.key
		info.starting_player_count = num_players
		if(traitors.len>1)
			traitor.memory += "<BR> Fellow hijackers: "
			for(var/datum/mind/ttt in traitors)
				traitor.memory +="\"[ttt.current.real_name]\" "

		if(istype(traitor.current, /mob/living/silicon))
			var/datum/objective/stealship/kill_objective = new(baseloc)
			kill_objective.owner = traitor
			traitor.objectives += kill_objective

			info.starting_occupation = "AI"

			add_law_zero(traitor.current)

		else
			info.starting_occupation = traitor.current:wear_id:assignment

			var/datum/objective/stealship/kill_objective = new(baseloc)
			kill_objective.owner = traitor
			traitor.objectives += kill_objective

		/*	switch(rand(1,200))
				if(1 to 50)
					var/datum/objective/assassinate/kill_objective = new
					kill_objective.owner = traitor
					kill_objective.find_target()
					traitor.objectives += kill_objective
				if(50 to 100)
					var/datum/objective/steal/steal_objective = new
					steal_objective.owner = traitor
					steal_objective.find_target()
					traitor.objectives += steal_objective
				else
					var/datum/objective/stealreagent/steal_objective = new
					steal_objective.owner = traitor
					steal_objective.find_target()
					traitor.objectives += steal_objective
			if(prob(25))
				switch(rand(1,100))
					if(1 to 50)
						var/datum/objective/steal/steal_objective = new
						steal_objective.owner = traitor
						steal_objective.find_target()
						traitor.objectives += steal_objective
					else
						var/datum/objective/stealreagent/steal_objective = new
						steal_objective.owner = traitor
						steal_objective.find_target()
						traitor.objectives += steal_objective
			switch(rand(1,100))
				if(1 to 90)
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective

				else
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = traitor
					traitor.objectives += hijack_objective*/


			equip_traitor(traitor.current)

		for(var/datum/objective/objective in traitor.objectives)
			info.starting_objective += objective.explanation_text + "            "

		logtraitors[traitor] = info

		traitor.current << "\red <B>You are a hijacker.</B>"
		traitor.current << "\red <B>REPEAT</B>"
		traitor.current << "\red <B>You are a hijacker.</B>"
		spawn(6000*tick_multiplier)			//Strumpetplaya - Just another friendly reminder so people don't forget they're the traitor.
			traitor.current << "\red <B>In case you missed it the first time - YOU ARE A HIJACKER!</B>"
		var/obj_count = 1
		for(var/datum/objective/objective in traitor.objectives)
			traitor.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++
		traitor.current << "\red <B>You have 1 and 1/2 hours to complete your objective</B>"
		traitor.current << "\red <B>If you do not complete your objective and return within the allotted time, we will be forced to reveal your identity</B>"
		spawn(54000*tick_multiplier)
			command_alert("Summary downloaded and printed out at all communications consoles.", "The traitor has been determined")
			var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested status information:</FONT><HR>"
			intercepttext += "We have determined the hijackers name to be: [traitor.current.real_name]"
			for (var/obj/machinery/computer/communications/comm in world)
				if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
					var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
					intercept.name = "paper- 'Cent. Com. Status Summary'"
					intercept.info = intercepttext

					comm.messagetitle.Add("Cent. Com. Status Summary")
					comm.messagetext.Add(intercepttext)
			spawn(12000*tick_multiplier)
				command_alert("Repeating the previous message over intercoms due to urgency. The station has a hijacker onboard by the name of [traitor.current.real_name], please arrest them and bring them on the emergency shuttle at once", "The hijacker has been determined")


	spawn (rand(waittime_l, waittime_h)*tick_multiplier)
		send_intercept()


/datum/game_mode/hijack/proc/get_possible_traitors()
	var/list/candidates = list()
	for(var/mob/new_player/player in world)
		if (player.client && player.ready)
			if(player.preferences.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if (player.client && player.ready)
				candidates += player.mind

	return candidates

/datum/game_mode/hijack/send_intercept()
	var/intercepttext = "<FONT size = 3><B>Cent. Com. Update</B> Requested status information:</FONT><HR>"
	intercepttext += "<B> Cent. Com has recently been contacted by the following syndicate affiliated organisations in your area, please investigate any information you may have:</B>"

	var/list/possible_modes = list()
	possible_modes.Add("revolution", "wizard", "nuke", "traitor", "malf")
	possible_modes -= "[ticker.mode]"
	var/number = pick(2, 3)
	for(var/i = 0, i < number, i++)
		possible_modes.Remove(pick(possible_modes))
	possible_modes.Insert(rand(possible_modes.len), "[ticker.mode]")

	var/datum/intercept_text/i_text = new /datum/intercept_text
	for(var/A in possible_modes)
		intercepttext += i_text.build(A, pick(traitors))

	for (var/obj/machinery/computer/communications/comm in world)
		if (!(comm.stat & (BROKEN | NOPOWER)) && comm.prints_intercept)
			var/obj/item/weapon/paper/intercept = new /obj/item/weapon/paper( comm.loc )
			intercept.name = "paper- 'Cent. Com. Status Summary'"
			intercept.info = intercepttext

			comm.messagetitle.Add("Cent. Com. Status Summary")
			comm.messagetext.Add(intercepttext)

	command_alert("Summary downloaded and printed out at all communications consoles.", "Enemy communication intercept. Security Level Elevated.")



/datum/game_mode/hijack/declare_completion()
	if(tgrid.Luna.loc == baseloc)
		world << "<B>Hijackers have stolen [station_name()]!</B>"
		for(var/datum/mind/M in traitors)
			if(!M.current)
				continue
			if(M.current.client)
				world << text("<B>[M.current.key] was [M.current.real_name]</B> [M.current.stat == 2 ? "(DEAD)" : ""]")

	else
		world << "<FONT size = 3><B>The Research Staff has stopped the hijackers!</B></FONT>"
		for(var/datum/mind/M in ticker.minds)
			if (!M.current)
				continue
			if ((M.current.client) && !(locate(M) in traitors))
				world << text("<B>[M.current.key] was [M.current.real_name]</B> [M.current.stat == 2 ? "(DEAD)" : ""]")
	check_round()
	return 1

/datum/game_mode/hijack/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Accomplish your objectives at all costs."
	killer << "<b>Your laws have been changed!</b>"
	killer:set_zeroth_law(law)
	killer << "New law: 0. [law]"

/datum/game_mode/hijack/proc/get_mob_list()
	var/list/mobs = list()
	for(var/mob/living/player in world)
		if (player.client)
			mobs += player
	return mobs

/datum/game_mode/hijack/proc/pick_human_name_except(excluded_name)
	var/list/names = list()
	for(var/mob/living/player in world)
		if (player.client && (player.real_name != excluded_name))
			names += player.real_name
	if(!names.len)
		return null
	return pick(names)