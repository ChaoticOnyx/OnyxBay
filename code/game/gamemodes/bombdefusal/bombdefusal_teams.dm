// ========== BOMB DEFUSAL - TEAMS & PLAYER DATA ==========

/datum/bombdefusal_team
	var/name = "Unnamed Team"
	var/datum/mind/captain
	var/list/datum/bombdefusal_player_data/members = list()
	var/list/datum/mind/pending_requests = list()  // Players waiting for captain approval
	var/color = "#FFFFFF"
	var/current_side // BOMBDEFUSAL_TEAM_T or BOMBDEFUSAL_TEAM_CT for current half

/datum/bombdefusal_team/New(team_name, datum/mind/team_captain)
	..()
	name = team_name
	captain = team_captain

/datum/bombdefusal_team/proc/is_full(team_size)
	return members.len >= team_size

/datum/bombdefusal_team/proc/add_member(datum/bombdefusal_player_data/player_data)
	members += player_data

/datum/bombdefusal_team/proc/remove_member(datum/bombdefusal_player_data/player_data)
	members -= player_data

/datum/bombdefusal_team/proc/get_alive_members()
	var/list/alive = list()
	for(var/datum/bombdefusal_player_data/pd in members)
		if(!pd.owner || !pd.owner.current)
			continue
		var/mob/living/L = pd.owner.current
		if(istype(L) && L.stat != DEAD && !pd.is_dead)
			alive += pd

	return alive

/datum/bombdefusal_team/proc/get_alive_count()
	return get_alive_members().len

// ========== PLAYER DATA ==========

/datum/bombdefusal_player_data
	var/datum/mind/owner
	var/datum/bombdefusal_team/team
	var/datum/bombdefusal_match/match

	// Economy
	var/money = 800
	var/loss_streak = 0

	// Stats
	var/kills = 0
	var/deaths = 0
	var/assists = 0

	var/is_dead = FALSE
	var/needs_reequip = FALSE  // Set on death/halftime; cleared after equip_player

	// Original body reference for respawning with same appearance
	var/mob/living/carbon/human/bombdefusal/original_body
	// Saved appearance data (survives gibbing/body destruction)
	var/list/saved_appearance

	// HUD elements (per-player screen objects)
	var/atom/movable/screen/bombdefusal/money_display
	var/atom/movable/screen/bombdefusal/timer_display
	var/atom/movable/screen/bombdefusal/killfeed_display
	var/list/image/team_marker_images = list()  // Team markers visible to this player
	var/atom/movable/screen/bombdefusal/announce_display

/datum/bombdefusal_player_data/New(datum/mind/player_mind, datum/bombdefusal_team/player_team)
	..()
	owner = player_mind
	team = player_team

/datum/bombdefusal_player_data/proc/reset_for_round()
	is_dead = FALSE

/datum/bombdefusal_player_data/proc/reset_for_match(starting_money)
	money = starting_money
	kills = 0
	deaths = 0
	assists = 0
	loss_streak = 0
	reset_for_round()

/datum/bombdefusal_player_data/proc/award_money(amount, max_money)
	money = min(money + amount, max_money)

/datum/bombdefusal_player_data/proc/can_afford(price)
	return money >= price

/datum/bombdefusal_player_data/proc/spend_money(amount)
	money = max(money - amount, 0)
