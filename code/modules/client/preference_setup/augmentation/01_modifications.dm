/datum/preferences
	var/list/organ_data
	var/list/rlimb_data
	var/current_organ = BP_CHEST

/datum/category_item/player_setup_item/augmentation
	name = "Augmentation"
	sort_order = 1

/datum/category_item/player_setup_item/augmentation/load_character(datum/pref_record_reader/R)
	pref.organ_data = R.read("organ_data")
	pref.rlimb_data = R.read("rlimb_data")

/datum/category_item/player_setup_item/augmentation/save_character(datum/pref_record_writer/W)
	W.write("organ_data", pref.organ_data)
	W.write("rlimb_data", pref.rlimb_data)

/datum/category_item/player_setup_item/augmentation/sanitize_character()
	LAZYINITLIST(pref.organ_data)
	LAZYINITLIST(pref.rlimb_data)

	if(pref.organ_data[BP_CHEST] == "cyborg")
		for(var/organ in BP_INTERNAL_ORGANS)
			if(pref.organ_data[organ] != null)
				continue

			switch(organ)
				if(BP_BRAIN)
					pref.organ_data[organ] = pick("assisted", "mechanical") // Either positronic or MMI
				else
					pref.organ_data[organ] = "mechanical" // No filthy organics in my FBP

	if(pref.organ_data[BP_BRAIN] != null && pref.organ_data[BP_CHEST] != "cyborg")
		pref.organ_data[BP_BRAIN] = null

/datum/category_item/player_setup_item/augmentation/content(mob/user)
	. = list()

	. += "<style>div.block{margin: 3px 0px;padding: 4px 0px;}"
	. += "span.color_holder_box{display: inline-block; width: 20px; height: 8px; border:1px solid #000; padding: 0px;}<"
	. += "a.Organs_active {background: #cc5555;}</style>"

	. +=  "<script language='javascript'> [js_byjax] function set(param, value) {window.location='?src=\ref[src];'+param+'='+value;}</script>"
	. += "<table style='max-height:400px;height:410px; margin-left:250px; margin-right:250px'>"
	. += "<tr style='vertical-align:top'>"
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
		selectable_limbs |= BP_HEAD
		selectable_organs |= BP_BRAIN

	else if(pref.organ_data[BP_CHEST] != "cyborg")
		selectable_limbs -= BP_HEAD
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
		if(organ in BP_INTERNAL_ORGANS)
			update_internal_organ(organ, action)
		else if(organ in BP_ALL_LIMBS)
			update_external_organ(organ, action)

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

			pref.organ_data[organ] = null
			pref.rlimb_data[organ] = null
			if(third_limb)
				pref.organ_data[third_limb] = null
				pref.rlimb_data[third_limb] = null

		if("removed")
			if(organ == BP_CHEST)
				return

			pref.organ_data[organ] = "amputated"
			pref.rlimb_data[organ] = null
			if(second_limb)
				pref.organ_data[second_limb] = "amputated"
				pref.rlimb_data[second_limb] = null

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
				for(var/other_limb in BP_ALL_LIMBS - BP_CHEST)
					pref.organ_data[other_limb] = "cyborg"
					pref.rlimb_data[other_limb] = action
				if(!pref.organ_data[BP_BRAIN])
					pref.organ_data[BP_BRAIN] = "assisted"
				for(var/internal_organ in list(BP_HEART,BP_EYES,BP_LUNGS,BP_LIVER,BP_KIDNEYS))
					pref.organ_data[internal_organ] = "mechanical"

/datum/category_item/player_setup_item/augmentation/proc/reset_limbs()
	pref.organ_data.Cut()
	pref.rlimb_data.Cut()

/datum/category_item/player_setup_item/augmentation/proc/get_augmentations(organ)
	var/list/modifications = list()
	var/class = ""
	modifications += "<div style = 'padding:2px' onclick=\"set('body_modification', '[organ] ["nothing"]');\" class='block[class]'><b>Nothing</b><br>Normal organ.</div>"
	var/list/removable_limbs = BP_LIMBS_LOCOMOTION + BP_LIMBS_ARM_LOCOMOTION
	if(organ in removable_limbs)
		modifications += "<div style = 'padding:2px' onclick=\"set('body_modification','[organ] ["removed"]');\" class='block[class]'><b>Amputated</b><br>Organ was removed.</div>"
	if(organ in BP_ALL_LIMBS)
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
	else if(organ in BP_INTERNAL_ORGANS)
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
