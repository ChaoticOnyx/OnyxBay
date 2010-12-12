/*
Luna updated:
Captain has access to everything.
The Mule has QM access. The Medibot has access to Medical, Genetics, Morgue and Robotics. Floorbot and Cleanbot dont even have a botID.
Checked jobs: HoP, HoS, Security Officer, Doctor, CE, Detective, Scientist RD, Chemist, Geneticist, Roboticist, Janitor, Barman, Chef, Counselor, Atmos Tec, Engineer

    access_security = 1 (HoS, Security Officer, Detective, HoP)
    access_brig = 2 (HoS, Security Officer, HoP) (only lockers)
    access_armory = 3 (HoS)
    access_forensic= 4 (Security Officer, Detective, HoS, HoP)
    access_medical = 5 (Geneticist, Doctor, RD, Security Officer, Detective, HoS, HoP, Chemist, Roboticist)
    access_morgue = 6 (HoS, Detective, RD, Doctor, Geneticist, Roboticist, Counselor)
    access_toxins = 7 (HoP, HoS, RD, Scientist)
    access_toxins_storage = 8 (HoS, RD, Scientist) (only locker)
    access_genetics = 9 (HoP, HoS, RD, Doctor, Scientist, Geneticist)
    access_engineering = 10 (HoP, HoS, CE, Engineer)
    access_electrical_storage = 11 (CE, Engineer)
    access_maintenance = 12 (Everyone)
    access_external_airlock = 13 (CE, Atmos Tec, Engineer) (Got name from Strumpet. Not used at all???)
    access_emergency_storage = 14 (HoP, CE, Atmos Tec) (Got name from Strumpet. Not used at all???)
    access_change_id = 15 (HoP)
    access_ai_facilities = 16 (HoP, CE)
    access_teleporter = 17 (HoS, RD)
    access_eva = 18 (HoP, CE)
    access_heads_only = 19 (HoP, CE, RD, HoS)
    access_captain_only = 20
    access_all_personal_lockers = 21 (HoP)
    access_counselor = 22 (Counselor)
    access_aux_storage = 23 (HoP, HoS, CE, RD, Roboticist, Atmos Tec, Engineer)
    access_atmos = 24 (HoS, CE, Atmos Tec)
    ??? = 25 (HoS, HoP, Barman)
    access_janitor = 26 (HoP, HoS, Janitor)
    access_chapel_incinerator = 27 (HoP, Counselor)
    access_kitchen_and_bar = 28 (HoP, Chef, Barman, HoS)
    access_robotics = 29 (RD, Roboticist, HoP, HoS)
    access_admins = 30 (Noone has this)
    access_supply_warehouse = 31 (QM, HoP)
    access_construction = 32 (CE) (Got name from Strumpet. What is this? Couldnt find it ingame.)
    access_chemistry = 33 (HoP, HoS, RD, Chemist)
    access_mule = 34 (Mule itself has this. The doors behind Security Checkpoint require this. QM, HoP)
    access_security_hq = 35 (Security Officer, Detective, CE, HoS, HoP, RD)
    access_research_hallway = 36 (Security Officer, Detective, HoS, HoP, CE, RD, Doctor, Scientist, Chemist, Geneticist, Janitor, Engineer)
    access_incinerator = 37 (HoS, Security Officer, HoP, Janitor, Engineer)
    ??? = 38 (HoS, Security Officer, HoP, CE, Janitor, Atmos Tec, Engineer)
    access_shields = 39 (HoS, Security Officer, HoP, CE, Engineer)

    */