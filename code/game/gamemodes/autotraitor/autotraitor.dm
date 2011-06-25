//This is a beta game mode to test ways to implement an "infinite" traitor round in which more traitors are automatically added in as needed.
//Automatic traitor adding is complete pending the inevitable bug fixes.  Need to add a respawn system to let dead people respawn after 30 minutes or so.


/datum/game_mode/traitor/autotraitor
	name = "AutoTraitor"
	config_tag = "Extend-A-Traitormongous"

/datum/game_mode/traitor/autotraitor/announce()
	..()
	world << "<B>This is a test bed for theories and methods to implement an infinite traitor round.  Traitors will be added to the round automagically as needed.<br>Expect bugs.</B>"


/datum/game_mode/traitor/autotraitor/post_setup()
	..()
	traitorcheckloop()

/datum/game_mode/traitor/autotraitor/proc/traitorcheckloop()
	spawn(9000)
		message_admins("Performing AutoTraitor Check")
		var/playercount = 0
		var/traitorcount = 0
		var/possible_traitors = list()
		for(var/mob/living/player in world)

			if (player.client && player.stat != 2)
				playercount += 1
			if (player.mind && player.mind.special_role && player.stat != 2)
				traitorcount += 1
			if (player.client && player.mind && !player.mind.special_role && player.stat != 2 && player.be_syndicate)
				possible_traitors += player
		message_admins("Live Players: [playercount]")
		message_admins("Live Traitors: [traitorcount]")
		message_admins("Potential Traitors:")
		for(var/mob/living/traitorlist in possible_traitors)
			message_admins("[traitorlist.real_name]")

		var/r = rand(5)
		var/target_traitors = 1

		target_traitors = max(1, min(round((num_players + r) / 10, 1), traitors_possible))
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

		traitorcheckloop()



/datum/game_mode/traitor/autotraitor/latespawn(mob/living/carbon/human/character)
	..()
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

		var/r = rand(5)
		var/target_traitors = 1

		target_traitors = max(1, min(round((num_players + r) / 10, 1), traitors_possible))
		message_admins("Target Traitor Count is: [target_traitors]")
		if (traitorcount < target_traitors)
			message_admins("Number of Traitors is below Target.  Making New Arrival Traitor.")
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
		message_admins("Late Joiner does not have Be Syndicate")



