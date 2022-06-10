// Spells/spellbooks have a variable for this but as artefacts are literal items they do not,
// so we do this instead.
var/list/artefact_feedback = list(
	/obj/structure/closet/wizard/armor        = "HS",
	/obj/item/gun/energy/staff/focus   = "MF",
	/obj/item/monster_manual           = "MA",
	/obj/item/magic_rock               = "RA",
	/obj/item/contract/apprentice      = "CP",
	/obj/structure/closet/wizard/souls        = "SS",
	/obj/item/contract/wizard/tk       = "TK",
	/obj/structure/closet/wizard/scrying      = "SO",
	/obj/item/teleportation_scroll     = "TS",
	/obj/item/gun/energy/staff         = "ST",
	/obj/item/gun/energy/staff/animate = "SA",
	/obj/item/dice/d20/cursed          = "DW"
)

/obj/item/spellbook
	name = "spell book"
	desc = "The legendary book of spells of the wizard."
	icon = 'icons/obj/library.dmi'
	icon_state = "spellbook"
	throw_range = 5
	w_class = ITEM_SIZE_NORMAL
	var/uses = 1
	/// A page that will be opened in the UI.
	var/page = 0
	/// A path of spell/artifact or whatever we inspecting in the UI.
	var/inspecting_path = null

/obj/item/spellbook/tgui_data(mob/user)
	var/datum/wizard/W = user.mind.wizard

	var/list/data = list(
		"page"            = page,
		"inspecting_path" = inspecting_path,
		"user" = list(
			"class"           = W.class?.type,
			"points"          = W.points,
			"name"            = user.name,
			"spells"          = list(),
			"can_reset_class" = W.can_reset_class,
		)
	)

	for(var/datum/spell/S in user.mind.learned_spells)
		data["user"]["spells"] += list(list(
			"path"        = S.type,
			"levels" = list(
				list(
					"type" = SP_SPEED,
					"level" = S.spell_levels[SP_SPEED],
					"max" = S.level_max[SP_SPEED],
					"can_upgrade" = S.can_improve(SP_SPEED)
				),
				list(
					"type" = SP_POWER,
					"level" = S.spell_levels[SP_POWER],
					"max" = S.level_max[SP_POWER],
					"can_upgrade" = S.can_improve(SP_POWER)
				)
			),
			"total_upgrades" = S.level_max[SP_TOTAL]
		))

	return data

/obj/item/spellbook/tgui_static_data(mob/user)
	var/list/data = list(
		"classes" = list()
	)

	for(var/T in GLOB.wizard_classes)
		var/datum/wizard_class/C = GLOB.wizard_classes[T]
		data["classes"] += list(C.to_list())

	return data

/obj/item/spellbook/tgui_act(action, list/params)
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
		if("buy_spell")
			buy_spell(usr, text2path(params["path"]))
			return TRUE
		if("reset_class")
			reset_class(usr)
			return TRUE
		if("upgrade_spell")
			upgrade_spell(usr, text2path(params["path"]), params["type"])
			return TRUE
		if("contract")
			make_contract(usr, text2path(params["path"]))
			return TRUE

/obj/item/spellbook/proc/make_contract(mob/user, spell_path)
	var/datum/wizard/W = user.mind.wizard
	var/spell_cost = W.class.get_spell_cost(spell_path)

	ASSERT(W.class.can_make_contracts)
	ASSERT(W.can_spend(spell_cost))

	W.spend(spell_cost)
	var/obj/O = new /obj/item/contract/boon(get_turf(user), spell_path)
	to_chat(user, "You have purchased \the [O].")

/obj/item/spellbook/proc/upgrade_spell(mob/user, datum/spell/path, upgrade_type)
	var/datum/wizard/W = user.mind.wizard
	var/datum/spell/spell_to_upgrade = null


	ASSERT(path in subtypesof(/datum/spell))

	for(var/datum/spell/S in user.mind.learned_spells)
		if(istype(S, path))
			spell_to_upgrade = S
			break

	if(!spell_to_upgrade)
		CRASH("Trying to upgrade a not learned spell.")

	if(!spell_to_upgrade.can_improve(upgrade_type))
		to_chat(user, SPAN("warning", "You can't do that type of upgrade more."))
		return

	if(!W.can_spend(1))
		to_chat(user, SPAN("warning", "You don't have enough points to upgrade the spell!"))
		return

	W.spend(1)
	switch(upgrade_type)
		if(SP_POWER)
			ASSERT(spell_to_upgrade.empower_spell())
			to_chat(user, "You empower [spell_to_upgrade]!")
		if(SP_SPEED)
			ASSERT(spell_to_upgrade.quicken_spell())
			to_chat(user, "You quicken [spell_to_upgrade]!")
		else
			CRASH("Unknown upgrade type [upgrade_type]")

/obj/item/spellbook/proc/reset_class(mob/user)
	var/datum/wizard/W = user.mind.wizard
	var/area/wizard_station/A = get_area(user)

	if(!istype(A))
		to_chat(user, SPAN("warning", "You must be in the wizard academy to re-memorize your spells."))
		return

	ASSERT(W.class)
	ASSERT(W.can_reset_class)

	user.spellremove()
	W.reset()
	to_chat(user, "All spells have been removed. You may now memorize a new set of spells.")
	feedback_add_details("wizard_class_reset", "UM")

/obj/item/spellbook/proc/buy_spell(mob/user, datum/spell/path)
	var/datum/wizard/W = user.mind.wizard

	ASSERT(path in subtypesof(/datum/spell))
	ASSERT(W.class.has_spell(path))

	for(var/datum/spell/S in user.mind.learned_spells)
		if(S.type == path)
			to_chat(user, SPAN("warning", "You already know the spell [S]."))
			return

	var/cost = W.class.get_spell_cost(path)

	ASSERT(W.can_spend(cost))

	W.spend(cost)
	var/datum/spell/new_spell = new path
	feedback_add_details("wizard_spell_purchased", new_spell.feedback)
	user.add_spell(new_spell)
	to_chat(user, "You learn the spell [new_spell].")

/obj/item/spellbook/proc/set_wizard_class(mob/user, datum/wizard_class/path)
	ASSERT(path in subtypesof(/datum/wizard_class))

	if(user.mind.wizard.class)
		to_chat(user, SPAN("warning", "You can't have more than one class at the moment."))
		return

	user.mind.wizard.set_class(path)
	feedback_add_details("wizard_class_choose", user.mind.wizard.class.feedback_tag)
	to_chat(user, SPAN("notice", "You are now \a [user.mind.wizard.class.name]!"))

/obj/item/spellbook/proc/buy_artifact(mob/user, obj/path)
	var/datum/wizard/W = user.mind.wizard

	ASSERT(W.class.has_artifact(path))

	var/cost = W.class.get_artifact_cost(path)

	ASSERT(W.can_spend(cost))
	W.can_reset_class = FALSE

	W.spend(cost)
	feedback_add_details("wizard_artifact_purchased", artefact_feedback[path])
	var/obj/A = new path(get_turf(usr))
	to_chat(user, "You have purchased \a [A].")

/obj/item/spellbook/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SpellBook", name)
		ui.open()

/obj/item/spellbook/tgui_state(mob/user)
	if(!GLOB.wizards.is_antagonist(user.mind))
		return UI_CLOSE

	return ..()

/obj/item/spellbook/tgui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/reaver)
	)

/obj/item/spellbook/attack_self(mob/user)
	if(!GLOB.wizards.is_antagonist(user.mind))
		to_chat(user, "You can't make heads or tails of this book.")
		return

	tgui_interact(user, null)
