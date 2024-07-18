/datum/preferences
	var/list/organ_data
	var/list/rlimb_data
	var/list/organ_modules
	var/current_organ = BP_CHEST

/datum/category_item/player_setup_item/augmentation
	name = "Augmentation"
	sort_order = 1

/datum/category_item/player_setup_item/augmentation/load_character(datum/pref_record_reader/R)
	pref.organ_data = R.read("organ_data")
	pref.rlimb_data = R.read("rlimb_data")
	pref.organ_modules = R.read("organ_modules")

/datum/category_item/player_setup_item/augmentation/save_character(datum/pref_record_writer/W)
	W.write("organ_data", pref.organ_data)
	W.write("rlimb_data", pref.rlimb_data)
	W.write("organ_modules", pref.organ_modules)

/datum/category_item/player_setup_item/augmentation/get_lp_cost()
	for(var/organ_tag in BP_ALL_LIMBS + BP_INTERNAL_ORGANS)
		for(var/obj/item/organ_module/mod as anything in pref.organ_modules[organ_tag])
			. += initial(mod.loadout_cost)

/datum/category_item/player_setup_item/augmentation/sanitize_character()
	LAZYINITLIST(pref.organ_data)
	LAZYINITLIST(pref.rlimb_data)
	LAZYINITLIST(pref.organ_modules)

	if(pref.organ_data[BP_CHEST] == "cyborg")
		for(var/organ in BP_INTERNAL_ORGANS)
			if(pref.organ_data[organ] != null)
				continue

			switch(organ)
				if(BP_BRAIN)
					pref.organ_data[organ] = pick("assisted", "mechanical") // Either positronic or MMI
				if(BP_JAW)
					pref.organ_data[organ] = "cyborg"
					pref.rlimb_data[organ] = pref.rlimb_data[BP_CHEST]
				else
					pref.organ_data[organ] = "mechanical" // No filthy organics in my FBP

	if(pref.organ_data[BP_BRAIN] != null && pref.organ_data[BP_CHEST] != "cyborg")
		pref.organ_data[BP_BRAIN] = null

	for(var/organ in pref.organ_data)
		var/datum/robolimb/R = GLOB.all_robolimbs[pref.rlimb_data[organ]]
		if(isnull(R))
			continue

		for(var/path in R.default_modules)
			LAZYDISTINCTADD(pref.organ_modules[organ], path)

/datum/category_item/player_setup_item/augmentation/content(mob/user)
	. = list()

	. += "<style>div.block{margin: 3px 0px;padding: 4px 0px;}"
	. += "span.color_holder_box{display: inline-block; width: 20px; height: 8px; border:1px solid #000; padding: 0px;}<"
	. += "a.Organs_active {background: #cc5555;}</style>"

	. +=  "<script language='javascript'> [js_byjax] function set(param, value) {window.location='?src=\ref[src];'+param+'='+value;}</script>"
	. += "<table style='max-height:400px;height:410px; margin-left:250px; margin-right:250px'>"
	. += "<tr style='vertical-align: top;'>"
	. += "<td><div style='max-width:230px;width:230px;height:100%;overflow-y:auto;border-right:1px solid;padding:3px'>"
	if(pref.current_organ in BP_ALL_LIMBS)
		. += "<b>Selected organ: [capitalize(GLOB.organ_tag_to_name[pref.current_organ])]</b>"
	else
		. += "<b>Selected organ: [capitalize(pref.current_organ)]</b>"
	. += get_augmentations(pref.current_organ)
	. += "</div></td>"
	. += "<td style='margin-left:10px;width-max:310px;width:310px;'>"
	. += "<table><tr><td style='width:115px; text-align:right; margin-right:10px;'>"

	var/list/selectable_limbs = BP_ALL_LIMBS - BP_GROIN
	var/list/selectable_organs = BP_INTERNAL_ORGANS
	var/datum/species/current_species = all_species[pref.species]
	if(current_species.spawn_flags & SPECIES_NO_FBP_CHARGEN)
		selectable_limbs -= BP_CHEST

	else if(pref.organ_data[BP_CHEST] == "cyborg")
		selectable_organs |= BP_BRAIN

	else if(pref.organ_data[BP_CHEST] != "cyborg")
		selectable_organs -= BP_BRAIN

	for(var/organ in selectable_limbs)
		. += "<a href='?src=\ref[src];organ=[organ]'><b>[capitalize(GLOB.organ_tag_to_name[organ])]</b></a>"
		. += "<br>[organ_get_display_name(organ)]<br>"

	. += "</td><td style='width:80px;'>"
	. += "<td style='width:115px; text-align:left'>"

	for(var/organ in selectable_organs)
		. += "<a href='?src=\ref[src];organ=[organ]'><b>[capitalize(organ)]</b></a>"
		. += "<br><div>[organ_get_display_name(organ)]</div></div>"

	. += "</td></tr></table><hr>"
	. += "<td><div style='max-width: 230px; width: 230px; height: 100%; overflow-y: auto; border-left: 1px solid; padding: 3px;'>"
	. += get_organ_modules(pref.current_organ)
	. += "</div></td>"

	. += "<table cellpadding='1' cellspacing='0' width='100%'>"
	. += "<tr align='center'>"

	. += "</tr></table>"
	. += "</span></div>"

	return jointext(., null)

/datum/category_item/player_setup_item/augmentation/OnTopic(href, list/href_list, mob/user)
	if(href_list["organ"])
		pref.current_organ = href_list["organ"]
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["body_modification"])
		var/spaceposition = findtext_char(href_list["body_modification"], " ")
		var/organ = copytext_char(href_list["body_modification"], 1, spaceposition)
		var/action = copytext_char(href_list["body_modification"], spaceposition + 1)
		if(organ in (BP_INTERNAL_ORGANS - BP_JAW)) // Kolhoz incorporated by Filatelele.
			update_internal_organ(organ, action)
		else if(organ in BP_ALL_LIMBS + BP_JAW)
			update_external_organ(organ, action)

		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["module"])
		var/spaceposition = findtext_char(href_list["module"], " ")
		var/obj/item/organ_module/module_path = text2path(copytext_char(href_list["module"], spaceposition + 1))
		if(isnull(module_path))
			return TOPIC_REFRESH

		if((initial(module_path.loadout_cost) + pref.total_lpoints_cost) > pref.max_loadout_points)
			return TOPIC_REFRESH

		if(!isnull(initial(module_path.module_type)))
			for(var/obj/item/organ_module/mod as anything in pref.organ_modules[pref.current_organ])
				if(isnull(initial(mod.module_type)))
					continue

				if(initial(mod.type) == initial(module_path.type))
					continue

				if(initial(mod.module_type) != initial(module_path.module_type))
					continue

				LAZYREMOVE(pref.organ_modules[pref.current_organ], mod)
				LAZYDISTINCTADD(pref.organ_modules[pref.current_organ], module_path)
				return TOPIC_REFRESH_UPDATE_PREVIEW

		if(LAZYFIND(pref.organ_modules[pref.current_organ], module_path))
			LAZYREMOVE(pref.organ_modules[pref.current_organ], module_path)
		else
			LAZYDISTINCTADD(pref.organ_modules[pref.current_organ], module_path)

		return TOPIC_REFRESH_UPDATE_PREVIEW

/datum/category_item/player_setup_item/augmentation/proc/update_internal_organ(organ, action)
	switch(action)
		if("nothing")
			pref.organ_data[organ] = null
		if("assisted")
			pref.organ_data[organ] = "assisted"
		if("mechanical")
			pref.organ_data[organ] = "mechanical"

/datum/category_item/player_setup_item/augmentation/proc/update_external_organ(organ, action)
	var/second_limb = null // if you try to change the arm, the hand should also change
	var/third_limb = null  // if you try to unchange the hand, the arm should also change
	switch(organ)
		if(BP_L_LEG)
			second_limb = BP_L_FOOT
		if(BP_R_LEG)
			second_limb = BP_R_FOOT
		if(BP_L_ARM)
			second_limb = BP_L_HAND
		if(BP_R_ARM)
			second_limb = BP_R_HAND
		if(BP_L_FOOT)
			third_limb = BP_L_LEG
		if(BP_R_FOOT)
			third_limb = BP_R_LEG
		if(BP_L_HAND)
			third_limb = BP_L_ARM
		if(BP_R_HAND)
			third_limb = BP_R_ARM
		if(BP_CHEST)
			third_limb = BP_GROIN

	switch(action)
		if("nothing")
			if(organ == BP_CHEST)
				for(var/other_limb in (BP_ALL_LIMBS - BP_CHEST))
					pref.organ_data[other_limb] = null
					pref.rlimb_data[other_limb] = null
					for(var/internal_organ in BP_INTERNAL_ORGANS)
						pref.organ_data[internal_organ] = null

				pref.organ_modules = null

			pref.organ_data[organ] = null
			pref.rlimb_data[organ] = null
			pref.organ_modules[organ] = null
			if(third_limb)
				pref.organ_data[third_limb] = null
				pref.rlimb_data[third_limb] = null
				pref.organ_modules[third_limb] = null

		if("removed")
			if(organ == BP_CHEST)
				return

			pref.organ_data[organ] = "amputated"
			pref.rlimb_data[organ] = null
			pref.organ_modules[organ] = null
			if(second_limb)
				pref.organ_data[second_limb] = "amputated"
				pref.rlimb_data[second_limb] = null
				pref.organ_modules[second_limb] = null

		else
			var/tmp_species = pref.species ? pref.species : SPECIES_HUMAN
			var/datum/robolimb/M = GLOB.chargen_robolimbs[action]
			if(tmp_species in M.species_cannot_use)
				return

			if(M.restricted_to.len && !(tmp_species in M.restricted_to))
				return

			if(M.applies_to_part.len && !(organ in M.applies_to_part))
				return

			pref.rlimb_data[organ] = action
			pref.organ_data[organ] = "cyborg"
			if(second_limb)
				pref.rlimb_data[second_limb] = action
				pref.organ_data[second_limb] = "cyborg"
			if(third_limb && pref.organ_data[third_limb] == "amputated")
				pref.organ_data[third_limb] = null

			if(organ == BP_CHEST)
				for(var/other_limb in BP_ALL_LIMBS + BP_JAW - BP_CHEST)
					pref.organ_data[other_limb] = "cyborg"
					pref.rlimb_data[other_limb] = action
				if(!pref.organ_data[BP_BRAIN])
					pref.organ_data[BP_BRAIN] = "assisted"
				for(var/internal_organ in list(BP_HEART, BP_EYES, BP_LUNGS, BP_LIVER, BP_KIDNEYS))
					pref.organ_data[internal_organ] = "mechanical"

			if(organ == BP_HEAD)
				pref.organ_data[BP_JAW] = "cyborg"
				pref.rlimb_data[BP_JAW] = action

/datum/category_item/player_setup_item/augmentation/proc/reset_limbs()
	pref.organ_data.Cut()
	pref.rlimb_data.Cut()
	pref.organ_modules.Cut()

/datum/category_item/player_setup_item/augmentation/proc/get_organ_modules(organ)
	var/list/data = list()

	var/total_cpu_power = 0
	var/loaded_cpu_power = 0
	var/total_space = 0
	var/occupied_space = 0

	var/mob/living/carbon/human/mannequin = get_mannequin(pref.client_ckey)
	var/obj/item/organ/O
	if(organ in BP_ALL_LIMBS)
		O = mannequin.organs_by_name[organ]
	else if(organ in BP_INTERNAL_ORGANS)
		O = mannequin.internal_organs_by_name[organ]

	total_space = O.max_module_size
	var/datum/robolimb/R = GLOB.all_robolimbs[pref.rlimb_data[organ]]
	if(istype(R))
		total_space += R.max_module_size

	for(var/path in pref.organ_modules[organ])
		var/obj/item/organ_module/module = path
		total_cpu_power += initial(module.cpu_power)
		loaded_cpu_power += initial(module.cpu_load)
		occupied_space += initial(module.w_class)

	data += "<table><tr><td style='width:115px; text-align:right; margin-right:10px;'>"
	data += "<tr style='vertical-align: top;'>"
	var/fcolor =  "#3366cc"

	var/total_cost = pref.get_lp_cost()

	if(total_cost < pref.max_loadout_points)
		fcolor = "#e67300"

	if(pref.max_loadout_points < INFINITY)
		data += "<font color = '[fcolor]'>[total_cost]/[pref.max_loadout_points]</font> loadout points spent.<br>"

	data += "<br><b>CPU: [loaded_cpu_power]/[total_cpu_power] <br>Space: [occupied_space]/[total_space]</b><br>"

	var/list/selected_jobs = list()
	for(var/job_title in (pref.job_medium | pref.job_low | pref.job_high))
		var/datum/job/J = job_master?.occupations_by_title[job_title]
		if(J)
			dd_insertObjectList(selected_jobs, J)

	for(var/mod_path in subtypesof(/obj/item/organ_module))
		var/obj/item/organ_module/mod = new mod_path(null)
		var/list/allowed = mod.allowed_organs
		if(!mod.available_in_charsetup)
			continue

		var/job_allows_this_module = TRUE
		if(LAZYLEN(mod.allowed_jobs))
			for(var/datum/job/J in selected_jobs)
				if(J.type in mod.allowed_jobs)
					job_allows_this_module = TRUE
					break

		if(!job_allows_this_module)
			return FALSE

		if(!(organ in allowed))
			continue

		if(pref.rlimb_data[organ] == "cyborg" && !(initial(mod.module_flags) & OM_FLAG_MECHANICAL))
			continue

		if(isnull(pref.rlimb_data[organ]) && !(initial(mod.module_flags) & OM_FLAG_BIOLOGICAL))
			continue

		var/list/job_restriction_data
		if(length(mod.allowed_jobs))
			job_restriction_data += "<br><b>Has jobs restrictions!</b>"
			job_restriction_data += "<br>"
			job_restriction_data += "<i>"
			var/ind = 0
			for(var/allowed_type in mod.allowed_jobs)
				if(!ispath(allowed_type, /datum/job))
					continue

				var/datum/job/J = job_master ? job_master.occupations_by_type[allowed_type] : new allowed_type
				++ind
				if(ind > 1)
					job_restriction_data += ", "
				if(selected_jobs && length(selected_jobs) && (J in selected_jobs))
					job_restriction_data += "<font color='#55cc55'>[J.title]</font>"
				else
					job_restriction_data += "<font color='#808080'>[J.title]</font>"

			job_restriction_data = jointext(job_restriction_data, "<br>")

		var/price = "<b>Price: [mod.loadout_cost] point[mod.loadout_cost != 1 ? "s" : ""]</b>"

		if(LAZYFIND(R?.default_modules, mod_path))
			data += "<div style = 'padding:2px' onclick=\"set('module', '[organ] [mod_path]');\" class='block'><b>[capitalize(mod.name)] [price]</b><br>[mod.desc] [job_restriction_data]</font></div>"
		else if(LAZYFIND(pref.organ_modules[pref.current_organ], mod_path))
			data += "<div style = 'padding:2px' onclick=\"set('module', '[organ] [mod_path]');\" class='block'><font color='#4f7529'><b>[capitalize(mod.name)] [price]</b><br>[mod.desc] [job_restriction_data]</font></div>"
		else
			data += "<div style = 'padding:2px' onclick=\"set('module', '[organ] [mod_path]');\" class='block'><font color='#ee0000'><b>[capitalize(mod.name)] [price]</b><br>[mod.desc] [job_restriction_data]</font></div>"

	data += "</td></tr></table>"

	return data

/datum/category_item/player_setup_item/augmentation/proc/get_augmentations(organ)
	if(pref.current_organ == BP_HEAD && pref.rlimb_data[BP_CHEST] != "cyborg")
		return

	var/list/modifications = list()
	var/class = ""
	modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["nothing"]');\" class='block[class]'><b>Nothing</b><br>Normal organ.</div>"
	var/list/removable_limbs = BP_LIMBS_LOCOMOTION + BP_LIMBS_ARM_LOCOMOTION
	if(organ in removable_limbs)
		modifications += "<div style = 'padding:2px' onclick=\"set('body_modification','[organ] ["removed"]');\" class='block[class]'><b>Amputated</b><br>Organ was removed.</div>"
	if(organ in BP_ALL_LIMBS + BP_JAW)
		var/tmp_species = pref.species ? pref.species : SPECIES_HUMAN
		for(var/company in GLOB.chargen_robolimbs)
			var/datum/robolimb/M = GLOB.chargen_robolimbs[company]
			if(tmp_species in M.species_cannot_use)
				continue

			if(M.restricted_to.len && !(tmp_species in M.restricted_to))
				continue

			if(M.applies_to_part.len && !(organ in M.applies_to_part))
				continue

			modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] [M.company]');\" class='block[class]'><b>[M.company]</b><br>[M.desc]</div>"
	else if(organ in BP_INTERNAL_ORGANS - BP_JAW)
		if(organ == BP_BRAIN)
			modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["mechanical"]');\" class='block[class]'><b>\tPositronic</b><br></div>"
		else
			modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["mechanical"]');\" class='block[class]'><b>\tSynthetic</b><br></div>"

		switch(organ)
			if(BP_HEART)
				modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["assisted"]');\" class='block[class]'><b>\tPacemaker-assisted</b><br></div>"
			if(BP_EYES)
				modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["assisted"]');\" class='block[class]'><b>\tRetinal overlayed</b><br></div>"
			if(BP_BRAIN)
				modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["assisted"]');\" class='block[class]'><b>\tMachine-interface</b><br></div>"
			else
				modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["assisted"]');\" class='block[class]'><b>\tMechanically assisted</b><br></div>"

	return modifications

/datum/category_item/player_setup_item/augmentation/proc/organ_get_display_name(organ)
	switch(pref.organ_data[organ])
		if(null)
			return "Normal"
		if("cyborg")
			return capitalize(pref.rlimb_data[organ])
		if("amputated")
			return "Amputated"
		if("mechanical")
			if(organ == BP_BRAIN)
				return "Positronic"
			else
				return "Synthetic"
		if("assisted")
			switch(organ)
				if(BP_HEART)
					return "Pacemaker-assisted"
				if(BP_EYES)
					return "Retinal overlayed"
				if(BP_BRAIN)
					return "Machine-interface"
				else
					return "Mechanically assisted"
