/datum/controller/subsystem/ticker/proc/create_event_of_round()
    var/event = pick(typesof(/datum/event_of_round) - /datum/event_of_round)
    eof = new event
    eof.apply_event()
    eof.announce_event()

/datum/event_of_round
    var/id = "default"
    var/event_message = "You shouldn't have seen it."
    var/required_players = 0 // maybe this fucking thing's gonna be needed someday

/datum/event_of_round/New()
    . = ..()

/datum/event_of_round/proc/announce_event()
    to_world("<h1 class='alert'>Event of round:</h1>")
    to_world("<br>[event_message]<br>")
    return

/datum/event_of_round/proc/apply_event()
    return

/datum/event_of_round/without_light
    id = "withoutlight"
    event_message = "Because of anomalies in the ionosphere, the station is left without light."

/datum/event_of_round/without_light/apply_event()
    lightsout(0,0)
    for(var/obj/item/device/flashlight/F)
        F.on = 0
        F.update_icon()

/datum/event_of_round/lack_of_energy
    id = "lackofenergy"
    event_message = "Supermattery has not been budgeted by NanoTrasen for this station. Good luck."

/datum/event_of_round/lack_of_energy/apply_event()
    for(var/obj/machinery/power/supermatter/SM in world)
        qdel(SM)

/datum/event_of_round/old_times
    id = "oldtimes"
    event_message = "Everyone at the station has visual hallucinations. Everything has aged in your eyes."

/datum/event_of_round/old_times/apply_event()
    for(var/atom/movable/lighting_overlay/LO in world)
        LO.icon = 'icons/effects/lighting_overlay_tile.dmi'
        LO.update_overlay()
        CHECK_TICK

/datum/event_of_round/assclowns
    id = "assclowns"
    event_message = "The assistants got a job."

/datum/event_of_round/assclowns/apply_event()
    . = ..()

/datum/event_of_round/ghetto_medbay
    id = "ghettomedbay"
    event_message = "NanoTrasen had to lower the budget of the medical department for your station. Doctors have to improvise."

/datum/event_of_round/apply_event()
    for(var/area/medical/M in world)
        for(var/obj/item/weapon/storage/firstaid/o2/FO in M)
            var/obj/item/weapon/reagent_containers/syringe/inaprovaline/SI = new(FO.loc)
            SI.desc = "Who needs a oxygen deprivation first-aid kit?"
            qdel(FO)
        for(var/obj/item/weapon/reagent_containers/spray/sterilizine/SS in M)
            var/obj/item/weapon/reagent_containers/food/drinks/bottle/vodka/BV = new(SS.loc)
            BV.name = "Sterilizine"
            qdel(SS)
        for(var/obj/structure/morgue/SM in M)
            var/obj/structure/closet/coffin/CC = new(SM.loc)
            CC.name = "Morgue"
            CC.desc = "Why does it look like a coffin?"
            qdel(SM)
        for(var/obj/structure/closet/secure_closet/medical1/M1 in M)
            var/obj/structure/closet/wardrobe/medic_white/MW = new(M1.loc)
            MW.name = "Improvised Medical Closet"
            qdel(M1)
        for(var/obj/structure/closet/secure_closet/chemical/C in M)
            var/obj/structure/closet/wardrobe/medic_white/MW = new(C.loc)
            MW.name = "Improvised Chemical Closet"
            qdel(C)
        for(var/obj/item/clothing/glasses/hud/health/HH in M)
            var/obj/item/clothing/glasses/regular/GR = new(HH.loc)
            GR.desc = "Why are they without HUD?"
            qdel(HH)
        for(var/obj/structure/closet/secure_closet/medical_wall/SCMW in M)
            qdel(SCMW)
        for(var/obj/item/stack/material/phoron/MP in M)
            qdel(MP)
        for(var/obj/machinery/vending/medical/VM in M)
            qdel(VM)
        for(var/obj/item/weapon/storage/firstaid/regular/FAR in M)
            var/obj/item/device/healthanalyzer/HA = new(FAR.loc)
            HA.desc = "Where's my first aid kit?"
            qdel(FAR)
        for(var/obj/item/weapon/defibrillator/compact/loaded/DCL in M)
            qdel(DCL)
        for(var/obj/item/weapon/rig/medical/RM in M)
            qdel(RM)
        for(var/obj/structure/closet/radiation/CR in M)
            qdel(CR)
        for(var/obj/item/weapon/storage/firstaid/surgery/FAS in M)
            var/obj/item/weapon/storage/toolbox/mechanical/TM = new(FAS.loc)
            TM.name = "Surgery Kit"
            qdel(FAS)
        for(var/obj/machinery/bodyscanner/BS in M)
            qdel(BS)
        for(var/obj/machinery/body_scanconsole/BSC in M)
            qdel(BSC)
        for(var/obj/machinery/chemical_dispenser/CD in M)
            var/obj/machinery/chemical_dispenser/lower_budget/CDLB = new(CD.loc)
            CDLB.desc = "For some reason, without most chemicals."
            qdel(CD)
        for(var/obj/machinery/organ_printer/flesh/mapped/OP in M)
            qdel(OP)
        for(var/obj/machinery/sleeper/S in M)
            qdel(S)
        for(var/obj/item/bodybag/cryobag/CB in M)
            var/obj/item/bodybag/B = new(CB.loc)
            B.name = "Cryobag Replacement"
            qdel(CB)
        for(var/obj/item/weapon/scalpel/SC in M)
            var/obj/item/weapon/material/knife/K = new(SC.loc)
            K.name = "Improvised scalpel"
            qdel(SC)
        for(var/obj/machinery/resleever/RE in M)
            qdel(RE)
        for(var/obj/item/weapon/storage/firstaid/fire/FAF in M)
            var/obj/item/stack/medical/ointment/MO = new(FAF.loc)
            MO.desc = "Who needs a fire first-aid kit?"
            qdel(FAF)
        for(var/obj/item/weapon/storage/firstaid/toxin/FAT in M)
            var/obj/item/weapon/reagent_containers/syringe/antitoxin/SAT = new(FAT.loc)
            SAT.desc = "Who needs a toxin first-aid kit?"
            qdel(FAT)
        for(var/obj/item/weapon/reagent_containers/spray/cleaner/SC in M)
            var/obj/item/weapon/soap/deluxe/SD = new(SC.loc)
            SD.name = "Space Cleaner Soap Deluxe"
            SD.desc = "In 2563 someone need space cleaners?"
            qdel(SC)
    for(var/area/crew_quarters/medbreak/M in world)
        for(var/obj/item/weapon/reagent_containers/spray/cleaner/SC in M)
            var/obj/item/weapon/soap/deluxe/SD = new(SC.loc)
            SD.name = "Space Cleaner Soap Deluxe"
            SD.desc = "In 2563 someone need space cleaners?"
            qdel(SC)