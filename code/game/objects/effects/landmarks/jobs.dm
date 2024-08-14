// Roundstart landmarks.
/obj/effect/landmark/start
	name = "start"
	icon_state = "landmark_assistant"
	should_be_added = TRUE

/obj/effect/landmark/start/crew/New()
	tag = "start*[name]"
	return ..()

// Heads
/obj/effect/landmark/start/crew/captain
	name = "Captain"
	icon_state = "landmark_captain"

/obj/effect/landmark/start/crew/hop
	name = "Head of Personnel"
	icon_state = "landmark_hop"

// Silicon
/obj/effect/landmark/start/crew/ai
	name = "AI"
	icon_state = "landmark_ai"

/obj/effect/landmark/start/crew/cyborg
	name = "Cyborg"
	icon_state = "landmark_cyborg"

// Service
/obj/effect/landmark/start/crew/janitor
	name = "Janitor"
	icon_state = "landmark_janitor"

/obj/effect/landmark/start/crew/chef
	name = "Chef"
	icon_state = "landmark_chef"

/obj/effect/landmark/start/crew/gartender
	name = "Gardener"
	icon_state = "landmark_botanist"

/obj/effect/landmark/start/crew/bartender
	name = "Bartender"
	icon_state = "landmark_bar"

/obj/effect/landmark/start/crew/barmonkey
	name = "Waiter"
	icon_state = "landmark_monkey"

// Civilian
/obj/effect/landmark/start/crew/assistant
	name = "Assistant"
	icon_state = "landmark_assistant"

/obj/effect/landmark/start/crew/chaplain
	name = "Chaplain"
	icon_state = "landmark_chaplain"

/obj/effect/landmark/start/crew/librarian
	name = "Librarian"
	icon_state = "landmark_librarian"

/obj/effect/landmark/start/crew/iaa
	name = "Internal Affairs Agent"
	icon_state = "landmark_iaa"

/obj/effect/landmark/start/crew/lawyer
	name = "Lawyer"
	icon_state = "landmark_lawyer"

// Merchant
/obj/effect/landmark/start/crew/merchant
	name = "Merchant"
	icon_state = "landmark_merchant"

// Actors
/obj/effect/landmark/start/crew/clown
	name = "Clown"
	icon_state = "landmark_clown"

/obj/effect/landmark/start/crew/mime
	name = "Mime"
	icon_state = "landmark_mime"

// Cargo department
/obj/effect/landmark/start/crew/qm
	name = "Quartermaster"
	icon_state = "landmark_quartermaster"

/obj/effect/landmark/start/crew/cargotech
	name = "Cargo Technician"
	icon_state = "landmark_cargo"

/obj/effect/landmark/start/crew/miner
	name = "Shaft Miner"
	icon_state = "landmark_shaftminer"

// Research and Development
/obj/effect/landmark/start/crew/rd
	name = "Research Director"
	icon_state = "landmark_rd"

/obj/effect/landmark/start/crew/scientist
	name = "Scientist"
	icon_state = "landmark_science"

/obj/effect/landmark/start/crew/xenobiologist
	name = "Xenobiologist"
	icon_state = "landmark_xenobio"

/obj/effect/landmark/start/crew/roboticist
	name = "Roboticist"
	icon_state = "landmark_roboticist"

// Security department
/obj/effect/landmark/start/crew/hos
	name = "Head of Security"
	icon_state = "landmark_hos"

/obj/effect/landmark/start/crew/warden
	name = "Warden"
	icon_state = "landmark_warden"

/obj/effect/landmark/start/crew/officer
	name = "Security Officer"
	icon_state = "landmark_security"

/obj/effect/landmark/start/crew/detective
	name = "Detective"
	icon_state = "landmark_detective"

// Medical deprtment
/obj/effect/landmark/start/crew/cmo
	name = "Chief Medical Officer"
	icon_state = "landmark_cmo"

/obj/effect/landmark/start/crew/doctor
	name = "Medical Doctor"
	icon_state = "landmark_medical"

/obj/effect/landmark/start/crew/virologist
	name = "Virologist"
	icon_state = "landmark_viro"

/obj/effect/landmark/start/crew/chemist
	name = "Chemist"
	icon_state = "landmark_chemist"

/obj/effect/landmark/start/crew/psyhiatrist
	name = "Psychiatrist"
	icon_state = "landmark_psych"

/obj/effect/landmark/start/crew/paramedic
	name = "Paramedic"
	icon_state = "landmark_paramedic"

// Engineering department
/obj/effect/landmark/start/crew/ce
	name = "Chief Engineer"
	icon_state = "landmark_ce"

/obj/effect/landmark/start/crew/engineer
	name = "Station Engineer"
	icon_state = "landmark_engineering"

/obj/effect/landmark/start/crew/atmostech
	name = "Atmospheric Technician"
	icon_state = "landmark_atmos"

// Antagonists
/obj/effect/landmark/start/antags
	icon_state = "landmark_syndicate"
	should_be_added = TRUE

/obj/effect/landmark/start/antags/actor
	name = "Actor"
	icon_state = "landmark_actor"

// NanoTrasen operatives
/obj/effect/landmark/start/antags/ert
	name = "Emergency Responder"
	icon_state = "landmark_ert"

/obj/effect/landmark/start/antags/deathsquad
	name = "Death Commando"
	icon_state = "landmark_deathsquad"

// Magic creatures
/obj/effect/landmark/start/antags/wizard
	name = "Wizard"
	icon_state = "landmark_wizard"

/obj/effect/landmark/start/antags/deity
	name = "Deity"
	icon_state = "landmark_deity"

// Syndicate operatives
/obj/effect/landmark/start/antags/operatives
	name = "Syndicate Operative"

/obj/effect/landmark/start/antags/commando
	name = "Syndicate Commando"
	icon_state = "landmark_commando"

// Raiders
/obj/effect/landmark/start/antags/vox
	name = "Vox"
	icon_state = "landmark_raider"

/obj/effect/landmark/start/antags/ninja
	name = "Ninja"
	icon_state = "landmark_ninja"

// Creatures
/obj/effect/landmark/start/antags/xeno
	name = "Xenomorph"
	icon_state = "landmark_xeno"
	delete_after = TRUE

/obj/effect/landmark/start/antags/xeno/Initialize()
	GLOB.xenospawn_areas += loc.loc
	return ..()

/obj/effect/landmark/start/antags/borer
	name = "Borer"
	icon_state = "landmark_borer"

// Latejoin landmarks.
/obj/effect/landmark/joinlate
	name = "JoinLate"
	icon_state = "landmark_late"
	delete_after = TRUE

/obj/effect/landmark/joinlate/New()
	switch(name)
		if("JoinLate")
			GLOB.latejoin += loc
			return
		if("JoinLateGateway")
			GLOB.latejoin_gateway += loc
			return
		if("JoinLateCryo")
			GLOB.latejoin_cryo += loc
			return
		if("JoinLateCyborg")
			GLOB.latejoin_cyborg += loc
			return
		if("Spessmans' haven")
			GLOB.spessmans_heaven += loc
			return
	return ..()

/obj/effect/landmark/joinlate/gate
	name = "JoinLateGateway"

/obj/effect/landmark/joinlate/cryo
	name = "JoinLateCryo"
	icon_state = "landmark_cryo"

/obj/effect/landmark/joinlate/cyborg
	name = "JoinLateCyborg"
	icon_state = "landmark_cyborg"

/obj/effect/landmark/joinlate/observer
	name = "Observer"
	icon_state = "landmark_observer"
	delete_after = FALSE
	should_be_added = TRUE

/obj/effect/landmark/joinlate/spessmans_heaven
	name = "Spessmans' haven"
