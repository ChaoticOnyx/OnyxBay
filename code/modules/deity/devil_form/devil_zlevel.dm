GLOBAL_LIST_EMPTY(devilspawns)
GLOBAL_LIST_INIT(devilspecies, list(SPECIES_HUMAN, SPECIES_TAJARA, SPECIES_UNATHI, SPECIES_SKRELL, SPECIES_SWINE))

/datum/map_template/devil_level
	name = "House of hope"
	mappaths = list("maps/devil_lair.dmm")

/obj/effect/landmark/devil_spawn
	name = "Devil's spawn"

/obj/effect/landmark/devil_spawn/Initialize()
	. = ..()
	GLOB.devilspawns += src

/obj/effect/landmark/devil_spawn/Destroy()
	GLOB.devilspawns -= src
	return ..()

/obj/machinery/acting/changer/devilschanger
	name = "Mirror of Many Faces"
	desc = "The mouse smiled brightly, it outfoxed the cat. Then down came the claw, and that, love, was that."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror_broke"
	anchored = TRUE
	density = FALSE

/obj/machinery/acting/changer/devilschanger/attack_hand(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	H.change_appearance(APPEARANCE_ALL, H.loc, H, TRUE, GLOB.devilspecies, state = GLOB.z_state)
	H.rename_self()

/obj/effect/devilsportal
	name = "portal"
	desc = "Looks unstable. Best to test it with the clown."
	icon = 'icons/obj/portals.dmi'
	icon_state = "portal"
	density = FALSE
	unacidable = TRUE
	anchored = TRUE

/obj/effect/devilsportal/Crossed(AM)
	teleport(AM)

/obj/effect/devilsportal/attack_hand(mob/user)
	teleport(user)

/obj/effect/devilsportal/proc/teleport(atom/movable/M, ignore_checks = FALSE)
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/user = M
	if(tgui_alert(user, "Teleport?", "Teleport", list("Yes", "No")) == "No")
		return

	if(!user.mind.assigned_role)
		user.mind.assigned_role = "Assistant"

	job_master.EquipRank(user, user.mind.assigned_role, TRUE)

	var/datum/job/job = job_master.GetJob(user.mind.assigned_role)

	var/spawnpoint = pick(GLOB.latejoin)

	if(tgui_alert(user, "Announce arrival?", "Announce arrival?", list("Yes","No")) == "Yes")
		INVOKE_ASYNC(src, nameof(.proc/announce_arrival), user, job)

	user.forceMove(spawnpoint)

/obj/effect/devilsportal/proc/announce_arrival(mob/living/carbon/human/user, datum/job/job)
	var/datum/spawnpoint/arrivals/spawn_point = new()
	SSannounce.announce_arrival(user.real_name, job, spawn_point)
	CreateModularRecord(user)

/area/devilslair
	name = "\improper Devil's lair"
	icon_state = "centcom"
	requires_power = FALSE
	dynamic_lighting = FALSE
