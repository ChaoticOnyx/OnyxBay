# Announces

## Meteors

announce-meteors =
    Meteors have been detected on a collision course with the { $station_name }.

announce-meteors-title =
    { $station_name } Sensor Array

announce-meteors-end =
    The { $station_name } has cleared the meteor storm.

announce-meteors-end-title =
    { $station_name } Sensor Array

announce-meteors-minor =
   The { $station_name } is now in a meteor shower.

announce-meteors-minor-title =
    { $station_name } Sensor Array

announce-meteors-end-minor =
    The { $station_name } has cleared the meteor shower.

announce-meteors-end-minor-title =
    { $station_name } Sensor Array

## Level X

announce-level-x =
    Confirmed outbreak of level { $bio_level } biohazard aboard the { $station_name }.
    All personnel must contain the outbreak.

announce-level-x-title =
    Biohazard Alert

## Ion Storm

announce-ion-storm =
    It has come to our attention that the { $station_name } passed through an ion storm.
    Please monitor all electronic equipment for malfunctions.

announce-ion-storm-title =
    Anomaly Alert

announce-ion-storm-ai-law =
    Ion storm detected near the { $station_name }. Please check all AI-controlled equipment for errors.

announce-ion-storm-ai-law-title =
    Anomaly Alert

## Grid Check

announce-grid-check =
    Abnormal activity detected in the { $station_name }'s power system.
    As a precaution, the { $station_name }'s power must be shut down for an indefinite duration.

announce-grid-check-title =
    Automated Grid Check

## Grid Restored

announce-grid-restored =
    Station power to the { $station_name } will be restored at this time.
    We apologize for the inconvenience.

announce-grid-restored-title =
    Power Systems Nominal

## Unidentified Lifesigns

announce-unidentified-lifesigns =
    Unidentified lifesigns detected coming aboard the { $station_name }.
    Please lockdown all exterior access points, including ducting and ventilation.

announce-unidentified-lifesigns-title =
    Lifesign Alert

## Radiation Detected

announce-radiation-detected =
    High levels of radiation has been detected in proximity of the { $station_name }.
    Please report to the medical bay if any strange symptoms occur.

announce-radiation-detected-title =
    Anomaly Alert

## Unknown Biological Entities

announce-unknown-biological-entities =
    Unknown biological entities have been detected near the { $station_name }, please stand-by.

announce-unknown-biological-entities-title =
    Lifesign Alert

## Grey Tide

announce-grey-tide =
    Gr3y.T1d3 virus detected in { $station_name } imprisonment subroutines.
    Recommend AI involvement.

announce-grey-tide-title =
    Security Alert

## Electrical Storm

announce-electrical-storm =
    An Electrical storm has been detected in your area, please repair potential electronic overloads.

announce-electrical-storm-title =
    Electrical Storm Alert

announce-electrical-storm-mundane =
    A minor electrical storm has been detected near the { $location_name }.
    Please watch out for possible electrical discharges.

announce-electrical-storm-moderate =
    The { $location_name } is about to pass through an electrical storm.
    Please secure sensitive electrical equipment until the storm passes.

announce-electrical-storm-major =
    Alert. A strong electrical storm has been detected in proximity of the { $location_name }.
    It is recommended to immediately secure sensitive electrical equipment until the storm passes.

announce-electrical-storm-title-02 =
    { $location_name } Sensor Array

announce-electrical-storm-end =
    The { $location_name } has cleared the electrical storm. Please repair any electrical overloads.

announce-electrical-storm-end-title =
    Electrical Storm Alert

## Carp Migration

announce-carp-migration =
    Unknown biological { $carps ->
        [one] entity has
        *[other] entities have
    } been detected near the { $location_name }, please stand-by.

announce-carp-migration-major =
    Massive migration of unknown biological entities has been detected near the { $location_name }, please stand-by.

announce-carp-migration-title =
    { $location_name } Sensor Array

## Brand Intelligence

announce-brand-intelligence =
    Rampant brand intelligence has been detected aboard the { $location_name }.
    The origin is believed to be a "{ $machine_name }" type.
    Fix it, before it spreads to other vending machines.

announce-brand-intelligence-title =
    Machine Learning Alert

announce-brand-intelligence-end =
    All traces of the rampant brand intelligence have disappeared from the systems.

announce-brand-intelligence-end-title =
    { $location_name } Firewall Subroutines

## Tear Reality

announce-tear-reality =
    High levels of bluespace interference detected at { $area }.
    Suspected wormhole forming. Investigate it immediately.

announce-tear-reality-ceased =
    Bluespace anomaly has ceased.

## Supermatter Cascade

announce-supermatter-cascade =
    A galaxy-wide electromagnetic pulse has been detected. All systems across space are heavily damaged and
    many personnel have died or are dying. We are currently detecting increasing indications thatthe universe itself is beginning to unravel.

    { $station_name }, the largest source of disturbances has been pinpointed directly to you.
    We estimate you have five minutes until a bluespace rift opens within your facilities.

    There is no known way to stop the formation of the rift, nor any way to escape it. You are entirely alone.

    God help your s\[\[###!!!-

    AUTOMATED ALERT: Link to { $command_name }lost.

announce-supermatter-cascade-title =
    SUPERMATTER CASCADE DETECTED

## Dust

announce-dust =
    The { $location_name } is now passing through a belt of space dust.

announce-dust-title =
    { $location_name } Sensor Array

announce-dust-end =
    The { $location_name } has now passed through the belt of space dust.

announce-dust-end-title =
    { $location_name } Sensor Array

## Gateway Distress

announce-gateway-distress =
    Security anomaly found in the { $gateway_name }{ $location }. Attempting to iso... Error.
    The IDS reports the IPS was shut down. Intrusion alarm level: RED.
    
    The IDS reports the transmission was accepted by device. The transmission source is "Unknown",
    signature: "NT high level distress signal". Triangulation process detected.

    Estimated time to triangulation completion: { $time ->
        [one] { $time } minute
        *[other] { $time } minutes
    }.

announce-gateway-distress-title =
    Gateway Managment Station

announce-gateway-distress-open =
    The { $gateway_name }{ $location } reports the portal has been opened.

## Gravity

announce-gravity =
    Feedback surge detected in mass-distributions systems. Engineers are strongly advised to deal with the problem.

announce-gravity-title =
    Gravity Failure

## Infestation

announce-infestation =
    Bioscans indicate that { $vermstring } have been breeding in the { $location }. Clear them out, before this starts to affect productivity.

announce-infestation-title =
    Major Bill's Shipping Critter Sensor

## Money Hacker

announce-money-hacker =
    A brute force hack has been detected (in progress since { $time }). The target of the attack is: Financial accounts.
    Without intervention this attack will succeed in approximately 10 minutes. Possible solutions: suspension of accounts, disabling NTnet server,
    increase account security level. Notifications will be sent as updates occur.

announce-money-hacker-title =
    { $location_name } Firewall Subroutines

announce-money-hacker-wins =
    The hack attempt has succeeded.

announce-money-hacker-loose =
    The attack has ceased, the affected accounts can now be brought online.

## Ictus

announce-ictus =
    Suspicious biological activity was noticed at the station.
    The medical crew should immediately prepare for the fight against the pathogen.
    Infected crew members must not leave the station under any circumstances.

## Prison Break

announce-prison-break =
    { PICK("Gr3y.T1d3 virus", "Malignant trojan") } detected in { $location_name } { $type } subroutines.
    Secure any compromised areas immediately. { $location_name } AI involvement is recommended.

announce-prison-break-title =
    ${ dept } Alert

## Radiation Storm

announce-radiation-storm =
    High levels of radiation detected in proximity of the { $location_name }.
    Please evacuate into one of the shielded maintenance tunnels.

announce-radiation-storm-title =
    { $location_name } Sensor Array

announce-radiation-storm-entered =
    The { $location_name } has entered the radiation belt.
    Please remain in a sheltered area until we have passed the radiation belt.

announce-radiation-storm-passed =
    The { $location_name } has passed the radiation belt.
    Please allow for up to one minute while radiation levels dissipate,
    and report to the infirmary if you experience any unusual symptoms.
    Maintenance will lose all access again shortly.

## Rogue Drone

announce-rogue-drone-01 =
    Attention: unidentified patrol drones detected within proximity to the { $location_name }

announce-rogue-drone-02 =
    Unidentified Unmanned Drones approaching the { $location_name }. All hands take notice.

announce-rogue-drone-03 =
    Class II Laser Fire detected nearby the { $location_name }.

announce-rogue-drone-title =
    { $location_name } Sensor Array

announce-rogue-drone-end =
    Be advised: sensors indicate the unidentified drone swarm has left the immediate proximity of the { $location_name }.

## Communications Blackout

announce-communications-blackout =
    { PICK(
    "Ionospheric anomalies detected. Temporary telecommunication failure imminent. Please contact you*%fj00)`5vc-BZZT",
    "Ionospheric anomalies detected. Temporary telecommunication failu*3mga;b4;'1v�-BZZZT",
    "Ionospheric anomalies detected. Temporary telec#MCi46:5.;@63-BZZZZT",
    "Ionospheric anomalies dete'fZ\\kg5_0-BZZZZZT",
    "Ionospheri:%� MCayj^j<.3-BZZZZZZT",
    "#4nd%;f4y6,>�%-BZZZZZZZT") }

## Solar Storm

announce-solar-storm =
    A solar storm has been detected approaching the { $location_name }.
    Please halt all EVA activites immediately and return inside.

announce-solar-storm-title =
    { $location_name } Sensor Array

announce-solar-storm-start =
    The solar storm has reached the { $location_name }. Please refain from EVA and remain inside until it has passed.

announce-solar-storm-end =
    The solar storm has passed the { $location_name }. It is now safe to resume EVA activities.

## Viral Outbreak

announce-viral-outbreak =
    Confirmed outbreak of level 7 biohazard aboard the { $location_name }.
    All personnel must contain the outbreak.

announce-viral-outbreak-title =
    Biohazard Alert

## Wallrot

announce-wallrot =
    Harmful fungi detected on { $location_name }. Structures may be contaminated.

announce-wallrot-title =
    Biohazard Alert

## Wormholes

announce-wormholes =
    Space-time anomalies detected on the station. There is no additional data.

announce-wormholes-title =
    { $location_name } Sensor Array

## Space Time Anomaly

announce-space-time-anomaly-detected =
    Space-time anomalies have been detected on the { $location_name }.

announce-space-time-anomaly-detected-title =
    Anomaly Alert

## Immovable Rod

announce-immovable-rod =
    What the fuck was that?!

announce-immovable-rod-title =
    General Alert

## Power Restore

announce-power-restore =
    All SMESs on the { $station_name } have been recharged. We apologize for the inconvenience.

announce-power-restore-title =
    Power Systems Nominal

## Hack Failure

announce-hack-failure-01 =
    We have detected a hack attempt into your { $text }.
    The intruder failed to access anything of importance,
    but disconnected before we could complete our traces.

announce-hack-failure-02 =
    We have detected another hack attempt.
    It was targeting { $text }. The intruder almost gained control of the system,
    so we had to disconnect them. We partially finished our trace and it seems to be
    originating either from the { $station_name }, or its immediate vicinity.

announce-hack-failure-03 =
    Another hack attempt has been detected, this time targeting { $text }.
    We are certain the intruder entered the network via a terminal located somewhere on the { $station_name }.

announce-hack-failure-04 =
    We have finished our traces and it seems the recent hack attempts are
    originating from your AI system { $user }. We recommend investigation.

announce-hack-failure-other =
    Another hack attempt has been detected, targeting { $text }.
    The source still seems to be your AI system { $user }.

## Hack Progress

announce-hack-progress-title =
    Network Monitoring

announce-hack-progress-01 =
    Caution, { $station_name }. We have detected abnormal behaviour in your network.
    It seems someone is trying to hack your electronic systems. We will update you when we have more information.

announce-hack-progress-02 =
    We started tracing the intruder. Whoever is doing this, they seem to be onboard.
    We suggest checking all network control terminals. We will keep you updated on the situation.

announce-hack-progress-03 =
    This is highly abnormal and somewhat concerning. The intruder is too fast,
    he is evading our traces.No man could be this fast...

announce-hack-progress-04 =
    We have traced the intrude#, it seem& t( e yo3r AI s7stem, it &# *#ck@ng th$ sel$ destru$t mechani&m,
    stop i# bef*@!)$#&&@@  <CONNECTION LOST>

announce-hack-progress-end =
    Our system administrators just reported that we've been locked out from your control network.
    Whoever did this now has full access to { $station_name }'s systems.

announce-hack-progress-end-title =
    Network Administration Center

## Shuttle Called

announce-shuttle-called-exodus =
    A crew transfer to { $dock_name } has been scheduled.
    The shuttle has been called. It will arrive in approximately { $eta ->
        [one] { $eta } minute
        *[other] { $eta } minutes
    }.

announce-shuttle-called-example =
    A scheduled transfer shuttle has been sent.

## Shuttle Recall

announce-shuttle-recall-exodus =
    The scheduled crew transfer has been cancelled.

announce-shuttle-recall-example =
    The shuttle has been recalled.

## Shuttle Docked

announce-shuttle-docked-exodus =
    The scheduled Crew Transfer Shuttle to { $dock_name } has docked with the station.
    It will depart in approximately { $etd ->
        [one] minute
        *[other] minutes
    }.

announce-shuttle-docked-example =
    The shuttle has docked.

## Shuttle Leaving Dock

announce-shuttle-leaving-dock-exodus =
    The Crew Transfer Shuttle has left the station. Estimate { $eta ->
        [one] { $eta } minute
        *[other] { $eta } minutes
    } until the shuttle docks at { $dock_name }.

announce-shuttle-leaving-dock-example =
    The shuttle has departed from home dock.

## Emergency Shuttle Called

announce-emergency-shuttle-called-exodus =
    An emergency evacuation shuttle has been called. It will arrive in approximately { $eta ->
        [one] { $eta } minute
        *[other] { $eta } minutes
    }.

announce-emergency-shuttle-called-example =
    An emergency escape shuttle has been sent.

announce-emergency-shuttle-called-demeter =
    An Emergency Request has been ordered for this facility.
    All authorized evacuees must proceed to the outbound Evacuation Zone within { $eta ->
        [one] { $eta } minute
        *[other] { $eta } minutes
    }.

## Emergency Shuttle Recall

announce-emergency-shuttle-recall-exodus =
    The emergency shuttle has been recalled.

announce-emergency-shuttle-recall-example =
    The emergency shuttle has been recalled.

announce-emergency-shuttle-recall-demeter =
    An Emergency Request has been declined by Overwatch. Return to your post.

## Emergency Shuttle Docked

announce-emergency-shuttle-docked-exodus =
    The Emergency Shuttle has docked with the station.
    You have approximately { $etd -> 
        [one] { $etd } minute
        *[other] { $etd } minutes
    } to board the Emergency Shuttle.

announce-emergency-shuttle-docked-example =
    The emergency escape shuttle has docked.

announce-emergency-shuttle-docked-demeter =
    The Emergency Request for RnCC Demeter Was successfully approved Evacuation is mandatory for all Foundation personnel.
    Shuttles will depart in { $etd -> 
        [one] { $etd } minute
        *[other] { $etd } minutes
    }.

## Emergency Shuttle Leaving Dock

announce-emergency-shuttle-leaving-dock-exodus =
    The Emergency Shuttle has left the station. Estimate { $eta ->
        [one] { $eta } minute
        *[other] { $eta } minutes
    } until the shuttle docks at { $dock_name }.

announce-emergency-shuttle-leaving-dock-example =
    The emergency escape shuttle has departed from { $dock_name }.

announce-emergency-shuttle-leaving-dock-demeter =
    The Emergency Shuttles is departing from RnCC Demeter and will arrive in { $eta ->
        [one] { $eta } minute
        *[other] { $eta } minutes
    }. Please cooperate with Responders upon arrival.

## Evacuation Canceled

announce-bluespace-distortion-cancels-evacuation =
    The evacuation has been aborted due to bluespace distortion.

## Arrival Message

announce-arrival-message-syndicate =
    Attention, you have a large signature approaching the station - looks unarmed to surface scans.
    We're too far out to intercept - brace for visitors.

announce-arrival-message-skipjack =
    Attention, you have a large signature approaching the station - looks unarmed to surface scans.
    We're too far out to intercept - brace for visitors.

announce-arrival-message-merchant =
    Attention, you have an unarmed cargo vessel, which appears to be a merchant ship, approaching the station.
## Departure Message

announce-departure-message-syndicate =
    Your visitors are on their way out of the system, burning delta-v like it's nothing. Good riddance.

announce-departure-message-skipjack =
    Your visitors are on their way out of the system, burning delta-v like it's nothing. Good riddance.

## Borer Spawn

announce-borer-spawn =
    Unidentified lifesigns detected coming aboard the { $station_name }.
    Please lockdown all exterior access points, including ducting and ventilation.

announce-borer-spawn-title =
    Lifesign Alert

## Alien Spawn

announce-alien-spawn =
    Unidentified lifesigns detected coming aboard the { $station_name }.
    Please lockdown all exterior access points, including ducting and ventilation.

announce-alien-spawn-title =
    Lifesign Alert

## Priority Alert

announce-priority-alert =
    Priority Alert

# Security Levels

announce-security-code-elevated-title =
    Attention! Alert level elevated to { $name }!

announce-security-code-changed-title =
    Attention! Alert level changed to { $name }!

## Code Green

announce-security-code-green-down =
    All threats to the station have passed. Security may not have weapons visible,
    privacy laws are once again fully enforced.

## Code Blue

announce-security-code-blue-up =
    The station has received reliable information about possible hostile activity on the station.
    Security staff may have weapons visible, random searches are permitted."

announce-security-code-blue-down =
    The immediate threat has passed. Security may no longer have weapons drawn at all times,
    but may continue to have them visible. Random searches are still allowed.

## Code Red

announce-security-code-red-up =
    There is an immediate serious threat to the station.
    Security may have weapons unholstered at all times.
    Random searches are allowed and advised.

announce-security-code-red-down =
    The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station.
    Security may have weapons unholstered at all times, random searches are allowed and advised.

## Code Delta

announce-security-code-delta-on =
    The self-destruct mechanism has been engaged.
    All crew are instructed to obey all instructions given by heads of staff.
    Any violations of these orders can be punished by death. This is not a drill.

announce-security-code-delta-on-title =
    Attention! Delta security level reached!

## Response Team

announce-response-team-call-failed =
    It would appear that an emergency response team was requested for { $station_name }.
    Unfortunately, we were unable to send one at this time.

announce-response-team-call-failed-title =
    { $boss_name }

announce-response-team-called =
    It would appear that an emergency response team was requested for { $station_name }.
    We will prepare and send one as soon as possible.

announce-response-team-called-title =
    { $boss_name }

announce-response-team-disabled =
    The presence of { PICK(
        "political instability",
        "quantum fluctuations",
        "hostile raiders",
        "derelict station debris",
        "REDACTED",
        "ancient alien artillery",
        "solar magnetic storms",
        "sentient time-travelling killbots",
        "gravitational anomalies",
        "wormholes to another dimension",
        "a telescience mishap",
        "radiation flares",
        "supermatter dust",
        "leaks into a negative reality",
        "antiparticle clouds",
        "residual bluespace energy",
        "suspected criminal operatives",
        "malfunctioning von Neumann probe swarms",
        "shadowy interlopers",
        "a stranded Vox arkship",
        "haywire IPC constructs",
        "rogue Unathi exiles",
        "artifacts of eldritch horror",
        "a brain slug infestation",
        "killer bugs that lay eggs in the husks of the living",
        "a deserted transport carrying xenomorph specimens",
        "an emissary for the gestalt requesting a security detail",
        "a Tajaran slave rebellion",
        "radical Skrellian transevolutionaries",
        "classified security operations"
    ) } in the region is tying up all available local emergency resources;
    emergency response teams cannot be called at this time, and
    post-evacuation recovery efforts will be substantially delayed.

announce-response-team-disabled-title =
    Emergency Transmission

## Crew

announce-captain-joined =
    All hands, Captain { $name } on deck!

## Self-destruct

announce-self-destruct-terminal-stage =
    The self-destruct sequence has reached terminal countdown, abort systems have been disabled.

announce-self-destruct-terminal-stage-title =
    Self-Destruct Control Computer

## Supply Beacon

announce-supply-beacon-deactivated =
    Nyx Rapid Fabrication priority supply request #{ $x }-{ $y } recieved.
    Shipment dispatched via ballistic supply pod for immediate delivery. Have a nice day.

announce-supply-beacon-deactivated-title =
    Thank You For Your Patronage

## Bluespace Artillery

announce-bluespace-artillery-fire =
    Bluespace artillery fire detected. Brace for impact.
