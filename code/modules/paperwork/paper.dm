/*
 * Paper
 * also scraps of paper
 */

/obj/item/paper
	name = "sheet of paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	randpixel = 8
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 1
	throw_speed = 3
	layer = ABOVE_OBJ_LAYER
	slot_flags = SLOT_HEAD
	body_parts_covered = HEAD
	attack_verb = list("bapped")

	var/info = ""   //What's actually written on the paper.
	var/info_links  //A different version of the paper which includes html links at fields and EOF
	var/stamps      //The (text for the) stamps on the paper.
	var/free_space = MAX_PAPER_MESSAGE_LEN
	var/stamps_generated = TRUE
	var/list/stamped
	var/list/ico[0]      //Icons and
	var/list/offset_x[0] //offsets stored for later
	var/list/offset_y[0] //usage by the photocopier
	var/taped = FALSE
	var/crumpled = FALSE
	var/rigged = FALSE
	var/spam_flag = FALSE
	var/readonly = FALSE
	var/appendable = TRUE
	var/dynamic_icon = FALSE
	var/rawhtml = FALSE

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"
	var/const/handfont = "Segoe Script"
	var/const/fancyfont = "Good Vibes Pro"
	var/text_color = COLOR_BLACK

	var/static/styles = {"
	@font-face {
		font-family: "Good Vibes Pro";
		src: url("./good_vibes.woff") format("woff");
		font-weight: 400;
		font-style: normal;
		font-display: swap;
	}

	table,th,td{
		border: 1px solid black;
	}

	.SmallFont {
		font-size: 0.7em;
	}

	.MediumFont {
		font-size: 1.2em;
	}

	.LargeFont {
		font-size: 1.3em;
	}

	hr.Handwritten {
		border: none;
		height: 5px;
		background-image: url('line_hand.png');
		background-repeat: repeat-x;
		background-size: contain;
	}

	table.Handwritten,
	th.Handwritten,
	td.Handwritten {
		border: 5px solid black;
		border-image: url('borders_hand.png') 27 fill;
		border-image-size: 10px;
	}
"}

	//static because these can't be const
	var/static/regex/named_field_tag_regex = regex(@"\[field=(\w+)\]", "g")
	var/static/regex/named_sign_field_tag_regex = regex(@"\[signfield=(\w+)\]", "g")
	var/static/regex/sign_field_regex = regex(@"<I><span class='sign_field_(\w+)'>sign here</span></I>", "g")
	var/static/regex/named_field_extraction_regex = regex(@#<!--paper_fieldstart_N(\w+)-->(.*?)(?:<!--paper_field_N\1-->)?<!--paper_fieldend_N\1-->#, "g")
	var/static/regex/field_regex = regex(@#<!--paper_field_(\w+)-->#, "g")
	var/static/regex/field_link_regex = regex("<font face=\"[deffont]\"><A href='\\?src=\[^'\]+?;write=\[^'\]+'>write</A></font>", "g")

/obj/item/paper/Initialize(mapload, text, title, rawhtml = TRUE, noinit = FALSE)
	. = ..()

	if (noinit)
		return
	set_content(text ? text : info, title, rawhtml || src.rawhtml)

/obj/item/paper/proc/copy(loc = src.loc, generate_stamps = TRUE)
	var/obj/item/paper/P = new (loc)
	P.name = (taped) ? copytext(name, 1, length(name)-7) : name
	P.info = info
	P.info_links = info_links
	P.migrateinfolinks(src)
	P.stamps = stamps
	P.free_space = free_space
	P.stamped = stamped
	P.ico = ico
	P.offset_x = offset_x
	P.offset_y = offset_y
	P.rigged = rigged
	P.readonly = readonly
	P.appendable = appendable
	P.color = color
	P.text_color = text_color
	if (generate_stamps)
		P.generate_stamps()
	else
		P.stamps_generated = FALSE
	return P

/obj/item/paper/proc/recolorize(saturation = 1, grayscale = FALSE)
	var/static/regex/color_regex = regex("color=(#\[0-9a-fA-F\]+)", "g")
	text_color = BlendRGB(color ? color : COLOR_WHITE, text_color, saturation)
	if (grayscale)
		if (color)
			color = GrayScale(color)
		text_color = GrayScale(text_color)

	var/list/found_colors = list()
	color_regex.next = 1
	while (color_regex.Find(info))
		var/found_color = color_regex.group[1]
		found_colors |= found_color

	for (var/found_color in found_colors)
		var/result_color = BlendRGB(color ? color : COLOR_WHITE, found_color, saturation)
		if (grayscale)
			result_color = GrayScale(result_color)
		info = replacetext(info, "color=[found_color]", "color=[result_color]")
		info_links = replacetext(info_links, "color=[found_color]", "color=[result_color]")

	if (!stamps_generated) //not sure how to remove merged stamps, so limiting it to generation (no regeneration) for now
		generate_stamps(saturation, grayscale)

/obj/item/paper/proc/generate_stamps(saturation = 1, grayscale = FALSE)
	stamps_generated = TRUE
	var/image/img
	for (var/j = 1, j <= min(ico.len), j++) //gray overlay onto the copy
		var/chosen_stamp = ico[j]
		img = image('icons/obj/bureaucracy.dmi', chosen_stamp)
		img.pixel_x = offset_x[j]
		img.pixel_y = offset_y[j]
		if (grayscale)
			img.color = list(0.3,0.3,0.3, 59,59,59, 11,11,11)
		img.alpha = saturation * 255
		overlays += img
	update_icon()

/obj/item/paper/proc/set_content(text, title, rawhtml = FALSE)
	if(title)
		SetName(title)
	info = text
	if(!rawhtml)
		info = html_encode(text)
	info = parsepencode(info, is_init = TRUE)
	generateinfolinks()
	update_space()
	update_icon()

/obj/item/paper/update_icon()
	if(dynamic_icon)
		return
	if(!crumpled)
		icon_state = "paper"
		if(!is_clean())
			icon_state = "[icon_state]_words"
	else
		icon_state = "scrap"
	if(taped)
		icon_state = "[icon_state]_taped"

/obj/item/paper/proc/update_space()
	free_space = initial(free_space)
	free_space -= length(strip_html_properly(info_links)) //using info_links to also count field prompts

/obj/item/paper/proc/is_clean()
	var/list/visible_html_tags = list("<table","<img","<hr")
	var/is_visible_html_tag = FALSE
	for(var/tag in visible_html_tags)
		if(findtext(info,tag))
			is_visible_html_tag = TRUE
			break
	return !length(strip_html_properly(info)) && !is_visible_html_tag

/obj/item/paper/_examine_text(mob/user)
	. = ..()
	if(name != "sheet of paper")
		. += "\nIt's titled '[name]'."
	if(user && (in_range(user, src) || isghost(user)))
		show_content(user)
	else
		. += "\n[SPAN_NOTICE("You have to go closer if you want to read it.")]"

/obj/item/paper/proc/show_content(mob/user, forceshow)
	var/can_read = (istype(user, /mob/living/carbon/human) || isghost(user) || istype(user, /mob/living/silicon)) || forceshow
	if(can_read && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.IsAdvancedToolUser(TRUE))
			can_read = FALSE
	if(!forceshow && istype(user,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = user
		can_read = get_dist(src, AI.camera) < 2
	var/content = {"
<html>
	<meta charset='utf-8'>
	<meta http-equiv='X-UA-Compatible' content='IE=edge'>
	<head>
		<title>[name]</title>
		<style>[styles]</style>
	</head>
	<body bgcolor='[color ? color : COLOR_WHITE]' text='[text_color]'>
		[can_read ? info : stars(info)][stamps]
	</body>
</html>
"}
	show_browser(user, content, "window=[name]")
	onclose(user, "[name]")

/obj/item/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if((MUTATION_CLUMSY in usr.mutations) && prob(50))
		to_chat(usr, SPAN_WARNING("You cut yourself on the paper."))
		return
	var/n_name = sanitizeSafe(input(usr, "What would you like to label the paper?", "Paper Labelling", null)  as text, MAX_NAME_LEN)

	// We check loc one level up, so we can rename in clipboards and such. See also: /obj/item/photo/rename()
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0 && n_name)
		SetName(n_name)
		if(taped)
			name = "[name] (taped)"
		add_fingerprint(usr)

/obj/item/paper/attack_self(mob/living/user)
	if(user.a_intent == I_HURT)
		if(crumpled)
			user.show_message(SPAN_NOTICE("\The [src] is already crumpled."))
			return
		//crumple dat paper
		info = stars(info,85)
		user.visible_message(SPAN_WARNING("\The [user] crumples \the [src] into a ball!"))
		crumpled = TRUE
		update_icon()
		throw_range = 7
		throw_speed = 1
		return
	if(taped)
		name = copytext(name, 1, length(name)-7)
		to_chat(user, "You removed the piece of tape from [name].")
		taped = FALSE
		anchored = FALSE
		update_icon()
	else
		user.examinate(src)
		if(rigged && (Holiday == "April Fool's Day") && !spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20) spam_flag = FALSE

/obj/item/paper/attack_hand(mob/user)
	anchored = FALSE // Unattach it from whereever it's on, if anything.
	return ..()

/obj/item/paper/attack_ai(mob/living/silicon/ai/user)
	show_content(user)

/obj/item/paper/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.zone_sel.selecting == BP_EYES)
		user.visible_message(SPAN_NOTICE("[user] holds up a paper and shows it to [M]."), \
		                     SPAN_NOTICE("You show the paper to [M]."))
		M.examinate(src)

	else if(user.zone_sel.selecting == BP_MOUTH) // lipstick wiping
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, SPAN_NOTICE("You wipe off the lipstick with [src]."))
				H.lip_style = null
				H.update_body()
			else
				user.visible_message(SPAN_WARNING("[user] begins to wipe [H]'s lipstick off with \the [src]."), \
				                     SPAN_NOTICE("You begin to wipe off [H]'s lipstick."))
				if(do_after(user, 10, H) && do_after(H, 10, needhand = 0))	//user needs to keep their active hand, H does not.
					user.visible_message(SPAN_NOTICE("[user] wipes [H]'s lipstick off with \the [src]."), \
					                     SPAN_NOTICE("You wipe off [H]'s lipstick."))
					H.lip_style = null
					H.update_body()

/obj/item/paper/afterattack(A, mob/user, flag, params)
	if(!taped)
		return

	if(!in_range(user, A) || istype(A, /obj/machinery/door) || istype(A, /obj/item))
		return

	if(src != user.get_active_hand()) // If anything took paper
		return

	var/turf/target_turf = get_turf(A)
	var/turf/source_turf = get_turf(user)

	var/dir_offset = 0
	if(target_turf != source_turf)
		dir_offset = get_dir(source_turf, target_turf)
		if(!(dir_offset in GLOB.cardinal))
			to_chat(user, SPAN_NOTICE("You cannot reach that from here.")) // Can only place stuck papers in cardinal directions, to
			return                                                         // Reduce papers around corners issue.

	user.drop_from_inventory(src)
	forceMove(source_turf)
	anchored = TRUE

	if(!params)
		return
	var/list/mouse_control = params2list(params)
	if(mouse_control["icon-x"])
		pixel_x = text2num(mouse_control["icon-x"]) - 16
		if(dir_offset & EAST)
			pixel_x += 32
		else if(dir_offset & WEST)
			pixel_x -= 32
	if(mouse_control["icon-y"])
		pixel_y = text2num(mouse_control["icon-y"]) - 16
		if(dir_offset & NORTH)
			pixel_y += 32
		else if(dir_offset & SOUTH)
			pixel_y -= 32

/obj/item/paper/attackby(obj/item/P, mob/user)
	..()

	if(istype(P, /obj/item/tape_roll))
		if(taped)
			to_chat(user, SPAN_NOTICE("It has been taped already!"))
			return
		name = "[name] (taped)"
		taped = TRUE
		update_icon()
		return

	if(istype(P, /obj/item/paper) || istype(P, /obj/item/photo))
		if (istype(P, /obj/item/paper/carbon))
			var/obj/item/paper/carbon/C = P
			if (!C.copied)
				to_chat(user, SPAN_NOTICE("Take off the carbon copy first."))
				add_fingerprint(user)
				return
		var/obj/item/paper_bundle/B = new(loc)
		if (name != "paper")
			B.SetName(name)
		else if (P.name != "paper" && P.name != "photo")
			B.SetName(P.name)

		user.drop_from_inventory(P)
		user.drop_from_inventory(src)
		user.put_in_hands(B)
		forceMove(B)
		P.forceMove(B)

		to_chat(user, SPAN_NOTICE("You clip the [P.name] to \the [src.name]."))

		B.pages += src
		B.pages += P
		B.update_icon()

	else if(istype(P, /obj/item/pen))
		if(crumpled)
			to_chat(usr, SPAN_WARNING("\The [src] is too crumpled to write on."))
			return

		var/obj/item/pen/robopen/RP = P
		if (istype(RP) && RP.mode == 2)
			RP.RenamePaper(user,src)
		else
			var/content = {"
<html>
	<meta charset='utf-8'>
	<meta http-equiv='X-UA-Compatible' content='IE=edge'>
	<head>
		<title>[name]</title>
		<style>[styles]</style>
	</head>
	<body bgcolor='[color]'>
		[info_links][stamps]
	</body>
</html>
"}
			show_browser(user, content, "window=[name]")
		return

	else if(istype(P, /obj/item/stamp) || istype(P, /obj/item/clothing/ring/seal))
		if((!in_range(src, user) && loc != user && !( istype(loc, /obj/item/clipboard) ) && loc.loc != user && user.get_active_hand() != P))
			return

		stamps += (stamps=="" ? "<hr>" : "<br>") + "<i>This paper has been stamped with the [P.name].</i>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x
		var/y
		if(istype(P, /obj/item/stamp/captain) || istype(P, /obj/item/stamp/centcomm))
			x = rand(-2, 0)
			y = rand(-1, 2)
		else
			x = rand(-2, 2)
			y = rand(-3, 2)
		offset_x += x
		offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(istype(P, /obj/item/stamp/clown))
			var/clown = user.mind && (user.mind.assigned_role == "Clown")
			if(!clown)
				to_chat(user, SPAN_NOTICE("You are totally unable to use the stamp. HONK!"))
				return

		if(!ico)
			ico = new
		ico += "paper_[P.icon_state]"
		stampoverlay.icon_state = "paper_[P.icon_state]"

		if(!stamped)
			stamped = new
		stamped += P.type
		overlays += stampoverlay

		to_chat(user, SPAN_NOTICE("You stamp the paper with your [P.name]."))

	else if(istype(P, /obj/item/flame))
		burnpaper(P, user)

	else if(istype(P, /obj/item/paper_bundle))
		var/obj/item/paper_bundle/attacking_bundle = P
		attacking_bundle.insert_sheet_at(user, (attacking_bundle.pages.len)+1, src)
		attacking_bundle.update_icon()

	else if(istype(P, /obj/item/reagent_containers/food/grown))
		var/obj/item/reagent_containers/food/grown/G = P
		if(!G.dry)
			to_chat(user, SPAN_NOTICE("[G] must be dried before you can grind and roll it."))
			return
		var/R_loc = loc
		var/roll_in_hands = FALSE
		if(ishuman(loc))
			R_loc = user.loc
			roll_in_hands = TRUE
		var/obj/item/clothing/mask/smokable/cigarette/roll/joint/big/R = new(R_loc)
		if(G.reagents)
			if(G.reagents.has_reagent(/datum/reagent/nutriment))
				G.reagents.del_reagent(/datum/reagent/nutriment)
			G.reagents.trans_to_obj(R, G.reagents.total_volume)
		R.desc += " Looks like it contains some [G]."
		to_chat(user, SPAN_NOTICE("You grind \the [G] and roll a big joint!"))
		R.add_fingerprint(user)
		qdel(src)
		qdel(G)
		if(roll_in_hands)
			user.put_in_hands(R)
		return

	add_fingerprint(user)

/obj/item/paper/proc/addtofield(id, text, terminate = FALSE)
	var/token = "<!--paper_field_[id]-->"
	var/token_link = "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[id]'>write</A></font>"
	var/text_with_links = field_regex.Replace(text, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=$1'>write</A></font>")
	text_with_links = sign_field_regex.Replace(text_with_links, " <I><A href='?src=\ref[src];signfield=$1'>sign here</A></I> ")
	info = replacetext(info, token, "[text][terminate ? "" : token]")
	info_links = replacetext(info_links, token_link, "[text_with_links][terminate ? "" : token_link]")


/obj/item/paper/proc/generateinfolinks()
	info_links = info
	if (readonly)
		return

	info_links = field_regex.Replace(info_links, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=$1'>write</A></font>")
	info_links = sign_field_regex.Replace(info_links, " <I><A href='?src=\ref[src];signfield=$1'>sign here</A></I> ")

	if (appendable)
		info += "<!--paper_field_end-->"
		info_links += "<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font>"

/obj/item/paper/proc/migrateinfolinks(from)
	info_links = replacetext(info_links, "\ref[from]", "\ref[src]")

/obj/item/paper/proc/make_readonly()
	if (readonly)
		return
	info_links = field_link_regex.Replace(info_links, "")
	readonly = TRUE

/obj/item/paper/proc/clearpaper()
	info = null
	stamps = null
	free_space = MAX_PAPER_MESSAGE_LEN
	stamped = list()
	overlays.Cut()
	generateinfolinks()
	update_icon()

/obj/item/paper/proc/get_signature(obj/item/pen/P, mob/user, signfield)
	if(P && istype(P, /obj/item/pen))
		return P.get_signature(user)
	return (user && user.real_name) ? user.real_name : "Anonymous"

/proc/new_unnamed_field(to_replace)
	var/static/counter
	if (!counter)
		counter = 0
	return "<!--paper_field_[counter++]-->"

/proc/new_sign_field(to_replace)
	var/static/counter
	if (!counter)
		counter = 0
	return " <I><span class='sign_field_[counter++]'>sign here</span></I> "

/obj/item/paper/proc/parsepencode(t, obj/item/pen/P, mob/user, iscrayon, isfancy, ishandwritten, is_init = FALSE)
	if(length(t) == 0)
		return ""

	var/using_font = deffont

	if(isfancy)
		using_font = fancyfont
	else if(iscrayon)
		using_font = crayonfont
	else if(ishandwritten)
		using_font = handfont

	if(findtext(t, "\[sign\]"))
		t = replacetext(t, "\[sign\]", "<font face=\"[using_font]\"><i>[get_signature(P, user)]</i></font>")

	t = replacetext(t, @"[signfield]", /proc/new_sign_field)
	t = replacetext(t, @"[field]", /proc/new_unnamed_field)
	//TODO: check if there's any way to sneak old fields there and add converter if there is
	//shouldn't allow users to create named fields because a) they're useless for them b) they'll (users) fuck you up
	if (is_init)
		//prefixed with N to prevent unnamed-named collisions
		//start and end tags for cases when you want to extract info from named fields
		t = replacetext(t, named_field_tag_regex, "<!--paper_fieldstart_N$1--><!--paper_field_N$1--><!--paper_fieldend_N$1-->")
		t = replacetext(t, named_sign_field_tag_regex, " <I><span class='sign_field_N$1'>sign here</span></I> ")

	if(iscrayon) // If it is a crayon, and he still tries to use these, make them empty!
		t = replacetext(t, "\[*\]", "")
		t = replacetext(t, "\[hr\]", "")
		t = replacetext(t, "\[small\]", "")
		t = replacetext(t, "\[/small\]", "")
		t = replacetext(t, "\[list\]", "")
		t = replacetext(t, "\[/list\]", "")
		t = replacetext(t, "\[table\]", "")
		t = replacetext(t, "\[/table\]", "")
		t = replacetext(t, "\[row\]", "")
		t = replacetext(t, "\[cell\]", "")
		t = replacetext(t, "\[logo\]", "")

	t = "<font face=\"[using_font]\" color=[P ? P.colour : COLOR_BLACK]>[t]</font>"

	t = pencode2html(t, isfancy || iscrayon || ishandwritten)

	return t

/obj/item/paper/proc/parse_named_fields()
	var/list/matches = list()
	named_field_extraction_regex.next = 1
	while (named_field_extraction_regex.Find(info))
		matches[named_field_extraction_regex.group[1]] = named_field_extraction_regex.group[2]
	return matches

/obj/item/paper/proc/burnpaper(obj/item/flame/P, mob/user)
	var/class = "warning"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/flame/lighter/zippo))
			class = "rose"

		user.visible_message("<span class='[class]'>[user] holds \the [P] up to \the [src], it looks like \he's trying to burn it!</span>", \
		"<span class='[class]'>You hold \the [P] up to \the [src], burning it slowly.</span>")

		spawn(20)
			if(get_dist(src, user) < 2 && user.get_active_hand() == P && P.lit)
				user.visible_message("<span class='[class]'>[user] burns right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>", \
				"<span class='[class]'>You burn right through \the [src], turning it to ash. It flutters through the air before settling on the floor in a heap.</span>")

				if(user.get_inactive_hand() == src)
					user.drop_from_inventory(src)

				new /obj/effect/decal/cleanable/ash(src.loc)
				qdel(src)

			else
				to_chat(user, SPAN_WARNING("You must hold \the [P] steady to burn \the [src]."))


/obj/item/paper/proc/get_pen()
	var/obj/item/i = usr.get_active_hand()
	if(istype(i, /obj/item/pen))
		return i
	if(usr.back && istype(usr.back,/obj/item/rig))
		var/obj/item/rig/r = usr.back
		var/obj/item/rig_module/device/pen/m = locate(/obj/item/rig_module/device/pen) in r.installed_modules
		if(!r.offline && m)
			return m.device
		else
			return
	else
		return

/obj/item/paper/proc/check_proximity()
	// if paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
	return !(src.loc != usr && !src.Adjacent(usr)\
		&& !((istype(src.loc, /obj/item/clipboard) || istype(src.loc, /obj/item/folder))\
		&& (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )


/obj/item/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return
	if (href_list["signfield"])
		var/signfield = href_list["signfield"]
		var/obj/item/pen/P = get_pen()
		if (!P || !check_proximity())
			return
		var/signfield_name
		if (copytext(signfield, 1, 2) == "N")
			signfield_name = copytext(signfield, 2)

		var/signature = get_signature(P, usr, signfield_name)
		if(istype(P, /obj/item/pen/crayon))
			signature = "<b>[signature]</b>"
		info = replacetext(info, "<I><span class='sign_field_[signfield]'>sign here</span></I>", "<font face=\"[signfont]\" color=[P.colour]><i>[signature]</i></font>")
		info_links = replacetext(info_links, "<I><A href='?src=\ref[src];signfield=[signfield]'>sign here</A></I>", "<font face=\"[signfont]\" color=[P.colour]><i>[signature]</i></font>")
		update_space()
		var/content = {"
<html>
	<meta http-equiv='X-UA-Compatible' content='IE=edge'>
	<meta charset='utf-8'>
	<head>
		<title>[name]</title>
		<style>[styles]</style>
	</head>
	<body bgcolor='[color]'>
		[info_links][stamps]
	</body>
</html>
"}
		show_browser(usr, content, "window=[name]") // Update the window
		return
	if(href_list["write"])
		if (readonly)
			to_chat(usr, SPAN_WARNING("Your pen fails to leave any trace on \the [src]!"))
			return
		var/id = href_list["write"]
		//var/t = strip_html_simple(input(usr, "What text do you wish to add to " + (id=="end" ? "the end of the paper" : "field "+id) + "?", "[name]", null),8192) as message

		if(free_space <= 0)
			to_chat(usr, SPAN("info", "There isn't enough space left on \the [src] to write anything."))
			return

		var/t =  sanitize(input("Enter what you want to write:", "Write", null, null) as message, free_space, extra = 0, trim = 0)

		if(!t)
			return

		var/obj/item/i = get_pen()
		if (!i)
			return

		var/ishandwritten = FALSE
		var/iscrayon = FALSE
		var/isfancy = FALSE

		if(istype(i, /obj/item/pen))
			ishandwritten = TRUE

			if(istype(i, /obj/item/pen/crayon))
				iscrayon = TRUE

			if(istype(i, /obj/item/pen/fancy))
				isfancy = TRUE

		if (!check_proximity())
			return

		if (counttext(t, @"[field]") > 50)
			to_chat(usr, SPAN_WARNING("Too many fields. Sorry, you can't do this."))
			return

		t = parsepencode(t, i, usr, iscrayon, isfancy, ishandwritten) // Encode everything from pencode to html

		var/terminated = FALSE
		if (findtext(t, @"[end]"))
			t = replacetext(t, @"[end]", "")
			terminated = TRUE

		addtofield(id, t, terminated) // He wants to edit a field, let him.
		if (id == "end" && terminated)
			appendable = FALSE

		update_space()

		var/content = {"
<html>
	<meta http-equiv='X-UA-Compatible' content='IE=edge'>
	<meta charset='utf-8'>
	<head>
		<title>[name]</title>
		<style>[styles]</style>
	</head>
	<body bgcolor='[color]'>
		[info_links][stamps]
	</body>
</html>
"}
		show_browser(usr, content, "window=[name]") // Update the window

		update_icon()

//For supply.
/obj/item/paper/manifest
	name = "supply manifest"
	var/is_copy = TRUE
