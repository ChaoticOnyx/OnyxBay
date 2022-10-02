/obj/item/gun/projectile/pistol/secgun/MK
	desc = "Similar in both appearance and use of the NT Mk58, the MK pistol is an cheap knock off that preys on the unsuspecting firearm buyers."
	jam_chance = 35

/obj/item/gun/projectile/pistol/silenced/cheap
	desc = "A handgun with an integrated silencer(?). Uses .45 rounds."

/obj/item/gun/projectile/pistol/silenced/cheap/handle_post_fire()
	silenced = prob(50)
	return ..()

/obj/item/gun/projectile/heavysniper/ant
	name = "ant-material rifle"
	desc = "A portable anti-armour rifle fitted with a scope, the HI PTR-7 Rifle was originally designed to used against armoured exosuits. It is capable of punching through windows and non-reinforced walls with ease. Fires armor piercing 14.5mm shells. This replica however fires 9mm rounds."
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	fire_sound = 'sound/effects/weapons/gun/fire_colt.ogg'

/obj/item/gun/energy/laser/dogan
	icon_state = "laser_cheap"
	desc = "This rifle works just as well as a normal rifle. Most of the time." //removed reference to Dogan, since only the merchant is likely to know who that is.

/obj/item/gun/energy/laser/dogan/consume_next_projectile()
	projectile_type = pick(/obj/item/projectile/beam/laser/mid, /obj/item/projectile/beam/lasertag/red, /obj/item/projectile/beam)
	return ..()

/obj/item/gun/projectile/automatic/machine_pistol/mini_uzi/usi
	desc = "An uncommon machine pistol, sometimes refered to as an 'uzi' by the backwater spacers it is often associated with. This one looks especially run-down. Uses .45 rounds."
	jam_chance = 20
	fire_sound = 'sound/effects/weapons/gun/fire_colt2.ogg'
