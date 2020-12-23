// Stuff worn on the ears. Items here go in the "ears" sort_category but they must not use
// the slot_r_ear or slot_l_ear as the slot, or else players will spawn with no headset.
/datum/gear/headphones
	display_name = "headphones"
	path = /obj/item/clothing/ears/earmuffs/headphones
	sort_category = "Earwear"

/datum/gear/earrings
	display_name = "earrings"
	path = /obj/item/clothing/ears/earring
	sort_category = "Earwear"

/datum/gear/earrings/New()
	..()
	var/earrings = list()
	earrings["stud, pearl"]      = /obj/item/clothing/ears/earring/stud
	earrings["stud, glass"]      = /obj/item/clothing/ears/earring/stud/glass
	earrings["stud, wood"]       = /obj/item/clothing/ears/earring/stud/wood
	earrings["stud, iron"]       = /obj/item/clothing/ears/earring/stud/iron
	earrings["stud, steel"]      = /obj/item/clothing/ears/earring/stud/steel
	earrings["stud, silver"]     = /obj/item/clothing/ears/earring/stud/silver
	earrings["stud, gold"]       = /obj/item/clothing/ears/earring/stud/gold
	earrings["stud, platinum"]   = /obj/item/clothing/ears/earring/stud/platinum
	earrings["stud, onyx"]       = /obj/item/clothing/ears/earring/stud/onyx
	earrings["stud, emerald"]    = /obj/item/clothing/ears/earring/stud/emerald
	earrings["stud, amber"]      = /obj/item/clothing/ears/earring/stud/amber
	earrings["stud, amethyst"]   = /obj/item/clothing/ears/earring/stud/amethyst
	earrings["stud, ruby"]       = /obj/item/clothing/ears/earring/stud/ruby
	earrings["stud, sapphire"]   = /obj/item/clothing/ears/earring/stud/sapphire
	earrings["stud, diamond"]    = /obj/item/clothing/ears/earring/stud/diamond
	earrings["dangle, glass"]    = /obj/item/clothing/ears/earring/dangle/glass
	earrings["dangle, wood"]     = /obj/item/clothing/ears/earring/dangle/wood
	earrings["dangle, iron"]     = /obj/item/clothing/ears/earring/dangle/iron
	earrings["dangle, steel"]    = /obj/item/clothing/ears/earring/dangle/steel
	earrings["dangle, silver"]   = /obj/item/clothing/ears/earring/dangle/silver
	earrings["dangle, gold"]     = /obj/item/clothing/ears/earring/dangle/gold
	earrings["dangle, platinum"] = /obj/item/clothing/ears/earring/dangle/platinum
	earrings["dangle, onyx"]     = /obj/item/clothing/ears/earring/dangle/onyx
	earrings["dangle, emerald"]  = /obj/item/clothing/ears/earring/dangle/emerald
	earrings["dangle, amber"]    = /obj/item/clothing/ears/earring/dangle/amber
	earrings["dangle, amethyst"] = /obj/item/clothing/ears/earring/dangle/amethyst
	earrings["dangle, ruby"]     = /obj/item/clothing/ears/earring/dangle/ruby
	earrings["dangle, sapphire"] = /obj/item/clothing/ears/earring/dangle/sapphire
	earrings["dangle, diamond"]  = /obj/item/clothing/ears/earring/dangle/diamond
	earrings["yin yang"]         = /obj/item/clothing/ears/earring/yinyang
	gear_tweaks += new /datum/gear_tweak/path(earrings)

/datum/gear/earring
	display_name = "single earring"
	path = /obj/item/clothing/ears/earring/single
	sort_category = "Earwear"

/datum/gear/earring/New()
	..()
	var/earring = list()
	earring["stud, pearl"]      = /obj/item/clothing/ears/earring/single/stud
	earring["stud, glass"]      = /obj/item/clothing/ears/earring/single/stud/glass
	earring["stud, wood"]       = /obj/item/clothing/ears/earring/single/stud/wood
	earring["stud, iron"]       = /obj/item/clothing/ears/earring/single/stud/iron
	earring["stud, steel"]      = /obj/item/clothing/ears/earring/single/stud/steel
	earring["stud, silver"]     = /obj/item/clothing/ears/earring/single/stud/silver
	earring["stud, gold"]       = /obj/item/clothing/ears/earring/single/stud/gold
	earring["stud, platinum"]   = /obj/item/clothing/ears/earring/single/stud/platinum
	earring["stud, onyx"]       = /obj/item/clothing/ears/earring/single/stud/onyx
	earring["stud, emerald"]    = /obj/item/clothing/ears/earring/single/stud/emerald
	earring["stud, amber"]      = /obj/item/clothing/ears/earring/single/stud/amber
	earring["stud, amethyst"]   = /obj/item/clothing/ears/earring/single/stud/amethyst
	earring["stud, ruby"]       = /obj/item/clothing/ears/earring/single/stud/ruby
	earring["stud, sapphire"]   = /obj/item/clothing/ears/earring/single/stud/sapphire
	earring["stud, diamond"]    = /obj/item/clothing/ears/earring/single/stud/diamond
	earring["dangle, glass"]    = /obj/item/clothing/ears/earring/single/dangle/glass
	earring["dangle, wood"]     = /obj/item/clothing/ears/earring/single/dangle/wood
	earring["dangle, iron"]     = /obj/item/clothing/ears/earring/single/dangle/iron
	earring["dangle, steel"]    = /obj/item/clothing/ears/earring/single/dangle/steel
	earring["dangle, silver"]   = /obj/item/clothing/ears/earring/single/dangle/silver
	earring["dangle, gold"]     = /obj/item/clothing/ears/earring/single/dangle/gold
	earring["dangle, platinum"] = /obj/item/clothing/ears/earring/single/dangle/platinum
	earring["dangle, onyx"]     = /obj/item/clothing/ears/earring/single/dangle/onyx
	earring["dangle, emerald"]  = /obj/item/clothing/ears/earring/single/dangle/emerald
	earring["dangle, amber"]    = /obj/item/clothing/ears/earring/single/dangle/amber
	earring["dangle, amethyst"] = /obj/item/clothing/ears/earring/single/dangle/amethyst
	earring["dangle, ruby"]     = /obj/item/clothing/ears/earring/single/dangle/ruby
	earring["dangle, sapphire"] = /obj/item/clothing/ears/earring/single/dangle/sapphire
	earring["dangle, diamond"]  = /obj/item/clothing/ears/earring/single/dangle/diamond
	gear_tweaks += new /datum/gear_tweak/path(earring)
