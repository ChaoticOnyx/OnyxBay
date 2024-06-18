/**
 * Common information used by both the hero ship and the fighters/AIs
 */

//The big mac. Coaxial railguns fired by the pilot.

/datum/ship_weapon/mac
	name = "Naval Artillery"
	default_projectile_type = /obj/item/projectile/bullet/mac_round
	burst_size = 1
	fire_delay = 3.5 SECONDS
	range_modifier = 50
	select_alert = SPAN_NOTICE("Naval artillery primed.")
	failure_alert = SPAN_WARNING("DANGER: Launch failure! Naval artillery systems are not loaded.")
	overmap_firing_sounds = list('sound/effects/ship/battleship_gun2.ogg')
	overmap_select_sound = 'sound/effects/ship/mac_ready.ogg'
	screen_shake = 2
	ai_fire_delay = 2 SECONDS

/obj/item/projectile/bullet/mac_round
	icon = 'icons/obj/projectiles_ftl_nsv.dmi'
	icon_state = "railgun"
	name = "artillery round"
	damage = 400
	speed = 1.85

/datum/ship_weapon/mac/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

//Coaxial railguns
/datum/ship_weapon/railgun
	name = "Coaxial railguns"
	default_projectile_type = /obj/item/projectile/bullet/railgun_slug
	burst_size = 1
	fire_delay = 1.5 SECONDS
	range_modifier = 20
	select_alert = SPAN_NOTICE("Charging railgun hardpoints...")
	failure_alert = SPAN_WARNING("DANGER: Launch failure! Railgun systems are not loaded.")
	overmap_firing_sounds = list('sound/effects/ship/railgun_fire.ogg')
	overmap_select_sound = 'sound/effects/ship/mac_hold.ogg'
	screen_shake = 1
	lateral = FALSE
	firing_arc = 45 //Broad side of a barn...
	ai_fire_delay = 5 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_PILOT

/datum/ship_weapon/railgun/valid_target(obj/structure/overmap/source, obj/structure/overmap/target, override_mass_check = FALSE)
	if(!istype(source) || !istype(target))
		return FALSE
	if(!override_mass_check && target.mass <= MASS_TINY) //Alright fighter mains. I'm not THAT much of a bastard. Generally AIs will prefer to not use their MAC for flyswatting.
		return FALSE
	return TRUE

/obj/item/projectile/bullet/railgun_slug
	icon_state = "mac"
	name = "tungsten slug"
	icon = 'icons/obj/projectiles_ftl_nsv.dmi'
	damage = 150
	speed = 1

/datum/ship_weapon/light_cannon
	name = "light autocannon"
	default_projectile_type = /obj/item/projectile/bullet/light_cannon_round
	burst_size = 2
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('sound/effects/fighters/autocannon.ogg')
	select_alert = SPAN_NOTICE("Cannon selected. DRADIS assisted targeting: online.")
	failure_alert = SPAN_WARNING("DANGER: Cannon ammunition reserves are depleted.")
	lateral = FALSE

/obj/item/projectile/bullet/light_cannon_round
	icon_state = "pdc"
	name = "light cannon round"
	icon = 'icons/obj/projectiles_ftl_nsv.dmi'
	damage = 40
	penetration_modifier = 2

/datum/ship_weapon/light_cannon/integrated	//Weapon for ships big enough that autocannon ammo concerns shouldn't matter this much anymore. Changes their class from HEAVY to LIGHT
	name = "integrated light autocannon"
	weapon_class = WEAPON_CLASS_LIGHT

/datum/ship_weapon/heavy_cannon
	name = ".30 cal heavy cannon"
	default_projectile_type = /obj/item/projectile/bullet/heavy_cannon_round
	burst_size = 2
	fire_delay = 0.5 SECONDS
	range_modifier = 10
	overmap_select_sound = 'sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('sound/effects/fighters/BRRTTTTTT.ogg')
	select_alert = SPAN_NOTICE("Cannon selected. DRADIS assisted targeting: online..")
	failure_alert = SPAN_WARNING("DANGER: Cannon ammunition reserves are depleted.")
	lateral = FALSE

/obj/item/projectile/bullet/heavy_cannon_round
	icon_state = "pdc"
	name = "heavy cannon round"
	icon = 'icons/obj/projectiles_ftl_nsv.dmi'
	damage = 30

/datum/ship_weapon/fighter_primary
	name = "Primary Equipment Mount"
	default_projectile_type = /obj/item/projectile/bullet/light_cannon_round //This is overridden anyway
	burst_size = 1
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	overmap_select_sound = 'sound/effects/ship/pdc_start.ogg'
	overmap_firing_sounds = list('sound/effects/fighters/autocannon.ogg')
	select_alert = SPAN_NOTICE("Primary mount selected.")
	failure_alert = SPAN_WARNING("DANGER: Primary mount not responding to fire command.")
	lateral = FALSE
	//special_fire_proc = /obj/structure/overmap/proc/primary_fire

/datum/ship_weapon/fighter_secondary
	name = "Secondary Equipment Mount"
	default_projectile_type = /obj/item/projectile/guided_munition/missile //This is overridden anyway
	burst_size = 1
	fire_delay = 0.5 SECONDS
	range_modifier = 30
	select_alert = SPAN_NOTICE("Secondary mount selected.")
	failure_alert = SPAN_WARNING("DANGER: Secondary mount not responding to fire command.")
	overmap_firing_sounds = list(
		'sound/effects/ship/torpedo.ogg',
		'sound/effects/ship/freespace2/m_shrike.wav',
		'sound/effects/ship/freespace2/m_stiletto.wav',
		'sound/effects/ship/freespace2/m_tsunami.wav',
		'sound/effects/ship/freespace2/m_wasp.wav')
	overmap_select_sound = 'sound/effects/ship/reload.ogg'
	firing_arc = 45 //Broad side of a barn...
	//special_fire_proc = /obj/structure/overmap/proc/secondary_fire
	ai_fire_delay = 1 SECONDS

// You don't ever actually select this. Crew act as gunners.
/datum/ship_weapon/gauss
	name = "Gauss guns"
	default_projectile_type = /obj/item/projectile/bullet/gauss_slug
	burst_size = 2
	fire_delay = 3 SECONDS
	range_modifier = 10
	select_alert = SPAN_NOTICE("Activating gauss weapon systems...")
	failure_alert = SPAN_WARNING("DANGER: Gauss gun systems not loaded.")
	overmap_firing_sounds = list('sound/effects/ship/gauss.ogg')
	overmap_select_sound = 'sound/effects/ship/mac_hold.ogg'
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	miss_chance = 20
	ai_fire_delay = 2 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_SECONDARY_GUNNER

/obj/item/projectile/bullet/gauss_slug
	icon_state = "gaussgun"
	name = "tungsten round"
	icon = 'icons/obj/projectiles_ftl_nsv.dmi'
	damage = 80

/datum/ship_weapon/pdc_mount // .50 cal flavored PDC bullets, which were previously just PDC flavored .50 cal turrets
	name = "PDC"
	default_projectile_type = /obj/item/projectile/bullet/pdc_round
	burst_size = 3
	fire_delay = 0.25 SECONDS
	range_modifier = 10
	select_alert = SPAN_NOTICE("Activating point defense system...")
	failure_alert = SPAN_WARNING("DANGER: point defense system not loaded.")
	overmap_firing_sounds = list('sound/effects/ship/pdc.ogg','sound/effects/ship/pdc2.ogg','sound/effects/ship/pdc3.ogg')
	overmap_select_sound = 'sound/effects/ship/mac_hold.ogg'
	weapon_class = WEAPON_CLASS_LIGHT //AIs can fire light weaponry like this for free.
	miss_chance = 33
	max_miss_distance = 6
	ai_fire_delay = 0.5 SECONDS
	allowed_roles = OVERMAP_USER_ROLE_PILOT | OVERMAP_USER_ROLE_GUNNER
	var/sound/lastsound // Special PDC sound handling

/obj/item/projectile/bullet/pdc_round
	icon_state = "pdc"
	name = "PDC round"
	icon = 'icons/obj/projectiles_ftl_nsv.dmi'
	damage = 15

/datum/ship_weapon/pdc_mount/New()
	..()
	lastsound = pick(overmap_firing_sounds)

// only change our firing sound if we haven't been firing for our fire delay + one second
/datum/ship_weapon/pdc_mount/weapon_sound()
	set waitfor = FALSE
	if(world.time > next_firetime + fire_delay + 10)
		lastsound = pick(overmap_firing_sounds)
	holder.relay(lastsound)
