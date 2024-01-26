
/obj/machinery/vending/sovietsoda
	name = "BODA"
	desc = "An old soda vending machine. How could this have got here?"

	icon_state = "sovietsoda"

	vending_sound = SFX_VENDING_GENERIC

	use_vend_state = TRUE
	product_ads = "For Tsar and Country.;Have you fulfilled your nutrition quota today?;Very nice!;We are simple people, for this is all we eat.;If there is a person, there is a problem. If there is no person, then there is no problem."
	idle_power_usage = 211 WATTS //refrigerator - believe it or not, this is actually the average power consumption of a refrigerated vending machine according to NRCan.

	component_types = list(
		/obj/item/vending_cartridge/sovietsoda
		)

	legal = list(
		/obj/item/reagent_containers/vessel/bottle/space_up = 30 // TO-DO: Russian cola can
		)

	illegal = list(
		/obj/item/reagent_containers/vessel/bottle/cola = 20
		)

/obj/machinery/vending/sovietsoda/attack_hand(mob/user)
	if(user.lying || user.stat)
		return TRUE

	if(ishuman(user) && user.a_intent == I_HURT)
		user.visible_message("<b>[user]</b> kicks \the [src]!")
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		user.do_attack_animation(src)
		obj_attack_sound()
		shake_animation(stime = 1)
		if(seconds_electrified != 0)
			shock(user, 100)
		free_drop_lottery()
		return TRUE

	return ..()

/obj/machinery/vending/sovietsoda/take_damage(force)
	free_drop_lottery(force)
	..()

/obj/machinery/vending/sovietsoda/proc/free_drop_lottery(prob = 5)
	if(!prob(prob))
		return
	if(prob(33) && !(stat & (BROKEN|NOPOWER)))
		throw_item()
	else
		var/obj/drop_item = null
		for(var/datum/stored_items/vending_products/R in shuffle(cartridge.product_records))
			drop_item = R.get_product(loc)
			if(drop_item)
				visible_message(SPAN("notice", "\The [src] clunks as \the [drop_item] suddenly drops out of it!"))
				return

/obj/item/vending_cartridge/sovietsoda
	icon_state = "refill_cola"
	build_path = /obj/machinery/vending/sovietsoda
