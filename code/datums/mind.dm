datum/mind
	var/key
	var/mob/current

	var/memory

	var/assigned_role
	var/special_role


	var/datum/logging/log

	var/list/datum/objective/objectives = list()

	proc/transfer_to(mob/new_character)
		if(current)
			current.mind = null

		new_character.mind = src
		current = new_character

		new_character.key = key

	proc/store_memory(new_text)
		memory += "[new_text]<BR>"

	proc/show_memory(mob/recipient)
		var/output = "<B>[current.real_name]'s Memory</B><HR>"
		output += memory

		if(objectives.len>0)
			output += "<HR><B>Objectives:</B>"

			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		recipient << browse(output,"window=memory")
	New()
		log = new /datum/logging


datum/logging

	var/writes = 0

	var/list/logs = list()
	var/area/loc = null

	proc/log_m(var/logtext,var/mob/mob)
		logs += text("[logtext] - [mob.name]([mob.real_name])([mob.key]) - [world.timeofday]")
		writes += 1
		if(writes > 100)
			return // Write contents to file here
	proc/updateloc(var/area/area,var/mob/mob)
		if(loc != area.master)
			loc = area.master
			log_m("Moved to [loc.name]",mob)