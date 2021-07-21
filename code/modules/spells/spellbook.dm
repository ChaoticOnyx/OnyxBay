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
	var/temp = null
	var/investing_time = 0 // What time we target forr a return on our spell investment.
	var/has_sacrificed = 0 // Whether we have already got our sacrifice bonus for the current investment.

/obj/item/weapon/spellbook/attack_self(mob/user as mob)
	if(user.mind)
		if(!GLOB.wizards.is_antagonist(user.mind))
			to_chat(user, "You can't make heads or tails of this book.")
			return
		if(spellbook.book_flags & LOCKED)
			if(user.mind.special_role == "apprentice")
				to_chat(user, "<span class='warning'>Drat! This spellbook's apprentice proof lock is on!.</span>")
				return
			else
				to_chat(user, "You notice the apprentice proof lock is on. Luckily you are beyond such things and can open it anyways.")

	interact(user)

/obj/item/weapon/spellbook/proc/make_sacrifice(obj/item/I, mob/user, reagent)
	if(has_sacrificed)
		return
	if(reagent)
		var/datum/reagents/R = I.reagents
		R.remove_reagent(reagent,5)
	else
		if(istype(I,/obj/item/stack))
			var/obj/item/stack/S = I
			if(S.amount < S.max_amount)
				to_chat(usr, "<span class='warning'>You must sacrifice [S.max_amount] stacks of [S]!</span>")
				return
		user.remove_from_mob(I)
		qdel(I)
	to_chat(user, "<span class='notice'>Your sacrifice was accepted!</span>")
	has_sacrificed = 1
	// Subtract 10 minutes. Make sure it doesn't act funky at the beginning of the game.
	investing_time = max(investing_time - 10 MINUTES, 1)

/obj/item/weapon/spellbook/attackby(obj/item/I, mob/user)
	if(investing_time && !has_sacrificed)
		var/list/objects = spellbook.sacrifice_objects
		if(objects && objects.len)
			for(var/type in objects)
				if(istype(I,type))
					make_sacrifice(I,user)
					return
		if(I.reagents)
			var/datum/reagents/R = I.reagents
			var/list/reagent_list = spellbook.sacrifice_reagents
			if(reagent_list && reagent_list.len)
				for(var/id in reagent_list)
					if(R.has_reagent(id,5))
						make_sacrifice(I,user, id)
						return 1
	..()

/obj/item/weapon/spellbook/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "SpellBook", name)
		ui.open()

/obj/item/weapon/spellbook/tgui_data(mob/user)
	var/list/data = list(
		"flags" = list(
			"norevert" = spellbook.book_flags & NOREVERT,
			"locked" = spellbook.book_flags & LOCKED,
			"can_make_contracts" = spellbook.book_flags & CAN_MAKE_CONTRACTS,
			"investable" = spellbook.book_flags & INVESTABLE
		),
		"spells" = list()
	)

	for(var/S in spellbook.spells)
		var/list/spell_data = list(
			"type" = "",
			"name" = initial(S.name),
			"description" = initial(S.desc),
			"information" = ""
		)

		if(ispath(S, /datum/spellbook))
			var/datum/spellbook/book = S
			data["type"] = "spellbook"
			data["information"] = "[initial(book.max_uses)] Spell Slots"
		else if(ispath(S, /obj))
			var/obj/artefact = S
			data["type"] = "artefact"
		else if (ispath(S, /datum/spell))
			var/datum/spell/spell = S
			data["type"] = "spell"
			var/flags = initial(spell.spell_flags)

			if(flags & NEEDSCLOTHES)
				data["information"] = "Needs clothing"
		else
			CRASH("Invalid path: [S]")

		data["spells"] += list(spell_data)

	return data

/obj/item/weapon/spellbook/tgui_state(mob/user)
	if(!istype(user))
		return UI_CLOSE

	// Make sure no scrubs get behind the lock
	if((spellbook.book_flags & LOCKED) && user?.mind.special_role == "apprentice")
		return UI_CLOSE

	return ..()

/obj/item/weapon/spellbook/Initialize()
	. = ..()
	GLOB.moved_event.register(src, src, /obj/item/weapon/spellbook/proc/check_z_level)

/obj/item/weapon/spellbook/proc/check_z_level()
	var/turf/T = get_turf(src)
	if(!T || isNotStationLevel(T.z))
		if(investing_time)
			src.visible_message(SPAN_WARNING("<b>\The [src]</b> emits a cranky chime."))
			if(uses < spellbook.max_uses)
				uses++
			investing_time = 0
			STOP_PROCESSING(SSobj, src)

/obj/item/weapon/spellbook/proc/invest()
	var/turf/T = get_turf(src)
	if(!T || isNotStationLevel(T.z))
		return "Your invest powers don't work in your current location!\n You must be on the station level for the successful investment."
	if(uses < 1)
		return "You don't have enough slots to invest!"
	if(investing_time)
		return "You can only invest one spell slot at a time."
	uses--
	START_PROCESSING(SSobj, src)
	investing_time = world.time + (15 MINUTES)
	return "You invest a spellslot and will recieve two in return in 15 minutes."

/obj/item/weapon/spellbook/Process()
	if(investing_time && investing_time <= world.time)
		src.visible_message("<b>\The [src]</b> emits a soft chime.")
		uses += 2
		if(uses > spellbook.max_uses)
			spellbook.max_uses = uses
		investing_time = 0
		has_sacrificed = 0
		STOP_PROCESSING(SSobj, src)
	return 1

/obj/item/weapon/spellbook/Destroy()
	GLOB.moved_event.unregister(src, src, /obj/item/weapon/spellbook/proc/check_z_level)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/weapon/spellbook/proc/send_feedback(path)
	if(ispath(path, /datum/spellbook))
		var/datum/spellbook/S = path
		feedback_add_details("wizard_spell_learned","[initial(S.feedback)]")
	else if(ispath(path, /datum/spell))
		var/datum/spell/S = path
		feedback_add_details("wizard_spell_learned","[initial(S.feedback)]")
	else if(ispath(path,/obj))
		feedback_add_details("wizard_spell_learned","[artefact_feedback[path]]")

/obj/item/weapon/spellbook/proc/add_spell(mob/user, spell_path)
	for(var/datum/spell/S in user.mind.learned_spells)
		if(istype(S,spell_path))
			if(!S.can_improve())
				return
			if(S.can_improve(Sp_SPEED) && S.can_improve(Sp_POWER))
				switch(alert(user, "Do you want to upgrade this spell's speed or power?", "Spell upgrade", "Speed", "Power", "Cancel"))
					if("Speed")
						return S.quicken_spell()
					if("Power")
						return S.empower_spell()
					else
						return
			else if(S.can_improve(Sp_POWER))
				return S.empower_spell()
			else if(S.can_improve(Sp_SPEED))
				return S.quicken_spell()

	var/datum/spell/S = new spell_path()
	user.add_spell(S)
	return "You learn the spell [S]"
