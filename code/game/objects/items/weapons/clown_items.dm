/* Clown Items
 * Contains:
 *		Bike Horns and C-Taperecorder
 */

/*
 * Bike Horns
 */
/obj/item/bikehorn
	name = "bike horn"
	desc = "A horn off of a bicycle."
	icon = 'icons/obj/items.dmi'
	icon_state = "bike_horn"
	item_state = "bike_horn"
	throwforce = 3
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.25
	mod_reach = 0.5
	mod_handy = 0.5
	throw_range = 15
	attack_verb = list("HONKED")
	var/spam_flag = 0

/obj/item/bikehorn/attack_self(mob/user)
	if(spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

//Oh no
/obj/item/bikehorn/vuvuzela
	name = "VUVUZELA"
	desc = "RIPS YOUR EARS OFF!!!"
	icon_state = "vuvuzela"
	item_state = "vuvuzela"
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.5
	mod_reach = 1.0
	mod_handy = 0.5
	attack_verb = list("HONKED","WORLD CUPPED","FOOTBALLED")

/obj/item/bikehorn/vuvuzela/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/AirHorn.ogg', 100, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

/obj/item/bikehorn/vuvuzela/traitor 

/obj/item/bikehorn/vuvuzela/traitor/attack_self(mob/user)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/AirHorn.ogg', 100, 1)
		src.add_fingerprint(user)
		if(prob(33))
			for(var/mob/living/carbon/M in ohearers(3, src))
				if(istype(M, /mob/living/carbon/human))
					if(M.get_ear_protection() > 2)
						continue
				M.sleeping = 0
				M.stuttering += 20
				M.ear_deaf += 20
				M.Weaken(3)
				if(prob(30))
					M.Stun(10)
					M.Paralyse(4)
		spawn(50)
			spam_flag = 0
	return

//Ha-ha-ha
/obj/item/device/clowntaperecorder
	var/honk_sound = 'sound/items/sitcom_laugh.ogg'
	name = "clown taperecorder"
	desc = "A funny-looking tiny taperecorder. It smells like bananas."
	icon = 'icons/obj/device.dmi'
	icon_state = "stereo"
	item_state = "stereo"
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	mod_weight = 0.5
	mod_reach = 0.5
	mod_handy = 0.5
	throw_range = 15
	attack_verb = list("HONKED")
	var/spam_flag = 0
	var/active = FALSE
	
/obj/item/device/clowntaperecorder/attack_self(mob/user as mob)
	if(spam_flag)
		to_chat(user, "<span class='warning'>The tape recorder needs a moment to rewind.</span>")
		return
	spam_flag = 1
	playsound(src.loc, honk_sound, 100, 0)
	src.add_fingerprint(user)

	active = !active
	if(active)
		icon_state = "stereo_playing"
	else
		icon_state = "stereo"
		
	update_icon()

	spawn(30)
		if(active)
			active = FALSE
			icon_state = "stereo"
			desc = initial(desc)
		spam_flag = 0

/obj/item/device/clowntaperecorder/verb/change_sound()
	set name = "Change sound"
	set category = "IC"
	set src in usr

	var/mob/M = usr

	if(M.stat || M.incapacitated())
		return

	if(honk_sound == 'sound/items/sitcom_laugh.ogg')
		honk_sound = 'sound/items/ba_dum_tss.ogg'
	else
		honk_sound = 'sound/items/sitcom_laugh.ogg'
