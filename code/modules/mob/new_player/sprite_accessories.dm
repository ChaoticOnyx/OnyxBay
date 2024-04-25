/*

	Hello and welcome to sprite_accessories: For sprite accessories, such as hair,
	facial hair, and possibly tattoos and stuff somewhere along the line. This file is
	intended to be friendly for people with little to no actual coding experience.
	The process of adding in new hairstyles has been made pain-free and easy to do.
	Enjoy! - Doohl


	Notice: This all gets automatically compiled in a list in dna2.dm, so you do not
	have to define any UI values for sprite accessories manually for hair and facial
	hair. Just add in new hair types and the game will naturally adapt.

	!!WARNING!!: changing existing hair information can be VERY hazardous to savefiles,
	to the point where you may completely corrupt a server's savefiles. Please refrain
	from doing this unless you absolutely know what you are doing, and have defined a
	conversion in savefile.dm
*/

/datum/sprite_accessory

	var/icon			// the icon file the accessory is located in
	var/icon_state		// the icon_state of the accessory
	var/preview_state	// a custom preview state for whatever reason

	var/name			// the preview name of the accessory

	// Determines if the accessory will be skipped or included in random hair generations
	var/gender = NEUTER

	// Restrict some styles to specific species
	var/list/species_allowed = list(SPECIES_HUMAN, SPECIES_DEVIL)

	// Whether or not the accessory can be affected by colouration
	var/do_coloration = TRUE

	var/blend = ICON_ADD


/*
////////////////////////////
/  =--------------------=  /
/  == Hair Definitions ==  /
/  =--------------------=  /
////////////////////////////
*/

/datum/sprite_accessory/hair
	var/flags
	var/has_secondary = FALSE

/datum/sprite_accessory/hair/bald
	name = "Bald"
	icon_state = "bald"
	gender = MALE
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_VOX, SPECIES_SWINE, SPECIES_DEVIL)
	flags = VERY_SHORT
	has_secondary = TRUE

/datum/sprite_accessory/hair/short
	name = "Short Hair"   // try to capatilize the names please~
	icon_state = "short"  // you do not need to define _s or _l sub-states, game automatically does this for you
	flags = VERY_SHORT

/datum/sprite_accessory/hair/short2
	name = "Short Hair 2"
	icon_state = "short2"

/datum/sprite_accessory/hair/short3
	name = "Short Hair 3"
	icon_state = "short3"

/datum/sprite_accessory/hair/twintail
	name = "Twintail"
	icon_state = "twintail"

/datum/sprite_accessory/hair/cut
	name = "Cut Hair"
	icon_state = "cut"
	flags = VERY_SHORT

/datum/sprite_accessory/hair/flair
	name = "Flaired Hair"
	icon_state = "flair"

/datum/sprite_accessory/hair/long
	name = "Shoulder-length Hair"
	icon_state = "shoulder_length"

/datum/sprite_accessory/hair/longer
	name = "Long Hair"
	icon_state = "vlong"

/datum/sprite_accessory/hair/longeralt2
	name = "Long Hair 2"
	icon_state = "longeralt2"

/datum/sprite_accessory/hair/longest
	name = "Very Long Hair"
	icon_state = "longest"

/datum/sprite_accessory/hair/longest_stylish
	name = "Very Long Hair S"
	icon_state = "longest_stylish"

/datum/sprite_accessory/hair/longfringe
	name = "Long Fringe"
	icon_state = "longfringe"

/datum/sprite_accessory/hair/longestalt
	name = "Longer Fringe"
	icon_state = "vlongfringe"

/datum/sprite_accessory/hair/halfbang
	name = "Half-banged Hair"
	icon_state = "halfbang"

/datum/sprite_accessory/hair/halfbangalt
	name = "Half-banged Hair Alt"
	icon_state = "halfbang_alt"

/datum/sprite_accessory/hair/ponytail1
	name = "Ponytail 1"
	icon_state = "ponytail"

/datum/sprite_accessory/hair/ponytail2
	name = "Ponytail 2"
	icon_state = "ponytail2"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail3
	name = "Ponytail 3"
	icon_state = "ponytail3"

/datum/sprite_accessory/hair/ponytail4
	name = "Ponytail 4"
	icon_state = "ponytail4"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail5
	name = "Ponytail 5"
	icon_state = "ponytail5"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail6
	name = "Ponytail 6"
	icon_state = "ponytail6"
	gender = FEMALE

/datum/sprite_accessory/hair/ponytail7
	name = "Ponytail 7"
	icon_state = "ponytail7"

/datum/sprite_accessory/hair/sideponytail
	name = "Side Ponytail"
	icon_state = "stail"
	gender = FEMALE

/datum/sprite_accessory/hair/parted
	name = "Parted"
	icon_state = "parted"

/datum/sprite_accessory/hair/pompadour
	name = "Pompadour"
	icon_state = "pompadour"
	gender = MALE

/datum/sprite_accessory/hair/sleeze
	name = "Sleeze"
	icon_state = "sleeze"
	flags = VERY_SHORT

/datum/sprite_accessory/hair/quiff
	name = "Quiff"
	icon_state = "quiff"
	gender = MALE

/datum/sprite_accessory/hair/bedhead
	name = "Bedhead"
	icon_state = "bedhead"

/datum/sprite_accessory/hair/bedhead2
	name = "Bedhead 2"
	icon_state = "bedhead2"

/datum/sprite_accessory/hair/bedhead3
	name = "Bedhead 3"
	icon_state = "bedhead3"

/datum/sprite_accessory/hair/Birdtail
	name = "Bird Tail"
	icon_state = "bird_tail"

/datum/sprite_accessory/hair/beehive
	name = "Beehive"
	icon_state = "beehive"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/beehive2
	name = "Beehive 2"
	icon_state = "beehive2"
	gender = FEMALE

/datum/sprite_accessory/hair/bob
	name = "Bob"
	icon_state = "bob"
	gender = FEMALE
	species_allowed = list(SPECIES_HUMAN, SPECIES_DEVIL)

/datum/sprite_accessory/hair/bob2
	name = "Bob 2"
	icon_state = "bob2"
	gender = FEMALE

/datum/sprite_accessory/hair/bobcurl
	name = "Bob Curly"
	icon_state = "bobcurl"
	gender = FEMALE

/datum/sprite_accessory/hair/bobasymm
	name = "Bob Asymmetrical"
	icon_state = "bob_asymm"
	gender = FEMALE

/datum/sprite_accessory/hair/bobasymm2
	name = "Bob Asymmetrical 2"
	icon_state = "bob_asymm2"
	gender = FEMALE

/datum/sprite_accessory/hair/bowl
	name = "Bowl"
	icon_state = "bowlcut"
	gender = MALE

/datum/sprite_accessory/hair/buzz
	name = "Buzzcut"
	icon_state = "buzzcut"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/buzzcut2
	name = "Buzzcut 2"
	icon_state = "buzzcut2"

/datum/sprite_accessory/hair/crew
	name = "Crewcut"
	icon_state = "crewcut"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/combover
	name = "Combover"
	icon_state = "combover"
	gender = MALE

/datum/sprite_accessory/hair/father
	name = "Father"
	icon_state = "father"
	gender = MALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/reversemohawk
	name = "Reverse Mohawk"
	icon_state = "reversemohawk"
	gender = MALE

/datum/sprite_accessory/hair/devillock
	name = "Devil Lock"
	icon_state = "devilock"

/datum/sprite_accessory/hair/dreadlocks
	name = "Dreadlocks"
	icon_state = "dreads"

/datum/sprite_accessory/hair/curls
	name = "Curls"
	icon_state = "curls"

/datum/sprite_accessory/hair/afro
	name = "Afro"
	icon_state = "afro"

/datum/sprite_accessory/hair/afro2
	name = "Afro 2"
	icon_state = "afro2"

/datum/sprite_accessory/hair/afro_large
	name = "Afro 3"
	icon_state = "afro_big"
	gender = MALE

/datum/sprite_accessory/hair/rows
	name = "Rows"
	icon_state = "rows1"
	flags = VERY_SHORT

/datum/sprite_accessory/hair/rows2
	name = "Rows 2"
	icon_state = "rows2"
	flags = VERY_SHORT

/datum/sprite_accessory/hair/sargeant
	name = "Flat Top"
	icon_state = "sargeant"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/emo
	name = "Emo"
	icon_state = "emo"

/datum/sprite_accessory/hair/emo2
	name = "Emo 2"
	icon_state = "emo2"

/datum/sprite_accessory/hair/longemo
	name = "Long Emo"
	icon_state = "emolong"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/shortovereye
	name = "Overeye Short"
	icon_state = "shortovereye"

/datum/sprite_accessory/hair/shortovereye_stylish
	name = "Overeye Short Stylish"
	icon_state = "shortovereye_stylish"

/datum/sprite_accessory/hair/longovereye
	name = "Overeye Long"
	icon_state = "longovereye"

/datum/sprite_accessory/hair/feather
	name = "Feather"
	icon_state = "feather"

/datum/sprite_accessory/hair/hitop
	name = "Hitop"
	icon_state = "hitop"
	gender = MALE

/datum/sprite_accessory/hair/mohawk
	name = "Mohawk"
	icon_state = "mohawk"
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI)

/datum/sprite_accessory/hair/jensen
	name = "Adam Jensen Hair"
	icon_state = "jensen"
	gender = MALE

/datum/sprite_accessory/hair/gelled
	name = "Gelled Back"
	icon_state = "gelled"
	gender = FEMALE

/datum/sprite_accessory/hair/undercut_1
	name = "Undercut"
	icon_state = "undercut1"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/undercut_2
	name = "Undercut Swept Right"
	icon_state = "undercut2"
	gender = MALE

/datum/sprite_accessory/hair/undercut_3
	name = "Undercut Swept Left"
	icon_state = "undercut3"
	gender = MALE

/datum/sprite_accessory/hair/gentle
	name = "Gentle"
	icon_state = "gentle"
	gender = FEMALE

/datum/sprite_accessory/hair/spiky
	name = "Spiky"
	icon_state = "spiky"
	species_allowed = list(SPECIES_HUMAN)

/datum/sprite_accessory/hair/kagami
	name = "Pigtails"
	icon_state = "kagami"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/pigtails_b
	name = "Pigtails 2"
	icon_state = "pigtails_b"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/himecut
	name = "Hime Cut"
	icon_state = "himecut"
	gender = FEMALE

/datum/sprite_accessory/hair/shorthime
	name = "Short Hime Cut"
	icon_state = "shorthime"
	gender = FEMALE

/datum/sprite_accessory/hair/grandebraid
	name = "Grande Braid"
	icon_state = "grande"
	gender = FEMALE

/datum/sprite_accessory/hair/mbraid
	name = "Medium Braid"
	icon_state = "shortbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/braid2
	name = "Long Braid"
	icon_state = "hbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/braid
	name = "Floorlength Braid"
	icon_state = "braid"
	gender = FEMALE

/datum/sprite_accessory/hair/odango
	name = "Odango"
	icon_state = "odango"
	gender = FEMALE

/datum/sprite_accessory/hair/ombre
	name = "Ombre"
	icon_state = "ombre"
	gender = FEMALE

/datum/sprite_accessory/hair/updo
	name = "Updo"
	icon_state = "updo"
	gender = FEMALE

/datum/sprite_accessory/hair/skinhead
	name = "Skinhead"
	icon_state = "skinhead"
	flags = VERY_SHORT

/datum/sprite_accessory/hair/balding
	name = "Balding Hair"
	icon_state = "balding"
	gender = MALE // turnoff!
	flags = VERY_SHORT

/datum/sprite_accessory/hair/familyman
	name = "The Family Man"
	icon_state = "thefamilyman"
	gender = MALE

/datum/sprite_accessory/hair/mahdrills
	name = "Drillruru"
	icon_state = "drillruru"
	gender = FEMALE

/datum/sprite_accessory/hair/drillruru_stylish
	name = "Drillruru Stylish"
	icon_state = "drillruru_stylish"
	gender = FEMALE

/datum/sprite_accessory/hair/fringetail
	name = "Fringetail"
	icon_state = "fringetail"
	gender = FEMALE

/datum/sprite_accessory/hair/dandypomp
	name = "Dandy Pompadour"
	icon_state = "dandypompadour"
	gender = MALE

/datum/sprite_accessory/hair/poofy
	name = "Poofy"
	icon_state = "poofy"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/crono
	name = "Chrono"
	icon_state = "toriyama"
	gender = MALE

/datum/sprite_accessory/hair/vegeta
	name = "Vegeta"
	icon_state = "toriyama2"
	gender = MALE

/datum/sprite_accessory/hair/cia
	name = "CIA"
	icon_state = "cia"
	gender = MALE

/datum/sprite_accessory/hair/mulder
	name = "Mulder"
	icon_state = "mulder"
	gender = MALE

/datum/sprite_accessory/hair/scully
	name = "Scully"
	icon_state = "scully"
	gender = FEMALE

/datum/sprite_accessory/hair/nitori
	name = "Nitori"
	icon_state = "nitori"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/joestar
	name = "Joestar"
	icon_state = "joestar"
	gender = MALE

/datum/sprite_accessory/hair/volaju
	name = "Volaju"
	icon_state = "volaju"

/datum/sprite_accessory/hair/volaju_stylish
	name = "Volaju Stylish"
	icon_state = "volaju_stylish"

/datum/sprite_accessory/hair/shortbangs
	name = "Short Bangs"
	icon_state = "shortbangs"

/datum/sprite_accessory/hair/shavedbun
	name = "Shaved Bun"
	icon_state = "shavedbun"

/datum/sprite_accessory/hair/halfshaved
	name = "Half-Shaved"
	icon_state = "halfshaved"

/datum/sprite_accessory/hair/halfshavedemo
	name = "Half-Shaved Emo"
	icon_state = "halfshavedemo"

/datum/sprite_accessory/hair/longsideemo
	name = "Long Side Emo"
	icon_state = "longsideemo"

/datum/sprite_accessory/hair/doublebun
	name = "Double-Bun"
	icon_state = "doublebun"

/datum/sprite_accessory/hair/doublebun2
	name = "Double-Bun 2"
	icon_state = "doublebun2"
	has_secondary = TRUE

/datum/sprite_accessory/hair/lowfade
	name = "Fade (Low)"
	icon_state = "lowfade"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/medfade
	name = "Fade (Medium)"
	icon_state = "medfade"

/datum/sprite_accessory/hair/highfade
	name = "Fade (High)"
	icon_state = "highfade"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/baldfade
	name = "Fade (Balding)"
	icon_state = "baldfade"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/nofade
	name = "Regulation Cut"
	icon_state = "nofade"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/trimflat
	name = "Trimmed Flat Top"
	icon_state = "trimflat"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/shaved
	name = "Shaved"
	icon_state = "shaved"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/trimmed
	name = "Trimmed"
	icon_state = "trimmed"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/tightbun
	name = "Tight Bun"
	icon_state = "tightbun"
	gender = FEMALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/coffeehouse
	name = "Coffee House Cut"
	icon_state = "coffeehouse"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/partfade
	name = "Parted Fade"
	icon_state = "shavedpart"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/hightight
	name = "High and Tight"
	icon_state = "hightight"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/rowbun
	name = "Row Bun"
	icon_state = "rowbun"
	gender = FEMALE

/datum/sprite_accessory/hair/rowdualbraid
	name = "Row Dual Braid"
	icon_state = "rowdualtail"
	gender = FEMALE

/datum/sprite_accessory/hair/rowbraid
	name = "Row Braid"
	icon_state = "rowbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/regulationmohawk
	name = "Regulation Mohawk"
	icon_state = "shavedmohawk"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/topknot
	name = "Topknot"
	icon_state = "topknot"
	gender = MALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/ronin
	name = "Ronin"
	icon_state = "ronin"
	gender = MALE

/datum/sprite_accessory/hair/bowlcut2
	name = "Bowl 2"
	icon_state = "bowlcut2"
	gender = MALE

/datum/sprite_accessory/hair/thinning
	name = "Thinning"
	icon_state = "thinning"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/thinningfront
	name = "Thinning Front"
	icon_state = "thinningfront"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/thinningback
	name = "Thinning Back"
	icon_state = "thinningback"
	gender = MALE
	flags = VERY_SHORT

/datum/sprite_accessory/hair/manbun
	name = "Manbun"
	icon_state = "manbun"
	gender = MALE

/datum/sprite_accessory/hair/leftsidecut
	name = "Sidecut (Left)"
	icon_state = "sideleft"

/datum/sprite_accessory/hair/rightsidecut
	name = "Sidecut (Right)"
	icon_state = "sideright"

/datum/sprite_accessory/hair/slick
	name = "Slick"
	icon_state = "slick"

/datum/sprite_accessory/hair/messyhair
	name = "Messy"
	icon_state = "messy"
	species_allowed = list(SPECIES_HUMAN)

/datum/sprite_accessory/hair/messyhair2
	name = "Messy 2"
	icon_state = "messy2"

/datum/sprite_accessory/hair/messy_bun
	name = "Messy Bun"
	icon_state = "messybun"
	gender = FEMALE

/datum/sprite_accessory/hair/smessy
	name = "Messy Long"
	icon_state = "smessy"

/datum/sprite_accessory/hair/averagejoe
	name = "Average Joe"
	icon_state = "averagejoe"

/datum/sprite_accessory/hair/sideswept
	name = "Sideswept"
	icon_state = "sideswept"

/datum/sprite_accessory/hair/mohawkshaved
	name = "Mohawk (Shaved)"
	icon_state = "mohawkshaved"

/datum/sprite_accessory/hair/mohawkshaved2
	name = "Mohawk (Tight Shaved)"
	icon_state = "mohawkshaved2"

/datum/sprite_accessory/hair/mohawkshavednaomi
	name = "Mohawk (Naomi)"
	icon_state = "mohawkshavednaomi"

/datum/sprite_accessory/hair/amazon
	name = "Amazon"
	icon_state = "amazon"

/datum/sprite_accessory/hair/straightlong
	name = "Straight Long"
	icon_state = "straightlong"

/datum/sprite_accessory/hair/antenna
	name = "Antenna Hair"
	icon_state = "antenna"
	gender = FEMALE

/datum/sprite_accessory/hair/birdnest
	name = "Birdnest"
	icon_state = "birdnest"

/datum/sprite_accessory/hair/birdnest2
	name = "Birdnest 2"
	icon_state = "birdnest2"

/datum/sprite_accessory/hair/blackswordsman
	name = "Mercenary"
	icon_state = "blackswordsman"

/datum/sprite_accessory/hair/business
	name = "Business Hair"
	icon_state = "business"

/datum/sprite_accessory/hair/business2
	name = "Business Hair 2"
	icon_state = "business2"

/datum/sprite_accessory/hair/business3
	name = "Business Hair 3"
	icon_state = "business3"

/datum/sprite_accessory/hair/business4
	name = "Business Hair 4"
	icon_state = "business4"

/datum/sprite_accessory/hair/bun
	name = "Bun"
	icon_state = "bun"

/datum/sprite_accessory/hair/bun2
	name = "Bun 2"
	icon_state = "bun2"

/datum/sprite_accessory/hair/bun3
	name = "Bun 3"
	icon_state = "bun3"

/datum/sprite_accessory/hair/chop
	name = "Chop"
	icon_state = "chop"

/datum/sprite_accessory/hair/cossack
	name = "Cossack"
	icon_state = "cossack"
	gender = MALE

/datum/sprite_accessory/hair/cossack2
	name = "Cossack2"
	icon_state = "cossack2"
	gender = MALE

/datum/sprite_accessory/hair/eighties
	name = "80's"
	icon_state = "80s"

/datum/sprite_accessory/hair/fag
	name = "Flow Hair"
	icon_state = "flow"

/datum/sprite_accessory/hair/femcut
	name = "Cut Hair Alt"
	icon_state = "femc"

/datum/sprite_accessory/hair/fringeemo
	name = "Emo Fringe"
	icon_state = "emofringe"

/datum/sprite_accessory/hair/hamasaki
	name = "Hamasaki Hair"
	icon_state = "hamasaki"

/datum/sprite_accessory/hair/hbangs
	name = "Combed Hair"
	icon_state = "hbangs"

/datum/sprite_accessory/hair/hbangsalt
	name = "Combed Hair Alt"
	icon_state = "hbangs_alt"

/datum/sprite_accessory/hair/highpony
	name = "High Ponytail"
	icon_state = "highponytail"
	gender = FEMALE

/datum/sprite_accessory/hair/kusangi
	name = "Kusanagi Hair"
	icon_state = "kusanagi"

/datum/sprite_accessory/hair/ladylike_stylish
	name = "Ladylike Stylish"
	icon_state = "ladylike_stylish"
	gender = FEMALE

/datum/sprite_accessory/hair/ladylike
	name = "Ladylike"
	icon_state = "ladylike"
	gender = FEMALE

/datum/sprite_accessory/hair/ladylike_alt_stylish
	name = "Ladylike Alt Stylish"
	icon_state = "ladylike_alt_stylish"
	gender = FEMALE

/datum/sprite_accessory/hair/ladylike_alt
	name = "Ladylike Alt"
	icon_state = "ladylike_alt"
	gender = FEMALE

/datum/sprite_accessory/hair/ming_dynasty_swtgr
	name = "Ming Dynasty"
	icon_state = "ming_dynasty"

/datum/sprite_accessory/hair/mbraid
	name = "Medium Braid"
	icon_state = "mediumbraid"
	gender = FEMALE

/datum/sprite_accessory/hair/modern
	name = "Modern"
	icon_state = "modern"

/datum/sprite_accessory/hair/monk_tonsure_by_swtgr
	name = "Monk Tonsure"
	icon_state = "monk_tonsure"

/datum/sprite_accessory/hair/nia
	name = "Nia"
	icon_state = "nia"

/datum/sprite_accessory/hair/bluntbangs
	name = "Blunt Bangs"
	icon_state = "bluntbangs"
	gender = FEMALE

/datum/sprite_accessory/hair/blunt_bangs_alt2
	name = "Blunt Bangs 2"
	icon_state = "bluntbangs_alt"
	gender = FEMALE

/datum/sprite_accessory/hair/blunt_bangs_curls
	name = "Blunt Bangs Curls"
	icon_state = "bluntbangs_curls"
	gender = FEMALE

/datum/sprite_accessory/hair/oxton
	name = "Oxton"
	icon_state = "oxton"

/datum/sprite_accessory/hair/pixie
	name = "Pixie"
	icon_state = "pixie"
	gender = FEMALE

/datum/sprite_accessory/hair/qing_dynasty_swtgr
	name = "Qing Dynasty"
	icon_state = "qing_dynasty"
	gender = MALE

/datum/sprite_accessory/hair/ramona
	name = "Ramona"
	icon_state = "ramona"

/datum/sprite_accessory/hair/sidepart
	name = "Sidepart"
	icon_state = "sidepart"

/datum/sprite_accessory/hair/sideponytail2
	name = "One Shoulder"
	icon_state = "oneshoulder"

/datum/sprite_accessory/hair/sideponytail3
	name = "Tress Shoulder"
	icon_state = "tressshoulder"

/datum/sprite_accessory/hair/stylo
	name = "Stylo"
	icon_state = "stylo"

/datum/sprite_accessory/hair/spikyponytail
	name = "Spiky Ponytail"
	icon_state = "spikyponytail"

/datum/sprite_accessory/hair/samurai_swtgr
	name = "Samurai"
	icon_state = "samurai"
	has_secondary = TRUE

/datum/sprite_accessory/hair/unkept
	name = "Unkept"
	icon_state = "unkept"

/datum/sprite_accessory/hair/viking
	name = "Viking"
	icon_state = "viking"
	gender = MALE

/datum/sprite_accessory/hair/viking2
	name = "Viking 2"
	icon_state = "viking2"
	gender = MALE

/datum/sprite_accessory/hair/veryshortovereye
	name = "Overeye Very Short"
	icon_state = "veryshortovereye"

/datum/sprite_accessory/hair/veryshortovereyealternate
	name = "Overeye Very Short 2"
	icon_state = "veryshortovereye2"

/datum/sprite_accessory/hair/zieglertail
	name = "Zieglertail"
	icon_state = "ziegler"
	has_secondary = TRUE

/datum/sprite_accessory/hair/zone
	name = "Zone Braid"
	icon_state = "zone"
	gender = FEMALE

/datum/sprite_accessory/hair/square
	name = "Square"
	icon_state = "square"
	gender = FEMALE

/datum/sprite_accessory/hair/mist
	name = "Mist"
	icon_state = "mist"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/maid_b
	name = "Maid tail"
	icon_state = "maid_b"
	gender = FEMALE

/datum/sprite_accessory/hair/long_sideparts
	name = "Long Sideparts"
	icon_state = "long_sideparts"
	gender = FEMALE

/datum/sprite_accessory/hair/long_straight_ponytail
	name = "Long Straight Ponytail"
	icon_state = "long_straight_ponytail"
	gender = FEMALE

/datum/sprite_accessory/hair/long_braid
	name = "Long Braid Stylish"
	icon_state = "long_braid"
	gender = FEMALE

/datum/sprite_accessory/hair/long_curls
	name = "Long Curls"
	icon_state = "long_curls"
	gender = FEMALE

/datum/sprite_accessory/hair/long_bedhead_alt
	name = "Long Bedhead Alt"
	icon_state = "long_bedhead_alt"
	gender = FEMALE

/datum/sprite_accessory/hair/new_era
	name = "New Era"
	icon_state = "new_era"
	gender = FEMALE

/datum/sprite_accessory/hair/cotton_hair
	name = "Cotton"
	icon_state = "cotton"
	gender = FEMALE

/datum/sprite_accessory/hair/braided_hair
	name = "Braided"
	icon_state = "braided"
	gender = FEMALE

/datum/sprite_accessory/hair/blades_hair
	name = "Blades Hair"
	icon_state = "blades"
	gender = FEMALE

/datum/sprite_accessory/hair/alien_h
	name = "Alien"
	icon_state = "alien"
	gender = FEMALE

/datum/sprite_accessory/hair/african_pigtails
	name = "African Pigtails"
	icon_state = "african_pigtails"
	gender = FEMALE
	has_secondary = TRUE

/datum/sprite_accessory/hair/missingno
	name = "MissingNo"
	icon_state = "" // that's the deal

/*I'm sorry I made this hairstyle,
May God have mercy.
*/

/datum/sprite_accessory/hair/marysue
	name = "Mary Sue"
	icon_state = "marysue"

/datum/sprite_accessory/hair/leon
	name = "Leon"
	icon_state = "leon"

/datum/sprite_accessory/hair/wong
	name = "Wong"
	icon_state = "wong"

/datum/sprite_accessory/hair/dreadtail1
	name = "Dreadtail"
	icon_state = "dreadtail"

/datum/sprite_accessory/hair/dreadtail2
	name = "Dreadtail 2"
	icon_state = "dreadtail2"

/datum/sprite_accessory/hair/backswept
	name = "Backswept"
	icon_state = "backswept"

/datum/sprite_accessory/hair/wolfmane
	name = "Wolven mane"
	icon_state = "wolfmane"

/datum/sprite_accessory/hair/sickboy
    name = "Sick"
    icon_state = "sickboy"

/datum/sprite_accessory/hair/bowie
    name = "From Mars"
    icon_state = "bowie"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Facial Hair Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

/datum/sprite_accessory/facial_hair
	gender = MALE // barf (unless you're a dorf, dorfs dig chix /w beards :P)

/datum/sprite_accessory/facial_hair/shaved
	name = "Shaved"
	icon_state = "shaved"
	gender = NEUTER
	species_allowed = list(SPECIES_HUMAN, SPECIES_UNATHI, SPECIES_TAJARA, SPECIES_SKRELL, SPECIES_VOX, SPECIES_SWINE)

/datum/sprite_accessory/facial_hair/watson
	name = "Watson Mustache"
	icon_state = "watson"

/datum/sprite_accessory/facial_hair/hogan
	name = "Hulk Hogan Mustache"
	icon_state = "hogan" //-Neek

/datum/sprite_accessory/facial_hair/vandyke
	name = "Van Dyke Mustache"
	icon_state = "vandyke"

/datum/sprite_accessory/facial_hair/chaplin
	name = "Square Mustache"
	icon_state = "chaplin"

/datum/sprite_accessory/facial_hair/selleck
	name = "Selleck Mustache"
	icon_state = "selleck"

/datum/sprite_accessory/facial_hair/neckbeard
	name = "Neckbeard"
	icon_state = "neckbeard"

/datum/sprite_accessory/facial_hair/fullbeard
	name = "Full Beard"
	icon_state = "fullbeard"

/datum/sprite_accessory/facial_hair/longbeard
	name = "Long Beard"
	icon_state = "longbeard"

/datum/sprite_accessory/facial_hair/vlongbeard
	name = "Very Long Beard"
	icon_state = "wise"

/datum/sprite_accessory/facial_hair/elvis
	name = "Elvis Sideburns"
	icon_state = "elvis"

/datum/sprite_accessory/facial_hair/abe
	name = "Abraham Lincoln Beard"
	icon_state = "abe"

/datum/sprite_accessory/facial_hair/chinstrap
	name = "Chinstrap"
	icon_state = "chin"

/datum/sprite_accessory/facial_hair/hip
	name = "Hipster Beard"
	icon_state = "hip"

/datum/sprite_accessory/facial_hair/gt
	name = "Goatee"
	icon_state = "goatee"

/datum/sprite_accessory/facial_hair/jensen
	name = "Adam Jensen Beard"
	icon_state = "jensen"

/datum/sprite_accessory/facial_hair/volaju
	name = "Volaju"
	icon_state = "volaju"

/datum/sprite_accessory/facial_hair/dwarf
	name = "Dwarf Beard"
	icon_state = "dwarf"

/datum/sprite_accessory/facial_hair/threeOclock
	name = "3 O'clock Shadow"
	icon_state = "3oclock"

/datum/sprite_accessory/facial_hair/threeOclockstache
	name = "3 O'clock Shadow and Moustache"
	icon_state = "3oclockm"

/datum/sprite_accessory/facial_hair/fiveOclock
	name = "5 O'clock Shadow"
	icon_state = "5oclock"

/datum/sprite_accessory/facial_hair/fiveOclockstache
	name = "5 O'clock Shadow and Moustache"
	icon_state = "5oclockm"

/datum/sprite_accessory/facial_hair/sevenOclock
	name = "7 O'clock Shadow"
	icon_state = "7oclock"

/datum/sprite_accessory/facial_hair/sevenOclockstache
	name = "7 O'clock Shadow and Moustache"
	icon_state = "7oclockm"

/datum/sprite_accessory/facial_hair/mutton
	name = "Mutton Chops"
	icon_state = "mutton"

/datum/sprite_accessory/facial_hair/muttonstache
	name = "Mutton Chops and Moustache"
	icon_state = "muttonmus"

/datum/sprite_accessory/facial_hair/walrus
	name = "Walrus Moustache"
	icon_state = "walrus"

/datum/sprite_accessory/facial_hair/croppedbeard
	name = "Full Cropped Beard"
	icon_state = "croppedfullbeard"

/datum/sprite_accessory/facial_hair/chinless
	name = "Chinless Beard"
	icon_state = "chinlessbeard"

/datum/sprite_accessory/facial_hair/braided
	name = "Braided Beard"
	icon_state = "biker"

/datum/sprite_accessory/facial_hair/seadog
	name = "Sea Dog"
	icon_state = "seadog"

/datum/sprite_accessory/facial_hair/lumberjack
	name = "Lumberjack"
	icon_state = "lumberjack"

/datum/sprite_accessory/facial_hair/great
	name = "Great Beard"
	icon_state = "great"

/datum/sprite_accessory/facial_hair/classy
	name = "Classy Beard"
	icon_state = "classy"

/datum/sprite_accessory/facial_hair/viking
	name = "Viking Beard"
	icon_state = "viking"

/datum/sprite_accessory/facial_hair/tsar
	name = "Tsar Beard"
	icon_state = "tsar"

/datum/sprite_accessory/facial_hair/jarl
	name = "Jarl Beard"
	icon_state = "jarl"

/*
///////////////////////////////////
/  =---------------------------=  /
/  == Alien Style Definitions ==  /
/  =---------------------------=  /
///////////////////////////////////
*/

// Unathi Hairstyles
/datum/sprite_accessory/hair/una_spines_long
	name = "Long Unathi Spines"
	icon_state = "longspines"
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/una_spines_short
	name = "Short Unathi Spines"
	icon_state = "shortspines"
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/una_frills_long
	name = "Long Unathi Frills"
	icon_state = "longfrills"
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/una_frills_short
	name = "Short Unathi Frills"
	icon_state = "shortfrills"
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/una_horns
	name = "Horns"
	icon_state = "horns"
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/una
	name = "Great Horns"
	icon_state = "great"
	blend = ICON_MULTIPLY
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/bobcut
	name = "Alternative Bobcut"
	icon_state = "bobcut"
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/hair/una/swept_horn
	name = "Swept Horns"
	icon_state = "swept"

/datum/sprite_accessory/hair/una/ram_horn
	name = "Ram Horns"
	icon_state = "ram"

/datum/sprite_accessory/hair/una/fin_hawk
	name = "Fin Hawk"
	icon_state = "fin"

// Skrell Hairstyles
/datum/sprite_accessory/hair/skr_hair_m
	name = "Short Headtails"
	icon_state = "skrell_hair_m"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skr_hair_f
	name = "Headtails"
	icon_state = "skrell_hair_f"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/veryshort_s
	name = "Very Short Headtails"
	icon_state = "veryshort_s"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/verylong_s
	name = "Long Headtails"
	icon_state = "verylong_s"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_hoop
	name = "Hoop Ponytail"
	icon_state = "skrell_hoop"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_backwater
	name = "Backwater Ponytail"
	icon_state = "skrell_backwater"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_reef
	name = "Reef Ponytail"
	icon_state = "skrell_reef"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_tucked
	name = "Short Tucked Headtails"
	icon_state = "skrell_tucked"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_straight_tuux
	name = "Straight Tuux Headtails"
	icon_state = "skrell_straight_tuux"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_straight_tuux_long
	name = "Long Straight Tuux Headtails"
	icon_state = "skrell_straight_tuux_long"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_long_tuux
	name = "Wavy Tuux Headtails"
	icon_state = "skrell_long_tuux"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_short_tuux
	name = "Short Tuux Headtails"
	icon_state = "skrell_short_tuux"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_slicked
	name = "Short Slicked Headtails"
	icon_state = "skrell_slicked"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_left_emo_long
	name = "Long Overeye Headtails (left)"
	icon_state = "skrell_left_emo_long"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_right_emo_long
	name = "Long Overeye Headtails (right)"
	icon_state = "skrell_right_emo_long"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_left_emo
	name = "Short Overeye Headtails (left)"
	icon_state = "skrell_left_emo"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_right_emo
	name = "Short Overeye Headtails (right)"
	icon_state = "skrell_right_emo"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_left_behind
	name = "Headtail Behind (left)"
	icon_state = "skrell_left_behind"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_right_behind
	name = "Headtail Behind (right)"
	icon_state = "skrell_right_behind"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_right_behind_long
	name = "Long Headtail Behind (right)"
	icon_state = "skrell_right_behind_long"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_left_behind_long
	name = "Long Headtail Behind (left)"
	icon_state = "skrell_left_behind_long"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind
	name = "Headtails Behind (both)"
	icon_state = "skrell_both_behind"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind_short
	name = "Short Headtails Behind (both)"
	icon_state = "skrell_both_behind_short"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind_long
	name = "Long Headtails Behind (both)"
	icon_state = "skrell_both_behind_long"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_reef_short
	name = "Short Reef Ponytail"
	icon_state = "skrell_reef_short"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_short_mid_bun
	name = "Skrell Short Bun"
	icon_state = "skrell_short_mid_bun"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_mid_bun
	name = "Skrell Bun"
	icon_state = "skrell_mid_bun"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_long_mid_bun
	name = "Skrell Long Bun"
	icon_state = "skrell_long_mid_bun"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_mullet
	name = "Skrell Mullet"
	icon_state = "skrell_mullet"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_low_bun
	name = "Skrell Low Bun"
	icon_state = "skrell_low_bun"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_loose_braid
	name = "Braided Headtails"
	icon_state = "skrell_loose_braid"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/verylong_s_dmg_r
	name = "Damaged Long Headtails (right)"
	icon_state = "verylong_s_dmg_r"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/verylong_s_dmg_l
	name = "Damaged Long Headtails (left)"
	icon_state = "verylong_s_dmg_l"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_hair_f_dmg_r
	name = "Damaged Headtails (right)"
	icon_state = "skrell_hair_f_dmg_r"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_hair_f_dmg_l
	name = "Damaged Headtails (left)"
	icon_state = "skrell_hair_f_dmg_l"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind_dmg_r
	name = "Damaged Headtails Behind (right)"
	icon_state = "skrell_both_behind_dmg_r"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind_dmg_l
	name = "Damaged Headtails Behind (left)"
	icon_state = "skrell_both_behind_dmg_l"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind_long_dmg_l
	name = "Long Damaged Headtails Behind (left)"
	icon_state = "skrell_both_behind_long_dmg_l"
	species_allowed = list(SPECIES_SKRELL)

/datum/sprite_accessory/hair/skrell_both_behind_long_dmg_r
	name = "Long Damaged Headtails Behind (right)"
	icon_state = "skrell_both_behind_long_dmg_r"
	species_allowed = list(SPECIES_SKRELL)

// Tajaran Hairstyles
/datum/sprite_accessory/hair/taj_ears
	name = "Ears"
	icon_state = "bald"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_small
	name = "Small Ears"
	icon_state = "small"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_clean
	name = "Clean"
	icon_state = "clean"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_bangs
	name = "Bangs"
	icon_state = "bangs"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_braid
	name = "Braid"
	icon_state = "braid"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_shaggy
	name = "Shaggy"
	icon_state = "shaggy"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_plait
	name = "Plait"
	icon_state = "plait"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_straight
	name = "Straight"
	icon_state = "straight"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_long
	name = "Long"
	icon_state = "long"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_ears_rattail
	name = "Rat Tail"
	icon_state = "rattail"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_fingerwave
	name = "Fingerwave"
	icon_state = "fingerwave"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_victory
	name = "Victory"
	icon_state = "victory"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_wife
	name = "Wifey"
	icon_state = "wife"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_curly
	name = "Curly"
	icon_state = "curly"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_bob
	name = "Tajaran Bob"
	icon_state = "bob"
	gender = FEMALE
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_spiky
	name = "Tajaran Spiky"
	icon_state = "spiky"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_messy
	name = "Tajaran Messy"
	icon_state = "messy"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

/datum/sprite_accessory/hair/taj_mohawk
	name = "Tajaran Mohawk"
	icon_state = "mohawk"
	species_allowed = list(SPECIES_TAJARA)
	has_secondary = TRUE

// Vox Hairstyles
/datum/sprite_accessory/hair/vox_quills_long
	name = "Long Vox Quills"
	icon_state = "longquills"
	species_allowed = list(SPECIES_VOX)

//facial hair

/datum/sprite_accessory/facial_hair/taj_sideburns
	name = "Tajara Sideburns"
	icon_state = "sideburns"
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/facial_hair/taj_mutton
	name = "Tajara Mutton"
	icon_state = "mutton"
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/facial_hair/taj_pencilstache
	name = "Tajara Pencilstache"
	icon_state = "pencilstache"
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/facial_hair/taj_moustache
	name = "Tajara Moustache"
	icon_state = "moustache"
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/facial_hair/taj_goatee
	name = "Tajara Goatee"
	icon_state = "goatee"
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/facial_hair/taj_smallstache
	name = "Tajara Smallsatche"
	icon_state = "smallstache"
	species_allowed = list(SPECIES_TAJARA)

// Swines

/datum/sprite_accessory/hair/swine_floppy
	name = "Floppy Ears"
	icon_state = "floppy"
	species_allowed = list(SPECIES_SWINE)
	flags = VERY_SHORT
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_pointy
	name = "Pointy Ears"
	icon_state = "floppy"
	species_allowed = list(SPECIES_SWINE)
	flags = VERY_SHORT
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_mohawk
	name = "Trottine Mohawk"
	icon_state = "mohawk"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_mohawk_floppy
	name = "Trottine Mohawk (Floppy)"
	icon_state = "mohawk_floppy"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_mohawk_pointy
	name = "Trottine Mohawk (Pointy)"
	icon_state = "mohawk"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_mane
	name = "Trottine Mane"
	icon_state = "mane"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_mane_floppy
	name = "Trottine Mane (Floppy)"
	icon_state = "mane_floppy"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_mane_pointy
	name = "Trottine Mane (Pointy)"
	icon_state = "mane_pointy"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_chancellor
	name = "Trottine Chancellor"
	icon_state = "chancellor"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_chancellor_floppy
	name = "Trottine Chancellor (Floppy)"
	icon_state = "chancellor_floppy"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE

/datum/sprite_accessory/hair/swine_chancellor_pointy
	name = "Trottine Chancellor (Pointy)"
	icon_state = "chancellor_pointy"
	species_allowed = list(SPECIES_SWINE)
	has_secondary = TRUE


/datum/sprite_accessory/facial_hair/swine_tusks
	name = "Tusks"
	icon_state = "tusks"
	species_allowed = list(SPECIES_SWINE)

/datum/sprite_accessory/facial_hair/swine_goatee
	name = "Tusks & Goatee"
	icon_state = "goatee"
	species_allowed = list(SPECIES_SWINE)

/datum/sprite_accessory/facial_hair/swine_sideburns
	name = "Tusks & Sideburns"
	icon_state = "sideburns"
	species_allowed = list(SPECIES_SWINE)

/datum/sprite_accessory/facial_hair/swine_stache
	name = "Stache"
	icon_state = "stache"
	species_allowed = list(SPECIES_SWINE)

/datum/sprite_accessory/facial_hair/swine_moustache
	name = "Moustache"
	icon_state = "moustache"
	species_allowed = list(SPECIES_SWINE)

/datum/sprite_accessory/facial_hair/swine_longbeard
	name = "Tusks & Beard"
	icon_state = "longbeard"
	species_allowed = list(SPECIES_SWINE)

//skin styles - WIP
//going to have to re-integrate this with surgery
//let the icon_state hold an icon preview for now
/datum/sprite_accessory/skin
	icon = 'icons/mob/human_races/r_human.dmi'

/datum/sprite_accessory/skin/human
	name = "Default human skin"
	icon_state = "default"
	species_allowed = list(SPECIES_HUMAN)

/datum/sprite_accessory/skin/human_tatt01
	name = "Tatt01 human skin"
	icon_state = "tatt1"
	species_allowed = list(SPECIES_HUMAN)

/datum/sprite_accessory/skin/tajaran
	name = "Default tajaran skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_tajaran.dmi'
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/skin/unathi
	name = "Default Unathi skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_lizard.dmi'
	species_allowed = list(SPECIES_UNATHI)

/datum/sprite_accessory/skin/skrell
	name = "Default skrell skin"
	icon_state = "default"
	icon = 'icons/mob/human_races/r_skrell.dmi'
	species_allowed = list(SPECIES_SKRELL)

/*
////////////////////////////
/  =--------------------=  /
/  ==  Body Markings   ==  /
/  =--------------------=  /
////////////////////////////
*/
/datum/sprite_accessory/marking
	icon = 'icons/mob/human_races/markings.dmi'
	do_coloration = 1 //Almost all of them have it, COLOR_ADD

	var/layer_blend = ICON_OVERLAY

	//Empty list is unrestricted. Should only restrict the ones that make NO SENSE on other species,
	//like Tajara inner-ear coloring overlay stuff.
	species_allowed = list()

	var/body_parts = list() //A list of bodyparts this covers, in organ_tag defines
	//Reminder: BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_CHEST,BP_GROIN,BP_HEAD

	var/draw_target = MARKING_TARGET_SKIN
	var/draw_order = 100 //A number used to sort markings before they are added to a sprite. Lower is earlier.

	var/list/disallows = list() //A list of other marking types to ban from adding when this marking is already added

/datum/sprite_accessory/marking/tat_heart
	name = "Tattoo (Heart, Torso)"
	icon_state = "tat_heart"
	body_parts = list(BP_CHEST)
	species_allowed = list(SPECIES_HUMAN, SPECIES_SWINE)

/datum/sprite_accessory/marking/tat_hive
	name = "Tattoo (Hive, Back)"
	icon_state = "tat_hive"
	body_parts = list(BP_CHEST)
	species_allowed = list(SPECIES_HUMAN, SPECIES_SWINE)

/datum/sprite_accessory/marking/tat_nightling
	name = "Tattoo (Nightling, Back)"
	icon_state = "tat_nightling"
	body_parts = list(BP_CHEST)
	species_allowed = list(SPECIES_HUMAN, SPECIES_SWINE)

/datum/sprite_accessory/marking/tat_campbell
	name = "Tattoo (Campbell, R.Arm)"
	icon_state = "tat_campbell"
	body_parts = list(BP_R_ARM)
	species_allowed = list(SPECIES_HUMAN, SPECIES_SWINE)

/datum/sprite_accessory/marking/tat_campbell/left
	name = "Tattoo (Campbell, L.Arm)"
	body_parts = list(BP_L_ARM)
	species_allowed = list(SPECIES_HUMAN, SPECIES_SWINE)

/datum/sprite_accessory/marking/tat_tiger
	name = "Tattoo (Tiger Stripes, Body)"
	icon_state = "tat_tiger"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_CHEST,BP_GROIN)
	species_allowed = list(SPECIES_HUMAN, SPECIES_SWINE)

/datum/sprite_accessory/marking/taj_paw_socks
	name = "Socks Coloration (Taj)"
	icon_state = "taj_pawsocks"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/paw_socks
	name = "Socks Coloration (Generic)"
	icon_state = "pawsocks"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/belly_hands_feet
	name = "Hands/Feet/Belly Color (Minor)"
	icon_state = "bellyhandsfeetsmall"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_GROIN,BP_CHEST)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/hands_feet_belly_full
	name = "Hands/Feet/Belly Color (Major)"
	icon_state = "bellyhandsfeet"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_GROIN,BP_CHEST)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/hands_feet_belly_full_female
	name = "Hands,Feet,Belly Color (Major, Female)"
	icon_state = "bellyhandsfeet_female"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_GROIN,BP_CHEST)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/patches
	name = "Color Patches"
	icon_state = "patches"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_CHEST,BP_GROIN)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/patchesface
	name = "Color Patches (Face)"
	icon_state = "patchesface"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/bands
	name = "Color Bands"
	icon_state = "bands"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_L_HAND,BP_R_HAND,BP_CHEST,BP_GROIN)

/datum/sprite_accessory/marking/bandsface
	name = "Color Bands (Face)"
	icon_state = "bandsface"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA, SPECIES_UNATHI, SPECIES_SKRELL) //It makes humans look like if their noses were foot-long :(

/datum/sprite_accessory/marking/tiger_stripes
	name = "Tiger Stripes"
	icon_state = "tiger"
	body_parts = list(BP_L_FOOT,BP_R_FOOT,BP_L_LEG,BP_R_LEG,BP_L_ARM,BP_R_ARM,BP_CHEST,BP_GROIN)
	species_allowed = list(SPECIES_TAJARA) //There's a tattoo for non-cats

/datum/sprite_accessory/marking/tigerhead
	name = "Tiger Stripes (Head, Minor)"
	icon_state = "tigerhead"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/tigerface
	name = "Tiger Stripes (Head, Major)"
	icon_state = "tigerface"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA) //There's a tattoo for non-cats

/datum/sprite_accessory/marking/backstripe
	name = "Back Stripe"
	icon_state = "backstripe"
	body_parts = list(BP_CHEST)

//Taj specific stuff
/datum/sprite_accessory/marking/taj_belly
	name = "Belly Fur (Taj)"
	icon_state = "taj_belly"
	body_parts = list(BP_CHEST)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_bellyfull
	name = "Belly Fur Wide (Taj)"
	icon_state = "taj_bellyfull"
	body_parts = list(BP_CHEST)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_earsout
	name = "Outer Ear (Taj)"
	icon_state = "taj_earsout"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_earsin
	name = "Inner Ear (Taj)"
	icon_state = "taj_earsin"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_nose
	name = "Nose Color (Taj)"
	icon_state = "taj_nose"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_crest
	name = "Chest Fur Crest (Taj)"
	icon_state = "taj_crest"
	body_parts = list(BP_CHEST)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_muzzle
	name = "Muzzle Color (Taj)"
	icon_state = "taj_muzzle"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_face
	name = "Cheeks Color (Taj)"
	icon_state = "taj_face"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

/datum/sprite_accessory/marking/taj_all
	name = "All Taj Head (Taj)"
	icon_state = "taj_all"
	body_parts = list(BP_HEAD)
	species_allowed = list(SPECIES_TAJARA)

// Hair Fade
/datum/sprite_accessory/marking/hair_fade
	icon = 'icons/mob/human_races/hair_fade.dmi'
	species_allowed = list(SPECIES_HUMAN)
	body_parts = list(BP_HEAD)
	draw_target = MARKING_TARGET_HAIR
	draw_order = 50 //before ears & horns
	disallows = list(/datum/sprite_accessory/marking/hair_fade)

/datum/sprite_accessory/marking/hair_fade/fade_up_short
	name = "Fade (Up, Short)"
	icon_state = "fade_up_short"
	species_allowed = list(SPECIES_HUMAN, SPECIES_SKRELL)

/datum/sprite_accessory/marking/hair_fade/fade_up_long
	name = "Fade (Up, Long)"
	icon_state = "fade_up_long"
	species_allowed = list(SPECIES_HUMAN, SPECIES_SKRELL)

/datum/sprite_accessory/marking/hair_fade/fade_down_short
	name = "Fade (Down, Short)"
	icon_state = "fade_down_short"

/datum/sprite_accessory/marking/hair_fade/fade_down_long
	name = "Fade (Down, Long)"
	icon_state = "fade_down_long"

/datum/sprite_accessory/marking/hair_fade/fade_high
	name = "Fade (High)"
	icon_state = "fade_high"

/datum/sprite_accessory/marking/hair_fade/fade_wavy
	name = "Fade (Wavy)"
	icon_state = "fade_wavy"

/datum/sprite_accessory/marking/hair_fade/fade_left
	name = "Fade (Left)"
	icon_state = "fade_left"

/datum/sprite_accessory/marking/hair_fade/fade_right
	name = "Fade (Right)"
	icon_state = "fade_right"

/datum/sprite_accessory/marking/hair_fade/split_vert_right
	name = "Split (Right)"
	icon_state = "split_vert_right"

/datum/sprite_accessory/marking/hair_fade/split_vert_left
	name = "Split (Left)"
	icon_state = "split_vert_left"

/datum/sprite_accessory/marking/hair_fade/split_horz_high
	name = "Split (High)"
	icon_state = "split_horz_high"

/datum/sprite_accessory/marking/hair_fade/split_horz_low
	name = "Split (Low)"
	icon_state = "split_horz_low"
