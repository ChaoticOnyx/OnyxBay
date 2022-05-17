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
#define SFX_SHELL_INSERT            "shell_insert"
#define SFX_BULLET_INSERT           "bullet_insert"
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

// MALE EMOTES
#define SFX_MALE_INTERNAL_BREATH    "male_internal_breath"
#define SFX_MALE_COUGH              "male_cough"
#define SFX_MALE_SNEEZE             "male_sneeze"
#define SFX_MALE_HEAVY_BREATH       "male_heavy_breath"
#define SFX_MALE_PAIN               "male_pain"
#define SFX_MALE_LONG_SCREAM        "male_long_scream"
#define SFX_MALE_FALL_ALIVE         "male_fall_alive"
#define SFX_MALE_FALL_DEAD          "male_fall_dead"

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

// AMBIENT WEATHER
#define SFX_WEATHER_OUT_NORMAL          "weather_out_normal"
#define SFX_WEATHER_IN_NORMAL           "weather_in_normal"
#define SFX_WEATHER_OUT_STORM_INCOMING  "weather_out_storm_incoming"
#define SFX_WEATHER_IN_STORM_INCOMING   "weather_in_storm_incoming"
#define SFX_WEATHER_OUT_STORM           "weather_out_storm"
#define SFX_WEATHER_IN_STORM            "weather_in_storm"

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

// PULLING
#define SFX_PULL_BODY               "pull_body"
#define SFX_PULL_BOX                "pull_box"
#define SFX_PULL_CLOSET             "pull_closet"
#define SFX_PULL_GLASS              "pull_glass"
#define SFX_PULL_MACHINE            "pull_machine"
#define SFX_PULL_STONE              "pull_stone"
#define SFX_PULL_WOOD               "pull_wood"

// PICKUP
#define SFX_PICKUP_BOTTLE           "pickup_bottle"

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
#define SFX_GLASS_KNOCK             "glass_knock"
#define SFX_GIB                     "gib"
#define SFX_CLOWN                   "clown"
#define SFX_HISS                    "hiss"
#define SFX_CHOP                    "chop"
#define SFX_TRR                     "trr"
#define SFX_RADIO                   "radio"
#define SFX_THROWING                "throwing"
#define SFX_DISTANT_MOVEMENT        "distant_movement"
#define SFX_DISPOSAL                "disposal"

#define GET_SFX(name) pick(GLOB.sfx_list[name])
