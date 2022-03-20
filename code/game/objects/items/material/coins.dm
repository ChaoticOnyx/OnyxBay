/*****************************Coin********************************/

/obj/item/material/coin
	icon = 'icons/obj/coins.dmi'
	name = "coin"
	icon_state = ""
	randpixel = 8
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	applies_material_colour = FALSE
	m_overlay = FALSE
	material_amount = 0.2

	force_const = 0
	thrown_force_const = 0
	force_divisor = 0
	thrown_force_divisor = 0

	var/string_attached
	var/sides = 2

/obj/item/material/coin/set_material(new_material)
	. = ..()
	if(material.name in icon_states(icon))
		icon_state = material.name
	else
		icon_state = "generic"
		color = material.icon_colour

/obj/item/material/coin/attackby(obj/item/W, mob/user)
	if(isCoil(W))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, SPAN("notice", "There already is a string attached to this coin."))
			return
		if (CC.use(1))
			overlays += image('icons/obj/items.dmi',"coin_string_overlay")
			string_attached = 1
			to_chat(user, SPAN("notice", "You attach a string to the coin."))
		else
			to_chat(user, SPAN("notice", "This cable coil appears to be empty."))
		return
	else if(isWirecutter(W))
		if(!string_attached)
			..()
			return

		var/obj/item/stack/cable_coil/CC = new /obj/item/stack/cable_coil(user.loc)
		CC.amount = 1
		CC.update_icon()
		overlays.Cut()
		string_attached = null
		to_chat(user, SPAN("notice", "You detach the string from the coin."))
	else ..()

/obj/item/material/coin/attack_self(mob/user)
	var/result = rand(1, sides)
	var/comment = ""
	if(result == 1)
		comment = "tails"
	else if(result == 2)
		comment = "heads"
	user.visible_message(SPAN("notice", "[user] has thrown \the [src]. It lands on [comment]!"), \
						 SPAN("notice", "You throw \the [src]. It lands on [comment]!"))


/obj/item/material/coin/gold
	icon_state = "gold"
	default_material = MATERIAL_GOLD

/obj/item/material/coin/silver
	icon_state = "silver"
	default_material = MATERIAL_SILVER

/obj/item/material/coin/diamond
	icon_state = "diamond"
	default_material = MATERIAL_DIAMOND

/obj/item/material/coin/iron
	icon_state = "iron"
	default_material = MATERIAL_IRON

/obj/item/material/coin/plasma
	icon_state = "plasma"
	default_material = MATERIAL_PLASMA

/obj/item/material/coin/uranium
	icon_state = "uranium"
	default_material = MATERIAL_URANIUM

/obj/item/material/coin/platinum
	icon_state = "platinum"
	default_material = MATERIAL_PLATINUM
