GLOBAL_LIST_EMPTY(survivor_report)
GLOBAL_LIST_EMPTY(common_report)

/datum/controller/subsystem/ticker/proc/personal_report(client/C, popcount)
	var/list/parts = list()
	var/mob/Player = C.mob
	if(Player.mind && !isnewplayer(Player))
		if(Player.stat != DEAD && !isbrain(Player))
			var/turf/playerTurf = get_turf(Player)
			if(evacuation_controller.round_over() && evacuation_controller.emergency_evacuation)
				if(isNotAdminLevel(playerTurf.z))
					parts += "<div class='panel stationborder'>"
					parts += "<span class='marooned'>You managed to survive, but were marooned on [station_name()] as [Player.real_name]...</span>"
				else
					parts += "<div class='panel greenborder'>"
					parts += "<span class='greentext'>You managed to survive the events on [station_name()] as [Player.real_name].</span>"
			else if(isAdminLevel(playerTurf.z))
				parts += "<div class='panel greenborder'>"
				parts += "<span class='greentext'>You successfully underwent crew transfer after events on [station_name()] as [Player.real_name].</span>"
			else if(issilicon(Player))
				parts += "<div class='panel greenborder'>"
				parts += "<span class='greentext'>You remain operational after the events on [station_name()] as [Player.real_name].</span>"
			else
				parts += "<div class='panel greenborder'>"
				parts += "<span class='greentext'>You got through just another workday on [station_name()] as [Player.real_name].</span>"

		else
			var/mob/observer/ghost/O = Player
			if (!istype(Player) || !O.started_as_observer)
				parts += "<div class='panel redborder'>"
				parts += "<span class='redtext'>You did not survive the events on [station_name()]...</span>"
	else
		parts += "<div class='panel stationborder'>"
	parts += "<br>"
	parts += GLOB.survivor_report
	parts += "</div>"

	return parts.Join()


/datum/controller/subsystem/ticker/proc/survivor_report()
	var/clients = 0
	var/surviving_humans = 0
	var/surviving_total = 0
	var/ghosts = 0
	var/escaped_humans = 0
	var/escaped_total = 0


	for(var/mob/M in GLOB.player_list)
		if(!M.client)
			continue
		clients++
		if(M.stat != DEAD)
			surviving_total++
			if(ishuman(M))
				surviving_humans++
			var/area/A = get_area(M)
			if(A && is_type_in_list(A, GLOB.using_map.post_round_safe_areas))
				escaped_total++
				if(ishuman(M))
					escaped_humans++
		else if(isghost(M))
			ghosts++

	var/list/parts = list()

	if(surviving_total > 0)
		parts += "<br>There [surviving_total>1 ? "were <b>[surviving_total] survivors</b>" : "was <b>one survivor</b>"]"
		parts += " (<b>[escaped_total>0 ? escaped_total : "none"] [evacuation_controller.emergency_evacuation ? "escaped" : "transferred"]</b>) and <b>[ghosts] ghosts</b>.<br>"
	else
		parts += "There were <b>no survivors</b> (<b>[ghosts] ghosts</b>)."

	if(clients > 0)
		feedback_set("round_end_clients", clients)
	if(ghosts > 0)
		feedback_set("round_end_ghosts", ghosts)
	if(surviving_humans > 0)
		feedback_set("survived_human", surviving_humans)
	if(surviving_total > 0)
		feedback_set("survived_total", surviving_total)
	if(escaped_humans > 0)
		feedback_set("escaped_human", escaped_humans)
	if(escaped_total > 0)
		feedback_set("escaped_total", escaped_total)

	send2mainirc("A round of [src.name] has ended - [surviving_total] survivor\s, [ghosts] ghost\s.")

	return parts.Join()

/datum/controller/subsystem/ticker/proc/synths_report()
	var/list/parts = list()
	var/borg_spacer = FALSE //inserts an extra linebreak to seperate AIs from independent borgs, and then multiple independent borgs.
	//Silicon laws report
	for (var/mob/living/silicon/ai/aiPlayer in SSmobs.mob_list)
		if (aiPlayer.stat != DEAD)
			parts += "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the round were:</b>"
		else
			parts += "<b>[aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</b>"


		parts += aiPlayer.laws?.print_laws()

		if (aiPlayer.connected_robots.len)
			parts += "<b>The AI's loyal minions were:</b> "
			for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
				parts += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"

		if(!borg_spacer)
			borg_spacer = TRUE

	var/dronecount = 0

	for (var/mob/living/silicon/robot/robo in SSmobs.mob_list)

		if(istype(robo,/mob/living/silicon/robot/drone))
			dronecount++
			continue

		if (!robo.connected_ai)
			parts += "[borg_spacer?"<br>":""]<b>[robo.name]</b> (Played by: <b>[robo.mind.key]</b>) [(robo.stat != DEAD)? "<span class='greentext'>survived</span> as an AI-less borg!" : "was <span class='redtext'>unable to survive</span> the rigors of being a cyborg without an AI."] Its laws were:"

			if(robo) //How the hell do we lose robo between here and the world messages directly above this?
				parts += robo.laws?.print_laws()

			if(!borg_spacer)
				borg_spacer = TRUE

	if(dronecount)
		parts += "[borg_spacer?"<br>":""]<b>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] at the end of this round.</b>"

	return parts.len ? "<div class='panel stationborder'>[parts.Join("<br>")]</div>" : null

/datum/controller/subsystem/ticker/proc/money_report()
	if(!all_money_accounts.len)
		return
	var/datum/money_account/max_profit = all_money_accounts[1]
	var/datum/money_account/max_loss = all_money_accounts[1]
	for(var/datum/money_account/D in all_money_accounts)
		if(D == vendor_account) //yes we know you get lots of money
			continue
		var/saldo = D.get_balance()
		if(saldo >= max_profit.get_balance())
			max_profit = D
		if(saldo <= max_loss.get_balance())
			max_loss = D
	var/list/parts = list()
	parts += "<b>[max_profit.owner_name]</b> received most <font color='green'><B>PROFIT</B></font> today, with net profit of <b>T[max_profit.get_balance()]</b>."
	parts += "On the other hand, <b>[max_loss.owner_name]</b> had most <font color='red'><B>LOSS</B></font>, with total loss of <b>T[max_loss.get_balance()]</b>."
	return "<div class='panel stationborder'>[parts.Join("<br>")]</div>"

/datum/controller/subsystem/ticker/proc/antag_report()
	var/list/parts = list()

	parts += mode.print_roundend()

	var/list/all_antag_types = GLOB.all_antag_types_
	for(var/datum/antagonist/antag in mode.antag_templates)
		parts += antag.print_roundend()
		parts += antag.print_player_summary()

	for(var/antag_type in all_antag_types)
		var/datum/antagonist/antag = all_antag_types[antag_type]
		if(!antag.current_antagonists.len || (antag in mode.antag_templates))
			continue
		parts += antag.print_player_summary()

	parts += uplink_purchase_repository.print_entries()

	listclearnulls(parts)
	return parts.len ? "<div class='panel stationborder'>[parts.Join("<br>")]</div>" : null

//Common part of the report
/datum/controller/subsystem/ticker/proc/build_roundend_report()
	var/list/parts = list()

	//AI laws and drones
	parts += synths_report()

	parts += money_report()

	CHECK_TICK

	parts += mode.special_report()

	CHECK_TICK

	//Antagonists
	parts += antag_report()

	parts += SSevent.RoundEnd()

	listclearnulls(parts)

	CHECK_TICK

	return parts.Join()

/datum/controller/subsystem/ticker/proc/display_report()
	GLOB.common_report = build_roundend_report()

	//taken from to_chat(), processes all explanded \icon macros since they don't work in minibrowser (they only work in text output)
	var/static/regex/icon_replacer = new(@/<IMG CLASS=icon SRC=(\[[^]]+])(?: ICONSTATE='([^']+)')?>/, "g")	//syntax highlighter fix -> '
	while(icon_replacer.Find(GLOB.common_report))
		GLOB.common_report =\
			copytext(GLOB.common_report,1,icon_replacer.index) +\
			icon2html(locate(icon_replacer.group[1]), target = world, icon_state=icon_replacer.group[2]) +\
			copytext(GLOB.common_report,icon_replacer.next)


	GLOB.survivor_report = survivor_report()
	for(var/client/C in GLOB.clients)
		show_roundend_report(C)
		give_show_report_button(C)
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/give_show_report_button(client/C)
	var/datum/action/report/R = new
	R.Grant(C.mob)
	to_chat(C,"<a href='?src=\ref[R];report=1'>Show roundend report again</a>")

/datum/action/report
	name = "Show roundend report"
	button_icon_state = "round_end"

/datum/action/report/Trigger()
	if(owner && GLOB.common_report)
		SSticker.show_roundend_report(owner.client, TRUE)

/datum/action/report/IsAvailable()
	return 1

/datum/action/report/Topic(href,href_list)
	if(usr != owner)
		return
	if(href_list["report"])
		Trigger()
		return

/client/proc/roundend_report_file()
	return "data/roundend_reports/[ckey].html"

/datum/controller/subsystem/ticker/proc/show_roundend_report(client/C, previous = FALSE)
	var/datum/browser/roundend_report = new(C.mob, "roundend")
	roundend_report.width = 800
	roundend_report.height = 600
	var/content
	var/filename = C.roundend_report_file()
	if(!previous)
		var/list/report_parts = list(personal_report(C), GLOB.common_report)
		content = report_parts.Join()
		fdel(filename)
		text2file(content, filename)
	else
		content = file2text(filename)
	roundend_report.set_content(content)
	roundend_report.stylesheets = list()
	roundend_report.add_stylesheet("roundend", 'html/browser/roundend.css')
	roundend_report.add_stylesheet("font-awesome", 'html/font-awesome/css/all.min.css')
	to_chat(C, content)
	log_roundend(GLOB.common_report)
	roundend_report.open(FALSE)
