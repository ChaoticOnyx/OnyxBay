
/obj/item/clothing/ears/earmuffs
	name = "earmuffs"
	desc = "Protects your hearing from loud noises, and quiet ones as well."
	icon_state = "earmuffs"
	item_state = "earmuffs"
	slot_flags = SLOT_EARS | SLOT_TWOEARS
	ear_protection = 1.5 // Worn on both ears, effectively providing 3 ear protection

/obj/item/clothing/ears/earmuffs/headphones
	name = "headphones"
	desc = "It's probably not in accordance with corporate policy to listen to music on the job... but fuck it."
	var/headphones_on = 0
	icon_state = "headphones_off"
	item_state = "headphones_off"
	slot_flags = SLOT_EARS | SLOT_TWOEARS
	ear_protection = 0

/obj/item/clothing/ears/earmuffs/headphones/verb/togglemusic()
	set name = "Toggle Headphone Music"
	set category = "Object"
	set src in usr

	if(!istype(usr, /mob/living))
		return
	if(usr.incapacitated())
		return

	if(headphones_on)
		icon_state = "headphones_off"
		item_state = "headphones_off"
		headphones_on = 0
		ear_protection = 0.5 // Worn on both ears, effectively providing 1 ear protection
		to_chat(usr, "<span class='notice'>You turn the music off.</span>")
	else
		icon_state = "headphones_on"
		item_state = "headphones_on"
		headphones_on = 1
		ear_protection = 0
		to_chat(usr, "<span class='notice'>You turn the music on.</span>")

	update_clothing_icon()
