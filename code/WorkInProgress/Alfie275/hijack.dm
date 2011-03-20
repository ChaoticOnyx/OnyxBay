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
	var/list/datum/mind/syndicates = list()
	var/finished = 0
	var/agents_possible = 0 //If we ever need more syndicate agents.

	var/const/waittime_l = 600 //lower bound on time before intercept arrives (in tenths of seconds)
	var/const/waittime_h = 1800 //upper bound on time before intercept arrives (in tenths of seconds)

	var/list/synd_spawns = list()

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

	uplink_uses = 0

/datum/game_mode/hijack/announce()
	..()
//	world << "<B>There is a syndicate traitor on the station. Do not let the traitor succeed!!</B>"

/datum/game_mode/hijack/pre_setup()
	agents_possible = (get_player_count())/5
	if(agents_possible < 1)
		agents_possible = 1
	if(agents_possible > 5)
		agents_possible = 5

	var/list/possible_syndicates = list()
	possible_syndicates = get_possible_syndicates()
	var/agent_number = 0

	if(possible_syndicates.len < 1)
		return 0

	if(possible_syndicates.len > agents_possible)
		agent_number = agents_possible
	else
		agent_number = possible_syndicates.len

	while(agent_number > 0)
		var/datum/mind/new_syndicate = pick(possible_syndicates)
		syndicates += new_syndicate
		possible_syndicates -= new_syndicate //So it doesn't pick the same guy each time.
		agent_number--

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.assigned_role = "MODE" //So they aren't chosen for other jobs.

	uplink_uses = (syndicates.len*10)

	return 1

/datum/objective/stealship
	var/datum/travloc/baseloc

/datum/objective/stealship/New()
	var/datum/travevent/meteor/base/b
	for(var/datum/travevent/meteor/base/bas in tgrid.events)
		b = bas
	if(!b)
		var/datum/travloc/t
		var/chosen
		while(!chosen)
			var/a = rand(20)
			var/c = rand(20)
			var/datum/travevent/Luna = tgrid.Luna
			var/datum/travloc/LOC = tgrid.grid[a][c]
			if(!LOC.contents.Find(Luna))
				t = tgrid.grid[a][c]
				chosen = 1
		b = tgrid.MakeEvent(/datum/travevent/meteor/base,t.x,t.y)
	baseloc = b.loc
	if(ticker.mode.name=="Hijack")
		ticker.mode:baseloc=baseloc
	explanation_text = "Bring the ship to our base disguised as a meteor storm at [baseloc.x] - [baseloc.y]"


/datum/objective/stealship/check_completion()
	if((tgrid.Luna.loc==baseloc))
		return 1
	else
		return 0

/datum/game_mode/hijack/check_finished()
	if((tgrid.Luna.loc==baseloc) || (main_shuttle.location==2))
		return 1
	else
		return 0


/datum/game_mode/hijack/post_setup()
	for(var/mob/living/carbon/human/player in world)
		if(player.mind)
			var/role = player.mind.assigned_role
			if(role == "Captain")
				player << "One of our ships was recently stolen, and the crew held at ransom. We believe the same hijackers are targetting your ship."

	for(var/obj/landmark/synd_spawn/S in world)
		synd_spawns += S.loc

	var/obj/landmark/closet_spawn = locate("landmark*Nuclear-Closet")


	var/leader_title = pick("Czar", "Boss", "Commander", "Chief", "Kingpin", "Director", "Overlord")
	var/leader_selected = 0
	var/radio_freq = random_radio_frequency()

	for(var/datum/mind/synd_mind in syndicates)
		synd_mind.current.loc = pick(synd_spawns)
		synd_spawns -= synd_mind.current.loc

		var/datum/objective/stealship/syndobj = new
		syndobj.owner = synd_mind
		synd_mind.objectives += syndobj

		var/obj_count = 1
		synd_mind.current << "\blue You are a [syndicate_name()] agent!"
		for(var/datum/objective/objective in synd_mind.objectives)
			synd_mind.current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++
		synd_mind.current << "<BR> Also try to keep some crew alive for ransom, but don't let that interfere with your primary objective."
		if(!leader_selected)
			synd_mind.current.real_name = "[syndicate_name()] [leader_title]"
			leader_selected = 1

		equip_syndicate(synd_mind.current, radio_freq)


	if(closet_spawn)
		new /obj/closet/syndicate/nuclear(closet_spawn.loc)

	for (var/obj/landmark/A in world)
		if (A.name == "Syndicate-Gear-Closet")
			new /obj/closet/syndicate/personal(A.loc)
			del(A)
			continue

		if (A.name == "Syndicate-Bomb")
			new /obj/item/weapon/syndie/c4explosive(A.loc)
			del(A)
			continue

		if (A.name == "Syndicate-Bomb-Strong")
			new /obj/item/weapon/syndie/c4explosive/heavy(A.loc)
			del(A)
			continue

	spawn (rand(waittime_l, waittime_h)*tick_multiplier)
		send_intercept()

	return


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
		world << "<B>Hijackers have stolen the ship!</B>"
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

/datum/game_mode/hijack/proc/get_possible_syndicates()
	var/list/candidates = list()

	for(var/mob/new_player/player in world)
		if((player.client) &&  (player.ready))
			if(player.be_syndicate)
				candidates += player.mind

	if(candidates.len < 1)
		for(var/mob/new_player/player in world)
			if((player.client) && (player.ready))
				candidates += player.mind

	if(candidates.len < 1)
		return null
	else
		return candidates



datum/game_mode/hijack/proc/equip_syndicate(mob/living/carbon/human/synd_mob, radio_freq)

	var/obj/item/device/radio/R = new /obj/item/device/radio/headset(synd_mob)
	R.set_frequency(radio_freq)
	synd_mob.equip_if_possible(R, synd_mob.slot_ears)

	synd_mob.equip_if_possible(new /obj/item/clothing/under/syndicate(synd_mob), synd_mob.slot_w_uniform)
	synd_mob.equip_if_possible(new /obj/item/clothing/shoes/black(synd_mob), synd_mob.slot_shoes)
	synd_mob.equip_if_possible(new /obj/item/clothing/suit/armor/vest(synd_mob), synd_mob.slot_wear_suit)
	synd_mob.equip_if_possible(new /obj/item/clothing/gloves/swat(synd_mob), synd_mob.slot_gloves)
	synd_mob.equip_if_possible(new /obj/item/clothing/head/helmet/swat(synd_mob), synd_mob.slot_head)

	synd_mob.equip_if_possible(new /obj/item/weapon/storage/backpack(synd_mob), synd_mob.slot_back)
	synd_mob.equip_if_possible(new /obj/item/weapon/reagent_containers/pill/tox(synd_mob), synd_mob.slot_in_backpack)



/datum/game_mode/hijack/proc/random_radio_frequency()
	var/f = 0

	do
		f = rand(1441, 1489)
		f = sanitize_frequency(f)
	while (f == 0 || f == 1459)

	return f

/datum/game_mode/hijack/proc/get_player_count()
	var/count = 0
	for(var/mob/new_player/P in world)
		if(P.ready)
			count++
	return count