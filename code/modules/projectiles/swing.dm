
// Projectiles handle too many things to just ignore them and copypaste shitloads of code.
/obj/item/projectile/swing_marker
	name = "attack"
	icon_state = "ion"
	nodamage = TRUE
	blockable = FALSE
	can_ricochet = FALSE
	range = 1

/obj/item/projectile/swing_marker/on_impact(atom/A)
		empulse(A, heavy_effect_range, light_effect_range)
		return 1
