//auras for shield effect
/obj/aura/shields/personal_shield
	var/obj/item/device/personal_shield/shield
	name = "personal shield"

/obj/aura/shields/shield_belt
	var/obj/item/weapon/shield/shield_belt/shield
	name = "shield belt"
	icon = 'icons/effects/auras.dmi'
	icon_state = "shield"
	mouse_opacity = 0

/obj/aura/shields/New(mob/living/user)
	..()
	playsound(user,'sound/weapons/flash.ogg',35,1)
	to_chat(user, SPAN_NOTICE("You feel your body prickle as \the [src] comes online."))

/obj/aura/shields/bullet_act(obj/item/projectile/P, def_zone)
	user.visible_message(SPAN_DANGER("\The [user]'s [src.name] flashes before \the [P] can hit them!"))
	new /obj/effect/shield_impact(user.loc)
	playsound(user, 'sound/effects/basscannon.ogg',35,1)
	return AURA_FALSE|AURA_CANCEL

/obj/aura/shields/Destroy()
	to_chat(user, SPAN_WARNING("\The [src] goes offline!"))
	playsound(user, 'sound/mecha/internaldmgalarm.ogg',25,1)
	return ..()

/obj/aura/shields/personal_shield/bullet_act()
	. = ..()
	if(shield)
		shield.take_charge()

/obj/aura/shields/shield_belt/bullet_act(obj/item/projectile/P)
	. = ..()
	if(shield)
		shield.take_charge(P)

/obj/aura/shields/personal_shield/New(mob/living/user, user_shield)
	..()
	shield = user_shield

/obj/aura/shields/shield_belt/New(mob/living/user, user_shield)
	..()
	shield = user_shield
	set_light(6,6, "#1271a7")

/obj/aura/shields/personal_shield/Destroy()
	shield = null
	return ..()

/obj/aura/shields/shield_belt/Destroy()
	shield = null
	return ..()
