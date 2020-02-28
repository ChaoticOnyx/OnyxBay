/obj/screen/specialblob
	var/obj/effect/blob/linked_blob = null

/obj/screen/specialblob/Click(location, control, params)
	var/mob/blob/overmind = usr

	if (!isovermind(overmind))
		return

	switch(name)
		if("Spawn Blob")
			overmind.expand_blob_power()
		if("Spawn Strong Blob")
			overmind.create_shield_power()
		if("Spawn Resource Blob")
			overmind.create_resource()
		if("Spawn Factory Blob")
			overmind.create_factory()
		if("Spawn Node Blob")
			overmind.create_node()
		if("Spawn Blob Core")
			overmind.create_core()
		if("Call Overminds")
			overmind.callblobs()
		if("Rally Spores")
			overmind.rally_spores_power()
		if("Psionic Message")
			var/message = input(overmind,"Send a message to the crew.","Psionic Message") as null|text
			if(message)
				overmind.telepathy(message)
		if("Jump to Blob")
			overmind.forceMove(linked_blob.loc)

/datum/hud/blob
	var/obj/screen/specialblob/blob_bgLEFT = null
	var/obj/screen/specialblob/blob_bgRIGHT = null
	var/obj/screen/specialblob/blob_coverLEFT = null
	var/obj/screen/specialblob/blob_coverRIGHT = null
	var/obj/screen/specialblob/blob_powerbar = null
	var/obj/screen/specialblob/blob_healthbar = null
	var/obj/screen/specialblob/blob_spawnblob = null
	var/obj/screen/specialblob/blob_spawnstrong = null
	var/obj/screen/specialblob/blob_spawnresource = null
	var/obj/screen/specialblob/blob_spawnfactory = null
	var/obj/screen/specialblob/blob_spawnnode = null
	var/obj/screen/specialblob/blob_spawncore = null
	var/obj/screen/specialblob/blob_ping = null
	var/obj/screen/specialblob/blob_rally = null
	var/obj/screen/specialblob/blob_taunt = null

	var/list/obj/screen/specialblob/spec_blobs = list()

/datum/hud/blob/FinalizeInstantiation(ui_style, ui_color, ui_alpha)
	blob_bgLEFT = new()
	blob_bgLEFT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	blob_bgLEFT.icon_state = "backgroundLEFT"
	blob_bgLEFT.name = "Blob HUD"
	blob_bgLEFT.layer = HUD_BASE_LAYER
	blob_bgLEFT.screen_loc = ui_blob_bgLEFT
	blob_bgLEFT.mouse_opacity = 0

	blob_bgRIGHT = new()
	blob_bgRIGHT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	blob_bgRIGHT.icon_state = "backgroundRIGHT"
	blob_bgRIGHT.name = "Blob HUD"
	blob_bgRIGHT.layer = HUD_BASE_LAYER
	blob_bgRIGHT.screen_loc = ui_blob_bgRIGHT
	blob_bgRIGHT.mouse_opacity = 0

	blob_coverLEFT = new()
	blob_coverLEFT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	blob_coverLEFT.icon_state = "coverLEFT"
	blob_coverLEFT.name = "Points"
	blob_coverLEFT.layer = HUD_ABOVE_ITEM_LAYER
	blob_coverLEFT.screen_loc = ui_blob_bgLEFT
	blob_coverLEFT.maptext_x = 1
	blob_coverLEFT.maptext_y = 126*PIXEL_MULTIPLIER

	blob_coverRIGHT = new()
	blob_coverRIGHT.icon = 'icons/mob/screen1_blob_fullscreen.dmi'
	blob_coverRIGHT.icon_state = "coverRIGHT"
	blob_coverRIGHT.name = "Health"
	blob_coverRIGHT.layer = HUD_ABOVE_ITEM_LAYER
	blob_coverRIGHT.screen_loc = ui_blob_bgRIGHT
	blob_coverRIGHT.maptext_x = 464*PIXEL_MULTIPLIER
	blob_coverRIGHT.maptext_y = 126*PIXEL_MULTIPLIER

	blob_powerbar = new()
	blob_powerbar.icon = 'icons/mob/screen1_blob_bars.dmi'
	blob_powerbar.icon_state = "points"
	blob_powerbar.name = "Points"
	blob_powerbar.screen_loc = ui_blob_powerbar

	blob_healthbar = new()
	blob_healthbar.icon = 'icons/mob/screen1_blob_bars.dmi'
	blob_healthbar.icon_state = "health"
	blob_healthbar.name = "Health"
	blob_healthbar.screen_loc = ui_blob_healthbar

	blob_spawnblob = new()
	blob_spawnblob.icon = 'icons/mob/screen1_blob.dmi'
	blob_spawnblob.icon_state = "blob1"
	blob_spawnblob.name = "Spawn Blob"
	blob_spawnblob.layer = 22
	blob_spawnblob.screen_loc = ui_blob_spawnblob

	blob_spawnstrong = new()
	blob_spawnstrong.icon = 'icons/mob/screen1_blob.dmi'
	blob_spawnstrong.icon_state = "strong1"
	blob_spawnstrong.name = "Spawn Strong Blob"
	blob_spawnstrong.layer = 22
	blob_spawnstrong.screen_loc = ui_blob_spawnstrong

	blob_spawnresource = new()
	blob_spawnresource.icon = 'icons/mob/screen1_blob.dmi'
	blob_spawnresource.icon_state = "resource1"
	blob_spawnresource.name = "Spawn Resource Blob"
	blob_spawnresource.layer = 22
	blob_spawnresource.screen_loc = ui_blob_spawnresource

	blob_spawnfactory = new()
	blob_spawnfactory.icon = 'icons/mob/screen1_blob.dmi'
	blob_spawnfactory.icon_state = "factory1"
	blob_spawnfactory.name = "Spawn Factory Blob"
	blob_spawnfactory.layer = 22
	blob_spawnfactory.screen_loc = ui_blob_spawnfactory

	blob_spawnnode = new()
	blob_spawnnode.icon = 'icons/mob/screen1_blob.dmi'
	blob_spawnnode.icon_state = "node1"
	blob_spawnnode.name = "Spawn Node Blob"
	blob_spawnnode.layer = 22
	blob_spawnnode.screen_loc = ui_blob_spawnnode

	blob_spawncore = new()
	blob_spawncore.icon = 'icons/mob/screen1_blob.dmi'
	blob_spawncore.icon_state = "core1"
	blob_spawncore.name = "Spawn Blob Core"
	blob_spawncore.layer = 22
	blob_spawncore.screen_loc = ui_blob_spawncore

	blob_ping = new()
	blob_ping.icon = 'icons/mob/screen1_blob.dmi'
	blob_ping.icon_state = "ping"
	blob_ping.name = "Call Overminds"
	blob_ping.layer = 22
	blob_ping.screen_loc = ui_blob_ping

	blob_rally = new()
	blob_rally.icon = 'icons/mob/screen1_blob.dmi'
	blob_rally.icon_state = "rally"
	blob_rally.name = "Rally Spores"
	blob_rally.layer = 22
	blob_rally.screen_loc = ui_blob_rally

	blob_taunt = new()
	blob_taunt.icon = 'icons/mob/screen1_blob.dmi'
	blob_taunt.icon_state = "taunt"
	blob_taunt.name = "Psionic Message"
	blob_taunt.layer = 22
	blob_taunt.screen_loc = ui_blob_taunt

	mymob.client.screen = list()

	mymob.client.screen += list(
		blob_bgLEFT,
		blob_bgRIGHT,
		blob_coverLEFT,
		blob_coverRIGHT,
		blob_powerbar,
		blob_healthbar,
		blob_spawnblob,
		blob_spawnstrong,
		blob_spawnresource,
		blob_spawnfactory,
		blob_spawnnode,
		blob_spawncore,
		blob_ping,
		blob_rally,
		blob_taunt,
	)

	/*
	for(var/i=1;i<=24;i++)
		var/obj/abstract/screen/specialblob/S = new()
		S.icon = 'icons/mob/screen1_blob.dmi'
		S.icon_state = ""
		var/total_offset = -16 + (i * 20)
		S.screen_loc = "[1 + round(total_offset/WORLD_ICON_SIZE)]:[total_offset%WORLD_ICON_SIZE],NORTH"
		mymob.gui_icons.specialblobs[i] = S

	for(var/i=1;i<=24;i++)
		mymob.client.screen += mymob.gui_icons.specialblobs[i]
	*/
