/proc/GetObjectives(var/job,var/datum/mind/traitor)
	var/list/datum/objective/objectives = list()
	for(var/o in typesof(/datum/objective/steal))
		if(o != /datum/objective/steal)		//Make sure not to get a blank steal objective.
			objectives += new o(null,job)

	//objectives += GenerateAssassinate(job,traitor)
	return objectives

/proc/GenerateAssassinate(var/job,var/datum/mind/traitor)
	var/list/datum/objective/assassinate/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/assassinate(null,job,target)
	return missions
/*
/proc/GenerateFrame(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/frame(null,job,target)
	return missions
*/
/proc/GenerateProtection(var/job,var/datum/mind/traitor)
	var/list/datum/objective/frame/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/protection(null,job,target)
	return missions



/proc/SelectObjectives(var/job,var/datum/mind/traitor)
	var/list/datum/objective/chosenobjectives = list()
	var/list/datum/objective/theftobjectives = GetObjectives(job,traitor)		//Separated all the objective types so they can be picked independantly of each other.
	var/list/datum/objective/killobjectives = GenerateAssassinate(job,traitor)
	//var/list/datum/objective/frameobjectives = GenerateFrame(job,traitor)
	var/list/datum/objective/protectobjectives = GenerateProtection(job,traitor)
	//var/points
	var/totalweight
	var/selectobj
	var/conflict

	while(totalweight < 100)
		selectobj = rand(1,100)	//Randomly determine the type of objective to be given.
		if(!length(killobjectives) || !length(protectobjectives))	//If any of these lists are empty, just give them theft objectives.
			var/datum/objective/objective = pick(theftobjectives)
			chosenobjectives += objective
			totalweight += objective.weight
			theftobjectives -= objective
		else switch(selectobj)
			if(1 to 50)		//Theft Objectives (50% chance)
				var/datum/objective/objective = pick(theftobjectives)
				chosenobjectives += objective
				totalweight += objective.weight
				theftobjectives -= objective
			if(51 to 90)	//Assassination Objectives (35% chance)
				var/datum/objective/assassinate/objective = pick(killobjectives)
				for(var/datum/objective/protection/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Assassinate somebody they need to Protect.
					if(conflicttest.target == objective.target)
						conflict = 1
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.weight
					killobjectives -= objective
				conflict = 0
			//if(86 to 95)	//Framing Objectives (10% chance) 	Removing fo now.
			//	var/datum/objective/objective = pick(frameobjectives)
			//	chosenobjectives += objective
			//	totalweight += objective.weight
			//	frameobjectives -= objective
			if(91 to 100)	//Protection Objectives (5% chance)
				var/datum/objective/protection/objective = pick(protectobjectives)
				for(var/datum/objective/assassinate/conflicttest in chosenobjectives)	//Check to make sure we aren't telling them to Protect somebody they need to Assassinate.
					if(conflicttest.target == objective.target)
						conflict = 1
				if(!conflict)
					chosenobjectives += objective
					totalweight += objective.weight
					protectobjectives -= objective
				conflict = 0

	var/hasendgame = 0
	for(var/datum/objective/o in chosenobjectives)
		if(o.type == /datum/objective/hijack)
			hasendgame = 1
	if(hasendgame == 0)
		chosenobjectives += new /datum/objective/escape(null,job)
	return chosenobjectives

datum
	objective
		var/datum/mind/owner
		var/explanation_text = "text not set"
		var/job
		var/points = INFINITY //If this isn't set to something else, the objective is bugged and should be ignored
		var/weight

		New(var/text,var/joba)
			if(text)
				src.explanation_text = text
			job=joba
			points = get_points(job)

		proc
			check_completion()
				return 1
			get_points(var/job)
				return INFINITY

		frame
			var/datum/mind/target

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				points = get_points(job)
				weight = 60
				explanation_text = "Frame [target.current.real_name], the [target.assigned_role] for a crime and make sure they are arrested and brought back to the Centcom station alive.  We'll handle the rest from there."

			check_completion()
				if(main_shuttle.location<2)
					return 0

				if(target.current.stat == 2)
					return 0

				var/turf/location = get_turf(target.current.loc)
				if(!location)
					return 0

				if(!target.current:handcuffed)
					return 0


				for(var/datum/shuttle/s in shuttles)
					if(location in locate(s.centcom))
						return 1

				return 0

			get_points()
				if(target)
					switch(GetRank(target.assigned_role))
						if(0)
							return 30
						if(1)
							return 40
						if(2)
							return 50
						if(3)
							return 55
						if(4)
							return 60
				else
					return INFINITY


		protection
			var/datum/mind/target
			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				points = get_points(job)
				weight = 30
				explanation_text = "[target.current.real_name], the [target.assigned_role] is a relative of a high ranking Syndicate Leader.  Make sure they get off the ship safely."

			check_completion()
				if(main_shuttle.location < 2)
					return 0

				if(target.current.stat == 2)
					return 0

				var/turf/location = get_turf(target.current.loc)
				if(!location)
					return 0

				for(var/datum/shuttle/s in shuttles)
					if(location in locate(s.centcom))
						return 1

				return 0
			get_points()
				return INFINITY

		assassinate
			var/datum/mind/target

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				points = get_points(job)
				weight = 60
				explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2)
						return 1
					else
						return 0
				else
					return 1
			get_points()
				if(target)
					switch(GetRank(target.assigned_role))
						if(0)
							return 30
						if(1)
							return 40
						if(2)
							return 50
						if(3)
							return 55
						if(4)
							return 60
				else
					return INFINITY

			proc/find_target_by_role(var/role)
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
						target = possible_target
						break

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target


			proc/find_target()
				var/list/possible_targets = list()

				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target

				if(possible_targets.len > 0)
					target = pick(possible_targets)

				if(target && target.current)
					explanation_text = "Assassinate [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target

		capture
			var/datum/mind/target
			var/separation_time = 0
			var/almost_complete = 0

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				explanation_text = "Capture [target.current.real_name], the [target.assigned_role]."

			check_completion()
				if(target && target.current)
					if(target.current.stat == 2)
						if(vsc.RPREV_REQUIRE_HEADS_ALIVE) return 0
					else
						if(!target.current.handcuffed)
							return 0
				else if(vsc.RPREV_REQUIRE_HEADS_ALIVE) return 0
				return 1

			proc/find_target_by_role(var/role)
				for(var/datum/mind/possible_target in ticker.minds)
					if((possible_target != owner) && istype(possible_target.current, /mob/living/carbon/human) && (possible_target.assigned_role == role))
						target = possible_target
						break

				if(target && target.current)
					explanation_text = "Capture [target.current.real_name], the [target.assigned_role]."
				else
					explanation_text = "Free Objective"

				return target


		hijack
			explanation_text = "Hijack the emergency shuttle by escaping alone."

			check_completion()
				if(main_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat == 2)
					return 0
				var/turf/location = get_turf(owner.current.loc)

				for(var/datum/shuttle/s in shuttles)
					if(location in locate(s.centcom))
						for(var/mob/living/player in locate(s.centcom))
							if (player.mind && (player.mind != owner))
								if (player.stat != 2) //they're not dead
									return 0
						return 1

				return 0
			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 65
					if(2)
						return 65
					if(3)
						return 50
					if(4)
						return 35

		escape
			explanation_text = "Escape on the shuttle alive, without being arrested"

			check_completion()
				if(main_shuttle.location<2)
					return 0

				if(!owner.current || owner.current.stat ==2)
					return 0

				var/turf/location = get_turf(owner.current.loc)
				if(!location)
					return 0

				if(owner.current:handcuffed)
					return 0


				for(var/datum/shuttle/s in shuttles)
					if(location in locate(s.centcom))
						return 1

				return 0
			get_points()
				return INFINITY

		survive
			explanation_text = "Stay alive until the end"

			check_completion()
				if(!owner.current || owner.current.stat == 2)
					return 0

				return 1
			get_points()
				return INFINITY


		steal
			var/obj/item/steal_target

			check_completion()
				if(steal_target)
					if(owner.current.check_contents_for(steal_target))
						return 1
					else
						return 0


		steal/captainslaser
			steal_target = /obj/item/weapon/gun/energy/laser_gun/captain
			explanation_text = "Steal the captain's antique laser gun"
			weight = 20

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 60
					if(1)
						return 50
					if(2)
						return 40
					if(3)
						return 30
					if(4)
						return INFINITY

		steal/plasmatank
			steal_target = /obj/item/weapon/tank/plasma
			explanation_text = "Steal a small plasma tank"
			weight = 20

			get_points(var/job)
				if(job == "Scientist")
					return INFINITY
				switch(IsResearcher(job))
					if(0)
						return 40
					if(1)
						return 25
					if(2)
						return INFINITY
		/*Removing this as an objective.  Not necessary to have two theft objectives in the same room.
		steal/captainssuit
			steal_target = /obj/item/clothing/under/rank/captain
			explanation_text = "Steal a captain's rank jumpsuit"
			weight = 50

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY
		*/

		steal/handtele
			steal_target = /obj/item/weapon/hand_tele
			explanation_text = "Steal a hand teleporter"
			weight = 20

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY

		steal/RCD
			steal_target = /obj/item/weapon/rcd
			explanation_text = "Steal a rapid construction device"
			weight = 20

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY

		/*steal/burger add this back in after humanburgers can be made again
			steal_target = /obj/item/weapon/reagent_containers/food/snacks/humanburger
			explanation_text = "Steal a burger made out of human organs, this will be presented as proof of NanoTrasen's chronic lack of standards."
			weight = 60

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY*/


		/*Needs some work before it can be put in the game to differentiate ship implanters from syndicate implanters.
		steal/implanter
			steal_target = /obj/item/weapon/implanter
			explanation_text = "Steal an implanter"
			weight = 50

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY
		*/
		steal/cyborg
			steal_target = /obj/item/robot_parts/robot_suit
			explanation_text = "Steal a completed cyborg shell (no brain)"
			weight = 30

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY

			check_completion()
				if(steal_target)
					for(var/obj/item/robot_parts/robot_suit/objective in owner.current.get_contents())
						if(istype(objective,/obj/item/robot_parts/robot_suit) && objective.check_completion())
							return 1
					return 0
		steal/AI
			steal_target = /obj/machinery/aiconstruct
			explanation_text = "Steal a finished AI Construct (with brain)"
			weight = 50

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY

			check_completion()
				if(steal_target)
					for(var/datum/shuttle/s in shuttles)
						for(var/obj/machinery/aiconstruct/objective in locate(s.centcom))
							if (objective.buildstate == 6)
								return 1
					return 0

		steal/drugs
			steal_target = /datum/reagent/space_drugs
			explanation_text = "Steal some space drugs"
			weight = 40

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY

			check_completion()
				if(steal_target)
					if(owner.current.check_contents_for_reagent(steal_target))
						return 1
					else
						return 0


		steal/pacid
			steal_target = /datum/reagent/pacid
			explanation_text = "Steal some polytrinic acid"
			weight = 40

			get_points(var/job)
				switch(GetRank(job))
					if(0)
						return 75
					if(1)
						return 60
					if(2)
						return 50
					if(3)
						return 30
					if(4)
						return INFINITY

			check_completion()
				if(steal_target)
					if(owner.current.check_contents_for_reagent(steal_target))
						return 1
					else
						return 0

/*

		stealreagent
			var/datum/reagent/steal_reagent
			var/target_name
			var/reagent_name
			proc/find_target()
				var/list/items = list("Sulphuric acid", "Polytrinic acid", "Space Lube", "Unstable mutagen",\
				 "Leporazine", "Cryptobiolin", "Lexorin ",\
				  "kelotane", "Dexalin", "Tricordrazine")
				target_name = pick(items)
				switch(target_name)
					if("Sulphuric acid")
						steal_reagent = /datum/reagent/acid
					if("Polytrinic acid")
						steal_reagent = /datum/reagent/pacid
					if("Space Lube")
						steal_reagent = /datum/reagent/lube
					if("Unstable mutagen")
						steal_reagent = /datum/reagent/mutagen
					if("Leporazine")
						steal_reagent = /datum/reagent/leporazine
					if("Cryptobiolin")
						steal_reagent =/datum/reagent/cryptobiolin
					if("Lexorin")
						steal_reagent = /datum/reagent/lexorin
					if("kelotane")
						steal_reagent = /datum/reagent/kelotane
					if("Dexalin")
						steal_reagent = /datum/reagent/dexalin
					if("Tricordrazine")
						steal_reagent = /datum/reagent/tricordrazine


				explanation_text = "Steal a container filled with [target_name]."

				return steal_reagent

			check_completion()
				if(steal_reagent)
					if(owner.current.check_contents_for_reagent(steal_reagent))
						return 1
					else
						return 0
		*/
		nuclear
			explanation_text = "Destroy the station with a nuclear device."