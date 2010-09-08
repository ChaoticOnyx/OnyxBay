/obj/item/weapon/robot_module
	name = "robot module"
	icon = 'module.dmi'
	icon_state = "std_module"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT|TABLEPASS | CONDUCT
	var/list/modules = list()

/obj/item/weapon/robot_module/standard
	name = "standard robot module"

/obj/item/weapon/robot_module/medical
	name = "medical robot module"

/obj/item/weapon/robot_module/engineering
	name = "engineering robot module"

/obj/item/weapon/robot_module/security
	name = "security robot module"

/obj/item/weapon/robot_module/janitor
	name = "janitorial robot module"

/obj/item/weapon/robot_module/brobot
	name = "brobot robot module"

/obj/item/weapon/robot_module/standard/New()
	modules += new /obj/item/weapon/baton(src)
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/device/healthanalyzer(src)

/obj/item/weapon/robot_module/engineering/New()
	modules += new /obj/item/weapon/extinguisher(src)
	modules += new /obj/item/weapon/screwdriver(src)
	modules += new /obj/item/weapon/weldingtool(src)
	modules += new /obj/item/weapon/wrench(src)
	modules += new /obj/item/device/analyzer(src)
	modules += new /obj/item/device/flashlight(src)

	var/obj/item/weapon/rcd/R = new /obj/item/weapon/rcd(src)
	R.matter = 30
	modules += R

	modules += new /obj/item/device/t_scanner(src)
	modules += new /obj/item/weapon/crowbar(src)
	modules += new /obj/item/weapon/wirecutters(src)

/obj/item/weapon/robot_module/medical/New()
	modules += new /obj/item/device/healthanalyzer(src)
	modules += new /obj/item/weapon/medical/ointment( src )
	modules += new /obj/item/weapon/medical/bruise_pack(src)
	modules += new /obj/item/weapon/reagent_containers/syringe/robot( src )

/obj/item/weapon/robot_module/security/New()
	modules += new /obj/item/weapon/baton(src)

	modules += new /obj/item/weapon/handcuffs(src)
	modules += new /obj/item/weapon/gun/energy/taser_gun(src)
	modules += new /obj/item/device/flash(src)

/obj/item/weapon/robot_module/janitor/New()
	modules += new /obj/item/weapon/cleaner(src)
	modules += new /obj/item/weapon/mop(src)
	modules += new /obj/item/weapon/reagent_containers/glass/bucket

/obj/item/weapon/robot_module/brobot/New()
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)
	modules += new /obj/item/weapon/reagent_containers/food/drinks/beer(src)