/*
	Screen objects
	Todo: improve/re-implement

	Screen objects are only used for the hud and should not appear anywhere "in-game".
	They are used with the client/screen list and the screen_loc var.
	For more information, see the byond documentation on the screen_loc and screen vars.
*/
/obj/screen
	name = ""
	icon = 'icons/mob/screen1.dmi'
	plane = HUD_PLANE
	layer = HUD_BASE_LAYER
	appearance_flags = NO_CLIENT_COLOR
	unacidable = 1
	var/obj/master = null    //A reference to the object in the slot. Grabs or items, generally.
	var/globalscreen = FALSE //Global screens are not qdeled when the holding mob is destroyed.

/obj/screen/Destroy()
	master = null
	return ..()

/obj/screen/text
	icon = null
	icon_state = null
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"
	maptext_height = 480
	maptext_width = 480


/obj/screen/inventory
	var/slot_id	//The indentifier for the slot. It has nothing to do with ID cards.


/obj/screen/close
	name = "close"

/obj/screen/close/Click()
	if(master)
		if(istype(master, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = master
			S.close(usr)
	return 1


/obj/screen/item_action
	var/obj/item/owner

/obj/screen/item_action/Destroy()
	..()
	owner = null

/obj/screen/item_action/Click()
	if(!usr || !owner)
		return 1
	if(!usr.canClick())
		return

	if(usr.stat || usr.restrained() || usr.stunned || usr.lying)
		return 1

	if(!(owner in usr))
		return 1

	owner.ui_action_click()
	return 1

/obj/screen/storage
	name = "storage"

/obj/screen/storage/Click()
	if(!usr.canClick())
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	if(master)
		var/obj/item/I = usr.get_active_hand()
		if(I)
			usr.ClickOn(master)
	return 1

/obj/screen/zone_sel
	name = "damage zone"
	icon_state = "zone_sel"
	screen_loc = ui_zonesel
	var/selecting = BP_CHEST

/obj/screen/zone_sel/Click(location, control,params)
	var/list/PL = params2list(params)
	var/icon_x = text2num(PL["icon-x"])
	var/icon_y = text2num(PL["icon-y"])
	var/old_selecting = selecting //We're only going to update_icon() if there's been a change

	switch(icon_y)
		if(1 to 3) //Feet
			switch(icon_x)
				if(10 to 15)
					selecting = BP_R_FOOT
				if(17 to 22)
					selecting = BP_L_FOOT
				else
					return 1
		if(4 to 9) //Legs
			switch(icon_x)
				if(10 to 15)
					selecting = BP_R_LEG
				if(17 to 22)
					selecting = BP_L_LEG
				else
					return 1
		if(10 to 13) //Hands and groin
			switch(icon_x)
				if(8 to 11)
					selecting = BP_R_HAND
				if(12 to 20)
					selecting = BP_GROIN
				if(21 to 24)
					selecting = BP_L_HAND
				else
					return 1
		if(14 to 22) //Chest and arms to shoulders
			switch(icon_x)
				if(8 to 11)
					selecting = BP_R_ARM
				if(12 to 20)
					selecting = BP_CHEST
				if(21 to 24)
					selecting = BP_L_ARM
				else
					return 1
		if(23 to 30) //Head, but we need to check for eye or mouth
			if(icon_x in 12 to 20)
				selecting = BP_HEAD
				switch(icon_y)
					if(23 to 24)
						if(icon_x in 15 to 17)
							selecting = BP_MOUTH
					if(26) //Eyeline, eyes are on 15 and 17
						if(icon_x in 14 to 18)
							selecting = BP_EYES
					if(25 to 27)
						if(icon_x in 15 to 17)
							selecting = BP_EYES

	if(old_selecting != selecting)
		update_icon()
	return 1

/obj/screen/zone_sel/proc/set_selected_zone(bodypart)
	var/old_selecting = selecting
	selecting = bodypart
	if(old_selecting != selecting)
		update_icon()

/obj/screen/zone_sel/update_icon()
	overlays.Cut()
	overlays += image('icons/mob/zone_sel.dmi', "[selecting]")
/obj/screen/intent
	name = "intent"
	icon = 'icons/mob/screen1_white.dmi'
	icon_state = "intent_help"
	screen_loc = ui_acti
	var/intent = I_HELP

/obj/screen/intent/Click(location, control, params)
	var/list/P = params2list(params)
	var/icon_x = text2num(P["icon-x"])
	var/icon_y = text2num(P["icon-y"])
	intent = I_DISARM


	if(icon_x <= world.icon_size/2)
		if(icon_y <= world.icon_size/2)
			intent = I_HURT
		else
			intent = I_HELP
	else if(icon_y <= world.icon_size/2)
		intent = I_GRAB
	update_icon()
	usr.a_intent = intent

/obj/screen/intent/update_icon()
	icon_state = "intent_[intent]"

/obj/screen/Click(location, control, params)
	switch(name)
		if("toggle")
			if(usr.hud_used.inventory_shown)
				usr.hud_used.inventory_shown = 0
				usr.client.screen -= usr.hud_used.other
			else
				usr.hud_used.inventory_shown = 1
				usr.client.screen += usr.hud_used.other

			usr.hud_used.hidden_inventory_update()

		if("equip")
			if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
				return 1
			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				H.quick_equip()

		if("resist")
			if(isliving(usr))
				var/mob/living/L = usr
				L.resist()
		if("rest")
			if(isliving(usr))
				var/mob/living/L = usr
				L.lay_down()

		if("mov_intent")
			switch(usr.m_intent)
				if(M_RUN)
					usr.m_intent = M_WALK
					usr.hud_used.move_intent.icon_state = "walking"
				if(M_WALK)
					usr.m_intent = M_RUN
					usr.hud_used.move_intent.icon_state = "running"

		if("Reset Machine")
			usr.unset_machine()

		if("internal")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				if(!C.stat && !C.stunned && !C.paralysis && !C.restrained())
					if(C.internal)
						C.internal = null
						to_chat(C, "<span class='notice'>No longer running on internals.</span>")
						if(C.internals)
							C.internals.icon_state = "internal0"
					else

						var/no_mask
						if(!(C.wear_mask && C.wear_mask.item_flags & ITEM_FLAG_AIRTIGHT))
							var/mob/living/carbon/human/H = C
							if(!(H.head && H.head.item_flags & ITEM_FLAG_AIRTIGHT))
								no_mask = 1

						if(no_mask)
							to_chat(C, "<span class='notice'>You are not wearing a suitable mask or helmet.</span>")
							return 1
						else
							var/list/nicename = null
							var/list/tankcheck = null
							var/breathes = "oxygen"    //default, we'll check later
							var/list/contents = list()
							var/from = "on"

							if(ishuman(C))
								var/mob/living/carbon/human/H = C
								breathes = H.species.breath_type
								nicename = list ("suit", "back", "belt", "right hand", "left hand", "left pocket", "right pocket")
								tankcheck = list (H.s_store, C.back, H.belt, C.r_hand, C.l_hand, H.l_store, H.r_store)
							else
								nicename = list("right hand", "left hand", "back")
								tankcheck = list(C.r_hand, C.l_hand, C.back)

							// Rigs are a fucking pain since they keep an air tank in nullspace.
							if(istype(C.back,/obj/item/weapon/rig))
								var/obj/item/weapon/rig/rig = C.back
								if(rig.air_supply)
									from = "in"
									nicename |= "hardsuit"
									tankcheck |= rig.air_supply

							for(var/i=1, i<tankcheck.len+1, ++i)
								if(istype(tankcheck[i], /obj/item/weapon/tank))
									var/obj/item/weapon/tank/t = tankcheck[i]
									if (!isnull(t.manipulated_by) && t.manipulated_by != C.real_name && findtext(t.desc,breathes))
										contents.Add(t.air_contents.total_moles)	//Someone messed with the tank and put unknown gasses
										continue					//in it, so we're going to believe the tank is what it says it is
									switch(breathes)
																		//These tanks we're sure of their contents
										if("nitrogen") 							//So we're a bit more picky about them.

											if(t.air_contents.gas["nitrogen"] && !t.air_contents.gas["oxygen"])
												contents.Add(t.air_contents.gas["nitrogen"])
											else
												contents.Add(0)

										if ("oxygen")
											if(t.air_contents.gas["oxygen"] && !t.air_contents.gas["plasma"])
												contents.Add(t.air_contents.gas["oxygen"])
											else
												contents.Add(0)

										// No races breath this, but never know about downstream servers.
										if ("carbon dioxide")
											if(t.air_contents.gas["carbon_dioxide"] && !t.air_contents.gas["plasma"])
												contents.Add(t.air_contents.gas["carbon_dioxide"])
											else
												contents.Add(0)


								else
									//no tank so we set contents to 0
									contents.Add(0)

							//Alright now we know the contents of the tanks so we have to pick the best one.

							var/best = 0
							var/bestcontents = 0
							for(var/i=1, i <  contents.len + 1 , ++i)
								if(!contents[i])
									continue
								if(contents[i] > bestcontents)
									best = i
									bestcontents = contents[i]


							//We've determined the best container now we set it as our internals

							if(best)
								to_chat(C, "<span class='notice'>You are now running on internals from [tankcheck[best]] [from] your [nicename[best]].</span>")
								playsound(usr, 'sound/effects/internals.ogg', 50, 0)
								C.internal = tankcheck[best]


							if(C.internal)
								if(C.internals)
									C.internals.icon_state = "internal1"
							else
								to_chat(C, "<span class='notice'>You don't have a[breathes=="oxygen" ? "n oxygen" : addtext(" ",breathes)] tank.</span>")

		if("act_intent")
			usr.a_intent_change("right")

		if("pull")

			usr.stop_pulling()
		if("throw")
			if(!usr.stat && isturf(usr.loc) && !usr.restrained())
				usr.toggle_throw_mode()

		if("drop")
			if(usr.client)
				usr.client.drop_item()

		if("block")
			if(istype(usr,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = usr
				H.useblock()

		if("blockswitch")
			if(istype(usr,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = usr
				H.blockswitch()

		if("module")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
//				if(R.module)
//					R.hud_used.toggle_show_robot_modules()
//					return 1
				R.pick_module()

		if("inventory")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.hud_used.toggle_show_robot_modules()
					return 1
				else
					to_chat(R, "You haven't selected a module yet.")

		if("radio")
			if(issilicon(usr))
				var/mob/living/silicon/robot/R = usr
				R.radio_menu()
		if("panel")
			if(issilicon(usr))
				var/mob/living/silicon/robot/R = usr
				R.installed_modules()

		if("store")
			if(isrobot(usr))
				var/mob/living/silicon/robot/R = usr
				if(R.module)
					R.uneq_active()
					R.hud_used.update_robot_modules_display()
				else
					to_chat(R, "You haven't selected a module yet.")

		if("module1")
			if(istype(usr, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/R = usr
				R.toggle_module(1)

		if("module2")
			if(istype(usr, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/R = usr
				R.toggle_module(2)

		if("module3")
			if(istype(usr, /mob/living/silicon/robot))
				var/mob/living/silicon/robot/R = usr
				R.toggle_module(3)


		if("AI core")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.view_core()

		if("Set AI Core Display")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.pick_icon()

		if("AI Status")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_statuschange()

		if("Change Hologram")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_hologram_change()

		if("Show Camera List")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/network = input(AI, "Chooce which network you want to view", "Networks") as null|anything in AI.get_camera_network_list()
			AI.ai_network_change(network)
			var/camera = input(AI, "Choose which camera you want to view", "Cameras") as null|anything in AI.get_camera_list()
			AI.ai_camera_list(camera)

		if("Track With Camera")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/target_name = input(AI, "Choose who you want to track", "Tracking") as null|anything in AI.trackable_mobs()
			AI.ai_camera_track(target_name)

		if("Toggle Camera Light")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.toggle_camera_light()

		if("Store Camera Location")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/name_l = input(AI, "Enter name camera location", "Name")
			AI.ai_store_location(name_l)

		if("Goto Camera Location")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/cam_loc = input(AI, "Choose which location you want to view", "Locations") as null|anything in AI.sorted_stored_locations()
			AI.ai_goto_location(cam_loc)

		if("Delete Camera Location")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			var/delete = input(AI, "Choose which location you want to delete", "Locations") as null|anything in AI.sorted_stored_locations()
			AI.ai_remove_location(delete)

		if("Crew Manifest")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_roster()

		if("Make Announcement")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_announcement()

		if("Call Emergency Shuttle")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_call_shuttle()

		if("State Laws")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_checklaws()

		if("Sensor Augmentation")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.toggle_sensor_mode()

		if("Radio Settings")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.control_integrated_radio()

		if("Take Image")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.silicon_camera.toggle_camera_mode()

		if("View Images")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.silicon_camera.viewpictures()

		if("Delete Image")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.silicon_camera.deletepicture()

		if("Toggle Shutdown")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_shutdown()

		if("Toggle Power Override")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.ai_power_override()

		if("Toggle Ringer")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.aiPDA.cmd_toggle_pda_silent()

		if("Send Message")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.aiPDA.cmd_send_pdamesg()

		if("Show Message Log")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.aiPDA.cmd_show_message_log()

		if("Toggle Sender/Receiver")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.aiPDA.cmd_toggle_pda_receiver()

		if("Toggle Multitool Mode")
			ASSERT(isAI(usr))
			var/mob/living/silicon/ai/AI = usr
			AI.multitool_mode()
		else
			return 0
	return 1

/obj/screen/inventory/Click()
	// At this point in client Click() code we have passed the 1/10 sec check and little else
	// We don't even know if it's a middle click
	if(!usr.canClick())
		return 1
	if(usr.stat || usr.paralysis || usr.stunned || usr.weakened)
		return 1
	if (istype(usr.loc,/obj/mecha)) // stops inventory actions in a mech
		return 1
	switch(name)
		if("r_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("r")
		if("l_hand")
			if(iscarbon(usr))
				var/mob/living/carbon/C = usr
				C.activate_hand("l")
		if("swap")
			usr.swap_hand()
		if("hand")
			usr.swap_hand()
		else
			if(usr.attack_ui(slot_id))
				usr.update_inv_l_hand(0)
				usr.update_inv_r_hand(0)
	return 1

/obj/screen/rec
	icon = 'icons/effects/effects.dmi'
	icon_state = "rec"
	screen_loc = "TOP-2,WEST+2"
	layer = FULLSCREEN_LAYER
