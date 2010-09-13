/*
CONTAINS:
IMPLANT CASE
TRACKER IMPLANT
IMPLANT PAD
FREEDOM IMPLANT
IMPLANTER

*/

/obj/item/weapon/implantcase/proc/update()
	if (src.imp)
		src.icon_state = text("implantcase-[]", src.imp.color)
	else
		src.icon_state = "implantcase-0"
	return

/obj/item/weapon/implantcase/attackby(obj/item/weapon/I as obj, mob/user as mob)
	if (istype(I, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.equipped() != I)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Glass Case- '[]'", t)
		else
			src.name = "Glass Case"
	else
		if (!( istype(I, /obj/item/weapon/implanter) ))
			return
	if (I:imp)
		if ((src.imp || I:imp.implanted))
			return
		I:imp.loc = src
		src.imp = I:imp
		I:imp = null
		src.update()
		I:update()
	else
		if (src.imp)
			if (I:imp)
				return
			src.imp.loc = I
			I:imp = src.imp
			src.imp = null
			update()
			I:update()
	return

/obj/item/weapon/implantcase/tracking/New()

	src.imp = new /obj/item/weapon/implant/tracking( src )
	..()
	return

/obj/item/weapon/implantpad/proc/update()

	if (src.case)
		src.icon_state = "implantpad-1"
	else
		src.icon_state = "implantpad-0"
	return

/obj/item/weapon/implantpad/attack_hand(mob/user as mob)

	if ((src.case && (user.l_hand == src || user.r_hand == src)))
		if (user.hand)
			user.l_hand = src.case
		else
			user.r_hand = src.case
		src.case.loc = user
		src.case.layer = 20
		src.case.add_fingerprint(user)
		src.case = null
		user.update_clothing()
		src.add_fingerprint(user)
		update()
	else
		if (user.contents.Find(src))
			spawn( 0 )
				src.attack_self(user)
				return
		else
			return ..()
	return

/obj/item/weapon/implantpad/attackby(obj/item/weapon/implantcase/C as obj, mob/user as mob)

	if (istype(C, /obj/item/weapon/implantcase))
		if (!( src.case ))
			user.drop_item()
			C.loc = src
			src.case = C
	else
		return
	src.update()
	return

/obj/item/weapon/implantpad/attack_self(mob/user as mob)

	user.machine = src
	var/dat = "<B>Implant Mini-Computer:</B><HR>"
	if (src.case)
		if (src.case.imp)
			if (istype(src.case.imp, /obj/item/weapon/implant/tracking))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Tracking Beacon<BR>
<b>Zone:</b> Spinal Column> 2-5 vertebrae<BR>
<b>Power Source:</b> Nervous System Ion Withdrawl Gradient<BR>
<b>Life:</b> 10 minutes after death of host<BR>
<b>Important Notes:</b> None<BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Continuously transmits low power signal on frequency- Useful for tracking.<BR>
Range: 35-40 meters<BR>
<b>Special Features:</b><BR>
<i>Neuro-Safe</i>- Specialized shell absorbs excess voltages self-destructing the chip if
a malfunction occurs thereby securing safety of subject. The implant will melt and
disintegrate into bio-safe elements.<BR>
<b>Integrity:</b> Gradient creates slight risk of being overcharged and frying the
circuitry. As a result neurotoxins can cause massive damage.<HR>
Implant Specifics:
Frequency (144.1-148.9):
<A href='byond://?src=\ref[src];freq=-10'>-</A>
<A href='byond://?src=\ref[src];freq=-2'>-</A> [format_frequency(T.frequency)]
<A href='byond://?src=\ref[src];freq=2'>+</A>
<A href='byond://?src=\ref[src];freq=10'>+</A><BR>

ID (1-100):
<A href='byond://?src=\ref[src];id=-10'>-</A>
<A href='byond://?src=\ref[src];id=-1'>-</A> [T.id]
<A href='byond://?src=\ref[src];id=1'>+</A>
<A href='byond://?src=\ref[src];id=10'>+</A><BR>"}
			else
				if (istype(src.case.imp, /obj/item/weapon/implant/freedom))
					dat += {"
<b>Implant Specifications:</b><BR>
<b>Name:</b> Freedom Beacon<BR>
<b>Zone:</b> Right Hand> Near wrist<BR>
<b>Power Source:</b> Lithium Ion Battery<BR>
<b>Life:</b> optimum 5 uses<BR>
<b>Important Notes: <font color='red'>Illegal</font></b><BR>
<HR>
<b>Implant Details:</b> <BR>
<b>Function:</b> Transmits a specialized cluster of signals to override handcuff locking
mechanisms<BR>
<b>Special Features:</b><BR>
<i>Neuro-Scan</i>- Analyzes certain shadow signals in the nervous system
<BR>
<b>Integrity:</b> The battery is extremely weak and commonly after injection its
life can drive down to only 1 use.<HR>
No Implant Specifics"}
				else
					dat += "Implant ID not in database"
		else
			dat += "The implant casing is empty."
	else
		dat += "Please insert an implant casing!"
	user << browse(dat, "window=implantpad")
	onclose(user, "implantpad")
	return

/obj/item/weapon/implantpad/Topic(href, href_list)
	..()
	if (usr.stat)
		return
	if ((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))))
		usr.machine = src
		if (href_list["freq"])
			if ((istype(src.case, /obj/item/weapon/implantcase) && istype(src.case.imp, /obj/item/weapon/implant/tracking)))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				T.frequency += text2num(href_list["freq"])
				T.frequency = sanitize_frequency(T.frequency)
		if (href_list["id"])
			if ((istype(src.case, /obj/item/weapon/implantcase) && istype(src.case.imp, /obj/item/weapon/implant/tracking)))
				var/obj/item/weapon/implant/tracking/T = src.case.imp
				T.id += text2num(href_list["id"])
				T.id = min(100, T.id)
				T.id = max(1, T.id)
		if (istype(src.loc, /mob))
			attack_self(src.loc)
		else
			for(var/mob/M in viewers(1, src))
				if (M.client)
					src.attack_self(M)
				//Foreach goto(290)
		src.add_fingerprint(usr)
	else
		usr << browse(null, "window=implantpad")
		return
	return

/obj/item/weapon/implant/proc/hear(message, source as mob)
	return

/obj/item/weapon/implant/proc/trigger(emote, source as mob)
	return

/obj/item/weapon/implant/proc/implanted(source as mob)
	return


/obj/item/weapon/implantcase/death_alarm/New()
	src.imp = new /obj/item/weapon/implant/death_alarm( src )
	..()
	return


/obj/item/weapon/implant/death_alarm/process()
	var/mob/M = src.loc
	if(M.stat == 2)
		var/turf/t = get_turf(M)
		radioalert("[M.name] has died in [t.loc.name]!","[M.name]'s death alarm")
		processing_items.Remove(src)


/obj/item/weapon/implant/death_alarm/implanted(mob/source as mob)
	processing_items.Add(src)


/obj/item/weapon/implant/freedom/New()
	src.uses = rand(1, 5)
	..()
	return

/obj/item/weapon/implant/freedom/trigger(emote, mob/source as mob)
	if (src.uses < 1)
		return 0

	if (emote == src.activation_emote)
		src.uses--
		source << "You feel a faint click."

		if (source.handcuffed)
			var/obj/item/weapon/W = source.handcuffed
			source.handcuffed = null
			if (source.client)
				source.client.screen -= W
			if (W)
				W.loc = source.loc
				dropped(source)
				if (W)
					W.layer = initial(W.layer)


/obj/item/weapon/implant/compressed/trigger(emote, mob/source as mob)
	if (src.scanned == null)
		return 0

	if (emote == src.activation_emote)
		source << "The air glows as \the [src.scanned.name] uncompresses."
		var/turf/t = get_turf(source)
		src.scanned.loc = t
		del src


/obj/item/weapon/implant/freedom/implanted(mob/source as mob)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	source.mind.store_memory("Freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	source << "The implanted freedom implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."

/obj/item/weapon/implant/compressed/implanted(mob/source as mob)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	source.mind.store_memory("Compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	source << "The implanted compressed matter implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."

/obj/item/weapon/implant/timplant/implanted(mob/source as mob)
	src.activation_emote = input("Choose activation emote:") in list("blink", "blink_r", "eyebrow", "chuckle", "twitch_s", "frown", "nod", "blush", "giggle", "grin", "groan", "shrug", "smile", "pale", "sniff", "whimper", "wink")
	source.mind.store_memory("Teleport implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate.", 0, 0)
	source << "The implanted Teleport implant can be activated by using the [src.activation_emote] emote, <B>say *[src.activation_emote]</B> to attempt to activate."

/obj/item/weapon/implant/explosive/implanted(mob/source as mob)
	src.phrase = input("Choose activation phrase:") as text
	usr.mind.store_memory("Explosive implant can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	usr << "The implanted explosive implant can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate."

/obj/item/weapon/implant/vfac/implanted(mob/source as mob)
	src.phrase = input("Choose activation phrase:") as text
	var/virus = input("Choose virus:") in list("The Cold", "Space Rhinovirus")
	switch(virus)
		if("The Cold")
			src.virus =/datum/disease/cold
		if("Space Rhinovirus")
			src.virus = /datum/disease/dnaspread
	//	else if("GBS")
	//		src.virus =/datum/disease/gbs

	usr.mind.store_memory("Viral factory implant can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate.", 0, 0)
	usr << "The implanted viral factory implant can be activated by saying something containing the phrase ''[src.phrase]'', <B>say [src.phrase]</B> to attempt to activate."



/obj/item/weapon/implant/explosive/hear(var/msg)
	if(findtext(msg,src.phrase))
		explosion(find_loc(src), 1, 3, 4, 6, 1)
		var/turf/t = find_loc(src)
		t.hotspot_expose(SPARK_TEMP,125)

/obj/item/weapon/implant/timplant/trigger(emote, mob/source as mob)


	if (emote == src.activation_emote)
		var/list/L = list()
		var/list/areaindex = list()
		if (!locate(/obj/item/device/radio/beacon/traitor) in world)
			source << "Unable to locate suitable beacon."
			return 0
		for(var/obj/item/device/radio/beacon/traitor/R in world)
			var/turf/T = find_loc(R)
			if (!T)	continue
			var/tmpname = T.loc.name
			if(areaindex[tmpname])
				tmpname = "[tmpname] ([++areaindex[tmpname]])"
			else
				areaindex[tmpname] = 1
			L[tmpname] = R
		var/desc = input("Please select a location to lock in.", "Locking Computer") in L
		source.loc = find_loc(L[desc])
		source << "You have used your teleport, and the circuits have burnt out."
		source.contents.Remove(src)




/obj/item/weapon/implant/alien/implanted(mob/source as mob)
	source.contract_disease(new/datum/disease/alien_embryo, 1)
	del src

/obj/item/weapon/implant/vfac/hear(var/msg)


	if(findtext(msg,src.phrase))
		var/datum/disease/virus = new src.virus
		var/mob/m = loc
		m.contract_disease(virus, 1)


/obj/item/weapon/implanter/proc/update()

	if (src.imp)
		src.icon_state = "implanter1"
	else
		src.icon_state = "implanter0"
	return


/obj/item/weapon/implanter/compress/update()
	if (src.imp)
		var/obj/item/weapon/implant/compressed/c = src.imp
		if(!c.scanned)
			src.icon_state = "cimplanter0"
		else
			src.icon_state = "cimplanter1"
	else
		src.icon_state = "cimplanter2"
	return

/obj/item/weapon/implanter/compress/attack(mob/M as mob, mob/user as mob)
	var/obj/item/weapon/implant/compressed/c = src.imp
	if (c.scanned == null)
		user << "Please scan an object with the implanter first."
		return
	..()

/obj/item/weapon/implanter/compress/afterattack(atom/A, mob/user as mob)
	if(istype(A,/obj))
		var/obj/item/weapon/implant/compressed/c = src.imp
		c.scanned = A
		A.loc.contents.Remove(A)
		src.update()


/obj/item/weapon/implanter/attack(mob/target as mob, mob/user as mob)
	spawn(0)
		if(ismob(target))
			for(var/mob/O in viewers(world.view, user))
				if (target != user)
					O.show_message(text("\red <B>[] is trying to implant [] with [src.name]!</B>", user, target), 1)
				else
					O.show_message("\red <B>[user] is trying to inject themselves with [src.name]!</B>", 1)
			if(!do_mob(user, target,60)) return
			for(var/mob/O in viewers(world.view, user))
				if (target != user)
					O.show_message(text("\red [] implants [] with [src.name]!", user, target), 1)
				else
					O.show_message("\red [user] implants themself with [src.name]!", 1)
			src.imp.loc = target
			src.imp.implanted = 1
			src.imp.implanted(target)
			src.imp = null
			src.icon_state = "implanter0"
