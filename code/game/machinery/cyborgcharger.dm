/obj/machinery/cyborgcharger
	name = "Cyborg Charging Station"
	icon = 'cyborgcharger.dmi'
	icon_state = "charge"
	density = 0
	anchored = 1



/obj/machinery/cyborgcharger/process()
	if(powered())
		for(var/mob/living/silicon/robot/R in src.loc)
			var/added
			if(R.cell)
				added = R.cell.maxcharge/100.0
				if(R.module_state_1)
					added+=5
				if(R.module_state_2)
					added+=5
				if(R.module_state_3)
					added+=5
				R.cell:give(added)
			use_power(added)
			//The following was added for cyborgchargers to refill cyborg modules.
			if(R.class == "standard")
				R.module_state_1 = null
				R.module_state_2 = null
				R.module_state_3 = null
				del(R.module)
				R.module = new /obj/item/weapon/robot_module/standard(src)
			if(R.class == "engineer")
				R.module_state_1 = null
				R.module_state_2 = null
				R.module_state_3 = null
				del(R.module)
				R.module = new /obj/item/weapon/robot_module/engineering(src)
			if(R.class == "medical")
				R.module_state_1 = null
				R.module_state_2 = null
				R.module_state_3 = null
				del(R.module)
				R.module = new /obj/item/weapon/robot_module/medical(src)
			if(R.class == "security")
				R.module_state_1 = null
				R.module_state_2 = null
				R.module_state_3 = null
				del(R.module)
				R.module = new /obj/item/weapon/robot_module/security(src)
			if(R.class == "janitor")
				R.module_state_1 = null
				R.module_state_2 = null
				R.module_state_3 = null
				del(R.module)
				R.module = new /obj/item/weapon/robot_module/janitor(src)
	return ..()

/obj/machinery/cyborgcharger/power_change()
	if(powered())
		stat &= ~NOPOWER
		src.icon_state = "charge"
	else
		stat |= NOPOWER
		src.icon_state = "charge0"
	return






/*
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

*/