/obj/machinery/photocopier
	name = "photocopier"
	icon = 'icons/obj/library.dmi'
	icon_state = "bigscanner"
	var/insert_anim = "bigscanner1"
	anchored = 1
	density = 1
	idle_power_usage = 30
	active_power_usage = 200
	power_channel = EQUIP
	atom_flags = ATOM_FLAG_CLIMBABLE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/obj/item/copyitem = null	//what's in the copier!
	var/copies = 1	//how many copies to print!
	var/toner = 30 //how much toner is left! woooooo~
	var/maxcopies = 10	//how many copies can be copied at once- idea shamelessly stolen from bs12's copier!
	var/grayscale = TRUE //if FALSE it'll preserve colors at least on paper
	var/busy = FALSE

/obj/machinery/photocopier/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/photocopier/attack_hand(mob/user as mob)
	user.set_machine(src)

	var/dat = "<meta charset=\"utf-8\">Photocopier<BR><BR>"
	if(copyitem)
		dat += "<a href='byond://?src=\ref[src];remove=1'>Remove Item</a><BR>"
		if(toner)
			dat += "<a href='byond://?src=\ref[src];copy=1'>Copy</a><BR>"
			dat += "Printing: [copies] copies."
			dat += "<a href='byond://?src=\ref[src];min=1'>-</a> "
			dat += "<a href='byond://?src=\ref[src];add=1'>+</a><BR><BR>"
	else if(toner)
		dat += "Please insert something to copy.<BR><BR>"
	if(istype(user,/mob/living/silicon))
		dat += "<a href='byond://?src=\ref[src];aipic=1'>Print photo from database</a><BR><BR>"
	dat += "Current toner level: [toner]"
	if(!toner)
		dat +="<BR>Please insert a new toner cartridge!"
	user << browse(dat, "window=copier")
	onclose(user, "copier")
	return

/obj/machinery/photocopier/proc/busy_check(user)
	if (busy)
		to_chat(user, SPAN_WARNING("[src] is busy!"))
	return busy

/obj/machinery/photocopier/Topic(href, href_list)
	. = ..()
	if (. != TOPIC_NOACTION)
		return
	if (busy_check(usr))
		return
	if(href_list["copy"])
		if(stat & (BROKEN|NOPOWER))
			return

		busy = TRUE
		for(var/i = 0, i < copies, i++)
			if(toner <= 0)
				break
			if(stat & (BROKEN|NOPOWER))
				break
			use_power_oneoff(active_power_usage)
			if (istype(copyitem, /obj/item/weapon/paper))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				copy(copyitem)
				sleep(15)
			else if (istype(copyitem, /obj/item/weapon/photo))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				photocopy(copyitem)
				sleep(15)
			else if (istype(copyitem, /obj/item/weapon/paper_bundle))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				var/obj/item/weapon/paper_bundle/B = bundlecopy(copyitem)
				sleep(15*B.pages.len)
			else if (istype(copyitem, /obj/item/weapon/complaint_folder))
				playsound(src.loc, 'sound/signals/processing20.ogg', 25)
				var/obj/item/weapon/complaint_folder/CF = complaintcopy(copyitem)
				sleep(15 * CF.contents.len)
			else
				to_chat(usr, "<span class='warning'>\The [copyitem] can't be copied by \the [src].</span>")
				break

		updateUsrDialog()
		busy = FALSE
	else if(href_list["remove"])
		if(copyitem)
			copyitem.loc = usr.loc
			usr.put_in_hands(copyitem)
			to_chat(usr, "<span class='notice'>You take \the [copyitem] out of \the [src].</span>")
			copyitem = null
			updateUsrDialog()
	else if(href_list["min"])
		if(copies > 1)
			copies--
			updateUsrDialog()
	else if(href_list["add"])
		if(copies < maxcopies)
			copies++
			updateUsrDialog()
	else if(href_list["aipic"])
		if(!istype(usr,/mob/living/silicon)) return
		if(stat & (BROKEN|NOPOWER)) return

		if(toner >= 5)
			var/mob/living/silicon/tempAI = usr
			var/obj/item/device/camera/siliconcam/camera = tempAI.silicon_camera

			if(!camera)
				return
			var/obj/item/weapon/photo/selection = camera.selectpicture()
			if (!selection)
				return

			var/obj/item/weapon/photo/p = photocopy(selection)
			if (p.desc == "")
				p.desc += "Copied by [tempAI.name]"
			else
				p.desc += " - Copied by [tempAI.name]"
			toner -= 5
			sleep(15)
		updateUsrDialog()

/obj/machinery/photocopier/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/paper) || istype(O, /obj/item/weapon/photo) || istype(O, /obj/item/weapon/paper_bundle) || istype(O, /obj/item/weapon/complaint_folder))
		if(!copyitem)
			user.drop_item()
			copyitem = O
			O.loc = src
			to_chat(user, "<span class='notice'>You insert \the [O] into \the [src].</span>")
			flick(insert_anim, src)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>There is already something in \the [src].</span>")
	else if(istype(O, /obj/item/device/toner))
		if(toner <= 10) //allow replacing when low toner is affecting the print darkness
			user.drop_item()
			to_chat(user, "<span class='notice'>You insert the toner cartridge into \the [src].</span>")
			var/obj/item/device/toner/T = O
			toner += T.toner_amount
			qdel(O)
			updateUsrDialog()
		else
			to_chat(user, "<span class='notice'>This cartridge is not yet ready for replacement! Use up the rest of the toner.</span>")
	else
		..()
	if(O.mod_weight >= 0.75)
		shake_animation(stime = 4)
	return

/obj/machinery/photocopier/ex_act(severity)
	switch(severity)
		if(1.0)
			qdel(src)
		if(2.0)
			if(prob(50))
				qdel(src)
			else
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
		else
			if(prob(50))
				if(toner > 0)
					new /obj/effect/decal/cleanable/blood/oil(get_turf(src))
					toner = 0
	return

/obj/machinery/photocopier/proc/copy(obj/item/weapon/paper/copy, need_toner=1)
	var/obj/item/weapon/paper/c = copy.copy(loc, generate_stamps = FALSE)
	c.recolorize(saturation = Clamp(toner / 30.0, 0.5, 0.94), grayscale = src.grayscale)
	if(need_toner)
		toner--
	if(toner == 0)
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
	c.update_icon()
	return c

/obj/machinery/photocopier/proc/complaintcopy(obj/item/weapon/complaint_folder/copy, need_toner=1)
	var/obj/item/weapon/complaint_folder/CF = copy.copy(loc, generate_stamps = !need_toner)
	if (need_toner)
		var/toner_left = toner
		toner_left = CF.recolorize(saturation = Clamp(toner / 30.0, 0.5, 0.94), grayscale = src.grayscale, amount = toner_left)
		if (toner_left <= 0)
			visible_message(SPAN_NOTICE("A red light on \the [src] flashes, indicating that it is out of toner."))
			toner_left = 0
		toner = toner_left
	return CF

/obj/machinery/photocopier/proc/photocopy(obj/item/weapon/photo/photocopy, need_toner=1)
	var/obj/item/weapon/photo/p = photocopy.copy()
	p.forceMove(get_turf(src))

	if(toner > 10)	//plenty of toner, go straight greyscale
		p.img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))//I'm not sure how expensive this is, but given the many limitations of photocopying, it shouldn't be an issue.
		p.update_icon()
	else			//not much toner left, lighten the photo
		p.img.MapColors(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(100,100,100))
		p.update_icon()
	if(need_toner)
		toner -= 5	//photos use a lot of ink!
	if(toner < 0)
		toner = 0
		visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")

	return p

//If need_toner is 0, the copies will still be lightened when low on toner, however it will not be prevented from printing. TODO: Implement print queues for fax machines and get rid of need_toner
/obj/machinery/photocopier/proc/bundlecopy(obj/item/weapon/paper_bundle/bundle, need_toner=1)
	var/obj/item/weapon/paper_bundle/p = new /obj/item/weapon/paper_bundle (src)
	for(var/obj/item/weapon/W in bundle.pages)
		if(toner <= 0 && need_toner)
			toner = 0
			visible_message("<span class='notice'>A red light on \the [src] flashes, indicating that it is out of toner.</span>")
			break

		if(istype(W, /obj/item/weapon/paper))
			W = copy(W)
		else if(istype(W, /obj/item/weapon/photo))
			W = photocopy(W)
		W.loc = p
		p.pages += W

	p.loc = src.loc
	p.update_icon()
	p.icon_state = "paper_words"
	p.SetName(bundle.name)
	return p

/obj/item/device/toner
	name = "toner cartridge"
	icon_state = "tonercartridge"
	var/toner_amount = 30
