/obj/structure/curtain
	name = "curtain"
	icon = 'icons/obj/curtain.dmi'
	icon_state = "closed"
	layer = ABOVE_HUMAN_LAYER
	opacity = 1
	density = 0
	breakable = TRUE

/obj/structure/curtain/open
	icon_state = "open"

	opacity = 0

/obj/structure/curtain/bullet_act(obj/item/projectile/P, def_zone)
	if(!P.nodamage)
		visible_message("<span class='warning'>[P] tears [src] down!</span>")
		qdel(src)
	else
		..(P, def_zone)

/obj/structure/curtain/attack_hand(mob/user)
	playsound(loc, SFX_SEARCH_CLOTHES, 15, 1, -5)
	toggle()
	..()

/obj/structure/curtain/attackby(obj/item/W, mob/user)
	if(isWrench(W))
		user.visible_message("[user] dissassembles [src].", "You start to dissassemble [src].")
		playsound(src.loc, 'sound/items/Ratchet.ogg', 100, 1)
		if(do_after(user, 40, src))
			if(!src)
				return
			to_chat(user,  SPAN_NOTICE("You dissasembled [src]!"))
			new /obj/item/stack/material/plastic(src.loc, 4)
			qdel(src)
	return ..()

/obj/structure/curtain/proc/toggle()
	set_opacity(!opacity)
	if(opacity)
		icon_state = "closed"

	else
		icon_state = "open"

/obj/structure/curtain/black
	name = "black curtain"
	color = "#222222"

/obj/structure/curtain/green
	name = "green curtain"
	color = "#465735"

/obj/structure/curtain/medical
	name = "plastic curtain"
	color = "#b8f5e3"
	alpha = 200

/obj/structure/curtain/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/open/privacy
	name = "privacy curtain"
	color = "#b8f5e3"

/obj/structure/curtain/open/shower
	name = "shower curtain"
	color = "#acd1e9"
	alpha = 200

/obj/structure/curtain/open/shower/engineering
	color = "#ffa500"

/obj/structure/curtain/open/shower/security
	color = "#aa0000"
