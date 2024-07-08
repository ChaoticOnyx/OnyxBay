/obj/item/storage/toolbox
	name = "toolbox"
	desc = "Bright red toolboxes like these are one of the most common sights in maintenance corridors on virtually every ship in the galaxy."
	description_info = "The toolbox is a general-purpose storage item with lots of space. With an item in your hand, click on it to store it inside."
	description_fluff = "No one remembers which company designed this particular toolbox. It's been mass-produced, retired, brought out of retirement, and counterfeited for decades."
	description_antag = "Carrying one of these and being bald tends to instill a certain primal fear in most people."
	icon_state = "red"
	item_state = "toolbox_red"
	inspect_state = TRUE
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	force = 15
	throwforce = 10
	throw_range = 7
	w_class = ITEM_SIZE_LARGE
	mod_weight = 1.6
	mod_reach = 0.75
	mod_handy = 0.75
	armor_penetration = 20
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_LARGEBOX_STORAGE //enough to hold all starting contents
	origin_tech = list(TECH_COMBAT = 1)
	attack_verb = list("robusted")
	can_get_wet = FALSE
	can_be_wrung_out = FALSE

	drop_sound = SFX_DROP_TOOLBOX
	pickup_sound = SFX_PICKUP_TOOLBOX

/obj/item/storage/toolbox/emergency
	name = "emergency toolbox"
	icon_state = "red"
	item_state = "toolbox_red"

	startswith = list(
		/obj/item/crowbar/red,
		/obj/item/extinguisher/mini,
		/obj/item/device/radio)

/obj/item/storage/toolbox/emergency/Initialize()
	. = ..()
	var/obj/item/I = pick(list(/obj/item/device/flashlight, /obj/item/device/flashlight/flare, /obj/item/device/flashlight/glowstick/red))
	new I(src)

/obj/item/storage/toolbox/mechanical
	name = "mechanical toolbox"
	desc = "Bright blue toolboxes like these are one of the most common sights in maintenance corridors on virtually every ship in the galaxy."
	icon_state = "blue"
	item_state = "toolbox_blue"

	startswith = list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		/obj/item/wirecutters,
		/obj/item/device/analyzer)

/obj/item/storage/toolbox/electrical
	name = "electrical toolbox"
	desc = "Bright yellow toolboxes like these are one of the most common sights in maintenance corridors on virtually every ship in the galaxy."
	icon_state = "yellow"
	item_state = "toolbox_yellow"

	startswith = list(
		/obj/item/screwdriver,
		/obj/item/wirecutters,
		/obj/item/crowbar,
		/obj/item/device/t_scanner)

/obj/item/storage/toolbox/electrical/Initialize()
	. = ..()
	new /obj/item/stack/cable_coil/random(src, 30)
	new /obj/item/stack/cable_coil/random(src, 30)
	if(prob(5))
		new /obj/item/clothing/gloves/insulated(src)
	else
		new /obj/item/stack/cable_coil/random(src, 30)

/obj/item/storage/toolbox/syndicate
	name = "black and red toolbox"
	desc = "A toolbox in black, with stylish red trim. This one feels particularly heavy."
	icon_state = "syndicate"
	item_state = "toolbox_syndi"
	origin_tech = list(TECH_COMBAT = 2, TECH_ILLEGAL = 1)
	force = 17.5 //Thatsa robusto toolboxo
	mod_weight = 1.75
	mod_reach = 0.75
	mod_handy = 1.0
	max_storage_space = 23

	startswith = list(
		/obj/item/screwdriver,
		/obj/item/wrench,
		/obj/item/weldingtool,
		/obj/item/crowbar,
		/obj/item/wirecutters,
		/obj/item/device/analyzer,
		/obj/item/clothing/gloves/insulated,
		/obj/item/clothing/glasses/welding)
