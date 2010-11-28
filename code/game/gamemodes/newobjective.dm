/proc/GetObjectives(var/job,var/datum/mind/traitor)
	var/list/datum/objective/objectives = list()
	for(var/o in typesof(/datum/objective))
		if(o != /datum/objective/assassinate)
			objectives += new o(null,job)

	objectives += GenerateAssassinate(job,traitor)
	return objectives

/proc/GenerateAssassinate(var/job,var/datum/mind/traitor)
	var/list/datum/objective/assassinate/missions = list()

	for(var/datum/mind/target in ticker.minds)
		if((target != traitor) && istype(target.current, /mob/living/carbon/human))
			if(target && target.current)
				missions +=	new /datum/objective/assassinate(null,job,target)
	return missions



/proc/SelectObjectives(var/job,var/datum/mind/traitor)
	var/list/datum/objective/chosenobjectives = list()
	var/list/datum/objective/objectives = GetObjectives(job,traitor)
	var/points
	while(length(objectives) > 0)
		var/datum/objective/objective = pick(objectives)
		if(objective.points < (100 - points))
			chosenobjectives += objective
			points += objective.points

		objectives -= objective
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


		assassinate
			var/datum/mind/target

			New(var/text,var/joba,var/datum/mind/targeta)
				target = targeta
				job = joba
				points = get_points(job)
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

		steal/captainslaser
			steal_target = "/obj/item/weapon/gun/energy/laser_gun/captain"
			explanation_text = "Steal the captain's antique laser gun"

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
			steal_target = "/obj/item/weapon/tank/plasma"
			explanation_text = "Steal a small plasma tank"

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

		steal/captainssuit
			steal_target = "/obj/item/clothing/under/rank/captain"
			explanation_text = "Steal a captain's rank jumpsuit"
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

		steal/handtele
			steal_target = "/obj/item/weapon/hand_tele"
			explanation_text = "steal a hand teleporter"
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

