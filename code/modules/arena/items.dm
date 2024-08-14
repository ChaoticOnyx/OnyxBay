/datum/ghost_arena_item
	var/name = "item name"
	var/category = "item category"
	var/item_path = null
	var/price = 0
	var/reward_per_kill

	//Used to create images for radial menu
	var/icon = 'icons/obj/guns/gun.dmi'
	var/icon_state = null

/datum/ghost_arena_item/pistol
	name = "Pistols"

	icon_state = "VP78"

/datum/ghost_arena_item/pistol/cheap_pistol
	name = "Pistol"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/cheap_pistol
	price = 150

	icon_state = "VP78"

/datum/ghost_arena_item/pistol/laser
	name = "Laser pistol"
	item_path = /obj/item/gun/energy/laser/pistol/arenapistol
	price = 250

	icon_state = "laser_pistol"

/datum/ghost_arena_item/pistol/mateba
	name = "Mateba"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/mateba
	price = 500

	icon_state = "colt-python"

/datum/ghost_arena_item/heavy
	name = "Rifles"

	icon_state = "c20r"

/datum/ghost_arena_item/heavy/laser
	name = "Laser Rifle"
	item_path = /obj/item/gun/energy/laser/arenarifle
	price = 600

	icon_state = "laser"

/datum/ghost_arena_item/heavy/shotgun
	name = "Combat Shotgun"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/shotgun
	price = 600

	icon_state = "cshotgun"

/datum/ghost_arena_item/heavy/smg
	name = "SMG"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/smg
	price = 250

	icon_state = "wt550"

/datum/ghost_arena_item/heavy/saw
	name = "L6 SAW"
	item_path = /obj/item/gun/projectile/automatic/l6_saw
	price = 800

	icon_state = "l6closed5"

/datum/ghost_arena_item/heavy/sniper
	name = "AWP"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/ptr
	price = 1000

	icon_state = "heavysniper"

/datum/ghost_arena_item/melee
	name = "Melee"

	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"

/datum/ghost_arena_item/melee/extinguisher
	name = "Petushitel"
	item_path = /obj/item/extinguisher
	price = 0

	icon = 'icons/obj/items.dmi'
	icon_state = "fire_extinguisher0"

/datum/ghost_arena_item/melee/esword
	name = "Energy Sword"
	item_path = /obj/item/melee/energy/sword/one_hand
	price = 3000

	icon = 'icons/obj/weapons.dmi'
	icon_state = "swordred"

/datum/ghost_arena_item/utility
	name = "Utility"

	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"

/datum/ghost_arena_item/utility/shield
	name = "Shield"
	item_path = /obj/item/shield/riot
	price = 300

	icon = 'icons/obj/weapons.dmi'
	icon_state = "riot"

/datum/ghost_arena_item/utility/frag
	name = "Frag"
	item_path = /obj/item/grenade/frag
	price = 100

	icon = 'icons/obj/grenade.dmi'
	icon_state = "frggrenade"

/datum/ghost_arena_item/utility/flash
	name = "Flashbang"
	item_path = /obj/item/grenade/flashbang
	price = 50

	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"

/datum/ghost_arena_item/utility/smoke
	name = "Smoke"
	item_path = /obj/item/grenade/smokebomb
	price = 50

	icon = 'icons/obj/grenade.dmi'
	icon_state = "flashbang"

/datum/ghost_arena_item/armor
	name = "Armors"

	icon = 'icons/obj/clothing/suits.dmi'
	icon_state = "onyxvest"

/datum/ghost_arena_item/armor/default
	name = "Armor"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/armor
	price = 200

	icon_state = "onyxvest"

/datum/ghost_arena_item/armor/heavy
	name = "Heavy armor"
	item_path = /obj/item/storage/briefcase/ghost_arena_case/armor_heavy
	price = 3000

	icon_state = "heavy"

/*
* Arena-specific items
*/

/obj/item/clothing/suit/armor/vest/arenavest
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS

/obj/item/gun/projectile/pistol/vp78/arenavp78
	magazine_type = /obj/item/ammo_magazine/c45m

/obj/item/gun/energy/laser/pistol/arenapistol
	max_shots = 18

/obj/item/gun/energy/laser/arenarifle
	max_shots = 24

/obj/item/gun/projectile/automatic/wt550/arenasmg
	magazine_type = /obj/item/ammo_magazine/mc9mmt

/obj/item/gun/projectile/heavysniper/arenaptr
	ammo_type = /obj/item/ammo_casing/a145/arena145

/obj/item/ammo_casing/a145/arena145
	projectile_type = /obj/item/projectile/bullet/rifle/a145/arena145

/obj/item/projectile/bullet/rifle/a145/arena145
	damage = 160

/obj/item/storage/briefcase/ghost_arena_case
	max_w_class = ITEM_SIZE_SMALL
	w_class = ITEM_SIZE_SMALL
	icon_state = "box"

/obj/item/storage/briefcase/ghost_arena_case/Initialize()
	. = ..()
	make_exact_fit()

/obj/item/storage/briefcase/ghost_arena_case/cheap_pistol
	startswith = list(
		/obj/item/gun/projectile/pistol/vp78/arenavp78,
		/obj/item/ammo_magazine/c45m = 3
	)

/obj/item/storage/briefcase/ghost_arena_case/mateba
	startswith = list(
		/obj/item/gun/projectile/revolver/coltpython,
		/obj/item/ammo_magazine/a357
	)

/obj/item/storage/briefcase/ghost_arena_case/shotgun
	startswith = list(
		/obj/item/gun/projectile/shotgun/pump/combat/hos,
		/obj/item/ammo_casing/shotgun/pellet = 10,
		/obj/item/ammo_casing/shotgun = 10
	)

/obj/item/storage/briefcase/ghost_arena_case/smg
	startswith = list(
		/obj/item/gun/projectile/automatic/wt550/arenasmg,
		/obj/item/ammo_magazine/mc9mmt
	)

/obj/item/storage/briefcase/ghost_arena_case/ptr
	startswith = list(
		/obj/item/gun/projectile/heavysniper/arenaptr,
		/obj/item/ammo_casing/a145/arena145 = 7
	)

/obj/item/storage/briefcase/ghost_arena_case/armor
	startswith = list(
		/obj/item/clothing/suit/armor/vest/arenavest,
		/obj/item/clothing/head/helmet
	)

/obj/item/storage/briefcase/ghost_arena_case/armor_heavy
	startswith = list(
		/obj/item/clothing/suit/armor/heavy,
		/obj/item/clothing/head/helmet/swat
	)
