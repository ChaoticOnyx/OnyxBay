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

	var/string_attached = FALSE
	var/string_color = COLOR_RED
	var/sides = 2

	drop_sound = SFX_DROP_RING
	pickup_sound = SFX_PICKUP_RING

/obj/item/material/coin/set_material(new_material)
	. = ..()
	var/temp_state = "[material.name]_coin"
	if(temp_state in icon_states(icon))
		icon_state = temp_state
	else
		icon_state = "generic_coin"
		color = material.icon_colour

/obj/item/material/coin/attackby(obj/item/W, mob/user)
	if(isCoil(W))
		var/obj/item/stack/cable_coil/CC = W
		if(string_attached)
			to_chat(user, SPAN("notice", "There already is a string attached to this coin."))
			return
		var/new_string_color = CC.color
		if(CC.use(1))
			var/image/string_overlay = image(icon, "coin_string_overlay")
			string_overlay.color = new_string_color
			AddOverlays(string_overlay)
			string_attached = TRUE
			string_color = new_string_color
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
		CC.color = string_color
		CC.update_icon()
		ClearOverlays()
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
	playsound(src, 'sound/items/coinflip.ogg', 50, TRUE)


/obj/item/material/coin/gold
	icon_state = "gold_coin"
	default_material = MATERIAL_GOLD

/obj/item/material/coin/silver
	icon_state = "silver_coin"
	default_material = MATERIAL_SILVER

/obj/item/material/coin/diamond
	icon_state = "diamond_coin"
	default_material = MATERIAL_DIAMOND

/obj/item/material/coin/iron
	icon_state = "iron_coin"
	default_material = MATERIAL_IRON

/obj/item/material/coin/plasma
	icon_state = "plasma_coin"
	default_material = MATERIAL_PLASMA

/obj/item/material/coin/uranium
	icon_state = "uranium_coin"
	default_material = MATERIAL_URANIUM

/obj/item/material/coin/platinum
	icon_state = "platinum_coin"
	default_material = MATERIAL_PLATINUM
