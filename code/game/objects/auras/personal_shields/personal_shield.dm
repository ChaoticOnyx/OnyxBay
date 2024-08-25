/obj/aura/personal_shield
	name = "personal shield"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shield-old"
	layer = BELOW_PROJECTILE_LAYER

/obj/aura/personal_shield/New(mob/living/user)
	..()
	playsound(user,'sound/effects/EMPulse.ogg',35,1)
	new /obj/effect/sparks(user.loc)
	to_chat(user,"<span class='notice'>You feel your body prickle as \the [src] comes online.</span>")

/obj/aura/personal_shield/bullet_act(obj/item/projectile/P, def_zone, mob/A)
	if(user != A)
		user.visible_message("<span class='warning'>\The [user]'s [src.name] flashes before \the [P] can hit them!</span>")
		new /obj/effect/shield_impact(user.loc)
		playsound(user,'sound/effects/bamf.ogg',40,1)
		new /obj/effect/sparks(user.loc)
		return AURA_FALSE|AURA_CANCEL
	else
		user.visible_message("<span class='warning'>\The [user]'s [src.name] flashes reflecting \the [P] back at them!</span>")
		new /obj/effect/shield_impact(user.loc)
		playsound(user,'sound/effects/fighting/energyblock.ogg',40,1)
		new /obj/effect/sparks(user.loc)
		return AURA_FALSE|AURA_CANCEL

/obj/aura/personal_shield/hitby(atom/movable/M, speed, nomsg)
	new /obj/effect/shield_impact(user.loc)
	playsound(user,'sound/effects/bamf.ogg',40,1)
	new /obj/effect/sparks(user.loc)
	return AURA_FALSE|AURA_CANCEL

/obj/aura/personal_shield/Destroy()
	to_chat(user,"<span class='warning'>\The [src] goes offline!</span>")
	playsound(user,'sound/mecha/internaldmgalarm.ogg',25,1)
	new /obj/effect/sparks(user.loc)
	return ..()

/obj/aura/personal_shield/device
	var/obj/item/device/personal_shield/shield

/obj/aura/personal_shield/device/bullet_act(obj/item/projectile/P)
	. = ..()
	if(shield)
		shield.take_charge(P.damage)

/obj/aura/personal_shield/device/New(mob/living/user, user_shield)
	..()
	shield = user_shield

/obj/aura/personal_shield/device/Destroy()
	shield = null
	return ..()
