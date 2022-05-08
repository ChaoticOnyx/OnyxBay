
/obj/item/reagent_containers/vessel/can
	volume = 45 //just over one and a half cups
	amount_per_transfer_from_this = 5
	atom_flags = 0 //starts closed
	lid_type = /datum/vessel_lid/can

/obj/item/reagent_containers/vessel/can/attack_self(mob/user)
	if((!reagents || !reagents.total_volume) && trash && user.a_intent != I_HELP)
		if(!ispath(trash, /obj/item/trash/cans))
			return ..()
		to_chat(user, SPAN("notice", "You crush \the [src]."))
		playsound(user.loc, pick('sound/items/cancrush1.ogg', 'sound/items/cancrush2.ogg'), 50, 1)
		user.drop_item()
		var/obj/item/trash/cans/TrashItem = new trash(get_turf(user))
		if(user.a_intent == I_HURT)
			TrashItem.icon_state = "[TrashItem.base_state]2" // Yeah it's ugly but I dont care; I don't wanna make separate types for v-crushed and h-crushed cans nor write an extra proc
		else
			TrashItem.icon_state = TrashItem.base_state
		user.put_in_hands(TrashItem)
		qdel(src)
	else
		return ..()
