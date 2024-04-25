
/mob/living/deity/hud_type = /datum/hud/deity
/mob/living/deity/var/inventory_shown = FALSE
/mob/living/deity/var/atom/movable/screen/deity_inv_background

/mob/living/deity/Initialize()
	. = ..()

	deity_inv_background = new()
	deity_inv_background.icon = 'icons/hud/common/screen_storage.dmi'
	deity_inv_background.icon_state = "block"

/mob/living/deity/Destroy()
	QDEL_NULL(deity_inv_background)
	return ..()

/datum/hud/deity
	var/atom/movable/screen/deity_current_building/selected
	var/atom/movable/screen/deity_building_cost/cost
	var/atom/movable/screen/deity_resource/followers
	var/atom/movable/screen/deity_resource/buildings
	var/list/resources = list()

/datum/hud/deity/FinalizeInstantiation(ui_style = 'icons/hud/deity.dmi')
	static_inventory = list()
	resources = list()

	var/atom/movable/screen/deity_current_building/ccb = new()

	static_inventory += ccb
	selected = ccb

	var/atom/movable/screen/deity_building_cost/cbc = new()

	static_inventory += cbc
	cost = cbc

	var/atom/movable/screen/intent = new /atom/movable/screen/intent()
	intent.screen_loc = "WEST+6:8, SOUTH+1:8"
	action_intent = intent
	static_inventory += intent

	for(var/i in 1 to 4)
		var/atom/movable/screen/deity_resource/res = new()
		res.maptext_x = 108 - (i % 2) * 98
		res.maptext_y = 36 - (i > 2 ? 16 : 0)
		res.icon_state = "resources_[i]"
		resources += res

	followers = new()
	followers.icon_state = "resource_followers"
	followers.maptext_x = 58
	followers.maptext_y = -7
	static_inventory += followers

	buildings = new()
	buildings.icon_state = "resource_buildings"
	buildings.maptext_x = 132
	buildings.maptext_y = -7
	static_inventory += buildings

	static_inventory += resources

	mymob.healths = new /atom/movable/screen()
	mymob.healths.SetName("health")
	mymob.healths.icon = 'icons/hud/deity.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.screen_loc = ui_construct_health
	static_inventory += mymob.healths

	mymob.client.screen = list()
	mymob.client.screen += static_inventory

/datum/hud/deity/proc/update_buildings_units(b, f)
	followers.update_resource(f)
	buildings.update_resource(b)

/datum/hud/deity/proc/update_resources(list/prints)
	for(var/i in 1 to prints.len)
		var/atom/movable/screen/deity_resource/res = resources[i]
		var/p = prints[i]
		res.update_resource(p)

/datum/hud/deity/proc/update_selected(datum/deity_power/selected_power)
	selected.update_to_hud(selected_power)
	if(selected_power)
		cost.update_to_cost(selected_power.get_printed_cost(mymob))
	else
		cost.update_to_cost(list())

/atom/movable/screen/deity_current_building
	name = "Building"
	screen_loc = "WEST:8,SOUTH:8"
	icon = 'icons/hud/deity_big.dmi'
	icon_state = "basic"
	maptext_width = 92
	maptext_x = 62
	maptext_y = 46

/atom/movable/screen/deity_current_building/proc/update_to_hud(datum/deity_power/selected_power)
	ClearOverlays()
	if(selected_power)
		var/image/I = selected_power._get_image()
		report_progress(selected_power._get_image())
		I.pixel_y = 17
		I.pixel_x = 17
		AddOverlays(I)
		maptext = MAPTEXT(selected_power._get_name())
	else
		maptext = null

/atom/movable/screen/deity_building_cost
	name = "Cost"
	screen_loc = "WEST:8,SOUTH:8"
	icon = 'icons/hud/deity_big.dmi'
	icon_state = "cost"
	maptext_x = 60
	maptext_y = 8
	maptext_width = 92
	maptext_height = 30

/atom/movable/screen/deity_building_cost/proc/update_to_cost(list/cost)
	var/list/dat = list()
	dat += {"
	<p style=\"font-size:5px\">
		<center>
			<table>
				<tr>
					<td>"}
	for(var/i = 1; i <= 4; i++)
		if(cost.len >= i)
			dat += "[cost[i]["print"]] [cost[i]["amount"]]"
		if(i == 4)
			break
		if(i == 2)
			dat += "</td></tr><tr><td>"
		dat += "</td><td>"
	dat += "</td></tr></table></center></p>"
	maptext = jointext(dat,null)

/atom/movable/screen/deity_resource
	name = "Resources"
	screen_loc = "EAST-4:-8, SOUTH:8"
	icon = 'icons/hud/deity_big.dmi'
	icon_state = "resources"
	maptext_width = 60

/atom/movable/screen/deity_resource/proc/update_resource(datum/deity_resource/res)
	maptext = "[MAPTEXT(res)]: [MAPTEXT(res.amount)]"

/datum/hud/deity/proc/toggle_show_deity_inventory()
	var/mob/living/deity/D = mymob

	D.inventory_shown = !D.inventory_shown
	update_inv_display()

/datum/hud/deity/proc/update_inv_display()
	var/mob/living/deity/D = mymob

	if(!D.client)
		return

	if(D.inventory_shown)
		if(!D.form)
			to_chat(usr, SPAN_DANGER("Select form first!"))
			return

		if(!D.deity_inv_background)
			return

		var/display_rows = -round(- (D.form.buildables.len) / 8)
		D.deity_inv_background.screen_loc = "CENTER-4:16,SOUTH+1:7 to CENTER+3:16,SOUTH+[display_rows]:7"
		D.client.screen += D.deity_inv_background

		var/x = -4
		var/y = 1

		for(var/atom/movable/A in D.form.buildables)
			D.client.screen += A
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
		if(!D.form)
			return

		for(var/atom/A in D.form.buildables)
			D.client.screen -= A

		D.client.screen -= D.deity_inv_background
