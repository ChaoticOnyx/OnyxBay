//This is a beta game mode to test ways to implement an "infinite" traitor round in which more traitors are automatically added in as needed.
//Automatic traitor adding is complete pending the inevitable bug fixes.  Need to add a respawn system to let dead people respawn after 30 minutes or so.


/datum/game_mode/traitor/autotraitor
	name = "AutoTraitor"
	config_tag = "Extend-A-Traitormongous"
	uplink_items = {"/obj/item/weapon/storage/syndie_kit/imp_freedom:3:Freedom Implant, with injector;
/obj/item/weapon/storage/syndie_kit/imp_compress:5:Compressed matter implant, with injector;/obj/item/weapon/storage/syndie_kit/imp_vfac:5:Viral factory implant, with injector;
/obj/item/weapon/storage/syndie_kit/imp_explosive:6:Explosive implant, with injector;/obj/item/device/hacktool:4:Hacktool;
/obj/item/clothing/under/chameleon:2:Chameleon Jumpsuit;/obj/item/weapon/gun/revolver:7:Revolver;
/obj/item/weapon/ammo/a357:3:Revolver Ammo;/obj/item/weapon/card/emag:3:Electromagnetic card;
/obj/item/weapon/card/id/syndicate:4:Fake ID;/obj/item/clothing/glasses/thermal:4:Thermal Glasses;
/obj/item/weapon/storage/emp_kit:4:Box of EMP grenades;/obj/item/device/powersink:5:Power sink;
/obj/item/weapon/cartridge/syndicate:3:Detomatix PDA cart;/obj/item/device/chameleon:4:Chameleon projector;
/obj/item/weapon/sword:5:Energy sword;/obj/item/weapon/pen/sleepypen:4:Sleepy pen;
/obj/item/weapon/gun/energy/crossbow:5:Energy crossbow;/obj/item/clothing/mask/gas/voice:3:Voice changer;
/obj/item/weapon/aiModule/freeform:3:Freeform AI module;/obj/item/weapon/syndie/c4explosive:4:Low power explosive charge, with detonator);
/obj/item/weapon/reagent_containers/pill/tox:2:Toxin Pill"}

/datum/game_mode/traitor/autotraitor/announce()
	..()
	world << "<B>This is a test bed for theories and methods to implement an infinite traitor round.  Traitors will be added to the round automagically as needed.<br>Expect bugs.</B>"

/datum/game_mode/traitor/autotraitor/pre_setup()
	var/list/possible_traitors = get_possible_traitors()

	for(var/mob/new_player/P in world)
		if(P.client && P.ready)
			num_players++

	//var/r = rand(5)
	var/num_traitors = 1
	var/max_traitors = 1
	var/traitor_prob = 0
	max_traitors = round(num_players, 10) / 10 + 1
	traitor_prob = min((num_players - (max_traitors - 1) * 10) * 10, 100)

	// Stop setup if no possible traitors
	if(!possible_traitors.len)
		return 0

	if(traitor_scaling)
		num_traitors = max_traitors - 1 + prob(traitor_prob)
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
			traitor.special_role = "traitor"

//	if(!traitors.len)
//		return 0
	return 1




/datum/game_mode/traitor/autotraitor/post_setup()
	..()
	abandon_allowed = 1
	traitorcheckloop()

/datum/game_mode/traitor/autotraitor/proc/traitorcheckloop()
	spawn(9000)
		if(LaunchControl.departed)
			return
		message_admins("Performing AutoTraitor Check")
		var/playercount = 0
		var/traitorcount = 0
		var/possible_traitors[0]
		for(var/mob/living/player in world)

			if (player.client && player.stat != 2)
				playercount += 1
			if (player.client && player.mind && player.mind.special_role && player.stat != 2)
				traitorcount += 1
			if (player.client && player.mind && !player.mind.special_role && player.stat != 2 && player.be_syndicate)
				possible_traitors += player
		message_admins("Live Players: [playercount]")
		message_admins("Live Traitors: [traitorcount]")
		message_admins("Potential Traitors:")
		for(var/mob/living/traitorlist in possible_traitors)
			message_admins("[traitorlist.real_name]")

//		var/r = rand(5)
//		var/target_traitors = 1
		var/max_traitors = 1
		var/traitor_prob = 0
		max_traitors = round(playercount, 10) / 10 + 1
		traitor_prob = min((playercount - (max_traitors - 1) * 10) * 10, 100) / 2


		if(traitorcount < max_traitors)
			message_admins("Number of Traitors is below maximum.  Rolling for new Traitor.")
			message_admins("The probability of a new traitor is [traitor_prob]%")

			if(prob(traitor_prob))
				message_admins("New traitor roll passed.  Making a new Traitor.")
				if(!possible_traitors.len)
					message_admins("No potential traitors.  Cancelling new traitor.")
					traitorcheckloop()
					return
				var/mob/living/newtraitor = pick(possible_traitors)
				message_admins("[newtraitor.real_name] is the new Traitor.")

				for(var/datum/objective/o in SelectObjectives(newtraitor.mind.assigned_role, newtraitor.mind))
					o.owner = newtraitor.mind
					newtraitor.mind.objectives += o

				equip_traitor(newtraitor)
				traitors += newtraitor.mind
				newtraitor << "\red <B>ATTENTION:</B> \black It is time to pay your debt to the Syndicate..."
				newtraitor << "<B>You are now a traitor.</B>"
				newtraitor.mind.special_role = "traitor"
				var/obj_count = 1
				newtraitor << "\blue Your current objectives:"
				for(var/datum/objective/objective in newtraitor.mind.objectives)
					newtraitor << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
					obj_count++
			else
				message_admins("No new traitor being added.")
		else
			message_admins("Number of Traitors is at maximum.  Not making a new Traitor.")


/*	Old equation.  Commenting out.
		target_traitors = max(1, min(round((playercount + r) / 10, 1), traitors_possible))
		message_admins("Target Traitor Count is: [target_traitors]")

		if (traitorcount < target_traitors)
			message_admins("Number of Traitors is below Target.  Making a new Traitor.")
			var/mob/living/newtraitor = pick(possible_traitors)
			message_admins("[newtraitor.real_name] is the new Traitor.")

			for(var/datum/objective/o in SelectObjectives(newtraitor.mind.assigned_role, newtraitor.mind))
				o.owner = newtraitor.mind
				newtraitor.mind.objectives += o

			equip_traitor(newtraitor)
			traitors += newtraitor.mind
			newtraitor << "\red <B>ATTENTION:</B> \black It is time to pay your debt to the Syndicate..."
			newtraitor << "<B>You are now a traitor.</B>"
			newtraitor.mind.special_role = "traitor"
			var/obj_count = 1
			newtraitor << "\blue Your current objectives:"
			for(var/datum/objective/objective in newtraitor.mind.objectives)
				newtraitor << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++
		else
			message_admins("Number of Traitors is at Target.  No new Traitor.")
*/
		traitorcheckloop()



/datum/game_mode/traitor/autotraitor/latespawn(mob/living/carbon/human/character)
	..()
	if(LaunchControl.departed)
		return
	message_admins("Late Join Check")
	if(character.be_syndicate == 1)
		message_admins("Late Joiner has Be Syndicate")
		message_admins("Checking number of players")
		var/playercount = 0
		var/traitorcount = 0
		for(var/mob/living/player in world)

			if (player.client && player.stat != 2)
				playercount += 1
			if (player.mind && player.mind.special_role && player.stat != 2)
				traitorcount += 1
		message_admins("Live Players: [playercount]")
		message_admins("Live Traitors: [traitorcount]")

		//var/r = rand(5)
		//var/target_traitors = 1
		var/max_traitors = 1
		var/traitor_prob = 0
		max_traitors = round(playercount, 10) / 10 + 1
		traitor_prob = min((playercount - (max_traitors - 1) * 10) * 10, 100) / 2


		//target_traitors = max(1, min(round((playercount + r) / 10, 1), traitors_possible))
		//message_admins("Target Traitor Count is: [target_traitors]")
		if (traitorcount < max_traitors)
			message_admins("Number of Traitors is below maximum.  Rolling for New Arrival Traitor.")
			message_admins("The probability of a new traitor is [traitor_prob]%")
			if(prob(traitor_prob))
				message_admins("New traitor roll passed.  Making a New Arrival Traitor.")
				for(var/datum/objective/o in SelectObjectives(character.mind.assigned_role, character.mind))
					o.owner = character.mind
					character.mind.objectives += o
				equip_traitor(character)
				traitors += character.mind
				character << "\red <B>You are the traitor.</B>"
				character.mind.special_role = "traitor"
				var/obj_count = 1
				character << "\blue Your current objectives:"
				for(var/datum/objective/objective in character.mind.objectives)
					character << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
					obj_count++
			else
				message_admins("New traitor roll failed.  No new traitor.")
	else
		message_admins("Late Joiner does not have Be Syndicate")



