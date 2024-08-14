/*	Note from Carnie:
		The way datum/mind stuff works has been changed a lot.
		Minds now represent IC characters rather than following a client around constantly.

	Guidelines for using minds properly:

	-	Never mind.transfer_to(ghost). The var/current and var/original of a mind must always be of type mob/living!
		ghost.mind is however used as a reference to the ghost's corpse

	-	When creating a new mob for an existing IC character (e.g. cloning a dead guy or borging a brain of a human)
		the existing mind of the old mob should be transfered to the new mob like so:

			mind.transfer_to(new_mob)

	-	You must not assign key= or ckey= after transfer_to() since the transfer_to transfers the client for you.
		By setting key or ckey explicitly after transfering the mind with transfer_to you will cause bugs like DCing
		the player.

	-	IMPORTANT NOTE 2, if you want a player to become a ghost, use mob.ghostize() It does all the hard work for you.

	-	When creating a new mob which will be a new IC character (e.g. putting a shade in a construct or randomly selecting
		a ghost to become a xeno during an event). Simply assign the key or ckey like you've always done.

			new_mob.key = key

		The Login proc will handle making a new mob for that mobtype (including setting up stuff like mind.name). Simple!
		However if you want that mind to have any special properties like being a traitor etc you will have to do that
		yourself.

*/

/datum/mind
	var/key
	var/name				//replaces mob/var/original_name
	var/mob/living/current
	var/weakref/original_mob = null // must contain /mob/living
	var/active = 0

	var/memory
	var/list/known_connections //list of known (RNG) relations between people
	var/gen_relations_info

	var/assigned_role
	var/special_role

	var/role_alt_title

	var/datum/job/assigned_job

	var/completed_contracts = 0
	var/list/datum/objective/objectives = list()
	var/list/datum/objective/special_verbs = list()
	var/syndicate_awareness = SYNDICATE_UNAWARE

	var/has_been_rev = 0//Tracks if this mind has been a rev or not

	var/datum/faction/faction 			// Associated faction
	var/datum/changeling/changeling		// Changeling holder
	var/datum/vampire/vampire 			// Vampire holder
	var/datum/wizard/wizard				// Wizard holder
	var/weakref/enslaved_to
	var/rev_cooldown = 0

	// the world.time since the mob has been brigged, or -1 if not at all
	var/brigged_since = -1

	//put this here for easier tracking ingame
	var/datum/money_account/initial_account

	//used for optional self-objectives that antagonists can give themselves, which are displayed at the end of the round.
	var/ambitions
	var/was_antag_given_by_storyteller = FALSE
	var/antag_was_given_at = ""

	//used to store what traits the player had picked out in their preferences before joining, in text form.
	var/list/traits = list()

	/// Overrides may have relations. That's it.
	var/may_have_relations = TRUE

/datum/mind/New(key)
	src.key = key
	..()

/datum/mind/Destroy()
	SSticker.minds -= src
	set_current(null)
	original_mob = null
	. = ..()

/datum/mind/proc/set_current(mob/new_current)
	if(new_current && QDELETED(new_current))
		util_crash_with("Tried to set a mind's current var to a qdeleted mob, what the fuck")
	if(current)
		unregister_signal(src, SIGNAL_QDELETING)
	current = new_current
	if(current)
		register_signal(src, SIGNAL_QDELETING, nameof(.proc/clear_current))

/datum/mind/proc/clear_current(datum/source)
	set_current(null)

/datum/mind/proc/transfer_to(mob/living/new_character)
	if(!istype(new_character))
		to_world_log("## DEBUG: transfer_to(): Some idiot has tried to transfer_to() a non mob/living mob. Please inform developers.")
		return FALSE

	if(current)					//remove ourself from our old body's mind variable
		current.mind = null
		SSnano.user_transferred(current, new_character) // transfer active NanoUI instances to new user

	if(new_character.mind)		//remove any mind currently in our new body's mind variable
		new_character.mind.set_current(null)

	set_current(new_character) //link ourself to our new body
	new_character.mind = src   //and link our new body to ourself

	if(learned_spells && learned_spells.len)
		restore_spells(new_character)

	if(changeling)
		changeling.transfer_to(new_character)

	if(vampire)
		vampire.transfer_to(new_character)

	if(active)
		new_character.key = key		//now transfer the key to link the client to our new body

	new_character.client?.init_verbs()

	return TRUE

/datum/mind/proc/store_memory(new_text)
	memory += "[new_text]<BR>"

/datum/mind/proc/show_memory(mob/recipient)
	var/output = "<meta charset=\"utf-8\"><B>[current.real_name]'s Memory</B><HR>"
	output += memory

	if(objectives.len>0)
		output += "<HR><B>Objectives:</B>"

		var/obj_count = 1
		for(var/datum/objective/objective in objectives)
			output += "<B>Objective #[obj_count]</B>: [objective.explanation_text]"
			obj_count++
	if(ambitions)
		output += "<HR><B>Ambitions:</B> [ambitions]<br>"
	show_browser(recipient, output,"window=memory")

/datum/mind/proc/edit_memory()
	if(GAME_STATE <= RUNLEVEL_SETUP)
		alert("Not before round-start!", "Alert")
		return

	var/out = "<meta charset=\"utf-8\"><B>[name]</B>[(current&&(current.real_name!=name))?" (as [current.real_name])":""]<br>"
	out += "Mind currently owned by key: [key] [active?"(synced)":"(not synced)"]<br>"
	out += "Assigned role: [assigned_role]. <a href='?src=\ref[src];role_edit=1'>Edit</a><br>"
	out += "<hr>"
	out += "Factions and special roles:<br><table>"
	var/list/all_antag_types = GLOB.all_antag_types_
	for(var/antag_type in all_antag_types)
		var/datum/antagonist/antag = all_antag_types[antag_type]
		out += "[antag.get_panel_entry(src)]"
	out += "</table><hr>"
	out += "<b>Objectives</b></br>"

	if(objectives && objectives.len)
		var/num = 1
		for(var/datum/objective/O in objectives)
			out += "<b>Objective #[num]:</b> [O.explanation_text] "
			if(O.completed)
				out += "(<font color='green'>complete</font>)"
			else
				out += "(<font color='red'>incomplete</font>)"
			out += " <a href='?src=\ref[src];obj_completed=\ref[O]'>\[toggle\]</a>"
			out += " <a href='?src=\ref[src];obj_delete=\ref[O]'>\[remove\]</a><br>"
			num++
		out += "<br><a href='?src=\ref[src];obj_announce=1'>\[announce objectives\]</a>"

	else
		out += "None."
	out += "<br><a href='?src=\ref[src];obj_add=1'>\[add\]</a><br><br>"
	out += "<b>Ambitions:</b> [ambitions ? ambitions : "None"] <a href='?src=\ref[src];amb_edit=\ref[src]'>\[edit\]</a></br>"
	show_browser(usr, out, "window=edit_memory[src]")

/datum/mind/Topic(href, href_list)
	if(!check_rights(R_ADMIN))	return

	if(href_list["add_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types_[href_list["add_antagonist"]]
		if(antag)
			if(antag.add_antagonist(src, 1, 1, 0, 1, 1)) // Ignore equipment and role type for this.
				log_admin("[key_name_admin(usr)] made [key_name(src)] into a [antag.role_text].")
			else
				to_chat(usr, "<span class='warning'>[src] could not be made into a [antag.role_text]!</span>")

	else if(href_list["remove_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types_[href_list["remove_antagonist"]]
		if(antag) antag.remove_antagonist(src)

	else if(href_list["equip_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types_[href_list["equip_antagonist"]]
		if(antag) antag.equip(src.current)

	else if(href_list["unequip_antagonist"])
		var/datum/antagonist/antag = GLOB.all_antag_types_[href_list["unequip_antagonist"]]
		if(antag) antag.unequip(src.current)

	else if(href_list["move_antag_to_spawn"])
		var/datum/antagonist/antag = GLOB.all_antag_types_[href_list["move_antag_to_spawn"]]
		if(antag) antag.place_mob(src.current)

	else if (href_list["role_edit"])
		var/new_role = input("Select new role", "Assigned role", assigned_role) as null|anything in joblist
		if (!new_role) return
		assigned_role = new_role

	else if (href_list["memory_edit"])
		var/new_memo = sanitize(input("Write new memory", "Memory", memory) as null|message)
		if (isnull(new_memo)) return
		memory = new_memo

	else if (href_list["amb_edit"])
		var/datum/mind/mind = locate(href_list["amb_edit"])
		if(!mind)
			return
		var/new_ambition = input("Enter a new ambition", "Memory", mind.ambitions) as null|message
		if(isnull(new_ambition))
			return
		new_ambition = sanitize(new_ambition)
		if(mind)
			mind.ambitions = new_ambition
			if(new_ambition)
				to_chat(mind.current, "<span class='warning'>Your ambitions have been changed by higher powers, they are now: [mind.ambitions]</span>")
				log_and_message_admins("made [key_name(mind.current)]'s ambitions be '[mind.ambitions]'.")
			else
				to_chat(mind.current, "<span class='warning'>Your ambitions have been unmade by higher powers.</span>")
				log_and_message_admins("has cleared [key_name(mind.current)]'s ambitions.")
		else
			to_chat(usr, "<span class='warning'>The mind has ceased to be.</span>")

	else if (href_list["obj_edit"] || href_list["obj_add"])
		var/datum/objective/objective
		var/objective_pos
		var/def_value

		if (href_list["obj_edit"])
			objective = locate(href_list["obj_edit"])
			if (!objective) return
			objective_pos = objectives.Find(objective)

			//Text strings are easy to manipulate. Revised for simplicity.
			var/temp_obj_type = "[objective.type]"//Convert path into a text string.
			def_value = copytext(temp_obj_type, 19)//Convert last part of path into an objective keyword.
			if(!def_value)//If it's a custom objective, it will be an empty string.
				def_value = "custom"

		var/new_obj_type = input("Select objective type:", "Objective type", def_value) as null|anything in list("assassinate", "debrain", "protect", "prevent", "harm", "brig", "hijack", "escape", "survive", "steal", "download", "nuke", "capture", "absorb", "custom")
		if (!new_obj_type) return

		var/datum/objective/new_objective = null

		switch (new_obj_type)
			if ("assassinate","protect","debrain", "harm", "brig")
				//To determine what to name the objective in explanation text.
				var/objective_type_capital = uppertext(copytext(new_obj_type, 1,2))//Capitalize first letter.
				var/objective_type_text = copytext(new_obj_type, 2)//Leave the rest of the text.
				var/objective_type = "[objective_type_capital][objective_type_text]"//Add them together into a text string.

				var/list/possible_targets = list("Free objective")
				for(var/datum/mind/possible_target in SSticker.minds)
					if ((possible_target != src) && istype(possible_target.current, /mob/living/carbon/human))
						possible_targets += possible_target.current

				var/mob/def_target = null
				var/objective_list[] = list(/datum/objective/assassinate, /datum/objective/protect, /datum/objective/debrain)
				if (objective&&(objective.type in objective_list) && objective:target)
					def_target = objective:target.current

				var/new_target = input("Select target:", "Objective target", def_target) as null|anything in possible_targets
				if (!new_target) return

				var/objective_path = text2path("/datum/objective/[new_obj_type]")
				var/mob/living/M = new_target
				if (!istype(M) || !M.mind || new_target == "Free objective")
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = null
					new_objective.explanation_text = "Free objective"
				else
					new_objective = new objective_path
					new_objective.owner = src
					new_objective:target = M.mind
					new_objective.explanation_text = "[objective_type] [M.real_name], the [M.mind.special_role ? M.mind:special_role : M.mind:assigned_role]."

			if ("prevent")
				new_objective = new /datum/objective/block
				new_objective.owner = src

			if ("hijack")
				new_objective = new /datum/objective/hijack
				new_objective.owner = src

			if ("escape")
				new_objective = new /datum/objective/escape
				new_objective.owner = src

			if ("survive")
				new_objective = new /datum/objective/survive
				new_objective.owner = src

			if ("nuke")
				new_objective = new /datum/objective/nuclear
				new_objective.owner = src

			if ("steal")
				if (!istype(objective, /datum/objective/steal))
					new_objective = new /datum/objective/steal
					new_objective.owner = src
				else
					new_objective = objective
				var/datum/objective/steal/steal = new_objective
				if (!steal.select_target())
					return

			if("download","capture","absorb")
				var/def_num
				if(objective&&objective.type==text2path("/datum/objective/[new_obj_type]"))
					def_num = objective.target_amount

				var/target_number = input("Input target number:", "Objective", def_num) as num|null
				if (isnull(target_number))//Ordinarily, you wouldn't need isnull. In this case, the value may already exist.
					return

				switch(new_obj_type)
					if("download")
						new_objective = new /datum/objective/download
						new_objective.explanation_text = "Download [target_number] research levels."
					if("capture")
						new_objective = new /datum/objective/capture
						new_objective.explanation_text = "Accumulate [target_number] capture points."
					if("absorb")
						new_objective = new /datum/objective/absorb
						new_objective.explanation_text = "Absorb [target_number] compatible genomes."
				new_objective.owner = src
				new_objective.target_amount = target_number

			if ("custom")
				var/expl = sanitize(input("Custom objective:", "Objective", objective ? objective.explanation_text : "") as text|null)
				if (!expl) return
				new_objective = new /datum/objective
				new_objective.owner = src
				new_objective.explanation_text = expl

		if (!new_objective) return

		if (objective)
			objectives -= objective
			objectives.Insert(objective_pos, new_objective)
		else
			objectives += new_objective

	else if (href_list["obj_delete"])
		var/datum/objective/objective = locate(href_list["obj_delete"])
		if(!istype(objective))	return
		objectives -= objective

	else if(href_list["obj_completed"])
		var/datum/objective/objective = locate(href_list["obj_completed"])
		if(!istype(objective))	return
		objective.completed = !objective.completed

	else if(href_list["implant"])
		var/mob/living/carbon/human/H = current

		BITSET(H.hud_updateflag, IMPLOYAL_HUD)   // updates that players HUD images so secHUD's pick up they are implanted or not.

		switch(href_list["implant"])
			if("remove")
				for(var/obj/item/implant/loyalty/I in H.contents)
					for(var/obj/item/organ/external/organs in H.organs)
						if(I in organs.implants)
							qdel(I)
							break
				to_chat(H, "<span class='notice'><font size =3><B>Your loyalty implant has been deactivated.</B></font></span>")
				log_admin("[key_name_admin(usr)] has de-loyalty implanted [current].")
			if("add")
				to_chat(H, "<span class='danger'><font size =3>You somehow have become the recepient of a loyalty transplant, and it just activated!</font></span>")
				H.implant_loyalty(H, override = TRUE)
				log_admin("[key_name_admin(usr)] has loyalty implanted [current].")
	else if (href_list["silicon"])
		BITSET(current.hud_updateflag, SPECIALROLE_HUD)
		switch(href_list["silicon"])

			if("unemag")
				var/mob/living/silicon/robot/R = current
				if (istype(R))
					R.emagged = 0
					if (R.activated(R.module.emag))
						R.module_active = null
					if(R.module_state_1 == R.module.emag)
						R.module_state_1 = null
						R.contents -= R.module.emag
					else if(R.module_state_2 == R.module.emag)
						R.module_state_2 = null
						R.contents -= R.module.emag
					else if(R.module_state_3 == R.module.emag)
						R.module_state_3 = null
						R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [R].")

			if("unemagcyborgs")
				if (istype(current, /mob/living/silicon/ai))
					var/mob/living/silicon/ai/ai = current
					for (var/mob/living/silicon/robot/R in ai.connected_robots)
						R.emagged = 0
						if (R.module)
							if (R.activated(R.module.emag))
								R.module_active = null
							if(R.module_state_1 == R.module.emag)
								R.module_state_1 = null
								R.contents -= R.module.emag
							else if(R.module_state_2 == R.module.emag)
								R.module_state_2 = null
								R.contents -= R.module.emag
							else if(R.module_state_3 == R.module.emag)
								R.module_state_3 = null
								R.contents -= R.module.emag
					log_admin("[key_name_admin(usr)] has unemag'ed [ai]'s Cyborgs.")

	else if (href_list["common"])
		switch(href_list["common"])
			if("undress")
				for(var/obj/item/I in current)
					current.drop(I)
			if("takeuplink")
				take_uplink()
				memory = null//Remove any memory they may have had.
			if("crystals")
				if (usr.client.holder.rights & R_FUN)
					var/datum/component/uplink/suplink = find_syndicate_uplink()
					if(!suplink)
						to_chat(usr, SPAN_WARNING("Failed to find an uplink."))
						return

					var/crystals = suplink.telecrystals
					crystals = tgui_input_number(usr, "Amount of telecrystals for [key]", "Operative uplink", crystals, min_value = 0)
					if(!isnull(crystals) && !QDELETED(suplink))
						suplink.telecrystals = crystals
						log_and_message_admins("set the telecrystals for [key] to [crystals]")

	else if (href_list["obj_announce"])
		var/obj_count = 1
		to_chat(current, "<span class='notice'>Your current objectives:</span>")
		for(var/datum/objective/objective in objectives)
			to_chat(current, "<B>Objective #[obj_count]</B>: [objective.explanation_text]")
			obj_count++
	edit_memory()

/datum/mind/proc/find_syndicate_uplink()
	var/datum/component/uplink/uplink
	var/list/L = current.get_contents()
	for(var/atom/movable/I in L)
		uplink = I.get_component(/datum/component/uplink)
		if(istype(uplink))
			return uplink

/datum/mind/proc/take_uplink()
	qdel(find_syndicate_uplink())

// check whether this mind's mob has been brigged for the given duration
// have to call this periodically for the duration to work properly
/datum/mind/proc/is_brigged(duration)
	var/turf/T = current.loc
	if(!istype(T))
		brigged_since = -1
		return FALSE

	var/is_currently_brigged = FALSE
	if(istype(T.loc, /area/security/brig) || istype(T.loc, /area/security/prison))
		is_currently_brigged = TRUE
		for(var/obj/item/card/id/card in current)
			is_currently_brigged = FALSE
			break
		for(var/obj/item/device/pda/P in current)
			if(P.id)
				is_currently_brigged = FALSE
				break
		if (player_is_antag(src) && find_syndicate_uplink())
			is_currently_brigged = FALSE

	if (!is_currently_brigged)
		brigged_since = -1
		return FALSE

	if (is_currently_brigged && brigged_since == -1)
		brigged_since = world.time

	if (!duration)
		return TRUE
	else
		return duration <= world.time - brigged_since

/datum/mind/proc/reset()
	assigned_role =   null
	special_role =    null
	role_alt_title =  null
	assigned_job =    null
	//faction =       null //Uncommenting this causes a compile error due to 'undefined type', fucked if I know.
	changeling =      null
	initial_account = null
	vampire =         null
	objectives =      list()
	special_verbs =   list()
	has_been_rev =    0
	rev_cooldown =    0
	brigged_since =   -1

//Antagonist role check
/mob/living/proc/check_special_role(role)
	if(mind)
		if(!role)
			return mind.special_role
		else
			return (mind.special_role == role) ? 1 : 0
	else
		return 0

//Initialisation procs
/mob/living/proc/mind_initialize()
	if(mind)
		mind.key = key
	else
		mind = new /datum/mind(key)
		mind.original_mob = weakref(src)
		SSticker.minds += mind
	if(!mind.name)	mind.name = real_name
	mind.set_current(src)
	if(player_is_antag(mind))
		src.client.verbs += /client/proc/aooc

//HUMAN
/mob/living/carbon/human/mind_initialize()
	..()
	if(!mind.assigned_role)	mind.assigned_role = "Assistant"	//defualt

//metroid
/mob/living/carbon/metroid/mind_initialize()
	..()
	mind.assigned_role = "metroid"

/mob/living/carbon/alien/larva/mind_initialize()
	..()
	mind.special_role = "Xenomorph"

//AI
/mob/living/silicon/ai/mind_initialize()
	..()
	mind.assigned_role = "AI"

//BORG
/mob/living/silicon/robot/mind_initialize()
	..()
	mind.assigned_role = "Cyborg"

//PAI
/mob/living/silicon/pai/mind_initialize()
	..()
	mind.assigned_role = "pAI"
	mind.special_role = ""

//Animals
/mob/living/simple_animal/mind_initialize()
	..()
	mind.assigned_role = "Animal"

/mob/living/simple_animal/corgi/mind_initialize()
	..()
	mind.assigned_role = "Corgi"

/mob/living/simple_animal/shade/mind_initialize()
	..()
	mind.assigned_role = "Shade"

/mob/living/simple_animal/construct/builder/mind_initialize()
	..()
	mind.assigned_role = "Artificer"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/wraith/mind_initialize()
	..()
	mind.assigned_role = "Wraith"
	mind.special_role = "Cultist"

/mob/living/simple_animal/construct/armoured/mind_initialize()
	..()
	mind.assigned_role = "Juggernaut"
	mind.special_role = "Cultist"
