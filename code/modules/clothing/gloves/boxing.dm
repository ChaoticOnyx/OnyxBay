/obj/item/clothing/gloves/boxing
	name = "boxing gloves"
	desc = "Because you really needed another excuse to punch your crewmates."
	icon_state = "boxing"
	armor = list(melee = 60, bullet = 30, laser = 50, energy = 15, bomb = 0, bio = 0)

	/// Holder for boxing unarmed attacks with no real damage.
	var/static/datum/unarmed_attack/punch/boxing/attack = /datum/unarmed_attack/punch/boxing
	species_restricted = list("exclude", SPECIES_VOX)

/obj/item/clothing/gloves/boxing/hologloves
	alpha = 180 // Semi-transparent since its a hologram

/obj/item/clothing/gloves/boxing/hologloves/green
	icon_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/hologloves/blue
	icon_state = "boxingblue"

/obj/item/clothing/gloves/boxing/hologloves/yellow
	icon_state = "boxingyellow"


/obj/item/clothing/gloves/boxing/Initialize()
	. = ..()
	if(ispath(attack))
		attack = new attack()

/obj/item/clothing/gloves/boxing/attackby(obj/item/W, mob/user)
	if(isWirecutter(W) || istype(W, /obj/item/scalpel) || isCoil(W))
		to_chat(user, SPAN("notice", "That won't work."))//Nope
		return
	..()

/obj/item/clothing/gloves/boxing/green
	icon_state = "boxinggreen"

/obj/item/clothing/gloves/boxing/blue
	icon_state = "boxingblue"

/obj/item/clothing/gloves/boxing/yellow
	icon_state = "boxingyellow"

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"

	item_state_slots = list(
		slot_l_hand_str = "lgloves",
		slot_r_hand_str = "lgloves",
		)

/datum/unarmed_attack/punch/boxing
	attack_verb = list("punched")
	attack_noun = list("fist")
	eye_attack_text = "fingers"
	eye_attack_text_victim = "digits"
	damage = 0

	deal_halloss = 1
