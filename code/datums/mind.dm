datum/mind
	var/key
	var/mob/current

	var/memory

	var/assigned_role
	var/special_role

	var/title
	var/datum/logging/log

	var/list/datum/objective/objectives = list()

	var/rev_cooldown = 0

	proc/transfer_to(mob/new_character)
		if(current)
			current.mind = null

		new_character.mind = src
		current = new_character

		if(ticker.mode.name == "rp-revolution" && (src in ticker.mode:head_revolutionaries | ticker.mode:revolutionaries))
			current.verbs += /mob/living/carbon/human/proc/RevConvert

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
				output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]<br>"
				obj_count++

		recipient << browse(output,"window=memory")
	New()
		log = new /datum/logging


	proc/edit_memory()		//This is called by admin panels to edit traitor objectives.
		var/dat = "<B>[current.real_name]</B><br>"
		var/cantoggle = 1
		var/datum/game_mode/current_mode = ticker.mode
		switch (current_mode.config_tag)
			if ("revolution")
				if (src in current_mode:head_revolutionaries)
					dat += "<font color=red>Head Revolutionary</font> "
					cantoggle = 0
				else if(src in current_mode:revolutionaries)
					dat += "<a href='?src=\ref[src];traitorize=headrev'>Head Revolutionary</a> <font color=red>Revolutionary</font> "
				else
					dat += "<a href='?src=\ref[src];traitorize=headrev'>Head Revolutionary</a> <a href='?src=\ref[src];traitorize=rev'>Revolutionary</a> "
			if ("rp-revolution")
				if (src in current_mode:head_revolutionaries)
					dat += "<font color=red>Head Revolutionary</font> "
					cantoggle = 0
				else if(src in current_mode:revolutionaries)
					dat += "<a href='?src=\ref[src];traitorize=headrev'>Head Revolutionary</a> <font color=red>Revolutionary</font> "
				else
					dat += "<a href='?src=\ref[src];traitorize=headrev'>Head Revolutionary</a> <a href='?src=\ref[src];traitorize=rev'>Revolutionary</a> "

			if ("malfunction")
				if (src in current_mode:malf_ai)
					dat += "<font color=red>Malfunction</font>"
					cantoggle = 0

			if ("nuclear")
				if(src in current_mode:syndicates)
					dat = "<B>Syndicate</B>"
					cantoggle = current_mode:syndicates.len > 1
				else
					dat += "<a href='?src=\ref[src];traitorize=syndicate'>Syndicate</a> "

		if (cantoggle)
			if(src in current_mode.traitors)
				dat += "<b>Traitor</b> | "
				dat += "<a href='?src=\ref[src];traitorize=civilian'>Not Traitor</a> "
			else
				dat += "<a href='?src=\ref[src];traitorize=traitor'>Traitor</a> | "
				dat += "<B>Not Traitor</B> "

		dat += "<br>"
		dat += "Memory:<hr>"
		dat += memory
		dat += "<hr><a href='?src=\ref[src];memory_edit=1'>Edit memory</a><br>"
		dat += "Objectives:<br>"
		if (objectives.len == 0)
			dat += "EMPTY<br>"
		else
			var/obj_count = 1
			for(var/datum/objective/objective in objectives)
				dat += "<B>#[obj_count]</B>: [objective.explanation_text] <a href='?src=\ref[src];obj_edit=\ref[objective]'>Edit</a> <a href='?src=\ref[src];obj_delete=\ref[objective]'>Delete</a><br>"
				obj_count++
		dat += "<br><a href='?src=\ref[src];obj_add=1'>Add objective</a><br>"
		dat += "<a href='?src=\ref[src];obj_random=1'>Randomize objectives</a><br>"
		dat += "<a href='?src=\ref[src];obj_announce=1'>Announce objectives</a><br><br>"
		dat += "Admin Note: Add objectives first, before you make them traitor."

		usr << browse(dat, "window=edit_memory[src]")


	Topic(href, href_list)
		if (href_list["role_edit"])
			var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in get_all_jobs()
			if (!new_role) return
			assigned_role = new_role

		else if (href_list["memory_edit"])
			var/new_memo = input("Write new memory", "Memory", memory) as message
			if (!new_memo) return
			memory = new_memo

		else if (href_list["obj_edit"] || href_list["obj_add"])
			var/datum/objective/objective = null
			var/objective_pos = null
			var/def_value = null

			if (href_list["obj_edit"])
				objective = locate(href_list["obj_edit"])
				if (!objective) return
				objective_pos = objectives.Find(objective)

				if (istype(objective, /datum/objective/assassinate))
					def_value = "assassinate"
				else if (istype(objective, /datum/objective/protection))
					def_value = "protection"
				else if (istype(objective, /datum/objective/steal))
					def_value = "steal"
				else if (istype(objective, /datum/objective/escape))
					def_value = "escape"
				else if (istype(objective, /datum/objective/hijack))
					def_value = "hijack"
				else if (istype(objective, /datum/objective/survive))
					def_value = "survive"
				else if (istype(objective, /datum/objective/nuclear))
					def_value = "nuclear"
				else if (istype(objective, /datum/objective))
					def_value = "custom"

			var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "protection", "steal", "escape", "hijack", "survive", "nuclear", "custom")
			if (!new_obj_type) return

			var/datum/objective/new_objective = null

			switch (new_obj_type)
				if ("assassinate")
					var/list/possible_targets = list("Free objective")
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					if (istype(objective, /datum/objective/assassinate) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return

					if (new_target == "Free objective")
						new_objective = new /datum/objective/assassinate(null,null,null)
						new_objective.owner = src
						new_objective:target = null
						new_objective.explanation_text = "Free objective"
					else
						new_objective = new /datum/objective/assassinate(null,new_target:mind:assigned_role,new_target:mind)
						new_objective.owner = src
						new_objective:target = new_target:mind
						new_objective.explanation_text = "Assassinate [new_target:real_name], the [new_target:mind:assigned_role]."
				if ("protection")
					var/list/possible_targets = list()
					for(var/datum/mind/possible_target in ticker.minds)
						if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
							possible_targets += possible_target.current

					var/mob/def_target = null
					if (istype(objective, /datum/objective/protection) && objective:target)
						def_target = objective:target.current

					var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
					if (!new_target) return
					new_objective = new /datum/objective/protection(null,new_target:mind:assigned_role,new_target:mind)
					new_objective.owner = src
					new_objective:target = new_target:mind
					new_objective.explanation_text = "[new_target:real_name], the [new_target:mind:assigned_role] is a relative of a high ranking Syndicate Leader.  Make sure they get off the ship safely."

				if ("hijack")
					new_objective = new /datum/objective/hijack
					new_objective.owner = src

				if ("escape")
					new_objective = new /datum/objective/escape
					new_objective.owner = src

				if ("survive")
					new_objective = new /datum/objective/survive
					new_objective.owner = src

				if ("steal")
					var/list/possible_items = list(
						"the captain's antique laser gun" = new /datum/objective/steal/captainslaser,
						"a small plasma tank" = new /datum/objective/steal/plasmatank,
						"a hand teleporter" = new /datum/objective/steal/handtele,
						"a rapid construction device" = new /datum/objective/steal/RCD,
					//	"a burger made of human organs" = new /datum/objective/steal/burger,
						"a cyborg shell" = new /datum/objective/steal/cyborg,
						"a finished AI Construct" = new /datum/objective/steal/AI,
						"some space drugs" = new /datum/objective/steal/drugs,
						"some polytrinic acid" = new /datum/objective/steal/pacid,
					)
					var/new_target = input("Select target:", "Objective target") as null|anything in possible_items
					if (!new_target) return
					new_objective = possible_items[new_target]
					new_objective.owner = src

				if ("nuclear")
					new_objective = new /datum/objective/nuclear
					new_objective.owner = src

				if ("custom")
					var/expl = input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null
					if (!expl) return
					new_objective = new /datum/objective
					new_objective.owner = src
					new_objective.explanation_text = expl
			//world << "new_objective = [new_objective]"
			if (!new_objective) return

			if (objective)
				objectives -= objective
				objectives.Insert(objective_pos, new_objective)
			else
				objectives += new_objective

		else if (href_list["obj_delete"])
			var/datum/objective/objective = locate(href_list["obj_delete"])
			if (!objective) return

			objectives -= objective

		else if (href_list["traitorize"])
			// clear old memory
			clear_memory(href_list["traitorize"] == "civilian" ? 0 : 1)

			var/datum/game_mode/current_mode = ticker.mode
			switch (href_list["traitorize"])
				if ("headrev")
					current_mode:equip_revolutionary(current)
					//find first headrev
					for(var/datum/mind/rev_mind in current_mode:head_revolutionaries)
						// copy objectives
						for (var/datum/objective/assassinate/obj in rev_mind.objectives)
							var/datum/objective/assassinate/rev_obj = new
							rev_obj = src
							rev_obj.target = obj.target
							rev_obj.explanation_text = obj.explanation_text
							objectives += rev_obj
						break
					current_mode:update_rev_icons_added(src)
					current_mode:head_revolutionaries += src

					var/obj_count = 1
					current << "\blue You are a member of the revolutionaries' leadership!"
					for(var/datum/objective/objective in objectives)
						current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
						obj_count++

				if ("rev")
					current_mode:add_revolutionary(src)

				if ("syndicate")
					var/obj/landmark/synd_spawn = locate("landmark*Syndicate-Spawn")
					current.loc = get_turf(synd_spawn)
					current_mode:equip_syndicate(current)
					current_mode:syndicates += src

				if ("traitor")
					current_mode.equip_traitor(current)
					current_mode.traitors += src
					current << "<B>You are the traitor.</B>"
					special_role = "traitor"

					var/obj_count = 1
					current << "\blue Your current objectives:"
					for(var/datum/objective/objective in objectives)
						current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
						obj_count++


		else if (href_list["obj_announce"])
			var/obj_count = 1
			current << "\blue Your current objectives:"
			for(var/datum/objective/objective in objectives)
				current << "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
				obj_count++

		else if (href_list["obj_random"])
			clear_memory()
			for(var/datum/objective/deleteobj in objectives)
				objectives -= deleteobj
			for(var/datum/objective/o in SelectObjectives(assigned_role, src))
				o.owner = src
				objectives += o

		edit_memory()


	proc/clear_memory(var/silent = 1)
		var/datum/game_mode/current_mode = ticker.mode

		// remove traitor uplinks
		var/list/L = current.get_contents()
		for (var/t in L)
			if (istype(t, /obj/item/device/pda))
				if (t:uplink) del(t:uplink)
				t:uplink = null
			else if (istype(t, /obj/item/device/radio))
				if (t:traitorradio) del(t:traitorradio)
				t:traitorradio = null
				t:traitor_frequency = 0.0

		// clear memory
		memory = ""
		special_role = null

		// remove from traitors list
		if (src in current_mode.traitors)
			current_mode.traitors -= src
			if (!silent)
				src.current << "\red <B>You are no longer a traitor!</B>"

		// clear gamemode specific values
		switch (current_mode.config_tag)
			if ("revolution")
				if (src in current_mode:head_revolutionaries)
					current_mode:head_revolutionaries -= src
					if (!silent)
						src.current << "\red <B>You are no longer a head revolutionary!</B>"
					current_mode:update_rev_icons_removed(src)

				else if(src in current_mode:revolutionaries)
					if (silent)
						current_mode:revolutionaries -= src
						current_mode:update_rev_icons_removed(src)
					else
						current_mode:remove_revolutionary(src)

			if ("rp-revolution")
				if (src in current_mode:head_revolutionaries)
					current_mode:head_revolutionaries -= src
					if (!silent)
						src.current << "\red <B>You are no longer a head revolutionary!</B>"
					current_mode:update_rev_icons_removed(src)

				else if(src in current_mode:revolutionaries)
					if (silent)
						current_mode:revolutionaries -= src
						current_mode:update_rev_icons_removed(src)
					else
						current_mode:remove_revolutionary(src)

			if ("nuclear")
				if (src in current_mode:syndicates)
					current_mode:syndicates -= src
					if (!silent)
						src.current << "\red <B>You are no longer a syndicate!</B>"








datum/logging

	var/writes = 0

	var/list/logs = list()
	var/area/loc = null

	proc/log_m(var/logtext,var/mob/mob)
		logs += "[logtext] - [mob.name]([mob.real_name])([mob.key]) - [world.timeofday]"
		writes += 1
		if(writes > 100)
			return // Write contents to file here
	proc/updateloc(var/area/area,var/mob/mob)
		if(loc != area.master)
			loc = area.master
			log_m("Moved to [loc.name]",mob)