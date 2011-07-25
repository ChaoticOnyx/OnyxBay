// this goes in gameticker.dm's setup() proc and works in conjuction with landmarks manually placed on the map
		var/list/artispawn = list()
		for(var/obj/landmark/S in world)
			if (S.name == "Artifact spawn")
				artispawn.Add(S.loc)
		if(artispawn.len)
			var/artiamt = rand(2,8)
			while(artiamt > 0)
				var/artiloc = pick(artispawn)
				if (prob(66)) new/obj/machinery/artifact(artiloc)
				--artiamt

// this is the entirety of artifacts.dm

// Artifact Research - these are used in the research system, depending on how yours is set up these could probably be
// ignored if not incorporatable

/datum/artiresearch/
	var/name = "artifact research"
	var/bonustype = null // What kind of artifact it gives a bonus to identifying
	var/bonusamtO = 0    // Bonus % to identifying origin
	var/bonusamtT = 0    // Bonus % to identifying trigger
	var/bonusamtE = 0    // Bonus % to identifying effect/range
	var/bonusTime = 0    // Seconds reduced from analysis time

/datum/artiresearch/ancient1
	name = "Ancient Artifacts"
	bonustype = "ancient"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/martian1
	name = "Martian Artifacts"
	bonustype = "martian"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/crystal1
	name = "Wizard Artifacts"
	bonustype = "wizard"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/eldritch1
	name = "Eldritch Artifacts"
	bonustype = "eldritch"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/precursor1
	name = "Precursor Artifacts"
	bonustype = "precursor"
	bonusamtO = 75
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/general1
	name = "General Artifacts"
	bonustype = "all"
	bonusamtO = 15
	bonusamtT = 5
	bonusamtE = 5

/datum/artiresearch/analyser1
	name = "Analysis Algorithms"
	bonustype = "analyser"
	bonusTime = 10

/datum/artiresearch/ancient2
	name = "Ancient Mechanisms"
	bonustype = "ancient"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/martian2
	name = "Martian Bio-triggers"
	bonustype = "martian"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/crystal2
	name = "Wizard Rituals"
	bonustype = "wizard"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/eldritch2
	name = "Eldritch Invocations"
	bonustype = "eldritch"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/precursor2
	name = "Precursor Sequencing"
	bonustype = "precursor"
	bonusamtO = 10
	bonusamtT = 75
	bonusamtE = 5

/datum/artiresearch/general2
	name = "General Activation Procedure"
	bonustype = "all"
	bonusamtO = 5
	bonusamtT = 15
	bonusamtE = 5

/datum/artiresearch/analyser2
	name = "Advanced Analysis Software"
	bonustype = "analyser"
	bonusTime = 10

/datum/artiresearch/ancient3
	name = "Ancient Technology"
	bonustype = "ancient"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/martian3
	name = "Martian Bioengineering"
	bonustype = "martian"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/crystal3
	name = "Wizard Enchantments"
	bonustype = "wizard"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/eldritch3
	name = "Eldritch Curses"
	bonustype = "eldritch"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/precursor3
	name = "Precursor Circuits"
	bonustype = "precursor"
	bonusamtO = 10
	bonusamtT = 15
	bonusamtE = 80

/datum/artiresearch/general3
	name = "General Power Capacity"
	bonustype = "all"
	bonusamtO = 5
	bonusamtT = 5
	bonusamtE = 15

/datum/artiresearch/analyser3
	name = "High-Grade Analysis Process"
	bonustype = "analyser"
	bonusTime = 15

////////////////////////////////////////////////////////////////////////////////////////////////////////

// the actual code for artifacts

/obj/machinery/artifact
	name = "alien artifact"
	desc = "A large alien device."
	icon = 'artifacts.dmi'
	icon_state = "obelisk-1"
	anchored = 0
	density = 1
	var/activated = 0          // Whether or not the artifact has been unlocked.
	var/charged = 1            // Whether the artifact is ready to have it's effect.
	var/chargetime = 0         // How much time until the artifact is charged.
	var/recharge = 5           // How long does it take this artifact to recharge?
	var/origin = null          // Used in the randomisation/research of the artifact.
	var/trigger = "touch"      // What activates it?
	var/triggerX = "none"      // Used for more varied triggers
	var/effecttype = "healing" // What does it do?
	var/effectmode = "aura"    // How does it carry out the effect?
	var/aurarange = 4          // How far the artifact will extend an aura effect.

	New()
		..()
		// Origin and appearance randomisation
		src.origin = pick("ancient","martian","wizard","eldritch","precursor")
		switch(src.origin)
			if("ancient") src.icon_state = pick("obelisk-1","obelisk-2")
			if("martian") src.icon_state = pick("martian-1","martian-2")
			if("wizard") src.icon_state = pick("crystal-1","crystal-2")
			if("eldritch") src.icon_state = pick("eldritch-1","eldritch-2")
			if("precursor") src.icon_state = pick("precursor-1","precursor-2")
		// Low-ish random chance to not look like it's origin
		if(prob(20)) src.icon_state = pick("obelisk-1","obelisk-2","martian-1","martian-2","crystal-1","crystal-2","eldritch-1","eldritch-2","precursor-1","precursor-2")
		// Power randomisation
		src.trigger = pick("force","energy","chemical","heat")
		if (src.trigger == "chemical") src.triggerX = pick("hydrogen","corrosive","volatile","toxic")
		// Ancient Artifacts focus on robotic/technological effects
		// Martian Artifacts focus on biological effects
		// Wizard Artifacts focus on weird shit
		// Eldritch Artifacts are 100% bad news
		// Precursor Artifacts do everything
		switch(src.origin)
			if("ancient") src.effecttype = pick("roboheal","robohurt","cellcharge","celldrain")
			if("martian") src.effecttype = pick("healing","injure","stun","planthelper")
			if("wizard") src.effecttype = pick("stun","forcefield","teleport")
			if("eldritch") src.effecttype = pick("injure","stun","robohurt","celldrain")
			if("precursor") src.effecttype = pick("healing","injure","stun","roboheal","robohurt","cellcharge","celldrain","planthelper","forcefield","teleport")
		// Select range based on the power
		var/canworldpulse = 1
		switch(src.effecttype)
			if("healing") src.effectmode = pick("aura","pulse","contact")
			if("injure") src.effectmode = pick("aura","pulse","contact")
			if("stun") src.effectmode = pick("aura","pulse","contact")
			if("roboheal") src.effectmode = pick("aura","pulse","contact")
			if("robohurt") src.effectmode = pick("aura","pulse","contact")
			if("cellcharge") src.effectmode = pick("aura","pulse")
			if("celldrain") src.effectmode = pick("aura","pulse")
			if("planthelper")
				src.effectmode = pick("aura","pulse")
				canworldpulse = 0
			if("forcefield")
				src.effectmode = "contact"
				canworldpulse = 0
			if("teleport") src.effectmode = pick("pulse","contact")
		// Recharge timer & range setup
		if (src.effectmode == "aura") src.aurarange = rand(1,4)
		if (src.effectmode == "contact")
			src.recharge = rand(5,15)
		if (src.effectmode == "pulse")
			src.aurarange = rand(2,14)
			src.recharge = rand(5,20)
		if (canworldpulse == 1 && prob(1))
			src.effectmode = "worldpulse"
			src.recharge = rand(40,120)

	attack_hand(var/mob/user as mob)
		if (istype(user, /mob/living/silicon/ai) || istype(user, /mob/dead/)) return
		if (istype(user, /mob/living/silicon/robot))
			if (get_dist(user, src) > 1)
				user << "\red You can't reach [src] from here."
				return
		for(var/mob/O in viewers(src, null))
			O.show_message(text("<b>[]</b> touches [].", user, src), 1)
		src.add_fingerprint(user)
		src.Artifact_Contact(user)

	attackby(obj/item/weapon/W as obj, mob/living/user as mob)
		if (istype(W, /obj/item/weapon/cargotele))
			W:cargoteleport(src, user)
			return
		if (src.trigger == "chemical" && istype(W, /obj/item/weapon/reagent_containers/))
			switch(src.triggerX)
				if("hydrogen")
					if (W.reagents.has_reagent("hydrogen") || W.reagents.has_reagent("water")) src.Artifact_Activate()
				if("corrosive")
					if (W.reagents.has_reagent("acid") || W.reagents.has_reagent("pacid") || W.reagents.has_reagent("diethylamine")) src.Artifact_Activate()
				if("volatile")
					if (W.reagents.has_reagent("plasma") || W.reagents.has_reagent("thermite")) src.Artifact_Activate()
				if("toxic")
					if (W.reagents.has_reagent("toxin") || W.reagents.has_reagent("cyanide") || W.reagents.has_reagent("amanitin") || W.reagents.has_reagent("neurotoxin")) src.Artifact_Activate()
		..()
		if (src.trigger == "force" && W.force >= 30 && !src.activated) src.Artifact_Activate()
		if (src.trigger == "energy")
			if (istype(W,/obj/item/weapon/baton)) src.Artifact_Activate()
			if (istype(W,/obj/item/weapon/gun/energy/)) src.Artifact_Activate()
			if (istype(W,/obj/item/device/multitool)) src.Artifact_Activate()
			if (istype(W,/obj/item/weapon/card/emag)) src.Artifact_Activate()
		if (src.trigger == "heat")
			if (istype(W,/obj/item/device/igniter)) src.Artifact_Activate()
			if (istype(W, /obj/item/weapon/weldingtool) && W:welding) src.Artifact_Activate()
			if (istype(W, /obj/item/weapon/zippo) && W:lit) src.Artifact_Activate()

	//Bump(atom/A)

	Bumped(M as mob|obj)
		if (istype(M,/obj/item/weapon/) && src.trigger == "force" && M:throwforce >= 30) src.Artifact_Activate()

	bullet_act(var/datum/projectile/P)
		if (src.trigger == "force")
			if(P.damage_type == D_KINETIC) src.Artifact_Activate()
			else if(P.damage_type == D_PIERCING) src.Artifact_Activate()
		if (src.trigger == "energy")
			if(P.damage_type == D_ENERGY) src.Artifact_Activate()

	ex_act(severity)
		switch(severity)
			if(1.0) del src
			if(2.0)
				if (prob(50)) del src
				if (src.trigger == "force") src.Artifact_Activate()
				if (src.trigger == "heat") src.Artifact_Activate()
			if(3.0)
				if (src.trigger == "force") src.Artifact_Activate()
				if (src.trigger == "heat") src.Artifact_Activate()
		return

	temperature_expose(null, temp, volume)
		if (src.trigger == "heat") src.Artifact_Activate()

	process()
		..()
		if (!src.activated) return
		if (src.chargetime > 0)
			src.chargetime--
		else src.charged = 1
		if (src.effectmode == "aura")
			switch(src.effecttype)
				if("healing")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(prob(10)) M << "\blue You feel a soothing energy radiating from something nearby."
						M.bruteloss--
						M.fireloss--
						M.toxloss--
						M.oxyloss--
						M.brainloss--
						M.updatehealth()
				if("injure")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(prob(10)) M << "\red You feel a painful force radiating from something nearby."
						M.bruteloss += 1
						M.fireloss += 1
						M.toxloss += 1
						M.oxyloss += 1
						M.brainloss += 1
						M.updatehealth()
				if("stun")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						if(prob(10)) M << "\red Energy radiating from the [src] is making you feel numb."
						if(prob(20))
							M << "\red Your body goes numb for a moment."
							M.stunned += 2
							M.weakened += 2
							M.stuttering += 2
				if("roboheal")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						if(prob(10)) M << "\blue SYSTEM ALERT: Beneficial energy field detected!"
						M.bruteloss -= 1
						M.fireloss -= 1
						M.updatehealth()
				if("robohurt")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						if(prob(10)) M << "\red SYSTEM ALERT: Harmful energy field detected!"
						M.bruteloss += 1
						M.fireloss += 1
						M.updatehealth()
				if("cellcharge")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge += 10
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 20
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge += 10
							if(prob(10)) M << "\blue SYSTEM ALERT: Energy boosting field detected!"
				if("celldrain")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge -= 10
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 20
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge -= 10
							if(prob(10)) M << "\red SYSTEM ALERT: Energy draining field detected!"
				if("planthelper")
					for (var/obj/machinery/plantpot/P in range(src.aurarange,src))
						if(!P.current) continue
						var/datum/plant/PL = P.current
						if(P.reagents.get_reagent_amount("water") <= 119) P.reagents.add_reagent("water", 1)
						if(P.plantcond == "poor" && PL.growthmode != "weed") P.health += 1
						if(PL.growthmode == "weed") P.health -= 1
		if (src.effectmode == "pulse")
			if (!src.charged) return
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<b>[]</b> emits a pulse of energy!", src), 1)
			switch(src.effecttype)
				if("healing")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						M << "\blue A wave of energy invigorates you."
						M.bruteloss -= 5
						M.fireloss -= 5
						M.toxloss -= 5
						M.oxyloss -= 5
						M.brainloss -= 5
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("injure")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						M << "\red A wave of energy causes you great pain!"
						M.bruteloss += 5
						M.fireloss += 5
						M.toxloss += 5
						M.oxyloss += 5
						M.brainloss += 5
						M.stunned += 3
						M.weakened += 3
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("stun")
					for (var/mob/living/carbon/M in range(src.aurarange,src))
						M << "\red A wave of energy overwhelms your senses!"
						M.paralysis += 3
						M.stunned += 4
						M.weakened += 4
						M.stuttering += 4
					src.charged = 0
					src.chargetime = src.recharge
				if("roboheal")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
						M.bruteloss -= 10
						M.fireloss -= 10
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("robohurt")
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
						M.bruteloss += 10
						M.fireloss += 10
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("cellcharge")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge += 250
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 400
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge += 250
							M << "\blue SYSTEM ALERT: Large energy boost detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("celldrain")
					for (var/obj/machinery/power/apc/C in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge -= 500
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 400
					for (var/mob/living/silicon/robot/M in range(src.aurarange,src))
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge -= 500
							M << "\red SYSTEM ALERT: Severe energy drain detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("planthelper")
					for (var/obj/machinery/plantpot/P in range(src.aurarange,src))
						if(!P.current) continue
						var/datum/plant/PL = P.current
						if(PL.growthmode == "weed")
							for(var/mob/O in viewers(src, null)) O.show_message(text("<b>[]</b> is destroyed!", P), 1)
							P.HYPkillplant()
					src.charged = 0
					src.chargetime = src.recharge
				if("teleport")
					for (var/mob/living/M in range(src.aurarange,src))
						var/list/randomturfs = new/list()
						for(var/turf/T in orange(M, 30))
							if(!istype(T, /turf/simulated/floor) || T.density)
								continue
							randomturfs.Add(T)
						if(randomturfs.len > 0)
							M << "\red You are displaced by a strange force!"
							M.loc = pick(randomturfs)
							var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
							s.set_up(5, 1, M)
							s.start()
					src.charged = 0
					src.chargetime = src.recharge
		if (src.effectmode == "worldpulse")
			if (!src.charged) return
			for(var/mob/O in viewers(src, null))
				O.show_message(text("<b>[]</b> emits a powerful burst of energy!", src), 1)
			switch(src.effecttype)
				if("healing")
					for (var/mob/living/carbon/M in world)
						M << "\blue Waves of soothing energy wash over you."
						M.bruteloss -= 3
						M.fireloss -= 3
						M.toxloss -= 3
						M.oxyloss -= 3
						M.brainloss -= 3
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("injure")
					for (var/mob/living/carbon/M in world)
						M << "\red A wave of painful energy strikes you!"
						M.bruteloss += 3
						M.fireloss += 3
						M.toxloss += 3
						M.oxyloss += 3
						M.brainloss += 3
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("stun")
					for (var/mob/living/carbon/M in world)
						M << "\red A powerful force causes you to black out momentarily."
						M.paralysis += 5
						M.stunned += 8
						M.weakened += 8
						M.stuttering += 8
					src.charged = 0
					src.chargetime = src.recharge
				if("roboheal")
					for (var/mob/living/silicon/robot/M in world)
						M << "\blue SYSTEM ALERT: Structural damage has been repaired by energy pulse!"
						M.bruteloss -= 5
						M.fireloss -= 5
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("robohurt")
					for (var/mob/living/silicon/robot/M in world)
						M << "\red SYSTEM ALERT: Structural damage inflicted by energy pulse!"
						M.bruteloss += 5
						M.fireloss += 5
						M.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				if("cellcharge")
					for (var/obj/machinery/power/apc/C in world)
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge += 100
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge += 250
					for (var/mob/living/silicon/robot/M in world)
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge += 100
							M << "\blue SYSTEM ALERT: Energy boost detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("celldrain")
					for (var/obj/machinery/power/apc/C in world)
						for (var/obj/item/weapon/cell/B in C.contents)
							B.charge -= 250
					for (var/obj/machinery/power/smes/S in range (src.aurarange,src)) S.charge -= 250
					for (var/mob/living/silicon/robot/M in world)
						for (var/obj/item/weapon/cell/D in M.contents)
							D.charge -= 250
							M << "\red SYSTEM ALERT: Energy drain detected!"
					src.charged = 0
					src.chargetime = src.recharge
				if("teleport")
					for (var/mob/living/M in world)
						var/list/randomturfs = new/list()
						for(var/turf/T in orange(M, 15))
							if(!istype(T, /turf/simulated/floor) || T.density)
								continue
							randomturfs.Add(T)
						if(randomturfs.len > 0)
							M << "\red You are displaced by a strange force!"
							M.loc = pick(randomturfs)
							var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
							s.set_up(5, 1, M)
							s.start()
					src.charged = 0
					src.chargetime = src.recharge

/obj/machinery/artifact/proc/Artifact_Activate()
	src.activated = 1
	for(var/mob/O in viewers(src, null))
		O.show_message(text("<b>[]</b> activates!", src), 1)
	var/artioverlay = src.icon_state + "-[rand(1,3)]"
	src.overlays += image('artifacts.dmi', artioverlay)

/obj/machinery/artifact/proc/Artifact_Contact(var/mob/user as mob)
	// Trigger Code
	if (istype (user,/mob/living/carbon/) && src.trigger == "touch" && !src.activated) src.Artifact_Activate()
	else if (src.trigger != "touch" && !src.activated) user << "Nothing happens."
	// Effect Code
	if (src.effectmode == "contact" && src.activated && src.charged)
		switch(src.effecttype)
			if("healing")
				if (istype(user, /mob/living/carbon/))
					user << "\blue You feel a soothing energy invigorate you."
					user.bruteloss -= 20
					user.fireloss -= 20
					user.toxloss -= 20
					user.oxyloss -= 20
					user.brainloss -= 20
					user.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("injure")
				if (istype(user, /mob/living/carbon/))
					user << "\red A painful discharge of energy strikes you!"
					user.bruteloss += 25
					user.fireloss += 25
					user.toxloss += 25
					user.oxyloss += 25
					user.brainloss += 25
					user.stunned += 6
					user.weakened += 6
					user.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("stun")
				if (istype(user, /mob/living/carbon/))
					user << "\red A powerful force overwhelms your consciousness."
					user.paralysis += 30
					user.stunned += 45
					user.weakened += 45
					user.stuttering += 45
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("roboheal")
				if (istype(user, /mob/living/silicon/robot))
					user << "\blue Your systems report damaged components mending by themselves!"
					user.bruteloss -= 30
					user.fireloss -= 30
					user.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("robohurt")
				if (istype(user, /mob/living/silicon/robot))
					user << "\red Your systems report severe damage has been inflicted!"
					user.bruteloss += 40
					user.fireloss += 40
					user.updatehealth()
					src.charged = 0
					src.chargetime = src.recharge
				else user << "Nothing happens."
			if("forcefield")
				new /obj/forcefield(locate(src.x + 2,src.y,src.z))
				new /obj/forcefield(locate(src.x + 2,src.y + 1,src.z))
				new /obj/forcefield(locate(src.x + 2,src.y + 2,src.z))
				new /obj/forcefield(locate(src.x + 2,src.y - 1,src.z))
				new /obj/forcefield(locate(src.x + 2,src.y - 2,src.z))
				new /obj/forcefield(locate(src.x - 2,src.y,src.z))
				new /obj/forcefield(locate(src.x - 2,src.y + 1,src.z))
				new /obj/forcefield(locate(src.x - 2,src.y + 2,src.z))
				new /obj/forcefield(locate(src.x - 2,src.y - 1,src.z))
				new /obj/forcefield(locate(src.x - 2,src.y - 2,src.z))
				new /obj/forcefield(locate(src.x,src.y + 2,src.z))
				new /obj/forcefield(locate(src.x + 1,src.y + 2,src.z))
				new /obj/forcefield(locate(src.x - 1,src.y + 2,src.z))
				new /obj/forcefield(locate(src.x,src.y - 2,src.z))
				new /obj/forcefield(locate(src.x + 1,src.y - 2,src.z))
				new /obj/forcefield(locate(src.x - 1,src.y - 2,src.z))
				src.charged = 0
				src.chargetime = src.recharge
				spawn (src.recharge)
					for(var/obj/forcefield/F in range(5,src))
						del F
			if("teleport")
				var/list/randomturfs = new/list()
				for(var/turf/T in orange(user, 50))
					if(!istype(T, /turf/simulated/floor) || T.density)
						continue
					randomturfs.Add(T)
				if(randomturfs.len > 0)
					user << "\red You are suddenly zapped away elsewhere!"
					user.loc = pick(randomturfs)
					var/datum/effects/system/spark_spread/s = new /datum/effects/system/spark_spread
					s.set_up(5, 1, user)
					s.start()

	else if (src.effectmode == "contact" && src.activated && !src.charged) user << "The artifact feels warm, but nothing interesting happens."

////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/submachine/artifact_analyser
	name = "Artifact Analyser"
	desc = "Studies the structure of artifacts to discover their uses."
	icon = 'artifacts.dmi'
	icon_state = "AAn-off"
	anchored = 1
	density = 1
	var/working = 0
	var/accuO = 0
	var/accuT = 0
	var/accuE1 = 0
	var/accuE2 = 0
	var/aorigin = "None"
	var/atrigger = "None"
	var/aeffect1 = "None"
	var/aeffect2 = "None"
	var/list/allorigins = list("Ancient Robots","Martian","Wizard Federation","Extradimensional","Precursor")
	var/list/alltriggers = list("Contact with Living Organism","Heavy Impact","Contact with Energy Source","Contact with Hydrogen","Contact with Corrosive Substance","Contact with Volatile Substance","Contact with Toxins","Exposure to Heat")
	var/list/alleffects = list("Healing Device","Anti-biological Weapon","Non-lethal Stunning Trap","Mechanoid Repair Module","Mechanoid Deconstruction Device","Power Generator","Power Drain","Stellar Mineral Attractor","Agriculture Regulator","Shield Generator","Space-Time Displacer")
	var/list/allranges = list("Constant Short-Range Energy Field","Medium Range Energy Pulses","Long Range Energy Pulses","Extreme Range Energy Pulses","Requires contact with subject")

	attack_hand(var/mob/user as mob)
		user.machine = src
		if (!src.working)
			var/dat = {"<B>Artifact Analyser</B><BR>
			<HR><BR>
			<B>Artifact Origin:</B> [aorigin] ([accuO]%)<BR>
			<B>Activation Trigger:</B> [atrigger] ([accuT]%)<BR>
			<B>Artifact Function:</B> [aeffect1] ([accuE1]%)<BR>
			<B>Artifact Range:</B> [aeffect2] ([accuE2]%)<BR><BR>
			<HR><BR>
			<A href='?src=\ref[src];ops=1'>Analyse Artifact<BR>
			<A href='?src=\ref[src];ops=2'>Label Artifact"}
			user << browse(dat, "window=artanalyser;size=400x500")
			onclose(user, "artanalyser")
		else
			var/dat = {"<B>Artifact Analyser</B><BR>
			<HR><BR>
			<B>Please wait. Analysis in progress.</B><BR>"}
			user << browse(dat, "window=artanalyser;size=450x500")
			onclose(user, "artanalyser")

	Topic(href, href_list)
		if(href_list["ops"])
			var/operation = text2num(href_list["ops"])
			if(operation == 1) // Analyse Artifact
				var/findarti = 0
				for(var/obj/machinery/artifact/A in range(1,src))
					findarti++
				if (findarti == 1)
					for(var/obj/machinery/artifact/A in range(1,src))
						A.anchored = 1
					src.working = 1
					src.icon_state = "AAn-on"
					var/time = 40
					for(var/i = artifact_research.starting_tier, i <= artifact_research.max_tiers, i++)
						for(var/datum/artiresearch/R in artifact_research.researched_items[i])
							if (R.bonustype == "analyser") time -= R.bonusTime
					time *= 10
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Commencing analysis.'", src), 1)
					AA_Analyse()
					spawn(time)
						for(var/obj/machinery/artifact/A in range(1,src))
							A.anchored = 0
						src.working = 0
						icon_state = "AAn-off"
						for(var/mob/O in hearers(src, null))
							O.show_message(text("<b>[]</b> states, 'Analysis complete.'", src), 1)
				else if (findarti > 1)
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Cannot analyse. Too many artifacts nearby.'", src), 1)
				else
					for(var/mob/O in hearers(src, null))
						O.show_message(text("<b>[]</b> states, 'Cannot analyse. No artifact found.'", src), 1)
				if(operation == 2) // Label Artifact
					var/input = input(usr, "What do you want to name this artifact?.", "What?", "")
					if (input)
						for(var/obj/machinery/artifact/A in range(1,src))
							A.name = input
			src.updateUsrDialog()

	proc
		AA_FailedAnalysis(var/failtype)
			switch(failtype)
				if(1)
					src.aorigin = "Failed to Identify"
					if (prob(20)) src.aorigin = pick(src.allorigins)
				if(2)
					src.atrigger = "Failed to Identify"
					if (prob(20)) src.atrigger = pick(src.alltriggers)
				if(3)
					src.aeffect1 = "Failed to Identify"
					if (prob(20)) src.aeffect1 = pick(src.alleffects)
				if(4)
					src.aeffect2 = "Failed to Identify"
					if (prob(20)) src.aeffect2 = pick(src.allranges)

		AA_Analyse()
			src.accuO = rand(0,10)
			src.accuT = rand(0,10)
			src.accuE1 = rand(0,10)
			src.accuE2 = rand(0,10)
			// Calculate report accuracy
			for (var/obj/machinery/artifact/A in range(1,src))
				for(var/i = artifact_research.starting_tier, i <= artifact_research.max_tiers, i++)
					for(var/datum/artiresearch/R in artifact_research.researched_items[i])
						if (R.bonustype == A.origin)
							src.accuO += R.bonusamtO
							src.accuT += R.bonusamtT
							src.accuE1 += R.bonusamtE
							src.accuE2 += R.bonusamtE
						if (R.bonustype == "all")
							src.accuO += R.bonusamtO
							src.accuT += R.bonusamtT
							src.accuE1 += R.bonusamtE
							src.accuE2 += R.bonusamtE
			if (src.accuO > 100) src.accuO = 100
			if (src.accuT > 100) src.accuT = 100
			if (src.accuE1 > 100) src.accuE1 = 100
			if (src.accuE2 > 100) src.accuE2 = 100
			// Roll to generate report
			for (var/obj/machinery/artifact/A in range(1,src))
				if (prob(accuO))
					switch(A.origin)
						if("ancient") src.aorigin = "Ancient Robots"
						if("martian") src.aorigin = "Martian"
						if("wizard") src.aorigin = "Wizard Federation"
						if("eldritch") src.aorigin = "Extradimensional"
						if("precursor") src.aorigin = "Precursor"
						else src.aorigin = "Unknown Origin"
				else AA_FailedAnalysis(1)
				if (prob(accuT))
					switch(A.trigger)
						if("touch") src.atrigger = "Contact with Living Organism"
						if("force") src.atrigger = "Heavy Impact"
						if("energy") src.atrigger = "Contact with Energy Source"
						if("chemical")
							switch(A.triggerX)
								if("hydrogen") src.atrigger = "Contact with Hydrogen"
								if("corrosive") src.atrigger = "Contact with Corrosive Substance"
								if("volatile") src.atrigger = "Contact with Volatile Substance"
								if("toxin") src.atrigger = "Contact with Toxins"
						if("heat") src.atrigger = "Exposure to Heat"
						else src.atrigger = "Unknown Trigger"
				else AA_FailedAnalysis(2)
				if (prob(accuE1))
					switch(A.effecttype)
						if("healing")  src.aeffect1 = "Healing Device"
						if("injure") src.aeffect1 = "Anti-biological Weapon"
						if("stun") src.aeffect1 = "Non-lethal Stunning Trap"
						if("roboheal") src.aeffect1 = "Mechanoid Repair Module"
						if("robohurt") src.aeffect1 = "Mechanoid Deconstruction Device"
						if("cellcharge") src.aeffect1 = "Power Generator"
						if("celldrain") src.aeffect1 = "Power Drain"
						if("planthelper") src.aeffect1 = "Agriculture Regulator"
						if("forcefield") src.aeffect1 = "Shield Generator"
						if("teleport") src.aeffect1 = "Space-Time Displacer"
						else src.aeffect1 = "Unknown Effect"
				else AA_FailedAnalysis(3)
				if (prob(accuE2))
					switch(A.effectmode)
						if("aura") src.aeffect2 = "Constant Short-Range Energy Field"
						if("pulse")
							if(A.aurarange > 7) src.aeffect2 = "Long Range Energy Pulses"
							else src.aeffect2 = "Medium Range Energy Pulses"
						if("worldpulse") src.aeffect2 = "Extreme Range Energy Pulses"
						if("contact") src.aeffect2 = "Requires contact with subject"
						else src.aeffect2 = "Unknown Range"
				else AA_FailedAnalysis(4)

// this was used in QM for a time but it fell into disuse and wasn't removed, the purpose being to check if an artifact
// was benevolent or malicious, to determine whether QMs would be paid or punished for shipping it

/proc/artifact_checkgood(var/obj/machinery/artifact/A)
	switch(A.effecttype)
		if("healing") return 1
		if("injure") return 0
		if("stun") return 0
		if("roboheal") return 1
		if("robohurt") return 0
		if("cellcharge") return 1
		if("celldrain") return 1
		if("planthelper") return 1
		if("forcefield") return 1
		if("teleport") return 0