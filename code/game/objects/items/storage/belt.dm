/obj/item/storage/belt
	name = "belt"
	desc = "Can hold various things."
	icon = 'icons/obj/clothing/belts.dmi'
	icon_state = "utilitybelt"
	item_state = "utility"
	storage_slots = 7
	force = 3.5
	mod_reach = 1.2
	mod_handy = 0.5
	mod_weight = 0.4
	item_flags = ITEM_FLAG_IS_BELT
	max_w_class = ITEM_SIZE_NORMAL
	slot_flags = SLOT_BELT
	attack_verb = list("whipped", "lashed", "disciplined")
	use_sound = SFX_SEARCH_CLOTHES

	drop_sound = SFX_DROP_TOOLBELT
	pickup_sound = SFX_PICKUP_TOOLBELT

/obj/item/storage/belt/verb/toggle_layer()
	set name = "Switch Belt Layer"
	set category = "Object"

	use_alt_layer = !use_alt_layer
	update_icon()

/obj/item/storage/on_update_icon()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.update_inv_belt()


/obj/item/storage/belt/get_mob_overlay(mob/user_mob, slot)
	. = ..()

	if(slot == slot_l_hand_str || slot == slot_r_hand_str)
		return

	var/image/ret = .

	if(slot == slot_belt_str && length(contents))
		for(var/obj/item/I in contents)
			ret.AddOverlays(image('icons/inv_slots/belts/mob.dmi', "[I.item_state ? I.item_state : I.icon_state]"))
	return ret

/obj/item/storage/belt/utility
	name = "tool-belt"
	desc = "A belt of durable leather, festooned with hooks, slots, and pouches."
	description_info = "The tool-belt has enough slots to carry a full engineer's toolset: screwdriver, crowbar, wrench, welder, cable coil, and multitool. Simply click the belt to move a tool to one of its slots."
	description_fluff = "Good hide is hard to come by in certain regions of the galaxy. When they can't come across it, most TSCs will outfit their crews with toolbelts made of synthesized leather."
	description_antag = "Only amateurs skip grabbing a tool-belt."
	icon_state = "utilitybelt"
	item_state = "utility"
	can_hold = list(
		///obj/item/combitool,
		/obj/item/crowbar,
		/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/device/multitool,
		/obj/item/device/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/device/t_scanner,
		/obj/item/device/analyzer,
		/obj/item/taperoll/engineering,
		/obj/item/device/robotanalyzer,
		/obj/item/material/minihoe,
		/obj/item/material/hatchet,
		/obj/item/device/analyzer/plant_analyzer,
		/obj/item/taperoll,
		/obj/item/extinguisher/mini,
		/obj/item/marshalling_wand,
		/obj/item/combotool/advtool,
		/obj/item/device/geiger,
		/obj/item/device/lightreplacer,
		/obj/item/device/robotanalyzer
		)


/obj/item/storage/belt/utility/full/New()
	..()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/stack/cable_coil(src,30,pick("red","yellow","orange"))


/obj/item/storage/belt/utility/atmostech/New()
	..()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/wirecutters(src)
	new /obj/item/device/t_scanner(src)

/obj/item/storage/belt/utility/chief/New()
	..()
	new /obj/item/screwdriver/old(src)
	new /obj/item/wrench/old(src)
	new /obj/item/weldingtool/old(src)
	new /obj/item/crowbar/brace_jack(src)
	new /obj/item/wirecutters/old(src)
	new /obj/item/device/t_scanner(src)
	new /obj/item/stack/cable_coil(src, 30, "red")


/obj/item/storage/belt/medical
	name = "medical belt"
	desc = "Can hold various medical equipment."
	icon_state = "medicalbelt"
	item_state = "medical"
	can_hold = list(
		/obj/item/device/healthanalyzer,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/vessel/beaker,
		/obj/item/reagent_containers/vessel/bottle/chemical,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/flame/lighter/zippo,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/device/flashlight/pen,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/head/surgery,
		/obj/item/clothing/gloves/latex,
		/obj/item/reagent_containers/hypospray,
		/obj/item/clothing/glasses/hud/one_eyed,
		/obj/item/crowbar,
		/obj/item/device/flashlight,
		/obj/item/taperoll,
		/obj/item/extinguisher/mini,
		/obj/item/device/antibody_scanner
		)

/obj/item/storage/belt/medical/emt
	name = "EMT utility belt"
	desc = "A sturdy black webbing belt with attached pouches."
	icon_state = "emsbelt"
	item_state = "emsbelt"

/obj/item/storage/belt/security
	name = "security belt"
	desc = "Can hold security gear like handcuffs and flashes."
	icon_state = "securitybelt"
	item_state = "security"
	can_hold = list(
		/obj/item/crowbar,
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/handcuffs,
		/obj/item/device/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_magazine,
		/obj/item/reagent_containers/food/donut/,
		/obj/item/melee/baton,
		/obj/item/gun/energy/taser,
		/obj/item/gun/energy/stunrevolver,
		/obj/item/flame/lighter,
		/obj/item/clothing/glasses/hud,
		/obj/item/device/flashlight,
		/obj/item/device/pda,
		/obj/item/device/radio/headset,
		/obj/item/device/hailer,
		/obj/item/device/megaphone,
		/obj/item/melee,
		/obj/item/gun/projectile/pistol/vp78,
		/obj/item/taperoll,
		/obj/item/device/holowarrant,
		/obj/item/rcd_ammo/magnetic_ammo,
		/obj/item/device/radio,
		/obj/item/material/knife,
		/obj/item/material/butterfly,
		/obj/item/material/hatchet/tacknife,
		/obj/item/cell/ammo/charge
		)

/obj/item/storage/belt/soulstone
	name = "soul stone belt"
	desc = "Designed for ease of access to the shards during a fight, as to not let a single enemy spirit slip away."
	icon_state = "soulstonebelt"
	item_state = "soulstonebelt"
	storage_slots = 6
	can_hold = list(
		/obj/item/device/soulstone
		)

/obj/item/storage/belt/soulstone/full/New()
	..()
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)
	new /obj/item/device/soulstone(src)


/obj/item/storage/belt/champion
	name = "championship belt"
	desc = "Proves to the world that you are the strongest!"
	icon_state = "championbelt"
	item_state = "champion"
	storage_slots = 1
	can_hold = list(
		/obj/item/clothing/mask/luchador
		)

/obj/item/storage/belt/security/tactical
	name = "combat belt"
	desc = "Can hold security gear like handcuffs and flashes, with more pouches for more storage."
	icon_state = "swatbelt"
	item_state = "swatbelt"
	storage_slots = 9

/obj/item/storage/belt/waistpack
	name = "waist pack"
	desc = "A small bag designed to be worn on the waist. May make your butt look big."
	icon_state = "fannypack_white"
	item_state = "fannypack_white"
	storage_slots = null
	max_w_class = ITEM_SIZE_SMALL
	max_storage_space = ITEM_SIZE_SMALL * 4
	slot_flags = SLOT_BELT | SLOT_BACK

/obj/item/storage/belt/waistpack/big
	name = "large waist pack"
	desc = "An bag designed to be worn on the waist. Definitely makes your butt look big."
	icon_state = "fannypack_big_white"
	item_state = "fannypack_big_white"
	w_class = ITEM_SIZE_LARGE
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = ITEM_SIZE_NORMAL * 4

/obj/item/storage/belt/waistpack/big/New()
	..()
	slowdown_per_slot[slot_belt] = 1

/obj/item/storage/belt/mining
	name = "explorer's belt"
	desc = "A versatile chest rig, cherished by miners and hunters alike."
	icon_state = "explorer"
	item_state = "explorer"
	storage_slots = 9
	w_class = 4
	max_w_class = 4 //Pickaxes are big.
	can_hold = list(/obj/item/screwdriver,
		/obj/item/weldingtool,
		/obj/item/wirecutters,
		/obj/item/wrench,
		/obj/item/resonator,
		/obj/item/oreportal,
		/obj/item/oremagnet,
		/obj/item/ore_radar,
		/obj/item/device/flashlight,
		/obj/item/stack/cable_coil,
		/obj/item/stack/flag,
		/obj/item/device/analyzer,
		/obj/item/extinguisher/mini,
		/obj/item/device/radio,
		/obj/item/clothing/gloves,
		/obj/item/clothing/glasses/hud,
		/obj/item/stack/material/animalhide,
		/obj/item/flame/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/reagent_containers/vessel/bottle,
		/obj/item/stack/medical,
		/obj/item/reagent_containers/hypospray,
		/obj/item/device/gps,
		/obj/item/storage/ore,
		/obj/item/reagent_containers/pill,
		/obj/item/storage/pill_bottle,
		/obj/item/ore,
		/obj/item/reagent_containers/vessel/can,
		/obj/item/storage/plants
		)

/obj/item/storage/belt/military
	name = "military belt"
	desc = "A syndicate belt designed to be used by boarding parties. Its style is modeled after the hardsuits they wear."
	icon_state = "militarybelt"
	item_state = "militarybelt"
	storage_slots = 9 //same as a combat belt now
	max_w_class = 3
	max_storage_space  = 28
	can_hold = list(
		/obj/item/grenade,
		/obj/item/handcuffs,
		/obj/item/device/flash,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_magazine,
		/obj/item/melee/baton,
		/obj/item/device/flashlight,
		/obj/item/device/pda,
		/obj/item/device/radio/headset,
		/obj/item/melee,
		/obj/item/shield/energy,
		/obj/item/pinpointer,
		/obj/item/plastique,
		/obj/item/gun/projectile/pistol,
		/obj/item/gun/energy/crossbow,
		/obj/item/ammo_casing/a145,
		/obj/item/device/radio/uplink,
		/obj/item/card/emag,
		/obj/item/device/multitool/hacktool,
		/obj/item/stack/telecrystal,
		/obj/item/material/knife,
		/obj/item/material/butterfly,
		/obj/item/material/hatchet/tacknife,
		/obj/item/cell/ammo/charge
		)

/obj/item/storage/belt/janitor
	name = "janibelt"
	desc = "A belt used to hold most janitorial supplies."
	icon_state = "janibelt"
	item_state = "janibelt"
	storage_slots = 6
	w_class = 3
	max_w_class = 3
	can_hold = list(
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/device/lightreplacer,
		/obj/item/device/flashlight,
		/obj/item/reagent_containers/spray,
		/obj/item/soap,
		/obj/item/storage/bag/trash,
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/crowbar
		)
