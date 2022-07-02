
/obj/machinery/vending/tool
	name = "YouTool"
	desc = "Tools for tools."
	icon_state = "tool"
	use_vend_state = TRUE
	gen_rand_amount = FALSE
	vend_delay = 11 SECONDS
	component_types = list(/obj/item/vending_cartridge/tool)
	legal = list(	/obj/item/stack/cable_coil/random = 10,
					/obj/item/crowbar = 5,
					/obj/item/weldingtool = 3,
					/obj/item/wirecutters = 5,
					/obj/item/wrench = 5,
					/obj/item/device/analyzer = 5,
					/obj/item/device/t_scanner = 5,
					/obj/item/screwdriver = 5,
					/obj/item/device/flashlight/glowstick = 3,
					/obj/item/device/flashlight/glowstick/red = 3)
	illegal = list(	/obj/item/weldingtool/hugetank = 2,
					/obj/item/clothing/gloves/insulated/cheap = 2)
	premium = list(/obj/item/clothing/gloves/insulated = 1)

/obj/item/vending_cartridge/tool
	name = "youtool"
	build_path = /obj/machinery/vending/tool

/obj/machinery/vending/engivend
	name = "Engi-Vend"
	desc = "Spare tool vending. What? Did you expect some witty description?"
	icon_state = "engivend"
	use_vend_state = TRUE
	vend_delay = 21 SECONDS
	req_one_access = list(access_atmospherics, access_engine_equip)
	component_types = list(/obj/item/vending_cartridge/engivend)
	legal = list(	/obj/item/clothing/glasses/hud/standard/meson = 2,
					/obj/item/device/multitool = 4,
					/obj/item/device/geiger = 4,
					/obj/item/airlock_electronics = 10,
					/obj/item/module/power_control = 10,
					/obj/item/airalarm_electronics = 10,
					/obj/item/cell = 10,
					/obj/item/clamp = 10)
	illegal = list(/obj/item/cell/high = 3)
	premium = list(/obj/item/storage/belt/utility = 3)

/obj/item/vending_cartridge/engivend
	name = "engi"
	build_path = /obj/machinery/vending/engivend

//This one's from bay12
/obj/machinery/vending/engineering
	name = "Robco Tool Maker"
	desc = "Everything you need for do-it-yourself repair."
	icon_state = "engi"
	req_one_access = list(access_atmospherics, access_engine_equip)
	component_types = list(/obj/item/vending_cartridge/engineering)
	// There was an incorrect entry (cablecoil/power).  I improvised to cablecoil/heavyduty.
	// Another invalid entry, /obj/item/circuitry.  I don't even know what that would translate to, removed it.
	// The original products list wasn't finished.  The ones without given quantities became quantity 5.  -Sayu
	legal = list(	/obj/item/storage/belt/utility = 4,
					/obj/item/clothing/glasses/hud/standard/meson = 4,
					/obj/item/clothing/gloves/insulated = 4,
					/obj/item/screwdriver = 12,
					/obj/item/crowbar = 12,
					/obj/item/wirecutters = 12,
					/obj/item/device/multitool = 12,
					/obj/item/wrench = 12,
					/obj/item/device/t_scanner = 12,
					/obj/item/cell = 8,
					/obj/item/weldingtool = 8,
					/obj/item/clothing/head/welding = 8,
					/obj/item/light/tube = 10,
					/obj/item/stock_parts/scanning_module = 5,
					/obj/item/stock_parts/micro_laser = 5,
					/obj/item/stock_parts/matter_bin = 5,
					/obj/item/stock_parts/manipulator = 5,
					/obj/item/stock_parts/console_screen = 5,
					/obj/item/stock_parts/capacitor = 5)
	illegal = list(	/obj/item/rcd = 1,
					/obj/item/rcd_ammo = 5)

/obj/item/vending_cartridge/engineering
	name = "tool maker"
	build_path = /obj/machinery/vending/engineering
