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

/obj/item/weapon/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/uses = 1
