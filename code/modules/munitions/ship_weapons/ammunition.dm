/obj/item/ship_weapon/ammunition
	pull_slowdown = PULL_SLOWDOWN_EXTREME
	var/projectile_type = null //What does the projectile look like on the overmap?
	///Type of the volatility component that will be attached if volatility is above 0
	var/volatile_type = /datum/component/volatile
	var/volatility = 0 //Is this ammo likely to go up in flames when hit or burned?
	var/explode_when_hit = FALSE //If the ammo's volatile, can it be detonated by damage? Or just burning it.
	///Some kinds of munitions have different scales of explosion but the same probability for it to happen.
	var/volatility_scale = 1
	var/climb_time = 20 //Time it takes to climb
	var/climb_stun = 20 //Time to be stunned for after climbing
	var/climbable = FALSE //Can you climb on it?
	var/mob/living/climber //Who is climbing on it
	var/no_trolley = FALSE //Can be put on a trolley?

/obj/item/ship_weapon/ammunition/Initialize(mapload)
	. = ..()
	if(volatility > 0)
		AddComponent(volatile_type, volatility, explode_when_hit, volatility_scale)

/obj/item/ship_weapon/ammunition/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!isliving(user))
		return FALSE

	if(!climbable)
		return

	if(!istype(O, /obj/item) || user.get_active_item() != O)
		return

	if(isrobot(user))
		return

	if(!user.drop(O))
		return

	if (O.loc != src.loc)
		step(O, get_dir(O, src))
