// Spells/spellbooks have a variable for this but as artefacts are literal items they do not,
// so we do this instead.
var/list/artefact_feedback = list(
	/obj/structure/closet/wizard/armor        = "HS",
	/obj/item/weapon/gun/energy/staff/focus   = "MF",
	/obj/item/weapon/monster_manual           = "MA",
	/obj/item/weapon/magic_rock               = "RA",
	/obj/item/weapon/contract/apprentice      = "CP",
	/obj/structure/closet/wizard/souls        = "SS",
	/obj/item/weapon/contract/wizard/tk       = "TK",
	/obj/structure/closet/wizard/scrying      = "SO",
	/obj/item/weapon/teleportation_scroll     = "TS",
	/obj/item/weapon/gun/energy/staff         = "ST",
	/obj/item/weapon/gun/energy/staff/animate = "SA",
	/obj/item/weapon/dice/d20/cursed          = "DW"
)

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
	var/page = 0
	/// A path of spell/class or whatever we inspecting in the UI.
	var/inspecting_path = null

/obj/item/weapon/spellbook/tgui_data(mob/user)
	var/datum/wizard/W = user.mind.wizard

	var/list/data = list(
		"page" = page,
		"inspecting_path" = inspecting_path,
		"user" = list(
			"class" = W.class?.type,
			"points" = W.points,
			"name" = user.name
		)
	)

	return data

/obj/item/weapon/spellbook/tgui_static_data(mob/user)
	var/list/data = list(
		"classes" = list()
	)

	for(var/T in GLOB.wizard_classes)
		var/datum/wizard_class/C = GLOB.wizard_classes[T]
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
		if("choose_class")
			set_wizard_class(usr, text2path(params["path"]))
			return TRUE
		if("buy_artifact")
			buy_artifact(usr, text2path(params["path"]))
			return TRUE

/obj/item/weapon/spellbook/proc/set_wizard_class(mob/user, datum/wizard_class/path)
	if(!(path in subtypesof(/datum/wizard_class)))
		CRASH("Invalid wizard class [path]")

	if(user.mind.wizard.class)
		to_chat(user, SPAN("warning", "You can't have more than one class at the moment."))
		return

	user.mind.wizard.set_class(path)
	to_chat(user, SPAN("notice", "You are now a [user.mind.wizard.class.name]!"))

/obj/item/weapon/spellbook/proc/buy_artifact(mob/user, obj/path)
	var/datum/wizard/W = user.mind.wizard

	if(!W.class)
		CRASH("Trying to buy an artifact without any wizard class assigned.")

	if(!W.class.has_artifact(path))
		CRASH("Artifact [path] does not exist in [W.class]")
	
	var/cost = W.class.get_artifact_cost(path)

	if(!W.can_spend(cost))
		to_chat(user, SPAN("warning", "You don't have enough points to purchase this artifact."))
		return
	
	W.spend(cost)
	feedback_add_details("wizard_artifact_purchased", artefact_feedback[path])
	new path(usr.loc)

/obj/item/weapon/spellbook/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SpellBook", name)
		ui.open()

/obj/item/weapon/spellbook/attack_self(mob/user)
	if(!GLOB.wizards.is_antagonist(user.mind))
		to_chat(user, "You can't make heads or tails of this book.")
		return

	tgui_interact(user, null)
