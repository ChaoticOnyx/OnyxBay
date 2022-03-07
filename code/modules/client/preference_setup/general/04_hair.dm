#define PER_PAGE 9

/datum/preferences
	var/h_style = "Short Hair"			//Hair type
	var/r_hair = 0						//Hair color
	var/g_hair = 0						//Hair color
	var/b_hair = 0						//Hair color
	var/f_style = "Shaved"				//Face hair type
	var/r_facial = 0					//Face hair color
	var/g_facial = 0					//Face hair color
	var/b_facial = 0					//Face hair color

/datum/category_item/player_setup_item/general/hair/
	name = "Hair"
	sort_order = 4
	var/page = 0

/datum/category_item/player_setup_item/general/hair/

/datum/category_item/player_setup_item/general/hair/content(mob/user)
	var/datum/species/mob_species = all_species[pref.species]
	. = list()
	. += "<b>Hair</b><br>"
	if(has_flag(mob_species, HAS_HAIR_COLOR))
		. += "Color: <font face='fixedsys' size='3' color='#[num2hex(pref.r_hair, 2)][num2hex(pref.g_hair, 2)][num2hex(pref.b_hair, 2)]'><table style='display:inline;' bgcolor='#[num2hex(pref.r_hair, 2)][num2hex(pref.g_hair, 2)][num2hex(pref.b_hair)]'><tr><td>__</td></tr></table></font> <a href='?src=\ref[src];hair_color=1'>Change Color</a>"
	. += "<br>Style: <a href='?src=\ref[src];hair_style=1'>[pref.h_style]</a><br>"
	. += " Cycle: <a href='?src=\ref[src];cycle_hair_style=-1'>&#8592;</a><a href='?src=\ref[src];cycle_hair_style=1'>&#8594;</a><br>"

	. += "<br><b>Facial</b><br>"
	if(has_flag(mob_species, HAS_HAIR_COLOR))
		. += "Color: <font face='fixedsys' size='3' color='#[num2hex(pref.r_facial, 2)][num2hex(pref.g_facial, 2)][num2hex(pref.b_facial, 2)]'><table  style='display:inline;' bgcolor='#[num2hex(pref.r_facial, 2)][num2hex(pref.g_facial, 2)][num2hex(pref.b_facial)]'><tr><td>__</td></tr></table></font> <a href='?src=\ref[src];facial_color=1'>Change Color</a><br>"
	. += " Style: <a href='?src=\ref[src];facial_style=1'>[pref.f_style]</a><br>"
	. += " Cycle: <a href='?src=\ref[src];cycle_fhair_style=-1'>&#8592;</a> <a href='?src=\ref[src];cycle_fhair_style=1'>&#8594;</a><br>"
	. = jointext(.,null)

/datum/category_item/player_setup_item/general/hair/proc/name_sanitize(name)
	return replacetext(name,"'","_")

/datum/category_item/player_setup_item/general/hair/proc/name_unsanitize(name)
	return replacetext(name,"_","'")

/datum/category_item/player_setup_item/general/hair/proc/show_hair_choices(mob/user)
	var/datum/species/mob_species = all_species[pref.species]
	var/list/valid_hairstyles = mob_species.get_hair_styles()
	var/dat = "<a href='?src=\ref[src];cycle_hair_pages=-1'>&#8592;</a> Page: <a href='?src=\ref[src];enter_hair_page=1'>[page+1]</a> <a href='?src=\ref[src];cycle_hair_pages=1'>&#8594;</a><br>"
	var/old_h_style = pref.h_style
	var/datum/browser/popup = new(user, "Hair choose","Hair choose", 550, 650, src)
	var/in_row_counter = 1
	dat+="<table><tr>"
	for (var/i=1+(page*PER_PAGE),i<=PER_PAGE+(page*PER_PAGE),i++)
		if(i>length(valid_hairstyles))
			break

		var/name = valid_hairstyles[i]
		pref.h_style = name
		pref.update_preview_icon()
		send_rsc(user, pref.preview_icon, "previewicon-[name_sanitize(name)].png")

		dat+="<td><div class='statusDisplay'><center> [old_h_style==name?"<span class='linkOn'><b>[name]</b></span>":"<a href='?src=\ref[src];h_style_change=[name_sanitize(name)]'><b>[name]</b></a>"]<br><img src='previewicon-[name_sanitize(name)].png' width=[pref.preview_icon.Width()] height=[pref.preview_icon.Height()]></center></div></td>"

		if(in_row_counter<3)
			in_row_counter++
		else
			dat+="</tr><tr>"
			in_row_counter=1

	pref.h_style = old_h_style
	pref.update_preview_icon()
	popup.set_content(dat)
	popup.open()

/datum/category_item/player_setup_item/general/hair/proc/show_facial_hair_choices(mob/user)
	var/datum/species/mob_species = all_species[pref.species]
	var/list/valid_facialhairstyles = mob_species.get_facial_hair_styles(pref.gender)
	to_chat(user,valid_facialhairstyles)
	var/dat = "<a href='?src=\ref[src];cycle_f_hair_pages=-1'>&#8592;</a> Page: <a href='?src=\ref[src];enter_facial_hair_page=1'>[page+1]</a> <a href='?src=\ref[src];cycle_f_hair_pages=1'>&#8594;</a><br>"
	var/old_f_style = pref.f_style
	var/datum/browser/popup = new(user, "Facial hair choose","Facial hair choose", 550, 650, src)
	var/in_row_counter = 1
	dat+="<table><tr>"
	for (var/i=1+(page*PER_PAGE),i<=PER_PAGE+(page*PER_PAGE),i++)
		if(i>length(valid_facialhairstyles))
			break

		var/name = valid_facialhairstyles[i]
		pref.f_style = name
		pref.update_preview_icon()
		send_rsc(user, pref.preview_icon, "previewicon-[name_sanitize(name)].png")

		dat+="<td><div class='statusDisplay'><center>[old_f_style==name?"<span class='linkOn'><b>[name]</b></span>":"<a href='?src=\ref[src];f_style_change=[name_sanitize(name)]'><b>[name]</b></a>"]<br><img src='previewicon-[name_sanitize(name)].png' width=[pref.preview_icon.Width()] height=[pref.preview_icon.Height()]></center></div></td>"

		if(in_row_counter<3)
			in_row_counter++
		else
			dat+="</tr><tr>"
			in_row_counter=1

	pref.f_style = old_f_style
	pref.update_preview_icon()
	popup.set_content(dat)
	popup.open()

/datum/category_item/player_setup_item/general/hair/OnTopic(href,list/href_list, mob/user)
	var/datum/species/mob_species = all_species[pref.species]
	var/list/valid_hairstyles = mob_species.get_hair_styles()
	var/list/valid_facialhairstyles = mob_species.get_facial_hair_styles(pref.gender)
	if(href_list["hair_style"])
		page = 0
		show_hair_choices(user)
		return TOPIC_NOACTION

	else if(href_list["h_style_change"])
		var/new_h_style = name_unsanitize(href_list["h_style_change"])
		mob_species = all_species[pref.species]
		if(new_h_style && (new_h_style in valid_hairstyles))
			pref.h_style = new_h_style
			show_hair_choices(user)
			return TOPIC_REFRESH_UPDATE_PREVIEW
		return TOPIC_NOACTION

	else if(href_list["hair_color"])
		if(!has_flag(mob_species, HAS_HAIR_COLOR))
			return TOPIC_NOACTION
		var/new_hair = input(user, "Choose your character's hair colour:", CHARACTER_PREFERENCE_INPUT_TITLE, rgb(pref.r_hair, pref.g_hair, pref.b_hair)) as color|null
		if(new_hair && has_flag(all_species[pref.species], HAS_HAIR_COLOR) && CanUseTopic(user))
			pref.r_hair = hex2num(copytext(new_hair, 2, 4))
			pref.g_hair = hex2num(copytext(new_hair, 4, 6))
			pref.b_hair = hex2num(copytext(new_hair, 6, 8))
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["cycle_hair_style"])
		var/list/hairstyles = mob_species.get_hair_styles()
		var/index_step = text2num(href_list["cycle_hair_style"])
		var/current_h_style = CycleArray(hairstyles, index_step, pref.h_style)
		if (current_h_style && CanUseTopic(user))
			pref.h_style = current_h_style
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["enter_hair_page"])
		var/new_page = input(user,"Enter page number(1-[ceil(length(valid_hairstyles)/PER_PAGE)]):","Quick page change",0) as num
		if(new_page>=1 && new_page<=ceil(length(valid_hairstyles)/PER_PAGE))
			page = new_page-1
		else
			return TOPIC_NOACTION
		show_hair_choices(user)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["enter_facial_hair_page"])
		var/new_page = input(user,"Enter page number(1-[ceil(length(valid_facialhairstyles)/PER_PAGE)]):","Quick page change",0) as num
		if(new_page>=1 && new_page<=ceil(length(valid_facialhairstyles)/PER_PAGE))
			page = new_page-1
		else
			return TOPIC_NOACTION
		show_facial_hair_choices(user)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["cycle_hair_pages"])
		var/new_page = page+text2num(href_list["cycle_hair_pages"])
		if(new_page<0 || new_page>round(length(valid_hairstyles)/PER_PAGE))
			return TOPIC_NOACTION
		page = new_page
		show_hair_choices(user)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["cycle_f_hair_pages"])
		var/new_page = page+text2num(href_list["cycle_f_hair_pages"])
		if(new_page<0 || new_page>round(length(valid_facialhairstyles)/PER_PAGE))
			return TOPIC_NOACTION
		page = new_page
		show_facial_hair_choices(user)
		return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["facial_color"])
		if(!has_flag(mob_species, HAS_HAIR_COLOR))
			return TOPIC_NOACTION
		var/new_facial = input(user, "Choose your character's facial-hair colour:", CHARACTER_PREFERENCE_INPUT_TITLE, rgb(pref.r_facial, pref.g_facial, pref.b_facial)) as color|null
		if(new_facial && has_flag(all_species[pref.species], HAS_HAIR_COLOR) && CanUseTopic(user))
			pref.r_facial = hex2num(copytext(new_facial, 2, 4))
			pref.g_facial = hex2num(copytext(new_facial, 4, 6))
			pref.b_facial = hex2num(copytext(new_facial, 6, 8))
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if(href_list["facial_style"])
		page = 0
		show_facial_hair_choices(user)
		return TOPIC_NOACTION

	else if(href_list["f_style_change"])
		var/new_f_style = name_unsanitize(href_list["f_style_change"])
		mob_species = all_species[pref.species]
		if(new_f_style && CanUseTopic(user) && valid_facialhairstyles)
			pref.f_style = new_f_style
			show_facial_hair_choices(user)
			return TOPIC_REFRESH_UPDATE_PREVIEW

	else if (href_list["cycle_fhair_style"])
		var/list/hairstyles = mob_species.get_facial_hair_styles(pref.gender)
		var/index_step = text2num(href_list["cycle_fhair_style"])
		var/current_fh_style = CycleArray(hairstyles, index_step, pref.f_style)

		mob_species = all_species[pref.species]
		if (current_fh_style && CanUseTopic(user) && mob_species.get_facial_hair_styles(pref.gender))
			pref.f_style = current_fh_style
			return TOPIC_REFRESH_UPDATE_PREVIEW
