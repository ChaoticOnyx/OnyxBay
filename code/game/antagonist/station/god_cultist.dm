#define IS_GODCULTIST(mob) is_god_cultist(mob)
#define IS_DEITYSFOLLOWER(deity, mob) is_deitys_follower(deity, mob)
GLOBAL_DATUM_INIT(godcult, /datum/antagonist/godcultist, new)

/datum/antagonist/godcultist
	id = MODE_GODCULTIST
	role_text = "God Cultist"
	role_text_plural = "God Cultists"
	restricted_jobs = list(/datum/job/merchant, /datum/job/iaa, /datum/job/captain, /datum/job/hos)
	additional_restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/detective)
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/chaplain, /datum/job/barmonkey)
	feedback_tag = "godcult_objective"
	antag_indicator = "hudcultist"
	faction_verb = /mob/living/proc/dpray
	welcome_text = "You are under the guidance of a powerful otherwordly being. Spread its will and keep your faith.<br>Use dpray to communicate directly with your master!<br>Ask your master for spells to start building!"
	victory_text = "The cult wins! It has succeeded in serving its dark masters!"
	loss_text = "The staff managed to stop the cult!"
	victory_feedback_tag = "win - cult win"
	loss_feedback_tag = "loss - staff stopped the cult"
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	hard_cap = 5
	hard_cap_round = 6
	initial_spawn_req = 2
	initial_spawn_target = 2
	antaghud_indicator = "hudcultist"

/datum/antagonist/godcultist/Initialize()
	. = ..()
	if(config.game.godcultist_min_age)
		min_player_age = config.game.godcultist_min_age

/datum/antagonist/godcultist/add_antagonist_mind(datum/mind/player, ignore_role, nonstandard_role_type, nonstandard_role_msg, max_stat, mob/living/deity/deity, evo_holder)
	if(!..())
		return FALSE

	player.godcultist = new /datum/godcultist(player.current, deity, evo_holder)

	return TRUE

/datum/antagonist/godcultist/get_extra_panel_options(datum/mind/player)
	return "<a href='?src=\ref[src];selectgod=\ref[player]'>\[Select Deity\]</a>"

/datum/antagonist/godcultist/Topic(href, href_list)
	if(..())
		return TRUE
	if(href_list["selectgod"])
		var/list/god_list = list()
		if(GLOB.deity && GLOB.deity.current_antagonists.len)
			for(var/m in GLOB.deity.current_antagonists)
				var/datum/mind/mind = m
				god_list += mind.current
		else
			for(var/mob/living/deity/deity in GLOB.player_list)
				god_list += deity
		if(god_list.len)
			var/mob/living/deity/D = input(usr, "Select a deity for this cultist.") in null|god_list
			if(D)
				var/datum/mind/player = locate(href_list["selectgod"])
				log_and_message_admins("has set [key_name(player.current)] to be a minion of [key_name(D)]")
		else
			to_chat(usr, "<span class='warning'>There are no deities to be linked to.</span>")
		return TRUE

/datum/antagonist/godcultist/proc/get_deity(datum/mind/player)
	return

/mob/living/proc/dpray(msg as text)
	set category = "Abilities"

	if(!src.mind || !GLOB.godcult || !GLOB.godcult.is_antagonist(mind))
		return
	msg = sanitize(msg)
	var/mob/living/deity/D = GLOB.godcult.get_deity(mind)
	if(!D || !msg)
		return

	//Make em wait a few seconds.
	src.visible_message("\The [src] bows their head down, muttering something.", "<span class='notice'>You send the message \"[msg]\" to your master.</span>")
	to_chat(D, "<span class='notice'>\The [src] (<A href='?src=\ref[D];jump=\ref[src];'>J</A>) prays, \"[msg]\"</span>")
	log_and_message_admins("dprayed, \"[msg]\" to \the [key_name(D)]")

/proc/is_god_cultist(mob/player)
	if(!GLOB.godcult || !player.mind)
		return FALSE

	if(player.mind in GLOB.godcult.current_antagonists)
		return TRUE

/proc/is_deitys_follower(mob/living/deity/D, mob/player)
	if(!is_god_cultist(player))
		return FALSE

	if(!istype(D))
		return FALSE

	if(player in D.followers)
		return TRUE

/datum/godcultist
	var/mob/living/deity/linked_deity
	var/mob/living/godcultist
	/// A universal counter to track progress e.t.c.
	var/points = 0
	var/spent_points = 0
	var/datum/evolution_holder/evo_holder

/datum/godcultist/New(mob/living/godcultist, mob/living/deity/linked_deity, evo_holder)
	. = ..()
	grant_verb(godcultist, /mob/living/carbon/human/proc/godcultist_tgui_interact)
	src.godcultist = godcultist
	src.linked_deity = linked_deity
	src.evo_holder = new evo_holder(godcultist)

/datum/godcultist/Destroy()
	revoke_verb(godcultist, /mob/living/carbon/human/proc/godcultist_tgui_interact)
	if(istype(evo_holder))
		QDEL_NULL(evo_holder)
	return ..()

/datum/godcultist/proc/spend_points(amount)
	if(points - amount < 0)
		return FALSE

	points -= amount
	spent_points += amount
	for(var/datum/modifier/sin/sin in godcultist.modifiers)
		sin.check_stage(spent_points)

	return TRUE

/datum/godcultist/tgui_state(mob/user)
	return GLOB.tgui_always_state

/datum/godcultist/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Godcultist")
		ui.open()

/datum/godcultist/tgui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("evolve")
			godcultist.evolve_deity(text2path(params["pack_name"]))
			return TRUE

/datum/godcultist/tgui_data(mob/user)
	var/list/data = list(
		"points" = points,
	)
	data["evolutionItems"] = list()
	for(var/datum/evolution_category/cat in evo_holder?.evolution_categories)
		var/list/cat_data = list(
			"name" = cat.name
		)

		for(var/datum/evolution_package/pack in cat.items)
			var/list/pack_data = list(
				"name" = pack.name,
				"desc" = pack.desc,
				"path" = pack.type,
				"cost" = pack.cost,
				"icon" = pack.icon,
				"tier" = pack.tier,
				"purchased" = pack.purchased,
				"unlocked" = pack.check_unlocked(evo_holder),
				"unlocked_by" = pack.unlocked_by,
			)
			cat_data["packages"] += list(pack_data)

		data["evolutionItems"] += list(cat_data)

	return data

/mob/living/carbon/human/proc/godcultist_tgui_interact()
	set name = "Evolution Menu"
	set category = "Godhood"

	mind.godcultist?.tgui_interact(src)
