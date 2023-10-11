/obj/effect/projectile/muzzle
	name = "muzzle flash"
	icon = 'icons/effects/projectiles/muzzle.dmi'

/obj/effect/projectile/muzzle/laser
	name = "laser"
	icon_state = "muzzle_laser"
	light_color = COLOR_RED_LIGHT

/obj/effect/projectile/muzzle/laser/blue
	icon_state = "muzzle_blue"
	light_color = COLOR_BLUE_LIGHT

/obj/effect/projectile/muzzle/laser/omni
	icon_state = "muzzle_omni"
	light_color = COLOR_LUMINOL

/obj/effect/projectile/muzzle/laser/small
	light_max_bright = 0.7
	icon_state = "muzzle_beam_small"

/obj/effect/projectile/muzzle/laser/heavy
	name = "heavy laser"
	icon_state = "muzzle_beam_heavy"

/obj/effect/projectile/muzzle/xray
	name = "xray laser"
	icon_state = "muzzle_xray"
	light_color = "#00cc00"

/obj/effect/projectile/muzzle/pulse
	name = "pulse laser"
	icon_state = "muzzle_u_laser"
	light_color = COLOR_DEEP_SKY_BLUE

/obj/effect/projectile/muzzle/trilaser
	name = "plasma blast"
	icon_state = "muzzle_plasmacutter"
	light_color = COLOR_LUMINOL

/obj/effect/projectile/muzzle/stun
	name = "stun beam"
	icon_state = "muzzle_stun"
	light_color = COLOR_YELLOW

/obj/effect/projectile/muzzle/emitter
	icon_state = "muzzle_emitter"
	light_color = "#00cc00"

/obj/effect/projectile/muzzle/accel
	icon_state = "muzzle_accel"
	light_outer_range = 5
	light_max_bright = 1
	light_color = COLOR_OFF_WHITE

/obj/effect/projectile/muzzle/bullet
	icon_state = "muzzle_bullet"
	light_outer_range = 5
	light_max_bright = 1
	light_color = COLOR_MUZZLE_FLASH
