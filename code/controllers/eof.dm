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

// /datum/event_of_round/without_light
//     id = "withoutlight"
//     event_message = "Because of anomalies in the ionosphere, the station is left without light."

// /datum/event_of_round/without_light/apply_event()
//     lightsout(0,0)
//     for(var/obj/item/device/flashlight/F)
//         F.on = 0
//         F.update_icon()

// /datum/event_of_round/lack_of_energy
//     id = "lackofenergy"
//     event_message = "Supermattery has not been budgeted by NanoTrasen for this station. Good luck."

// /datum/event_of_round/lack_of_energy/apply_event()
//     for(var/obj/machinery/power/supermatter/SM in world)
//         qdel(SM)

// /datum/event_of_round/old_times
//     id = "oldtimes"
//     event_message = "You feel old."

// /datum/event_of_round/old_times/apply_event()
//     for(var/atom/movable/lighting_overlay/LO in world)
//         LO.icon = 'icons/effects/lighting_overlay_tile.dmi'
//         LO.update_overlay()
//         CHECK_TICK

/datum/event_of_round/assclowns
    id = "assclowns"
    event_message = "The assistants got a job."

/datum/event_of_round/assclowns/apply_event()
    . = ..()