// Spells/spellbooks have a variable for this but as artefacts are literal items they do not.
// so we do this instead.
var/list/artefact_feedback = list(/obj/structure/closet/wizard/armor = 		"HS",
								/obj/item/weapon/gun/energy/staff/focus = 	"MF",
								/obj/item/weapon/monster_manual = 			"MA",
								/obj/item/weapon/magic_rock = 				"RA",
								/obj/item/weapon/contract/apprentice = 		"CP",
								/obj/structure/closet/wizard/souls = 		"SS",
								/obj/item/weapon/contract/wizard/tk = 		"TK",
								/obj/structure/closet/wizard/scrying = 		"SO",
								/obj/item/weapon/teleportation_scroll = 	"TS",
								/obj/item/weapon/gun/energy/staff = 		"ST",
								/obj/item/weapon/gun/energy/staff/animate =	"SA",
								/obj/item/weapon/dice/d20/cursed = 			"DW")

#define PAGE_CLASSES  0
#define PAGE_SPELLS   1
#define PAGE_CLASS    2
#define PAGE_SPELL    3

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/uses = 1
	var/page = PAGE_CLASSES

/obj/item/weapon/spellbook/tgui_data(mob/user)
	var/list/data = list(
		"page" = page,
		"data" = get_page_data()
	)

	return data

/obj/item/weapon/spellbook/proc/get_class_data(class_path)
	for(var/datum/wizard_class/class in GLOB.wizard_classes)
		if(istype(class, class_path))
			return class

/obj/item/weapon/spellbook/proc/get_classes_page_data()
	var/list/data = list()

	return data

/obj/item/weapon/spellbook/proc/get_spells_page_data()
	var/list/data = list()

	return data

/obj/item/weapon/spellbook/proc/get_page_data()
	switch(page)
		if(PAGE_CLASSES)
			return get_classes_page_data()
		if(PAGE_SPELLS)
			return get_spells_page_data()

	CRASH("Invalid page [page]")

/obj/item/weapon/spellbook/tgui_static_data(mob/user)
	var/list/data = list(
		"classes" = list()
	)

	for(var/datum/wizard_class/C in GLOB.wizard_classes)
		data["classes"] += list(C.to_list())
	
	return data

/obj/item/weapon/spellbook/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SpellBook", name)
		ui.open()

/obj/item/weapon/spellbook/attack_self(mob/user)
	tgui_interact(user, null)

#undef PAGE_CLASSES
#undef PAGE_SPELLS
#undef PAGE_CLASS
#undef PAGE_SPELL
