/mob/living/carbon/metroid
	hud_type = /datum/hud/metroid

/datum/hud/metroid/FinalizeInstantiation(ui_style = 'icons/hud/style/midnight.dmi')
	static_inventory = list()

	action_intent = new /atom/movable/screen/intent()
	static_inventory += action_intent
