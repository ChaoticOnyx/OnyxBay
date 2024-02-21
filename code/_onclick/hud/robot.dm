var/atom/movable/screen/robot_inventory

/mob/living/silicon/robot
	bubble_icon = "robot"
	hud_type = /datum/hud/robot

/datum/hud/robot/FinalizeInstantiation()

	ASSERT(isrobot(mymob))

	var/mob/living/silicon/robot/R = mymob

	infodisplay = list()
	static_inventory = list()

	var/atom/movable/screen/using

//Radio
	using = new /atom/movable/screen()
	using.SetName("radio")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_robot.dmi'
	using.icon_state = "radio"
	using.screen_loc = ui_movi
	static_inventory += using

//Module select

	using = new /atom/movable/screen()
	using.SetName("module1")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_robot.dmi'
	using.icon_state = "inv1"
	using.screen_loc = ui_inv1
	static_inventory += using
	R.inv1 = using

	using = new /atom/movable/screen()
	using.SetName("module2")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_robot.dmi'
	using.icon_state = "inv2"
	using.screen_loc = ui_inv2
	static_inventory += using
	R.inv2 = using

	using = new /atom/movable/screen()
	using.SetName("module3")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_robot.dmi'
	using.icon_state = "inv3"
	using.screen_loc = ui_inv3
	static_inventory += using
	R.inv3 = using

//End of module select

//Intent
	using = new /atom/movable/screen()
	using.SetName("act_intent")
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/hud/mob/screen_robot.dmi'
	using.icon_state = R.a_intent
	using.screen_loc = ui_acti
	static_inventory += using
	action_intent = using

//Cell
	R.cells = new /atom/movable/screen()
	R.cells.icon = 'icons/hud/mob/screen_robot.dmi'
	R.cells.icon_state = "charge-empty"
	R.cells.SetName("cell")
	R.cells.screen_loc = ui_toxin
	infodisplay += R.cells

//Health
	R.healths = new /atom/movable/screen()
	R.healths.icon = 'icons/hud/mob/screen_robot.dmi'
	R.healths.icon_state = "health0"
	R.healths.SetName("health")
	R.healths.screen_loc = ui_borg_health
	infodisplay += R.healths

//Installed Module
	R.hands = new /atom/movable/screen()
	R.hands.icon = 'icons/hud/mob/screen_robot.dmi'
	R.hands.icon_state = "nomod"
	R.hands.SetName("module")
	R.hands.screen_loc = ui_borg_module
	static_inventory += R.hands

//Module Panel
	using = new /atom/movable/screen()
	using.SetName("panel")
	using.icon = 'icons/hud/mob/screen_robot.dmi'
	using.icon_state = "panel"
	using.screen_loc = ui_borg_panel
	static_inventory += using

//Store
	R.throw_icon = new /atom/movable/screen()
	R.throw_icon.icon = 'icons/hud/mob/screen_robot.dmi'
	R.throw_icon.icon_state = "store"
	R.throw_icon.SetName("store")
	R.throw_icon.screen_loc = ui_borg_store
	static_inventory += R.throw_icon

//Inventory
	robot_inventory = new /atom/movable/screen()
	robot_inventory.SetName("inventory")
	robot_inventory.icon = 'icons/hud/mob/screen_robot.dmi'
	robot_inventory.icon_state = "inventory"
	robot_inventory.screen_loc = ui_borg_inventory
	static_inventory += robot_inventory

//Temp
	R.bodytemp = new /atom/movable/screen()
	R.bodytemp.icon = 'icons/hud/mob/screen_robot.dmi'
	R.bodytemp.icon_state = "temp0"
	R.bodytemp.SetName("temperature")
	R.bodytemp.screen_loc = ui_fire
	infodisplay += R.bodytemp

	R.oxygen = new /atom/movable/screen()
	R.oxygen.icon = 'icons/hud/mob/screen_robot.dmi'
	R.oxygen.icon_state = "oxy0"
	R.oxygen.SetName("oxygen")
	R.oxygen.screen_loc = ui_oxygen
	infodisplay += R.oxygen

	R.pullin = new /atom/movable/screen()
	R.pullin.icon = 'icons/hud/mob/screen_robot.dmi'
	R.pullin.icon_state = "pull0"
	R.pullin.SetName("pull")
	R.pullin.screen_loc = ui_borg_pull
	static_inventory += R.pullin

	R.zone_sel = new /atom/movable/screen/zone_sel()
	R.zone_sel.icon = 'icons/hud/mob/screen_robot.dmi'
	R.zone_sel.ClearOverlays()
	R.zone_sel.AddOverlays(image('icons/hud/common/screen_zone_sel.dmi', "[R.zone_sel.selecting]"))
	static_inventory += R.zone_sel

	//Handle the gun settings buttons
	R.gun_setting_icon = new /atom/movable/screen/gun/mode(null)
	R.item_use_icon = new /atom/movable/screen/gun/item(null)
	R.gun_move_icon = new /atom/movable/screen/gun/move(null)
	R.radio_use_icon = new /atom/movable/screen/gun/radio(null)

	static_inventory += list(R.gun_setting_icon, R.item_use_icon, R.gun_move_icon, R.radio_use_icon)


/datum/hud/proc/toggle_show_robot_modules()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	R.shown_robot_modules = !R.shown_robot_modules
	update_robot_modules_display()


/datum/hud/proc/update_robot_modules_display()
	if(!isrobot(mymob))
		return

	var/mob/living/silicon/robot/R = mymob

	if(!R.client) // Some dumb piece of shit did NOT put it here
		return

	if(R.shown_robot_modules)
		//Modules display is shown
		//R.client.screen += robot_inventory	//"store" icon

		if(!R.module)
			to_chat(usr, "<span class='danger'>No module selected</span>")
			return

		if(!R.module.modules)
			to_chat(usr, "<span class='danger'>Selected module has no modules to select</span>")
			return

		if(!R.robot_modules_background)
			return

		var/display_rows = -round(-(R.module.modules.len) / 8)
		R.robot_modules_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		R.client.screen += R.robot_modules_background

		var/x = -4	//Start at CENTER-4,SOUTH+1
		var/y = 1

		//Unfortunately static_inventory the emag module to the list of modules has to be here. This is because a borg can
		//be emagged before they actually select a module. - or some situation can cause them to get a new module
		// - or some situation might cause them to get de-emagged or something.
		if(R.emagged)
			if(!(R.module.emag in R.module.modules))
				R.module.modules.Add(R.module.emag)
		else
			if(R.module.emag in R.module.modules)
				R.module.modules.Remove(R.module.emag)

		for(var/atom/movable/A in R.module.modules)
			if( (A != R.module_state_1) && (A != R.module_state_2) && (A != R.module_state_3) )
				//Module is not currently active
				R.client.screen += A
				if(x < 0)
					A.screen_loc = "CENTER[x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:7"
				else
					A.screen_loc = "CENTER+[x]:[WORLD_ICON_SIZE/2],SOUTH+[y]:7"
				A.hud_layerise()

				x++
				if(x == 4)
					x = -4
					y++

	else
		if(!R.module)
			return

		if(!R.module.modules)
			return
		//Modules display is hidden
		//R.client.screen -= robot_inventory	//"store" icon
		for(var/atom/A in R.module.modules)
			if( (A != R.module_state_1) && (A != R.module_state_2) && (A != R.module_state_3) )
				//Module is not currently active
				R.client.screen -= A
		R.shown_robot_modules = 0
		R.client.screen -= R.robot_modules_background
