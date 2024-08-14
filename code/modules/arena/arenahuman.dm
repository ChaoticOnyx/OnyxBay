#define SPAWN_PROTECTION_TIME 5 SECONDS
#define DEAD_DELETE_COUNTDOWN 5 SECONDS

/mob/living/carbon/human/arenahuman
	var/datum/mind/vr_mind
	var/died = FALSE
	var/atom/movable/screen/arenahuman_timer/arenahuman_timer
	var/atom/movable/screen/arenahuman_money/arenahuman_money
	var/atom/movable/screen/sec_counter/arenahuman_sec_counter
	var/atom/movable/screen/greytide_counter/arenahuman_grey_counter

	//alpha = 127
	var/list/attackers = list()

/mob/living/carbon/human/arenahuman/New(new_loc)
	..(new_loc, SPECIES_ARENAMOB)

/mob/living/carbon/human/arenahuman/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/mob/living/carbon/human/arenahuman/LateInitialize()
	. = ..()
	SSarena.gamemode.handle_post_spawn(src)
	//CtrlClick(src)

/mob/living/carbon/human/arenahuman/updatehealth()
	. = ..()
	var/current_health = getBruteLoss() + getFireLoss() + getToxLoss() + getBrainLoss() + getOxyLoss()
	if(current_health > 200)
		death()

/mob/living/carbon/human/arenahuman/death()
	if(died) //No dying twice xd
		return

	calculate_attackers()
	died = TRUE
	. = ..() // God remains dead and we have killed him
	SSarena.gamemode.on_death(client)
	hide_body()

/mob/living/carbon/human/arenahuman/ghost()
	exit_body()
	return

/mob/living/carbon/human/arenahuman/proc/hide_body()
	//animate(src, alpha = 255, alpha = 0, time = DEAD_DELETE_COUNTDOWN)
	//animate(src, alpha = 0, time = DEAD_DELETE_COUNTDOWN)
	//qdel(src)

/mob/living/carbon/human/arenahuman/proc/exit_body()
	var/answer = alert(src, "Would you like to exit the arena?", "Alert", "Yes", "No")
	if(answer == "Yes")
		SSarena.remove_player(src.client)
	else
		return

/mob/living/carbon/human/arenahuman/CtrlClick(mob/user)
	if(user != src)
		return ..()

	if(!SSarena.gamemode.can_buy(src))
		return ..()

	var/category = show_radial_menu(src, src,  SSarena.categories)
	var/datum/ghost_arena_item/item = null

	if(istype(category, /datum/ghost_arena_item/pistol))
		item = show_radial_menu(src, src,  SSarena.pistols)
	else if(istype(category, /datum/ghost_arena_item/heavy))
		item = show_radial_menu(src, src,  SSarena.rifles)
	else if(istype(category, /datum/ghost_arena_item/melee))
		item = show_radial_menu(src, src,  SSarena.melee)
	else if(istype(category, /datum/ghost_arena_item/utility))
		item = show_radial_menu(src, src,  SSarena.utilities)
	else if(istype(category, /datum/ghost_arena_item/armor))
		item = show_radial_menu(src, src,  SSarena.armors)

	if(isnull(item))
		return

	var/datum/ghost_arena_player/player_datum = SSarena.players[client]
	if(!istype(player_datum))
		return

	if(player_datum.money < item.price)
		to_chat(user, SPAN_WARNING("You don't have enough money!"))
		return

	player_datum.money -= item.price
	var/obj/item/I = new item.item_path(src)
	if(!usr.put_in_any_hand_if_possible(I))
		I.forceMove(get_turf(loc))

/mob/living/carbon/human/arenahuman/Life(mob/user)
	update_uis()
	return ..()

/mob/living/carbon/human/arenahuman/proc/update_uis()
	if(!client)
		return

	arenahuman_timer.overlays.Cut()
	arenahuman_money.overlays.Cut()
	arenahuman_sec_counter.overlays.Cut()
	arenahuman_grey_counter.overlays.Cut()

	var/image/time_image = image(loc = src.loc, layer = ABOVE_HUD_LAYER)

	var/timeleft

	switch(SSarena.gamemode.gamemode_stage)
		if(GA_GAMEMODE_FREEZETIME)
			timeleft = SPAN_INFO("Freezetime: [round((SSarena.gamemode.round_start_time + SSarena.gamemode.freezetime - world.time)/10)]")
		if(GA_GAMEMODE_RUNNING)
			timeleft = round((SSarena.gamemode.round_start_time + SSarena.gamemode.round_duration - world.time)/10)
			timeleft = "[add_zero(num2text((timeleft / 60) % 60),2)]:[add_zero(num2text(timeleft % 60), 2)]"
		if(GA_GAMEMODE_POSTROUND)
			timeleft = SPAN_INFO("Time until new round: [round((SSarena.gamemode.round_start_time + SSarena.gamemode.round_duration + SSarena.gamemode.freezetime - world.time)/10)]")

	time_image.maptext = MAPTEXT(timeleft)

	var/datum/ghost_arena_player/player_datum = SSarena.players[client]
	if(!istype(player_datum))
		return

	var/image/money_image = image(loc = src.loc, layer = ABOVE_HUD_LAYER)
	money_image.maptext = MAPTEXT("[player_datum.money]$")

	var/image/sec_image = image(loc = src.loc, layer = ABOVE_HUD_LAYER)
	var/image/grey_image = image(loc = src.loc, layer = ABOVE_HUD_LAYER)

	if(istype(SSarena.gamemode, /datum/ghost_arena_gamemode/coop))
		var/datum/ghost_arena_gamemode/coop/gamemode = SSarena.gamemode
		sec_image.maptext = MAPTEXT("Security: [gamemode.sec_score]")
		grey_image.maptext = MAPTEXT("Greytide: [gamemode.grey_score]")
		arenahuman_sec_counter.overlays += sec_image
		arenahuman_grey_counter.overlays += grey_image

	arenahuman_money.overlays += money_image
	arenahuman_timer.overlays += time_image

/mob/living/carbon/human/arenahuman/proc/calculate_attackers()
	var/datum/ghost_arena_player/player_datum = SSarena.players[client]

	if(player_datum)
		player_datum.deaths += 1

	if(!last_attacker_)
		return

	for(var/client/killer in SSarena.players)
		if(killer.key != last_attacker_.client.key)
			continue

		var/datum/ghost_arena_player/killer_datum = SSarena.players[killer]
		killer_datum.kills += 1
		killer_datum.money += MONEY_PER_KILL

	var/list/messages = list("put to sleep", "unalived", "killed", "pwned", "removed", "destroyed")
	for(var/client/player in SSarena.players)
		to_chat(player, SPAN_DANGER("[last_attacker_.name] [pick(messages)] [src.client]!"))

/mob/living/carbon/human/arenahuman/can_fall()
	return FALSE

/mob/living/carbon/human/arenahuman/verb/scoreboard()
	set name = "Arena Scoreboard"
	set category = "Arena"

	SSarena.tgui_interact(src)

/mob/living/carbon/human/arenahuman/verb/suicide()
	set name = "Succumb"
	set category = "Arena"

	if(incapacitated(INCAPACITATION_ALL))
		death()
	else
		to_chat(usr, SPAN_WARNING("You must be incapacitated to succumb!"))

/mob/living/carbon/human/arenahuman/verb/quit()
	set name = "Leave arena"
	set category = "IC"

	exit_body()
