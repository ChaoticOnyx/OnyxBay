/obj/item/gun/energy/accelerator
	name = "accelerator shotgun"
	desc = "A NanoTrasen UPA \"Shepherd\". It synthesizes unstable particles and accelerates them, effectively shooting \"temporary\" bullets without using any ammunition besides electric power."
	icon_state = "phazer"
	item_state = "phazer"
	wielded_item_state = "phazer-wielded"
	icon_rounder = 20
	screen_shake = 1
	slot_flags = SLOT_BACK
	w_class = ITEM_SIZE_HUGE
	force = 12.5
	mod_weight = 1.0
	mod_reach = 0.8
	mod_handy = 1.0
	one_hand_penalty = 2
	max_shots = 8
	origin_tech = list(TECH_COMBAT = 3, TECH_MAGNET = 3, TECH_MATERIAL = 2)
	matter = list(MATERIAL_STEEL = 2000)
	projectile_type = /obj/item/projectile/bullet/pellet/accelerated
	var/pumped = TRUE
	var/recentpump = 0 // to prevent spammage
	fire_sound = 'sound/effects/weapons/energy/kinetic_accel.ogg'

/obj/item/gun/energy/accelerator/consume_next_projectile()
	if(!pumped)
		return null
	. = ..()
	if(.)
		pumped = FALSE

/obj/item/gun/energy/accelerator/attack_self(mob/living/user)
	if(!pumped && world.time > recentpump + 1.5 SECOND)
		recentpump = world.time
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		add_fingerprint(user)
		pumped = TRUE
		playsound(user, 'sound/effects/weapons/energy/kinetic_reload.ogg', 60, FALSE)
		update_icon()

/obj/item/gun/energy/accelerator/update_icon()
	overlays.Cut()
	overlays += image(icon, "[initial(icon_state)]_over[pumped]")
	..()

/obj/item/gun/energy/accelerator/pistol
	name = "accelerator pistol"
	desc = "An experimental NanoTrasen UPA \"Wingman\", based on the famous VP78. While being almost just as powerful as its larger counterpart, it is as small as a regular pistol."
	icon_state = "phazer_pistol"
	item_state = "vp78"
	w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT|SLOT_HOLSTER
	one_hand_penalty = 0
	max_shots = 8
	fire_delay = 5.5
	projectile_type = /obj/item/projectile/bullet/pellet/accelerated/lesser
	wielded_item_state = null
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0
