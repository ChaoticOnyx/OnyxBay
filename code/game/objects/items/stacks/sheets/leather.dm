/obj/item/stack/material/animalhide
	drop_sound = SFX_DROP_CLOTH
	pickup_sound = SFX_PICKUP_CLOTH

/obj/item/stack/material/animalhide/human
	name = "human skin"
	desc = "The by-product of human farming."
	singular_name = "human skin piece"
	icon_state = "hide"

/obj/item/stack/material/animalhide/corgi
	name = "corgi hide"
	desc = "The by-product of corgi farming."
	singular_name = "corgi hide piece"
	icon_state = "corgi"

/obj/item/stack/material/animalhide/cat
	name = "cat hide"
	desc = "The by-product of cat farming."
	singular_name = "cat hide piece"
	icon_state = "cat"

/obj/item/stack/material/animalhide/monkey
	name = "monkey hide"
	desc = "The by-product of monkey farming."
	singular_name = "monkey hide piece"
	icon_state = "monkey"

/obj/item/stack/material/animalhide/lizard
	name = "lizard skin"
	desc = "Sssssss..."
	singular_name = "lizard skin piece"
	icon_state = "lizard"

/obj/item/stack/material/animalhide/xeno
	name = "alien hide"
	desc = "The skin of a terrible creature."
	singular_name = "alien hide piece"
	icon_state = "xeno"

/obj/item/stack/material/animalhide/goat
	default_type = "goat hide"
	name = "goat hide"
	desc = "A goat hide."
	singular_name = "goat hide piece"
	icon_state = "goatskin"

// don't see anywhere else to put these, maybe together they could be used to make the xenos suit?
/obj/item/stack/material/xenochitin
	name = "alien chitin"
	desc = "A piece of the hide of a terrible creature."
	singular_name = "alien hide piece"
	icon = 'icons/mob/alien.dmi'
	icon_state = "chitin"

/obj/item/xenos_claw
	name = "alien claw"
	desc = "The claw of a terrible creature."
	icon = 'icons/mob/alien.dmi'
	icon_state = "claw"

/obj/item/weed_extract
	name = "weed extract"
	desc = "A piece of slimy, purplish weed."
	icon = 'icons/mob/alien.dmi'
	icon_state = "weed_extract"

/obj/item/stack/material/hairlesshide
	default_type = "hairless hide"
	name = "hairless hide"
	desc = "This hide was stripped of it's hair, but still needs tanning."
	singular_name = "hairless hide piece"
	icon_state = "hairlesshide"

/obj/item/stack/material/wetleather
	name = "wet leather"
	desc = "This leather has been cleaned but still needs to be dried."
	singular_name = "wet leather piece"
	icon_state = "wetleather"
	var/wetness = 30 //Reduced when exposed to high temperautres
	var/drying_threshold_temperature = 500 //Kelvin to start drying

//Step one - dehairing.
/obj/item/stack/material/animalhide/attackby(obj/item/W as obj, mob/user as mob)
	if(	istype(W, /obj/item/material/knife) || \
		istype(W, /obj/item/material/kitchen/utensil/knife) || \
		istype(W, /obj/item/material/twohanded/fireaxe) || \
		istype(W, /obj/item/material/hatchet) )

		//visible message on mobs is defined as visible_message(var/message, var/self_message, var/blind_message)
		usr.visible_message("<span class='notice'>\The [usr] starts cutting hair off \the [src]</span>", "<span class='notice'>You start cutting the hair off \the [src]</span>", "You hear the sound of a knife rubbing against flesh")
		if(do_after(user, 50, luck_check_type = LUCK_CHECK_ENG))
			to_chat(usr, "<span class='notice'>You cut the hair from this [src.singular_name]</span>")
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/material/hairlesshide/HS in usr.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/material/hairlesshide/HS = new(usr.loc)
			HS.amount = 1
			src.use(1)
	else
		..()


//Step two - washing..... it's actually in washing machine code.

//Step three - drying
/obj/item/stack/material/wetleather/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature >= drying_threshold_temperature)
		wetness--
		if(wetness == 0)
			//Try locating an exisitng stack on the tile and add to there if possible
			for(var/obj/item/stack/material/leather/HS in src.loc)
				if(HS.amount < 50)
					HS.amount++
					src.use(1)
					wetness = initial(wetness)
					break
			//If it gets to here it means it did not find a suitable stack on the tile.
			var/obj/item/stack/material/leather/HS = new(src.loc)
			HS.amount = 1
			wetness = initial(wetness)
			src.use(1)
