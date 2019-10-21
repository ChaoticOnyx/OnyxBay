/* Any ready to use items that can be placed on maps */

/obj/item/clothing/glasses/hud/psychoscope/with_battery/Initialize()
	. = ..()

	bcell = new /obj/item/weapon/cell/standard/(src.contents)

/obj/item/weapon/reagent_containers/neuromod_shell/light_regeneration
	neuromod = /datum/neuromod/light_regeneration
	created_for = /mob/living/carbon/human
