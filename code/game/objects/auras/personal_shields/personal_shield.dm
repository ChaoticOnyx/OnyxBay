//auras for shield effect
/obj/aura/shields/personal_shield
	var/obj/item/device/personal_shield/shield
	name = "personal shield"
/obj/aura/shields/shield_belt
	var/obj/item/weapon/shield/shield_belt/shield
	name = "shield belt"
/obj/aura/shields/New(mob/living/user)
	..()
	playsound(user,'sound/weapons/flash.ogg',35,1)
	to_chat(user,"<span class='notice'>You feel your body prickle as \the [src] comes online.</span>")

/obj/aura/shields/bullet_act(obj/item/projectile/P, def_zone)
	user.visible_message("<span class='warning'>\The [user]'s [src.name] flashes before \the [P] can hit them!</span>")
	new /obj/effect/shield_impact(user.loc)
	playsound(user,'sound/effects/basscannon.ogg',35,1)
	return AURA_FALSE|AURA_CANCEL

/obj/aura/shields/Destroy()
	to_chat(user,"<span class='warning'>\The [src] goes offline!</span>")
	playsound(user,'sound/mecha/internaldmgalarm.ogg',25,1)
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

/obj/aura/shields/personal_shield/Destroy()
	shield = null
	return ..()
/obj/aura/shields/shield_belt/Destroy()
	shield = null
	return ..()