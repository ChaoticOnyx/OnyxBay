GLOBAL_LIST_INIT(abductor_teams,list("Create New Team"))
/datum/abductor
	var/datum/team/abductor_team/team
	var/agent = FALSE
	var/scientist = FALSE


/datum/abductor/proc/create_team(datum/team/abductor_team/new_team)
	if(!new_team)
		return
	if(!istype(new_team))
		log_debug("Wrong team type passed to [type] initialization.")
	team = new_team

/datum/abductor/proc/get_team()
	return team

//Abductors teams
/datum/team/abductor_team
	name = "team"
	member_name = "abductor"
	var/team_number
	var/list/datum/mind/abductees = list()
	var/static/team_count = 1

/datum/team/abductor_team/New()
	..()
	GLOB.abductor_teams+=src
	team_number = team_count++
	name = "Mothership [pick(GLOB.possible_abductor_names)]" //TODO Ensure unique and actual alieny names
	add_objective(new /datum/objective/experiment)


/datum/team/abductor_team/is_solo()
	return FALSE

/datum/team/abductor_team/proc/add_objective(datum/objective/O)
	O.team = src
	O.update()
	objectives += O
