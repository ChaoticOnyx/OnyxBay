#define PICKUP_SOUND_VOLUME_MIN 20
#define PICKUP_SOUND_VOLUME_MAX 60
#define DROP_SOUND_VOLUME_MIN 20
#define DROP_SOUND_VOLUME_MAX 70
#define THROW_SOUND_VOLUME 90

//Sound environment defines. Reverb preset for sounds played in an area, see sound datum reference for more.
#define GENERIC 0
#define PADDED_CELL 1
#define ROOM 2
#define BATHROOM 3
#define LIVINGROOM 4
#define STONEROOM 5
#define AUDITORIUM 6
#define CONCERT_HALL 7
#define CAVE 8
#define ARENA 9
#define HANGAR 10
#define CARPETED_HALLWAY 11
#define HALLWAY 12
#define STONE_CORRIDOR 13
#define ALLEY 14
#define FOREST 15
#define CITY 16
#define MOUNTAINS 17
#define QUARRY 18
#define PLAIN 19
#define PARKING_LOT 20
#define SEWER_PIPE 21
#define UNDERWATER 22
#define DRUGGED 23
#define DIZZY 24
#define PSYCHOTIC 25

#define STANDARD_STATION STONEROOM
#define LARGE_ENCLOSED HANGAR
#define SMALL_ENCLOSED BATHROOM
#define TUNNEL_ENCLOSED CAVE
#define LARGE_SOFTFLOOR CARPETED_HALLWAY
#define MEDIUM_SOFTFLOOR LIVINGROOM
#define SMALL_SOFTFLOOR ROOM
#define ASTEROID CAVE
#define SPACE UNDERWATER

#define VOLUME_AMBIENT_MUSIC 50

// Timing
#define AMBIENT_MUSIC_COOLDOWN 2 MINUTES
// TODO: Also add cooldown for ambients.

// Sound channels
// TODO: Replace hardcoded values with these defines.
#define SOUND_CHANNEL_AMBIENT       1
#define SOUND_CHANNEL_AMBIENT_MUSIC 2
#define SOUND_CHANNEL_HUM           3
#define SOUND_CHANNEL_WEATHER       4

// Ambient music tags
#define MUSIC_TAG_NORMAL          0
#define MUSIC_TAG_MYSTIC          1
#define MUSIC_TAG_SPACE           2
#define MUSIC_TAG_SPACE_TRAVELING 3
#define MUSIC_TAG_CENTCOMM        4

// SFX List
// FIREARMS SOUND
#define SFX_FAR_FIRE                "far_fire"
#define SFX_SILENT_FIRE             "silent_fire"
#define SFX_MAGAZINE_INSERT         "magazine_insert"
#define SFX_BULLET_INSERT "bullet_insert"
#define SFX_SHELL_INSERT "shell_insert"
#define SFX_SPAS12_SHELL_INSERT "spas12_shell_insert"
#define SFX_REM870_SHELL_INSERT "rem870_shell_insert"
#define SFX_SHOTGUN_PUMP_IN         "shotgun_pump_in"
#define SFX_SHOTGUN_PUMP_OUT        "shotgun_pump_out"
#define SFX_CASING_DROP             "casing_drop"

// FEMALE EMOTES
#define SFX_FEMALE_INTERNAL_BREATH  "female_internal_breath"
#define SFX_FEMALE_COUGH            "female_cough"
#define SFX_FEMALE_SNEEZE           "female_sneeze"
#define SFX_FEMALE_HEAVY_BREATH     "female_heavy_breath"
#define SFX_FEMALE_PAIN             "female_pain"
#define SFX_FEMALE_LONG_SCREAM      "female_long_scream"
#define SFX_FEMALE_FALL_ALIVE       "female_fall_alive"
#define SFX_FEMALE_FALL_DEAD        "female_fall_dead"
#define SFX_FEMALE_CRY              "female_cry"
#define SFX_FEMALE_LAUGH            "female_laugh"
#define SFX_FEMALE_YAWN             "female_yawn"
#define SFX_FEMALE_SIGH             "female_sigh"

// MALE EMOTES
#define SFX_MALE_INTERNAL_BREATH    "male_internal_breath"
#define SFX_MALE_COUGH              "male_cough"
#define SFX_MALE_SNEEZE             "male_sneeze"
#define SFX_MALE_HEAVY_BREATH       "male_heavy_breath"
#define SFX_MALE_PAIN               "male_pain"
#define SFX_MALE_LONG_SCREAM        "male_long_scream"
#define SFX_MALE_FALL_ALIVE         "male_fall_alive"
#define SFX_MALE_FALL_DEAD          "male_fall_dead"
#define SFX_MALE_CRY                "male_cry"
#define SFX_MALE_LAUGH              "male_laugh"
#define SFX_MALE_YAWN               "male_yawn"
#define SFX_MALE_SIGH               "male_sigh"

// AMBIENT
#define SFX_AMBIENT_POWERED_GLOBAL      "ambient_powered_global"
#define SFX_AMBIENT_OFF_GLOBAL          "ambient_off_global"
#define SFX_AMBIENT_SCIENCE             "ambient_science"
#define SFX_AMBIENT_AI                  "ambient_ai"
#define SFX_AMBIENT_COMMS               "ambient_powered_comms"
#define SFX_AMBIENT_POWERED_MAINTENANCE "ambient_powered_maintenance"
#define SFX_AMBIENT_OFF_MAINTENANCE     "ambient_off_maintenance"
#define SFX_AMBIENT_ENGINEERING         "ambient_engineering"
#define SFX_AMBIENT_SPACE               "ambient_space"
#define SFX_AMBIENT_OUTPOST             "ambient_outpost"
#define SFX_AMBIENT_MINE                "ambient_mine"
#define SFX_AMBIENT_CHAPEL              "ambient_chapel"
#define SFX_AMBIENT_ATMOSPHERICS        "ambient_atmospherics"
#define SFX_AMBIENT_MORGUE              "ambient_morgue"
#define SFX_AMBIENT_JUNGLE              "ambient_jungle"

// AMBIENT MUSIC
#define SFX_AMBIENT_MUSIC_NORMAL       "ambient_music_normal"
#define SFX_AMBIENT_MUSIC_MYSTIC       "ambient_music_mystic"
#define SFX_AMBIENT_MUSIC_SPACE        "ambient_music_space"
#define SFX_AMBIENT_MUSIC_SPACE_TRAVEL "ambient_music_space_travel"
#define SFX_AMBIENT_MUSIC_CENTCOMM     "ambient_music_centcomm"

// ITEMS USING
#define SFX_USE_HANDCUFFS           "use_handcuffs"
#define SFX_USE_CABLE_HANDCUFFS     "use_cable_handcuffs"
#define SFX_USE_OUTFIT              "use_outfit"
#define SFX_USE_SMALL_SWITCH        "use_small_switch"
#define SFX_USE_LARGE_SWITCH        "use_large_switch"
#define SFX_USE_PAGE                "use_page"
#define SFX_USE_BUTTON              "use_button"
#define SFX_USE_LIGHTER             "use_lighter"
#define SFX_USE_CHISEL              "use_chisel"
#define SFX_KEYBOARD                "use_keyboard"

// PULLING
#define SFX_PULL_BODY               "pull_body"
#define SFX_PULL_BOX                "pull_box"
#define SFX_PULL_CLOSET             "pull_closet"
#define SFX_PULL_GLASS              "pull_glass"
#define SFX_PULL_MACHINE            "pull_machine"
#define SFX_PULL_STONE              "pull_stone"
#define SFX_PULL_WOOD               "pull_wood"

// PICKUP
#define SFX_PICKUP_GENERIC          "pickup_generic"
#define SFX_PICKUP_ACCESSORY        "pickup_accessory"
#define SFX_PICKUP_AMMOBOX          "pickup_ammobox"
#define SFX_PICKUP_AXE              "pickup_axe"
#define SFX_PICKUP_BACKPACK         "pickup_backpack"
#define SFX_PICKUP_BALL             "pickup_ball"
#define SFX_PICKUP_BOOK             "pickup_book"
#define SFX_PICKUP_BOOTS            "pickup_boots"
#define SFX_PICKUP_BOTTLE           "pickup_bottle"
#define SFX_PICKUP_GLASSBOTTLE      "pickup_glassbottle"
#define SFX_PICKUP_CARD             "pickup_card"
#define SFX_PICKUP_CARDBOARD        "pickup_cardboard"
#define SFX_PICKUP_CLOTH            "pickup_cloth"
#define SFX_PICKUP_COMPONENT        "pickup_component"
#define SFX_PICKUP_CROWBAR          "pickup_crowbar"
#define SFX_PICKUP_DEVICE           "pickup_device"
#define SFX_PICKUP_DISK             "pickup_disk"
#define SFX_PICKUP_DRINKGLASS       "pickup_drinkglass"
#define SFX_PICKUP_FLESH            "pickup_flesh"
#define SFX_PICKUP_FOOD             "pickup_food"
#define SFX_PICKUP_GASCAN           "pickup_gascan"
#define SFX_PICKUP_GLASS            "pickup_glass"
#define SFX_PICKUP_GLASSSMALL       "pickup_glasssmall"
#define SFX_PICKUP_GLOVES           "pickup_gloves"
#define SFX_PICKUP_GUN              "pickup_gun"
#define SFX_PICKUP_HAT              "pickup_hat"
#define SFX_PICKUP_HELMET           "pickup_helmet"
#define SFX_PICKUP_HERB             "pickup_herb"
#define SFX_PICKUP_KNIFE            "pickup_knife"
#define SFX_PICKUP_LEATHER          "pickup_leather"
#define SFX_PICKUP_MATCHBOX         "pickup_matchbox"
#define SFX_PICKUP_METALPOT         "pickup_metalpot"
#define SFX_PICKUP_METALWEAPON      "pickup_metalweapon"
#define SFX_PICKUP_MULTITOOL        "pickup_multitool"
#define SFX_PICKUP_PAPER            "pickup_paper"
#define SFX_PICKUP_PAPERCUP         "pickup_papercup"
#define SFX_PICKUP_PILLBOTTLE       "pickup_pillbottle"
#define SFX_PICKUP_PLUSHIE          "pickup_plushie"
#define SFX_PICKUP_RING             "pickup_ring"
#define SFX_PICKUP_RUBBER           "pickup_rubber"
#define SFX_PICKUP_SCREWDRIVER      "pickup_screwdriver"
#define SFX_PICKUP_SHEL              "pickup_shelldrop"
#define SFX_PICKUP_SHOES            "pickup_shoes"
#define SFX_PICKUP_SHOVEL           "pickup_shovel"
#define SFX_PICKUP_SODACAN          "pickup_sodacan"
#define SFX_PICKUP_SWORD            "pickup_sword"
#define SFX_PICKUP_TOOLBELT         "pickup_toolbelt"
#define SFX_PICKUP_TOOLBOX          "pickup_toolbox"
#define SFX_PICKUP_WELDINGTOOL      "pickup_weldingtool"
#define SFX_PICKUP_WIRECUTTER       "pickup_wirecutter"
#define SFX_PICKUP_WOODEN           "pickup_wooden"
#define SFX_PICKUP_WRAPPER          "pickup_wrapper"
#define SFX_PICKUP_WRENCH           "pickup_wrench"

// DROP
#define SFX_DROP_GENERIC            "drop_generic"
#define SFX_DROP_ACCESSORY          "drop_accessory"
#define SFX_DROP_AMMOBOX            "drop_ammobox"
#define SFX_DROP_AXE                "drop_axe"
#define SFX_DROP_BACKPACK           "drop_backpack"
#define SFX_DROP_BALL               "drop_ball"
#define SFX_DROP_BOOK               "drop_book"
#define SFX_DROP_BOOTS              "drop_boots"
#define SFX_DROP_BOTTLE             "drop_bottle"
#define SFX_DROP_GLASSBOTTLE        "drop_glassbottle"
#define SFX_DROP_CARD               "drop_card"
#define SFX_DROP_CARDBOARD          "drop_cardboard"
#define SFX_DROP_CLOTH              "drop_cloth"
#define SFX_DROP_COMPONENT          "drop_component"
#define SFX_DROP_CROWBAR            "drop_crowbar"
#define SFX_DROP_DEVICE             "drop_device"
#define SFX_DROP_DISK               "drop_disk"
#define SFX_DROP_DRINKGLASS         "drop_drinkglass"
#define SFX_DROP_FLESH              "drop_flesh"
#define SFX_DROP_FOOD               "drop_food"
#define SFX_DROP_GASCAN             "drop_gascan"
#define SFX_DROP_GLASS              "drop_glass"
#define SFX_DROP_GLASSSMALL         "drop_glasssmall"
#define SFX_DROP_GLOVES             "drop_gloves"
#define SFX_DROP_GUN                "drop_gun"
#define SFX_DROP_HAT                "drop_hat"
#define SFX_DROP_HELMET             "drop_helmet"
#define SFX_DROP_HERB               "drop_herb"
#define SFX_DROP_KNIFE              "drop_knife"
#define SFX_DROP_LEATHER            "drop_leather"
#define SFX_DROP_MATCHBOX           "drop_matchbox"
#define SFX_DROP_METALPOT           "drop_metalpot"
#define SFX_DROP_METALWEAPON        "drop_metalweapon"
#define SFX_DROP_MULTITOOL          "drop_multitool"
#define SFX_DROP_PAPER              "drop_paper"
#define SFX_DROP_PAPERCUP           "drop_papercup"
#define SFX_DROP_PILLBOTTLE         "drop_pillbottle"
#define SFX_DROP_PLUSHIE            "drop_plushie"
#define SFX_DROP_RING               "drop_ring"
#define SFX_DROP_RUBBER             "drop_rubber"
#define SFX_DROP_SCREWDRIVER        "drop_screwdriver"
#define SFX_DROP_SHELL              "drop_shelldrop"
#define SFX_DROP_SHOES              "drop_shoes"
#define SFX_DROP_SHOVEL             "drop_shovel"
#define SFX_DROP_SODACAN            "drop_sodacan"
#define SFX_DROP_SWORD              "drop_sword"
#define SFX_DROP_TOOLBELT           "drop_toolbelt"
#define SFX_DROP_TOOLBOX            "drop_toolbox"
#define SFX_DROP_WELDINGTOOL        "drop_weldingtool"
#define SFX_DROP_WIRECUTTER         "drop_wirecutter"
#define SFX_DROP_WOODEN             "drop_wooden"
#define SFX_DROP_WRAPPER            "drop_wrapper"
#define SFX_DROP_WRENCH             "drop_wrench"

// HOLSTER & SHEATH
#define SFX_HOLSTERIN               "holster_in"
#define SFX_HOLSTEROUT              "holster_out"
#define SFX_SHEATHIN                "sheath_in"
#define SFX_SHEATHOUT               "sheath_out"
#define SFX_TACHOLSTERIN            "tacholster_in"
#define SFX_TACHOLSTEROUT           "tacholster_out"

// DRINK & EAT
#define SFX_DRINK                   "drink"
#define SFX_EAT                     "eat"

// OPEN & CLOSE
#define SFX_OPEN_CLOSET             "open_closet"
#define SFX_CLOSE_CLOSET            "close_closet"

// SEARCHING
#define SFX_SEARCH_CLOTHES          "search_clothes"
#define SFX_SEARCH_CABINET          "search_cabinet"
#define SFX_SEARCH_CASE             "search_case"

// SPARK
#define SFX_SPARK_SMALL             "spark_small"
#define SFX_SPARK                   "spark"
#define SFX_SPARK_MEDIUM            "spark_medium"
#define SFX_SPARK_HEAVY             "spark_heavy"

// TURRETS
#define SFX_TURRET_DEPLOY           "turret_deploy"
#define SFX_TURRET_RETRACT          "turret_retract"
#define SFX_TURRET_ROTATE           "turret_rotate"

// EXPLOSION
#define SFX_EXPLOSION               "explosion"
#define SFX_EXPLOSION_ELECTRIC      "explosion_electric"
#define SFX_EXPLOSION_FAR           "explosion_far"
#define SFX_EXPLOSION_FUEL          "explosion_fuel"

// BEEP
#define SFX_BEEP_COMP               "beep_comp"
#define SFX_BEEP_MEDICAL            "beep_medical"

// BREAKING
#define SFX_BREAK_CONSOLE           "break_console"
#define SFX_BREAK_WINDOW            "break_window"
#define SFX_BREAK_BONE              "break_bone"

// FIGHTING
#define SFX_FIGHTING_CRUNCH         "fighting_crunch"
#define SFX_FIGHTING_PUNCH          "fighting_punch"
#define SFX_FIGHTING_SWING          "fighting_swing"

// DEVICES
#define SFX_GEIGER_LOW              "geiger_low"
#define SFX_GEIGER_MODERATE         "geiger_moderate"
#define SFX_GEIGER_HIGH             "geiger_high"
#define SFX_GEIGER_VERY_HIGH        "geiger_very_high"

// MISC
#define SFX_VENT                    "vent"
#define SFX_GLASS_HIT               "glass_hit"
#define SFX_CHAINSAW                "chainsaw"
#define SFX_GLASS_KNOCK             "glass_knock"
#define SFX_GIB                     "gib"
#define SFX_CLOWN                   "clown"
#define SFX_HISS                    "hiss"
#define SFX_WHISTLE                 "whistle"
#define SFX_SNORE                   "snore"
#define SFX_CLAP                    "clap"
#define SFX_CHOP                    "chop"
#define SFX_TRR                     "trr"
#define SFX_RADIO                   "radio"
#define SFX_THROWING                "throwing"
#define SFX_DISPOSAL                "disposal"
#define SFX_OINK                    "oink"

// FOOTSTEPS
#define SFX_DISTANT_MOVEMENT        "distant_movement"
#define SFX_FOOTSTEP_WOOD           "footstep_wood"
#define SFX_FOOTSTEP_TILES          "footstep_tiles"
#define SFX_FOOTSTEP_PLATING        "footstep_plating"
#define SFX_FOOTSTEP_CARPET         "footstep_carpet"
#define SFX_FOOTSTEP_ASTEROID       "footstep_asteroid"
#define SFX_FOOTSTEP_SNOW           "footstep_snow"
#define SFX_FOOTSTEP_GRASS          "footstep_grass"
#define SFX_FOOTSTEP_WATER          "footstep_water"
#define SFX_FOOTSTEP_BLANK          "footstep_blank"
#define SFX_FOOTSTEP_ROBOT_LEGS     "footstep_robot_legs"
#define SFX_FOOTSTEP_ROBOT_SPIDER   "footstep_robot_spider"
#define SFX_FOOTSTEP_STAIRS         "footstep_stairs"

// VENDING
#define SFX_VENDING_CANS            "vending_cans"
#define SFX_VENDING_COFFEE          "vending_coffee"
#define SFX_VENDING_DROP            "vending_drop"
#define SFX_VENDING_GENERIC         "vending_generic"

#define GET_SFX(name) pick(GLOB.sfx_list[name])
