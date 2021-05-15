/obj/item/clothing/under/pj/red
	name = "red pj's"
	desc = "Sleepwear."
	icon_state = "red_pyjamas"
	item_state_slots = list(
		slot_hand_str = "w_suit"
		)

/obj/item/clothing/under/pj/blue
	name = "blue pj's"
	desc = "Sleepwear."
	icon_state = "blue_pyjamas"
	item_state_slots = list(
		slot_hand_str = "w_suit"
		)

/obj/item/clothing/under/gorka
	name = "Gorka"
	desc = "A special suit designed to be cool everytime when you wear it, this one has a strange tag 'Alex Wood', i wonder who is this?"
	icon_state = "gorka"
	item_state_slots = list(
		slot_hand_str = "black"
		)
	armor = list(melee = 15, bullet = 10, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/under/gorka/mob_can_equip(mob/user)
	.=..()
	if(user.gender == FEMALE)
		to_chat(user, "<span class='warning'> You aren't sure you'll fit in this men's cloth..</span>")
		return 0

/obj/item/clothing/under/dress/maid
	name = "maid uniform"
	desc = "Traditional French maid uniform."
	icon_state = "maid"

/obj/item/clothing/under/dress/gothic_d
	name = "Gothic dress"
	desc = "It's a gothic dress. Somehow it reminds you of Queen Victoria."
	icon_state = "gothic_d"
	item_state = "gothic_d"
	worn_state = "gothic_d"

/obj/item/clothing/under/dress/bar_f
	name = "black bartender dress"
	desc = "A black bartender dress with a white blouse."
	icon_state = "bar_f"

/obj/item/clothing/under/rank/rosa
	desc = "A dress commonly worn by the nursing staff in the medical departament"
	name = "rosa dress"
	icon_state = "rosa"
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0, energy = 0, bomb = 0, bio = 10, rad = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/captain_fly
	name = "rogue's uniform"
	desc = "For the man who doesn't care because he's still free."
	icon_state = "captain_fly"
	item_state_slots = list(
		slot_hand_str = "r_suit"
		)

/obj/item/clothing/under/scratch
	name = "white suit"
	desc = "A white suit, suitable for an excellent host."
	icon_state = "scratch"

/obj/item/clothing/under/sl_suit
	desc = "It's a very amish looking suit."
	name = "amish suit"
	icon_state = "sl_suit"

/obj/item/clothing/under/waiter
	name = "waiter's outfit"
	desc = "It's a very smart uniform with a special pocket for tip."
	icon_state = "waiter"

/obj/item/clothing/under/rank/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	item_state_slots = list(
		slot_hand_str = "blue"
		)

/obj/item/clothing/under/sexyclown
	name = "sexy-clown suit"
	desc = "It makes you look HONKable!"
	icon_state = "sexyclown"
	item_state_slots = list(
		slot_hand_str = "clown"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/rank/vice
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	item_state_slots = list(
		slot_hand_str = "grey"
		)

//This set of uniforms looks fairly fancy and is generally used for high-ranking NT personnel from what I've seen, so lets give them appropriate ranks.
/obj/item/clothing/under/rank/centcom
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Captain.\"."
	name = "\improper Officer's Dress Uniform"
	icon_state = "officer"
	item_state_slots = list(
		slot_hand_str = "lawyer_black"
		)
	displays_id = 0

/obj/item/clothing/under/rank/centcom/officer
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Admiral.\"."

/obj/item/clothing/under/rank/centcom/captain
	desc = "Gold trim on space-black cloth, this uniform displays the rank of \"Admiral-Executive.\"."

/obj/item/clothing/under/ert
	name = "ERT tactical uniform"
	desc = "A short-sleeved black uniform, paired with grey digital-camo cargo pants. It looks very tactical."
	icon_state = "ert_uniform"
	item_state_slots = list(
		slot_hand_str = "black"
		)
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0, rad = 0)
	siemens_coefficient = 0.9

/obj/item/clothing/under/space
	name = "\improper NASA jumpsuit"
	desc = "It has a NASA logo on it and is made of space-proofed materials."
	icon_state = "black"
	w_class = ITEM_SIZE_HUGE//bulky item
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.02
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | ARMS //Needs gloves and shoes with cold protection to be fully protected.
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE

/obj/item/clothing/under/acj
	name = "administrative cybernetic jumpsuit"
	icon_state = "syndicate"
	item_state_slots = list(
		slot_hand_str = "black"
		)
	desc = "it's a cybernetically enhanced jumpsuit used for administrative duties."
	gas_transfer_coefficient = 0.01
	permeability_coefficient = 0.01
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 100, bullet = 100, laser = 100,energy = 100, bomb = 100, bio = 100, rad = 100)
	cold_protection = UPPER_TORSO | LOWER_TORSO | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/under/owl
	name = "owl uniform"
	desc = "A jumpsuit with owl wings. Photorealistic owl feathers! Twooooo!"
	icon_state = "owl"

/obj/item/clothing/under/johnny
	name = "johnny~~ jumpsuit"
	desc = "Johnny~~"
	icon_state = "johnny"

/obj/item/clothing/under/color/rainbow
	name = "rainbow"
	icon_state = "rainbow"

// /obj/item/clothing/under/cloud
// 	name = "cloud"
// 	icon_state = "cloud"

/obj/item/clothing/under/psysuit
	name = "dark undersuit"
	desc = "A thick, layered grey undersuit lined with power cables. Feels a little like wearing an electrical storm."
	icon_state = "psysuit"
	item_state_slots = list(
		slot_hand_str = "black"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS

/obj/item/clothing/under/gentlesuit
	name = "gentlemans suit"
	desc = "A silk black shirt with a white tie and a matching gray vest and slacks. Feels proper."
	icon_state = "gentlesuit"
	item_state_slots = list(
		slot_hand_str = "grey"
		)

/obj/item/clothing/under/gimmick/rank/captain/suit
	name = "captain's suit"
	desc = "A green suit and yellow necktie. Exemplifies authority."
	icon_state = "green_suit"
	item_state_slots = list(
		slot_hand_str = "centcom"
		)

/obj/item/clothing/under/gimmick/rank/head_of_personnel/suit
	name = "head of personnel's suit"
	desc = "A teal suit and yellow necktie. An authoritative yet tacky ensemble."
	icon_state = "hop_teal"
	item_state_slots = list(
		slot_hand_str = "green"
		)

/obj/item/clothing/under/suit_jacket
	name = "black suit"
	desc = "A black suit and red tie. Very formal."
	icon_state = "black_suit"
	item_state_slots = list(
		slot_hand_str = "gray"
		)

/obj/item/clothing/under/suit_jacket/really_black
	name = "executive suit"
	desc = "A formal black suit and red tie, intended for the galaxy's finest."
	icon_state = "really_black_suit"
	item_state_slots = list(
		slot_hand_str = "black"
		)

/obj/item/clothing/under/suit_jacket/female
	name = "executive suit"
	desc = "A formal trouser suit for women, intended for the galaxy's finest."
	icon_state = "black_suit_fem"
	item_state_slots = list(
		slot_hand_str = "lawyer_black"
		)

/obj/item/clothing/under/suit_jacket/red
	name = "red suit"
	desc = "A red suit and blue tie. Somewhat formal."
	icon_state = "red_suit"
	item_state_slots = list(
		slot_hand_str = "red"
		)

/obj/item/clothing/under/blackskirt
	name = "black skirt"
	desc = "A black skirt, very fancy!"
	icon_state = "blackskirt"
	item_state_slots = list(
		slot_hand_str = "black"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/schoolgirl
	name = "schoolgirl uniform"
	desc = "It's just like one of my Japanese animes!"
	icon_state = "schoolgirl"
	item_state_slots = list(
		slot_hand_str = "blue"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	item_state_slots = list(
		slot_hand_str = "blue"
		)

/obj/item/clothing/under/pirate
	name = "pirate outfit"
	desc = "Yarr."
	icon_state = "pirate"
	item_state_slots = list(
		slot_hand_str = "sl_suit"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/soviet
	name = "soviet uniform"
	desc = "For the Motherland!"
	icon_state = "soviet"
	item_state_slots = list(
		slot_hand_str = "grey"
		)

/obj/item/clothing/under/redcoat
	name = "redcoat uniform"
	desc = "Looks old."
	icon_state = "redcoat"
	item_state_slots = list(
		slot_hand_str = "red"
		)

/obj/item/clothing/under/phantom
	name = "stylish red vest"
	desc = "Looks stylish."
	icon_state = "phantom"
	item_state = "phantom"
	item_state_slots = list(
		slot_hand_str = "red"
		)

/obj/item/clothing/under/kilt
	name = "kilt"
	desc = "This skirt is not for women. And don't wear anything under it!"
	icon_state = "kilt"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|FEET

/obj/item/clothing/under/sexymime
	name = "sexy mime outfit"
	desc = "The only time when you DON'T enjoy looking at someone's rack."
	icon_state = "sexymime"
	item_state_slots = list(
		slot_hand_str = "mime"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/gladiator
	name = "gladiator uniform"
	desc = "Are you not entertained? Is that not why you are here?"
	icon_state = "gladiator"
	item_state_slots = list(
		slot_hand_str = "lightbrown"
		)
	body_parts_covered = LOWER_TORSO

//dress
/obj/item/clothing/under/dress
	name = "dress"
	desc = "A fancy dress."
	icon_state = "maid"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/dress/dress_fire
	name = "flame dress"
	desc = "A small black dress with blue flames print on it."
	icon_state = "dress_fire"

/obj/item/clothing/under/dress/dress_green
	name = "green dress"
	desc = "A simple, tight fitting green dress."
	icon_state = "dress_green"

/obj/item/clothing/under/dress/dress_orange
	name = "orange dress"
	desc = "A fancy orange gown for those who like to show leg."
	icon_state = "dress_orange"

/obj/item/clothing/under/dress/dress_pink
	name = "pink dress"
	desc = "A simple, tight fitting pink dress."
	icon_state = "dress_pink"

/obj/item/clothing/under/dress/dress_purple
	name = "purple dress"
	desc= "A simple, tight fitting purple dress."
	icon_state = "tian_dress"
	item_state_slots = list(
		slot_hand_str = "dress_white"
		)

/obj/item/clothing/under/dress/dress_yellow
	name = "yellow dress"
	desc = "A flirty, little yellow dress."
	icon_state = "dress_yellow"

/obj/item/clothing/under/dress/dress_saloon
	name = "saloon girl dress"
	desc = "A old western inspired gown for the girl who likes to drink."
	icon_state = "dress_saloon"
	item_state_slots = list(
		slot_hand_str = "dress_white"
		)

/obj/item/clothing/under/dress/dress_cap
	name = "captain's dress uniform"
	desc = "Feminine fashion for the style concious captain."
	icon_state = "dress_cap"
	item_state_slots = list(
		slot_hand_str = "dress_cap"
		)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/dress_cap/captain_dress_alt
	icon_state = "captain_dress_alt"

/obj/item/clothing/under/dress/dress_hop
	name = "head of personnel dress uniform"
	desc = "Feminine fashion for the style concious HoP."
	icon_state = "dress_hop"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/dress_hr
	name = "human resources director uniform"
	desc = "Superior class for the nosy H.R. Director."
	icon_state = "huresource"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS

/obj/item/clothing/under/dress/plaid_blue
	name = "blue plaid skirt"
	desc = "A preppy blue skirt with a white blouse."
	icon_state = "plaid_blue"
	item_state_slots = list(
		slot_hand_str = "dress_white"
		)

/obj/item/clothing/under/dress/plaid_red
	name = "red plaid skirt"
	desc = "A preppy red skirt with a white blouse."
	icon_state = "plaid_red"
	item_state_slots = list(
		slot_hand_str = "dress_white"
		)

/obj/item/clothing/under/dress/plaid_purple
	name = "blue purple skirt"
	desc = "A preppy purple skirt with a white blouse."
	icon_state = "plaid_purple"
	item_state_slots = list(
		slot_hand_str = "dress_white"
		)

/obj/item/clothing/under/dress/black_tango
	name = "tango dress"
	desc = "Por una cabeza..."
	icon_state = "black_tango"

/obj/item/clothing/under/dress/franziska_dress
	name = "prosecutor's formal dress"
	desc = "The most fashionable prosecutor's dress."
	icon_state = "franziska_dress"

//wedding stuff
/obj/item/clothing/under/wedding
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/wedding/bride_orange
	name = "orange wedding dress"
	desc = "A big and puffy orange dress."
	icon_state = "bride_orange"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_purple
	name = "purple wedding dress"
	desc = "A big and puffy purple dress."
	icon_state = "bride_purple"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_blue
	name = "blue wedding dress"
	desc = "A big and puffy blue dress."
	icon_state = "bride_blue"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_red
	name = "red wedding dress"
	desc = "A big and puffy red dress."
	icon_state = "bride_red"
	flags_inv = HIDESHOES

/obj/item/clothing/under/wedding/bride_white
	name = "silky wedding dress"
	desc = "A white wedding gown made from the finest silk."
	icon_state = "bride_white"
	flags_inv = HIDESHOES
	body_parts_covered = UPPER_TORSO|LOWER_TORSO



/obj/item/clothing/under/sundress
	name = "sundress"
	desc = "Makes you want to frolic in a field of daisies."
	icon_state = "sundress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/sundress_white
	name = "white sundress"
	desc = "A white sundress decorated with purple lilies."
	icon_state = "sundress_white"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/blackjumpskirt
	name = "black jumpskirt"
	desc = "A black jumpskirt, with a pink undershirt."
	icon_state = "blackjumpskirt"
	item_state_slots = list(
		slot_hand_str = "black"
		)

/obj/item/clothing/under/shortjumpskirt
	name = "short jumpskirt"
	desc = "A slimming, short jumpskirt."
	icon_state = "shortjumpskirt"
	item_state_slots = list(
		slot_hand_str = "white"
		)

/obj/item/clothing/under/captainformal
	name = "captain's formal uniform"
	desc = "A captain's formal-wear, for special occasions."
	icon_state = "captain_formal"
	item_state_slots = list(
		slot_hand_str = "captain"
		)

/obj/item/clothing/under/captainformal/captain_formal_alt
	icon_state = "captain_formal_alt"
	item_state_slots = list(
		slot_hand_str = "captain_formal_alt"
		)

/obj/item/clothing/under/hosformalmale
	name = "head of security's male formal uniform"
	desc = "A male head of security's formal-wear, for special occasions."
	icon_state = "hos_formal_male"
	item_state_slots = list(
		slot_hand_str = "red"
		)

/obj/item/clothing/under/hosformalfem
	name = "head of security's female formal uniform"
	desc = "A female head of security's formal-wear, for special occasions."
	icon_state = "hos_formal_fem"
	item_state_slots = list(
		slot_hand_str = "red"
		)

/obj/item/clothing/under/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	item_state_slots = list(
		slot_hand_str = "grey"
		)

/obj/item/clothing/under/blazer
	name = "blue blazer"
	desc = "A bold but yet conservative outfit, red corduroys, navy blazer and a tie."
	icon_state = "blue_blazer"
	item_state_slots = list(
		slot_hand_str = "blue"
		)

// /obj/item/clothing/under/rank/psych/turtleneck/sweater
// 	desc = "A warm looking sweater and a pair of dark blue slacks."
// 	name = "sweater"
// 	icon_state = "turtleneck"

/obj/item/clothing/under/hazard
	name = "hazard jumpsuit"
	desc = "A high visibility jumpsuit made from heat and radiation resistant materials."
	icon_state = "engine"
	siemens_coefficient = 0.8
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 20, bio = 0, rad = 20)
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/under/sterile
	name = "sterile jumpsuit"
	desc = "A sterile white jumpsuit with medical markings. Protects against all manner of biohazards."
	icon_state = "medical"
	item_state_slots = list(
		slot_hand_str = "white"
		)
	permeability_coefficient = 0.50
	armor = list(melee = 0, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 30, rad = 0)

/obj/item/clothing/under/suit_jacket/charcoal
	name = "charcoal suit"
	desc = "A charcoal suit. Very professional."
	icon_state = "charcoal_suit"
	item_state = "ba_suit"
	worn_state = "charcoal_suit"

/obj/item/clothing/under/suit_jacket/navy
	name = "navy suit"
	desc = "A navy suit, intended for the galaxy's finest."
	icon_state = "navy_suit"
	item_state = "sl_suit"
	worn_state = "navy_suit"


/obj/item/clothing/under/suit_jacket/burgundy
	name = "burgundy suit"
	desc = "A burgundy suit and black tie. Somewhat formal."
	icon_state = "burgundy_suit"
	item_state = "ba_suit"
	worn_state = "burgundy_suit"

/obj/item/clothing/under/suit_jacket/checkered
	name = "checkered suit"
	desc = "That's a very nice suit you have there. Shame if something were to happen to it, eh?"
	icon_state = "checkered_suit"
	item_state = "ba_suit"
	worn_state = "checkered_suit"


/obj/item/clothing/under/suit_jacket/tan
	name = "tan suit"
	desc = "A tan suit. Smart, but casual."
	icon_state = "tan_suit"
	item_state = "tan_suit"
	worn_state = "tan_suit"

/obj/item/clothing/under/cheongsam
	name = "cheongsam"
	desc = "It is a cheongsam dress."
	icon_state = "mai_yang"
	item_state = "mai_yang"
	worn_state = "mai_yang"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS

/obj/item/clothing/under/abaya
	name = "abaya"
	desc = "A loose-fitting, robe-like dress."
	icon_state = "abaya"
	item_state = "abaya"
	worn_state = "abaya"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/under/harness
	name = "gear harness"
	desc = "How... minimalist."
	icon_state = "gear_harness"
	worn_state = "gear_harness"
	species_restricted = null
	body_parts_covered = 0

// /obj/item/clothing/under/pcrc
// 	name = "\improper PCRC uniform"
// 	desc = "A uniform belonging to Proxima Centauri Risk Control, a private security firm."
// 	icon_state = "pcrc"
// 	item_state = "jensensuit"
// 	worn_state = "pcrc"

/obj/item/clothing/under/grayson
	name = "\improper Grayson overalls"
	desc = "A set of overalls belonging to Grayson Manufactories, a manufacturing and mining company."
	icon_state = "grayson"
	worn_state = "grayson"

// /obj/item/clothing/under/wardt
// 	name = "\improper Ward-Takahashi jumpsuit"
// 	desc = "A jumpsuit belonging to Ward-Takahashi, a megacorp in the consumer goods and research market."
// 	icon_state = "wardt"
// 	worn_state = "wardt"

// /obj/item/clothing/under/mbill
// 	name = "\improper Major Bill's uniform"
// 	desc = "A uniform belonging to Major Bill's Transportation, a major shipping company."
// 	icon_state = "mbill"
// 	worn_state = "mbill"

// //
/obj/item/clothing/under/confederacy
	name = "\improper Confederate uniform"
	desc = "A military uniform belonging to an independent human government."
	icon_state = "confed"

/obj/item/clothing/under/saare
	name = "\improper SAARE uniform"
	desc = "A uniform belonging to Strategic Assault and Asset Retention Enterprises, a minor private military corporation."
	icon_state = "saare"

/obj/item/clothing/under/frontier
	name = "frontier clothes"
	desc = "A rugged flannel shirt and denim overalls. A popular style among frontier colonists."
	icon_state = "frontier"

/obj/item/clothing/under/aether
	name = "\improper Aether jumpsuit"
	desc = "A jumpsuit belonging to Aether Atmospherics and Recycling, a company that supplies recycling and atmospheric systems to colonies."
	icon_state = "aether"

/obj/item/clothing/under/focal
	name = "\improper Focal Point jumpsuit"
	desc = "A jumpsuit belonging to Focal Point Energistics, an engineering corporation."
	icon_state = "focal"

/obj/item/clothing/under/hephaestus
	name = "\improper Hephaestus jumpsuit"
	desc = "A jumpsuit belonging to Hephaestus Industries, a megacorp best known for its arms production."
	icon_state = "heph"

/obj/item/clothing/under/savage_hunter
	name = "savage hunter's hides"
	desc = "Makeshift hides bound together with the sinew, packwax, and leather of some alien creature."
	icon_state = "hunterhide"
	item_state = "hunter"
	body_parts_covered = LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/under/savage_hunter/female
	name = "savage huntress's hides"
	desc = "Makeshift hides bound together with the sinew, packwax, and leather of some alien creature. Includes a chestwrap so as not to leave one topless."
	item_state = "huntress"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS

/obj/item/clothing/under/fig_leaf
	name = "fig leaf"
	desc = "And the eyes of them both were opened, and they knew that they were naked; and they sewed fig leaves together, and made themselves aprons."
	icon_state = "fig_leaf"
	body_parts_covered = LOWER_TORSO
	has_sensor = 0

// /obj/item/clothing/under/wetsuit
// 	name = "tactical wetsuit"
// 	desc = "For when you want to scuba dive your way into an enemy base but still want to show off a little skin."
// 	icon_state = "wetsuit"
// 	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/contortionist
	name = "contortionist's jumpsuit"
	desc = "A light jumpsuit useful for squeezing through narrow vents."
	icon_state = "darkholme"
	item_state = "darkholme"

/obj/item/clothing/under/latex_suit
	name = "Latex suit"
	desc = "A shiny and tight suit for a variety of perversions."
	icon_state = "latex_suit"

/obj/item/clothing/under/contortionist/proc/check_clothing(mob/user as mob)
	//Allowed to wear: glasses, shoes, gloves, pockets, mask, and jumpsuit (obviously)
	var/list/slot_must_be_empty = list(slot_back,slot_handcuffed,slot_legcuffed,slot_belt,slot_head,slot_wear_suit)
	for(var/slot_id in slot_must_be_empty)
		if(user.get_equipped_item(slot_id))
			to_chat(user, "<span class='warning'>You can't fit inside while wearing that \the [user.get_equipped_item(slot_id)].</span>")
			return 0

	if(user.r_hand != null || user.l_hand != null)
		to_chat(user, "<span class='warning'>You can't fit inside while holding items.</span>")
		return 0

	return 1

/obj/item/clothing/under/contortionist/verb/crawl_through_vent()
	set name = "Crawl Through Vent"
	set category = "Object"
	set src in usr

	var/mob/living/carbon/human/user = usr
	if(istype(user) && user.w_uniform == src && check_clothing(user))
		var/pipe = user.start_ventcrawl()
		if(pipe)
			user.handle_ventcrawl(pipe)
