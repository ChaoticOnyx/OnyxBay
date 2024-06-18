/obj/item/ship_weapon/parts //Base item
	name = "weapon electronics"
	desc = "This piece of equipment is a figment of your imagination, let the coders know how you got it!"
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/obj/item/ship_weapon/parts/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE

	return ..()

/**
 * Firing electronics - used in construction of <s>new</s> old munitions machinery
 */
/obj/item/ship_weapon/parts/firing_electronics
	name = "firing electronics"
	desc = "The firing circuitry for a large weapon."
	icon = 'icons/obj/module.dmi'
	icon_state = "mcontroller"

/**
 * Railgun loading tray
 */
/obj/item/ship_weapon/parts/loading_tray
	name = "loading tray"
	desc = "A loading tray for a large weapon."
	icon = 'icons/obj/ship_weapons.dmi'
	icon_state = "railgun_tray"

/**
 * Railgun rail
 */
/obj/item/ship_weapon/parts/railgun_rail
	name = "rail"
	desc = "A magnetic rail for a railgun."
	icon = 'icons/obj/ship_weapons.dmi'
	icon_state = "railgun_rail"

/**
 * MAC Barrel
 */
/obj/item/ship_weapon/parts/mac_barrel
	name = "barrel"
	desc = "The barrel for a MAC."
	icon = 'icons/obj/ship_weapons.dmi'
	icon_state = "mac_barrel"

/obj/item/ship_weapon/parts/broadside_casing
	name = "broadside shell casing"
	desc = "An empty casing for the Broadside Cannon. Load it into the Shell Packer!"
	icon = 'icons/obj/munitions.dmi'
	icon_state = "broadside_casing"

/obj/item/ship_weapon/parts/broadside_load
	name = "broadside shell load"
	desc = "A loose load meant for a Broadside shell. Load it into the Shell Packer!"
	icon = 'icons/obj/munitions.dmi'
	icon_state = "broadside_load"
