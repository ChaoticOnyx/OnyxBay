/obj/item/clothing/shoes/black
	name = "black shoes"
	icon_state = "black"
	desc = "A pair of black shoes."

	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

	item_state_slots = list(
		slot_l_hand_str = "bl_shoes",
		slot_r_hand_str = "bl_shoes",
		)

/obj/item/clothing/shoes/brown
	name = "brown shoes"
	desc = "A pair of brown shoes."
	icon_state = "brown"

	item_state_slots = list(
		slot_l_hand_str = "b_shoes",
		slot_r_hand_str = "b_shoes",
		)

/obj/item/clothing/shoes/blue
	name = "blue shoes"
	icon_state = "blue"

/obj/item/clothing/shoes/green
	name = "green shoes"
	icon_state = "green"

/obj/item/clothing/shoes/yellow
	name = "yellow shoes"
	icon_state = "yellow"

/obj/item/clothing/shoes/purple
	name = "purple shoes"
	icon_state = "purple"

/obj/item/clothing/shoes/red
	name = "red shoes"
	desc = "Stylish red shoes."
	icon_state = "red"

	item_state_slots = list(
		slot_l_hand_str = "r_shoes",
		slot_r_hand_str = "r_shoes",
		)

/obj/item/clothing/shoes/white
	name = "white shoes"
	icon_state = "white"
	permeability_coefficient = 0.01

	item_state_slots = list(
		slot_l_hand_str = "w_shoes",
		slot_r_hand_str = "w_shoes",
		)

/obj/item/clothing/shoes/leather
	name = "leather shoes"
	desc = "A sturdy pair of leather shoes."
	icon_state = "leather"

	item_state_slots = list(
		slot_l_hand_str = "leather_shoes",
		slot_r_hand_str = "leather_shoes",
		)

/obj/item/clothing/shoes/rainbow
	name = "rainbow shoes"
	desc = "Very gay shoes."
	icon_state = "rain_bow"

	item_state_slots = list(
		slot_l_hand_str = "r_shoes",
		slot_r_hand_str = "r_shoes",
		)

/obj/item/clothing/shoes/orange
	name = "orange shoes"
	icon_state = "orange"
	force = 0 //nerf brig shoe throwing
	throwforce = 0
	siemens_coefficient = 1  // prisoners shall be scared of tasers
	desc = "A pair of flimsy, cheap shoes. The soles have been made of a soft rubber."
	item_state_slots = list(
		slot_l_hand_str = "o_shoes",
		slot_r_hand_str = "o_shoes",
		)

	var/obj/item/handcuffs/chained = null

/obj/item/clothing/shoes/orange/proc/attach_cuffs(obj/item/handcuffs/cuffs, mob/user as mob)
	if(chained)
		return
	if(!user.drop(cuffs, src))
		return
	chained = cuffs
	slowdown_per_slot[slot_shoes] += 15
	icon_state = "orange1"
	item_state_slots = list(
		slot_l_hand_str = "o_shoes1",
		slot_r_hand_str = "o_shoes1",
		)

/obj/item/clothing/shoes/orange/proc/remove_cuffs(mob/user as mob)
	if(!chained)
		return

	user.pick_or_drop(chained)
	chained.add_fingerprint(user)

	slowdown_per_slot[slot_shoes] -= 15
	icon_state = "orange"
	item_state_slots = list(
		slot_l_hand_str = "o_shoes",
		slot_r_hand_str = "o_shoes",
		)
	chained = null

/obj/item/clothing/shoes/orange/attack_self(mob/user as mob)
	..()
	remove_cuffs(user)

/obj/item/clothing/shoes/orange/attackby(H as obj, mob/user as mob)
	..()
	if (istype(H, /obj/item/handcuffs))
		attach_cuffs(H, user)
