/*
 * Paper
 * also scraps of paper
 */

/obj/item/weapon/paper
	name = "sheet of paper"
	gender = NEUTER
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	randpixel = 8
	throwforce = 0
	w_class = ITEM_SIZE_TINY
	throw_range = 1
	throw_speed = 1
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
	var/rigged = FALSE
	var/spam_flag = FALSE
	var/readonly = FALSE
	var/appendable = TRUE
	var/dynamic_icon = FALSE
	var/rawhtml = FALSE

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"
	var/const/fancyfont = "Segoe Script"
	var/text_color = COLOR_BLACK

	//static because these can't be const
	var/static/regex/named_field_tag_regex = regex(@"\[field=(\w+)\]", "g")
	var/static/regex/named_sign_field_tag_regex = regex(@"\[signfield=(\w+)\]", "g")
	var/static/regex/sign_field_regex = regex(@"<I><span class='sign_field_(\w+)'>sign here</span></I>", "g")
	var/static/regex/named_field_extraction_regex = regex(@#<!--paper_fieldstart_N(\w+)-->(.*?)(?:<!--paper_field_N\1-->)?<!--paper_fieldend_N\1-->#, "g")
	var/static/regex/field_regex = regex(@#<!--paper_field_(\w+)-->#, "g")
	var/static/regex/field_link_regex = regex("<font face=\"[deffont]\"><A href='\\?src=\[^'\]+?;write=\[^'\]+'>write</A></font>", "g")

/obj/item/weapon/paper/Initialize(mapload, text, title, rawhtml = TRUE, noinit = FALSE)
	. = ..()

	if (noinit)
		return
	set_content(text ? text : info, title, rawhtml || src.rawhtml)

/obj/item/weapon/paper/proc/copy(loc = src.loc, generate_stamps = TRUE)
	var/obj/item/weapon/paper/P = new (loc)
	P.name = name
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

/obj/item/weapon/paper/proc/recolorize(saturation = 1, grayscale = FALSE)
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

/obj/item/weapon/paper/proc/generate_stamps(saturation = 1, grayscale = FALSE)
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

/obj/item/weapon/paper/proc/set_content(text, title, rawhtml = FALSE)
	if(title)
		SetName(title)
	info = text
	if(!rawhtml)
		info = html_encode(text)
	info = parsepencode(info, is_init = TRUE)
	update_icon()
	update_space()
	generateinfolinks()

/obj/item/weapon/paper/update_icon()
	if(dynamic_icon)
		return
	else if(info)
		icon_state = "paper_words"
	else
		icon_state = "paper"

/obj/item/weapon/paper/proc/update_space()
	free_space = initial(free_space)
	free_space -= length(strip_html_properly(info_links)) //using info_links to also count field prompts

/obj/item/weapon/paper/proc/is_clean()
	return free_space == initial(free_space)

/obj/item/weapon/paper/examine(mob/user)
	. = ..()
	if(name != "sheet of paper")
		. += "\nIt's titled '[name]'."
	if(user && (in_range(user, src) || isghost(user)))
		show_content(user)
	else
		. += "\n<span class='notice'>You have to go closer if you want to read it.</span>"

/obj/item/weapon/paper/proc/show_content(mob/user, forceshow)
	var/can_read = (istype(user, /mob/living/carbon/human) || isghost(user) || istype(user, /mob/living/silicon)) || forceshow
	if(!forceshow && istype(user,/mob/living/silicon/ai))
		var/mob/living/silicon/ai/AI = user
		can_read = get_dist(src, AI.camera) < 2
	show_browser(user, "<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[name]</TITLE></HEAD><BODY bgcolor='[color ? color : COLOR_WHITE]' text='[text_color]'>[can_read ? info : stars(info)][stamps]</BODY></HTML>", "window=[name]")
	onclose(user, "[name]")

/obj/item/weapon/paper/verb/rename()
	set name = "Rename paper"
	set category = "Object"
	set src in usr

	if((MUTATION_CLUMSY in usr.mutations) && prob(50))
		to_chat(usr, "<span class='warning'>You cut yourself on the paper.</span>")
		return
	var/n_name = sanitizeSafe(input(usr, "What would you like to label the paper?", "Paper Labelling", null)  as text, MAX_NAME_LEN)

	// We check loc one level up, so we can rename in clipboards and such. See also: /obj/item/weapon/photo/rename()
	if((loc == usr || loc.loc && loc.loc == usr) && usr.stat == 0 && n_name)
		SetName(n_name)
		add_fingerprint(usr)

/obj/item/weapon/paper/attack_self(mob/living/user as mob)
	if(user.a_intent == I_HURT)
		if(icon_state == "scrap")
			user.show_message("<span class='warning'>\The [src] is already crumpled.</span>")
			return
		//crumple dat paper
		info = stars(info,85)
		user.visible_message("\The [user] crumples \the [src] into a ball!")
		icon_state = "scrap"
		throw_range = 7
		throw_speed = 2
		return
	user.examinate(src)
	if(rigged && (Holiday == "April Fool's Day"))
		if(!spam_flag)
			spam_flag = TRUE
			playsound(loc, 'sound/items/bikehorn.ogg', 50, 1)
			spawn(20)
				spam_flag = FALSE

/obj/item/weapon/paper/attack_ai(mob/living/silicon/ai/user)
	show_content(user)

/obj/item/weapon/paper/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	if(user.zone_sel.selecting == BP_EYES)
		user.visible_message("<span class='notice'>You show the paper to [M]. </span>", \
			"<span class='notice'> [user] holds up a paper and shows it to [M]. </span>")
		M.examinate(src)

	else if(user.zone_sel.selecting == BP_MOUTH) // lipstick wiping
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H == user)
				to_chat(user, "<span class='notice'>You wipe off the lipstick with [src].</span>")
				H.lip_style = null
				H.update_body()
			else
				user.visible_message("<span class='warning'>[user] begins to wipe [H]'s lipstick off with \the [src].</span>", \
								 	 "<span class='notice'>You begin to wipe off [H]'s lipstick.</span>")
				if(do_after(user, 10, H) && do_after(H, 10, needhand = 0))	//user needs to keep their active hand, H does not.
					user.visible_message("<span class='notice'>[user] wipes [H]'s lipstick off with \the [src].</span>", \
										 "<span class='notice'>You wipe off [H]'s lipstick.</span>")
					H.lip_style = null
					H.update_body()

/obj/item/weapon/paper/proc/addtofield(id, text, terminate = FALSE)
	var/token = "<!--paper_field_[id]-->"
	var/token_link = "<font face=\"[deffont]\"><A href='?src=\ref[src];write=[id]'>write</A></font>"
	var/text_with_links = field_regex.Replace(text, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=$1'>write</A></font>")
	text_with_links = sign_field_regex.Replace(text_with_links, " <I><A href='?src=\ref[src];signfield=$1'>sign here</A></I> ")
	info = replacetext(info, token, "[text][terminate ? "" : token]")
	info_links = replacetext(info_links, token_link, "[text_with_links][terminate ? "" : token_link]")


/obj/item/weapon/paper/proc/generateinfolinks()
	info_links = info
	if (readonly)
		return

	info_links = field_regex.Replace(info_links, "<font face=\"[deffont]\"><A href='?src=\ref[src];write=$1'>write</A></font>")
	info_links = sign_field_regex.Replace(info_links, " <I><A href='?src=\ref[src];signfield=$1'>sign here</A></I> ")

	if (appendable)
		info += "<!--paper_field_end-->"
		info_links += "<font face=\"[deffont]\"><A href='?src=\ref[src];write=end'>write</A></font>"

/obj/item/weapon/paper/proc/migrateinfolinks(from)
	info_links = replacetext(info_links, "\ref[from]", "\ref[src]")

/obj/item/weapon/paper/proc/make_readonly()
	if (readonly)
		return
	info_links = field_link_regex.Replace(info_links, "")
	readonly = TRUE

/obj/item/weapon/paper/proc/clearpaper()
	info = null
	stamps = null
	free_space = MAX_PAPER_MESSAGE_LEN
	stamped = list()
	overlays.Cut()
	generateinfolinks()
	update_icon()

/obj/item/weapon/paper/proc/get_signature(obj/item/weapon/pen/P, mob/user, signfield)
	if(P && istype(P, /obj/item/weapon/pen))
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

/obj/item/weapon/paper/proc/parsepencode(t, obj/item/weapon/pen/P, mob/user, iscrayon, isfancy, is_init = FALSE)
	if(length(t) == 0)
		return ""

	if(findtext(t, "\[sign\]"))
		t = replacetext(t, "\[sign\]", "<font face=\"[signfont]\"><i>[get_signature(P, user)]</i></font>")

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

	if(iscrayon)
		t = "<font face=\"[crayonfont]\" color=[P ? P.colour : COLOR_BLACK]><b>[t]</b></font>"
	else if(isfancy)
		t = "<font face=\"[fancyfont]\" color=[P ? P.colour : COLOR_BLACK]><i>[t]</i></font>"
	else
		t = "<font face=\"[deffont]\" color=[P ? P.colour : COLOR_BLACK]>[t]</font>"

	t = pencode2html(t)

	return t

/obj/item/weapon/paper/proc/parse_named_fields()
	var/list/matches = list()
	named_field_extraction_regex.next = 1
	while (named_field_extraction_regex.Find(info))
		matches[named_field_extraction_regex.group[1]] = named_field_extraction_regex.group[2]
	return matches

/obj/item/weapon/paper/proc/burnpaper(obj/item/weapon/flame/P, mob/user)
	var/class = "warning"

	if(P.lit && !user.restrained())
		if(istype(P, /obj/item/weapon/flame/lighter/zippo))
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
				to_chat(user, "<span class='warning'>You must hold \the [P] steady to burn \the [src].</span>")


/obj/item/weapon/paper/proc/get_pen()
	var/obj/item/i = usr.get_active_hand()
	if(istype(i, /obj/item/weapon/pen))
		return i
	if(usr.back && istype(usr.back,/obj/item/weapon/rig))
		var/obj/item/weapon/rig/r = usr.back
		var/obj/item/rig_module/device/pen/m = locate(/obj/item/rig_module/device/pen) in r.installed_modules
		if(!r.offline && m)
			return m.device
		else
			return
	else
		return

/obj/item/weapon/paper/proc/check_proximity()
	// if paper is not in usr, then it must be near them, or in a clipboard or folder, which must be in or near usr
	return !(src.loc != usr && !src.Adjacent(usr)\
		&& !((istype(src.loc, /obj/item/weapon/clipboard) || istype(src.loc, /obj/item/weapon/folder))\
		&& (src.loc.loc == usr || src.loc.Adjacent(usr)) ) )


/obj/item/weapon/paper/Topic(href, href_list)
	..()
	if(!usr || (usr.stat || usr.restrained()))
		return
	if (href_list["signfield"])
		var/signfield = href_list["signfield"]
		var/obj/item/weapon/pen/P = get_pen()
		if (!P || !check_proximity())
			return
		var/signfield_name
		if (copytext(signfield, 1, 2) == "N")
			signfield_name = copytext(signfield, 2)

		var/signature = get_signature(P, usr, signfield_name)
		if(istype(P, /obj/item/weapon/pen/crayon))
			signature = "<b>[signature]</b>"
		info = replacetext(info, "<I><span class='sign_field_[signfield]'>sign here</span></I>", "<font face=\"[signfont]\" color=[P.colour]><i>[signature]</i></font>")
		info_links = replacetext(info_links, "<I><A href='?src=\ref[src];signfield=[signfield]'>sign here</A></I>", "<font face=\"[signfont]\" color=[P.colour]><i>[signature]</i></font>")
		update_space()
		show_browser(usr, "<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[name]</TITLE></HEAD><BODY bgcolor='[color]'>[info_links][stamps]</BODY></HTML>", "window=[name]") // Update the window
		return
	if(href_list["write"])
		if (readonly)
			to_chat(usr, SPAN("warning", "Your pen fails to leave any trace on \the [src]!"))
			return
		var/id = href_list["write"]
		//var/t = strip_html_simple(input(usr, "What text do you wish to add to " + (id=="end" ? "the end of the paper" : "field "+id) + "?", "[name]", null),8192) as message

		if(free_space <= 0)
			to_chat(usr, "<span class='info'>There isn't enough space left on \the [src] to write anything.</span>")
			return

		var/t =  sanitize(input("Enter what you want to write:", "Write", null, null) as message, free_space, extra = 0, trim = 0)

		if(!t)
			return

		var/obj/item/i = get_pen()
		if (!i)
			return
		var/iscrayon = 0
		var/isfancy = 0

		if(istype(i, /obj/item/weapon/pen/crayon))
			iscrayon = 1

		if(istype(i, /obj/item/weapon/pen/fancy))
			isfancy = 1

		if (!check_proximity())
			return

		if (counttext(t, @"[field]") > 50)
			to_chat(usr, SPAN("warning", "Too many fields. Sorry, you can't do this."))
			return

		t = parsepencode(t, i, usr, iscrayon, isfancy) // Encode everything from pencode to html

		var/terminated = FALSE
		if (findtext(t, @"[end]"))
			t = replacetext(t, @"[end]", "")
			terminated = TRUE

		addtofield(id, t, terminated) // He wants to edit a field, let him.
		if (id == "end" && terminated)
			appendable = FALSE

		update_space()

		show_browser(usr, "<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[name]</TITLE></HEAD><BODY bgcolor='[color]'>[info_links][stamps]</BODY></HTML>", "window=[name]") // Update the window

		update_icon()


/obj/item/weapon/paper/attackby(obj/item/weapon/P as obj, mob/user as mob)
	..()
	var/clown = FALSE
	if(user.mind && (user.mind.assigned_role == "Clown"))
		clown = TRUE

	if(istype(P, /obj/item/weapon/tape_roll))
		var/obj/item/weapon/tape_roll/tape = P
		tape.stick(src, user)
		return

	if(istype(P, /obj/item/weapon/paper) || istype(P, /obj/item/weapon/photo))
		if (istype(P, /obj/item/weapon/paper/carbon))
			var/obj/item/weapon/paper/carbon/C = P
			if (!C.iscopy && !C.copied)
				to_chat(user, "<span class='notice'>Take off the carbon copy first.</span>")
				add_fingerprint(user)
				return
		var/obj/item/weapon/paper_bundle/B = new(src.loc)
		if (name != "paper")
			B.SetName(name)
		else if (P.name != "paper" && P.name != "photo")
			B.SetName(P.name)

		user.drop_from_inventory(P)
		user.drop_from_inventory(src)
		user.put_in_hands(B)
		src.forceMove(B)
		P.forceMove(B)

		to_chat(user, "<span class='notice'>You clip the [P.name] to [(src.name == "paper") ? "the paper" : src.name].</span>")

		B.pages.Add(src)
		B.pages.Add(P)
		B.update_icon()

	else if(istype(P, /obj/item/weapon/pen))
		if(icon_state == "scrap")
			to_chat(usr, "<span class='warning'>\The [src] is too crumpled to write on.</span>")
			return

		var/obj/item/weapon/pen/robopen/RP = P
		if ( istype(RP) && RP.mode == 2 )
			RP.RenamePaper(user,src)
		else
			show_browser(user, "<HTML><meta charset=\"utf-8\"><HEAD><TITLE>[name]</TITLE></HEAD><BODY bgcolor='[color]'>[info_links][stamps]</BODY></HTML>", "window=[name]")
		return

	else if(istype(P, /obj/item/weapon/stamp) || istype(P, /obj/item/clothing/ring/seal))
		if((!in_range(src, usr) && loc != user && !( istype(loc, /obj/item/weapon/clipboard) ) && loc.loc != user && user.get_active_hand() != P))
			return

		stamps += (stamps=="" ? "<HR>" : "<BR>") + "<i>This paper has been stamped with the [P.name].</i>"

		var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
		var/x
		var/y
		if(istype(P, /obj/item/weapon/stamp/captain) || istype(P, /obj/item/weapon/stamp/centcomm))
			x = rand(-2, 0)
			y = rand(-1, 2)
		else
			x = rand(-2, 2)
			y = rand(-3, 2)
		offset_x += x
		offset_y += y
		stampoverlay.pixel_x = x
		stampoverlay.pixel_y = y

		if(istype(P, /obj/item/weapon/stamp/clown))
			if(!clown)
				to_chat(user, "<span class='notice'>You are totally unable to use the stamp. HONK!</span>")
				return

		if(!ico)
			ico = new
		ico += "paper_[P.icon_state]"
		stampoverlay.icon_state = "paper_[P.icon_state]"

		if(!stamped)
			stamped = new
		stamped += P.type
		overlays += stampoverlay

		to_chat(user, "<span class='notice'>You stamp the paper with your [P.name].</span>")

	else if(istype(P, /obj/item/weapon/flame))
		burnpaper(P, user)

	else if(istype(P, /obj/item/weapon/paper_bundle))
		var/obj/item/weapon/paper_bundle/attacking_bundle = P
		attacking_bundle.insert_sheet_at(user, (attacking_bundle.pages.len)+1, src)
		attacking_bundle.update_icon()

	else if(istype(P, /obj/item/weapon/reagent_containers/food/snacks/grown))
		var/obj/item/weapon/reagent_containers/food/snacks/grown/G = P
		if(!G.dry)
			to_chat(user, SPAN("notice", "[G] must be dried before you can grind and roll it."))
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
		to_chat(user, SPAN("notice", "You grind \the [G] and roll a big joint!"))
		R.add_fingerprint(user)
		qdel(src)
		qdel(G)
		if(roll_in_hands)
			user.put_in_hands(R)
		return

	add_fingerprint(user)
	return

//For supply.
/obj/item/weapon/paper/manifest
	name = "supply manifest"
	var/is_copy = TRUE
