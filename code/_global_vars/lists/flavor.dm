// Used by robots and robot preferences.
GLOBAL_LIST_INIT(robot_module_types, list(
	"Standard",
	"Engineering",
	"Medical",
	"Miner",
	"Janitor",
	"Service",
	"Security",
	"Research"
)) // This shouldn't be a static list. Am I the only one who cares about extendability around here?

// Noises made when hit while typing.
GLOBAL_LIST_INIT(hit_appends, list("-OOF", "-ACK", "-UGH", "-HRNK", "-HURGH", "-GLORF"))

// Some scary sounds.
GLOBAL_LIST_INIT(scarySounds, list(
	'sound/weapons/thudswoosh.ogg',
	'sound/weapons/Taser.ogg',
	'sound/weapons/armbomb.ogg',
	'sound/voice/hiss1.ogg',
	'sound/voice/hiss2.ogg',
	'sound/voice/hiss3.ogg',
	'sound/voice/hiss4.ogg',
	'sound/voice/hiss5.ogg',
	'sound/voice/hiss6.ogg',
	'sound/items/Welder.ogg',
	'sound/items/Welder2.ogg',
	'sound/machines/airlock.ogg',
	'sound/effects/clownstep1.ogg',
	'sound/effects/clownstep2.ogg'
))

// Reference list for disposal sort junctions. Filled up by sorting junction's New()
GLOBAL_LIST_EMPTY(tagger_locations)

GLOBAL_LIST_INIT(station_prefixes, list("", "Imperium", "Heretical", "Cuban",
	"Psychic", "Elegant", "Common", "Uncommon", "Rare", "Unique",
	"Houseruled", "Religious", "Atheist", "Traditional", "Houseruled",
	"Mad", "Super", "Ultra", "Secret", "Top Secret", "Deep", "Death",
	"Zybourne", "Central", "Main", "Government", "Uoi", "Fat",
	"Automated", "Experimental", "Augmented"))

GLOBAL_LIST_INIT(station_names, list("", "Stanford", "Dorf", "Alium",
	"Prefix", "Clowning", "Aegis", "Ishimura", "Scaredy", "Death-World",
	"Mime", "Honk", "Rogue", "MacRagge", "Ultrameens", "Safety", "Paranoia",
	"Explosive", "Neckbear", "Donk", "Muppet", "North", "West", "East",
	"South", "Slant-ways", "Widdershins", "Rimward", "Expensive",
	"Procreatory", "Imperial", "Unidentified", "Immoral", "Carp", "Ork",
	"Pete", "Control", "Nettle", "Aspie", "Class", "Crab", "Fist",
	"Corrogated","Skeleton","Race", "Fatguy", "Gentleman", "Capitalist",
	"Communist", "Bear", "Beard", "Derp", "Space", "Spess", "Star", "Moon",
	"System", "Mining", "Neckbeard", "Research", "Supply", "Military",
	"Orbital", "Battle", "Science", "Asteroid", "Home", "Production",
	"Transport", "Delivery", "Extraplanetary", "Orbital", "Correctional",
	"Robot", "Hats", "Pizza"))

GLOBAL_LIST_INIT(station_suffixes, list("Station", "Frontier",
	"Suffix", "Death-trap", "Space-hulk", "Lab", "Hazard","Spess Junk",
	"Fishery", "No-Moon", "Tomb", "Crypt", "Hut", "Monkey", "Bomb",
	"Trade Post", "Fortress", "Village", "Town", "City", "Edition", "Hive",
	"Complex", "Base", "Facility", "Depot", "Outpost", "Installation",
	"Drydock", "Observatory", "Array", "Relay", "Monitor", "Platform",
	"Construct", "Hangar", "Prison", "Center", "Port", "Waystation",
	"Factory", "Waypoint", "Stopover", "Hub", "HQ", "Office", "Object",
	"Fortification", "Colony", "Planet-Cracker", "Roost", "Fat Camp",
	"Airstrip"))

GLOBAL_LIST_INIT(greek_letters, list("Alpha", "Beta", "Gamma", "Delta",
	"Epsilon", "Zeta", "Eta", "Theta", "Iota", "Kappa", "Lambda", "Mu",
	"Nu", "Xi", "Omicron", "Pi", "Rho", "Sigma", "Tau", "Upsilon", "Phi",
	"Chi", "Psi", "Omega"))

GLOBAL_LIST_INIT(phonetic_alphabet, list("Alpha", "Bravo", "Charlie",
	"Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet",
	"Kilo", "Lima", "Mike", "November", "Oscar", "Papa", "Quebec",
	"Romeo", "Sierra", "Tango", "Uniform", "Victor", "Whiskey", "X-ray",
	"Yankee", "Zulu"))

GLOBAL_LIST_INIT(numbers_as_words, list("One", "Two", "Three", "Four",
	"Five", "Six", "Seven", "Eight", "Nine", "Ten", "Eleven", "Twelve",
	"Thirteen", "Fourteen", "Fifteen", "Sixteen", "Seventeen",
	"Eighteen", "Nineteen"))

GLOBAL_LIST_INIT(music_tracks, list(
	"Prey" = 'sound/music/prey.ogg',
	"Clouds of Fire" = 'sound/music/clouds.s3m',
	"D`Bert" = 'sound/music/title2.ogg',
	"D`Fort" = 'sound/ambience/song_game.ogg',
	"Floating" = 'sound/music/main.ogg',
	"Endless Space" = 'sound/music/space.ogg',
	"Part A" = 'sound/misc/TestLoop1.ogg',
	"Scratch" = 'sound/music/title1.ogg',
	"Trai`Tor" = 'sound/music/traitor.ogg',
	"All That I Can See" = 'sound/music/all_that_i_can_see.ogg',
	"Delirium" = 'sound/music/delirium.ogg',
	"End" = 'sound/music/end.ogg',
	"Magicfly" = 'sound/music/magicfly.ogg',
	"Self Justified Sacrifices" = 'sound/music/self_justified_sacrifices.ogg',
	"Mr. Sandman" = 'sound/music/sandman.ogg',
	"Lone Digger" = 'sound/music/lonedigger.ogg',
	"Reaper & Blues" = 'sound/music/reapernblues.ogg',
	"Undead Man Walkin`" = 'sound/music/undeadwalking.ogg',
	"Space Oddity" = 'sound/music/space_oddity.ogg',
	"Crockett's Theme" = 'sound/music/crokett_39_s_theme.ogg'
))

/proc/setup_music_tracks(list/tracks)
	. = list()
	var/track_list = LAZYLEN(tracks) ? tracks : GLOB.music_tracks
	for(var/track_name in track_list)
		var/track_path = track_list[track_name]
		. += new /datum/track(track_name, track_path)

