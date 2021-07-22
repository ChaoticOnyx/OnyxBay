// Spells/spellbooks have a variable for this but as artefacts are literal items they do not,
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

// These constants must be the same in SpellBook.tsx.
// Pages that contains list of all objects of a type:
#define PAGE_CLASSES   0
#define PAGE_SPELLS    1
#define PAGE_ARTEFACTS 2
// Pages about one thing:
#define PAGE_SPELL     3
#define PAGE_ARTEFACT  4
#define PAGE_CHARACTER 5

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/uses = 1
	/// A page that will be opened in the UI.
	var/page = PAGE_CLASSES
	/// A path of spell/class or whatever we inspecting in the UI.
	var/inspecting_path = null

/obj/item/weapon/spellbook/tgui_data(mob/user)
	var/list/data = list(
		"page" = page,
		"inspecting_path" = inspecting_path
	)

	return data

/obj/item/weapon/spellbook/tgui_static_data(mob/user)
	var/list/data = list(
		"classes" = list()
	)

	for(var/datum/wizard_class/C in GLOB.wizard_classes)
		data["classes"] += list(C.to_list())
	
	return data

/obj/item/weapon/spellbook/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_page")
			page = params["page"]
			return TRUE
		if("set_inspecting")
			inspecting_path = params["path"]
			return TRUE

/obj/item/weapon/spellbook/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SpellBook", name)
		ui.open()

/obj/item/weapon/spellbook/attack_self(mob/user)
	tgui_interact(user, null)

#undef PAGE_CLASSES
#undef PAGE_SPELLS
#undef PAGE_ARTEFACTS
#undef PAGE_CLASS
#undef PAGE_SPELL
#undef PAGE_ARTEFACT
#undef PAGE_CHARACTER
