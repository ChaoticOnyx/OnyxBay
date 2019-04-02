/* Clown Items
 * Contains:
 * 		Banana Peels
 *		Bike Horns
 */

/*
 * Banana Peals
 */
/obj/item/weapon/bananapeel/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living))
		var/mob/living/M = AM
		M.slip("the [src.name]",3)
/*
 * Bike Horns
 */
/obj/item/weapon/bikehorn
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
	throw_speed = 3
	throw_range = 15
	attack_verb = list("HONKED")
	var/spam_flag = 0

/obj/item/weapon/bikehorn/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return

//Oh no
/obj/item/weapon/bikehorn/vuvuzela
	name = "VUVUZELA"
	desc = "RIPS YOUR EARS OFF!!!"
	icon_state = "vuvuzela"
	item_state = "vuvuzela"
	w_class = ITEM_SIZE_NORMAL
	mod_weight = 0.5
	mod_reach = 1.0
	mod_handy = 0.5
	attack_verb = list("HONKED","WORLD CUPPED","FOOTBALLED")

/obj/item/weapon/bikehorn/vuvuzela/attack_self(mob/user as mob)
	if (spam_flag == 0)
		spam_flag = 1
		playsound(src.loc, 'sound/items/AirHorn.ogg', 100, 1)
		src.add_fingerprint(user)
		spawn(20)
			spam_flag = 0
	return