/* Any ready to use items that can be placed on maps */

/obj/item/clothing/glasses/hud/psychoscope/with_battery/Initialize()
	. = ..()

	bcell = new /obj/item/weapon/cell/standard/(src.contents)

/* Ready to use neuromod shells */
/obj/item/weapon/reagent_containers/neuromod_shell/light_regeneration
	neuromod = /datum/neuromod/light_regeneration
	created_for = /mob/living/carbon/human

/obj/item/weapon/reagent_containers/neuromod_shell/language_siik_maas
	neuromod = /datum/neuromod/language/siik_maas
	created_for = /mob/living/carbon/human

/obj/item/weapon/reagent_containers/neuromod_shell/language_soghun
	neuromod = /datum/neuromod/language/soghun
	created_for = /mob/living/carbon/human

/* Random ready to use neuromod shells for humans */
/obj/item/weapon/reagent_containers/neuromod_shell/human_random/Initialize()
	neuromod = pick(subtypesof(/datum/neuromod) - list(/datum/neuromod/language))
	created_for = /mob/living/carbon/human

	. = ..()

/* Fully random ready to use neuromod shells */
/obj/item/weapon/reagent_containers/neuromod_shell/random/Initialize()
	neuromod = pick(subtypesof(/datum/neuromod) - list(/datum/neuromod/language))
	created_for = pick(typesof(/mob/living/carbon/human))

	. = ..()

/* Researched */
/obj/item/weapon/disk/neuromod_disk/researched/light_regeneration
	neuromod = /datum/neuromod/light_regeneration

/obj/item/weapon/disk/neuromod_disk/researched/language_siik_maas
	neuromod = /datum/neuromod/language/siik_maas

/obj/item/weapon/disk/neuromod_disk/researched/language_soghun
	neuromod = /datum/neuromod/language/soghun

/* With a random chance to be researched */
/obj/item/weapon/disk/neuromod_disk/light_regeneration
	neuromod = /datum/neuromod/light_regeneration

/obj/item/weapon/disk/neuromod_disk/language_siik_maas
	neuromod = /datum/neuromod/language/siik_maas

/obj/item/weapon/disk/neuromod_disk/language_soghun
	neuromod = /datum/neuromod/language/soghun

/* Fully random neuromod disk */
/obj/item/weapon/disk/neuromod_disk/random/Initialize()
	. = ..()

	neuromod = pick(subtypesof(/datum/neuromod/))
	researched = prob(35)
