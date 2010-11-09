/datum/game_mode
	var/name = "Invalid"
	var/config_tag = null
	var/votable = 1
	var/probability = 1
	// this includes admin-appointed traitors and multitraitors. Easy!
	var/list/datum/mind/traitors = list()
	var/list/logtraitors = list( )
	var/enabled = 1

/datum/game_mode/proc/announce()
	world << "<B>The current game mode is - [name]!</B>"

/datum/game_mode/proc/pre_setup()
	return 1

/datum/game_mode/proc/post_setup()

/datum/game_mode/proc/process()

/datum/game_mode/proc/check_finished()
	if(main_shuttle.location==2)
		return 1
	return 0

/datum/game_mode/proc/declare_completion()
	for(var/datum/mind/traitor in traitors)
		var/traitorwin = 1
		var/traitor_name

		if(traitor.current)
			traitor_name = "[traitor.current.real_name] (played by [traitor.key])"
		else
			traitor_name = "[traitor.key] (character destroyed)"

		world << "<B>The syndicate traitor was [traitor_name]</B>"
		var/count = 1
		for(var/datum/objective/objective in traitor.objectives)
			world << "<B>Objective #[count]</B>: [objective.explanation_text] \..."
			if (objective.check_completion())
				world << "\green <B>Success</B>"
				for(var/client/C in world)
					if(C.key == traitor.key)
						C.mob.add_stat(4,1)
						C.mob.unlock_medal("Oh I'm a terrorist?", 0, "Kinda", "medium")
			else
				world << "\red Failed"
				traitorwin = 0
			count++

		world << "<B>The traitor [(traitorwin ? "was successful" : "has failed")]!</B>"

		var/datum/traitorinfo/info = logtraitors[traitor]
		if (info)
			var/DBQuery/query = dbcon.NewQuery("INSERT INTO `bay12`.`traitorlogs` (`CKey`, `Objective`, `Succeeded`, `Spawned`, `Occupation`, `PlayerCount`) VALUES ('[info.ckey]', '[info.starting_objective]', '[traitorwin]', '[dd_list2text(info.spawnlist, ";")]', '[info.starting_occupation]', '[info.starting_player_count]')")
			query.Execute()

	check_round()
	return 1

/datum/game_mode/proc/check_win()

/datum/game_mode/proc/latespawn(var/mob)

/datum/game_mode/proc/send_intercept()
/datum/game_mode/proc/check_round()
	for(var/client/C)
		if(C.mob)
			C.mob.add_stat(1,1)
			if(C.mob.stat != 2)
				C.mob.unlock_medal("Survivor", 0, "What do you think?", "easy")

/datum/game_mode/proc/equip_traitor(mob/living/carbon/human/traitor_mob)
	if (!istype(traitor_mob))
		return

	// generate list of radio freqs
	var/freq = 1441
	var/list/freqlist = list()
	while (freq <= 1489)
		if (freq < 1451 || freq > 1459)
			freqlist += freq
		freq += 2
		if ((freq % 2) == 0)
			freq += 1
	freq = freqlist[rand(1, freqlist.len)]
	// generate a passcode if the uplink is hidden in a PDA
	var/pda_pass = "[rand(100,999)] [pick("Alpha","Bravo","Delta","Omega")]"

	// find a radio! toolbox(es), backpack, belt, headset
	var/loc = ""
	var/obj/item/device/R = null //Hide the uplink in a PDA if available, otherwise radio
	if (!R && istype(traitor_mob.belt, /obj/item/device/pda))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.l_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.l_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your left hand"
			break
	if (!R && istype(traitor_mob.r_hand, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.r_hand
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] in your right hand"
			break
	if (!R && istype(traitor_mob.back, /obj/item/weapon/storage))
		var/obj/item/weapon/storage/S = traitor_mob.back
		var/list/L = S.return_inv()
		for (var/obj/item/device/radio/foo in L)
			R = foo
			loc = "in the [S.name] on your back"
			break
	if (!R && traitor_mob.w_uniform && istype(traitor_mob.belt, /obj/item/device/radio))
		R = traitor_mob.belt
		loc = "on your belt"
	if (!R && istype(traitor_mob.ears, /obj/item/device/radio))
		R = traitor_mob.ears
		loc = "on your head"
	if (!R)
		traitor_mob << "Unfortunately, the Syndicate wasn't able to get you a radio."
	else
		if (istype(R, /obj/item/device/radio))
			var/obj/item/weapon/syndicate_uplink/T = new /obj/item/weapon/syndicate_uplink(R)
			R:traitorradio = T
			R:traitor_frequency = freq
			T.name = R.name
			T.icon_state = R.icon_state
			T.origradio = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply dial the frequency [format_frequency(freq)] to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Radio Freq:</B> [format_frequency(freq)] ([R.name] [loc]).")
		else if (istype(R, /obj/item/device/pda))
			var/obj/item/weapon/integrated_uplink/T = new /obj/item/weapon/integrated_uplink(R)
			R:uplink = T
			T.lock_code = pda_pass
			T.hostpda = R
			traitor_mob << "The Syndicate have cunningly disguised a Syndicate Uplink as your [R.name] [loc]. Simply enter the code \"[pda_pass]\" into the ringtone select to unlock its hidden features."
			traitor_mob.mind.store_memory("<B>Uplink Passcode:</B> [pda_pass] ([R.name] [loc]).")