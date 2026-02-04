
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chefhat"
	item_state = "chefhat"
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	coverage = 0.5

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	item_state_slots = list(
		slot_l_hand_str = "caphat",
		slot_r_hand_str = "caphat",
		)
	armor = list(melee = 15, bullet = 10, laser = 10, energy = 5, bomb = 0, bio = 0)
	coverage = 0.5

/obj/item/clothing/head/caphat/alt //Kind of like a legacy version of the hat
	name = "captain's old hat"
	desc = "It's good being old and wise king."
	icon_state = "captain_alt"
	//item_state = "captain_alt"

/obj/item/clothing/head/caphat/cap
	name = "captain's cap"
	desc = "You fear to wear it for the negligence it brings."
	icon_state = "capcap"

/obj/item/clothing/head/caphat/cap/capcap_alt
	icon_state = "capcap_alt"

/obj/item/clothing/head/caphat/formal
	name = "parade hat"
	desc = "No one in a commanding position should be without a perfect, white hat of ultimate authority."
	icon_state = "officercap"

//HOP
/obj/item/clothing/head/caphat/hop
	name = "provisioning inspection hat"
	desc = "A stylish hat that both protects you from enraged crewmembers waiting for their supply orders since the beginning of the shift, and gives you a false sense of authority."
	icon_state = "hopcap"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags_inv = BLOCKHAIR
	body_parts_covered = HEAD
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	coverage = 0.7

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags_inv = BLOCKHAIR
	body_parts_covered = HEAD
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	coverage = 0.8

//Medical
/obj/item/clothing/head/surgery
	name = "surgical cap"
	desc = "A cap surgeons wear during operations. Keeps their hair from tickling your internal organs."
	icon_state = "surgcap"
	flags_inv = BLOCKHEADHAIR
	armor = list(melee = 5, bullet = 5, laser = 5, energy = 0, bomb = 0, bio = 40)
	coverage = 0.4

/obj/item/clothing/head/surgery/purple
	name = "purple surgical cap"
	color = "#7a1b3f"

/obj/item/clothing/head/surgery/blue
	name = "blue surgical cap"
	color = "#4891e1"

/obj/item/clothing/head/surgery/green
	name = "green surgical cap"
	color = "#255a3e"

/obj/item/clothing/head/surgery/black
	name = "black surgical cap"
	color = "#242424"

/obj/item/clothing/head/surgery/navyblue
	name = "navy blue surgical cap"
	color = "#1f3a69"

/obj/item/clothing/head/surgery/lilac
	name = "lilac surgical cap"
	color = "#c8a2c8"

/obj/item/clothing/head/surgery/teal
	name = "teal surgical cap"
	color = "#008080"

/obj/item/clothing/head/surgery/heliodor
	name = "heliodor surgical cap"
	color = "#aad539"

//Berets
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, an artists favorite headwear."
	icon_state = "beret"
	body_parts_covered = NO_BODYPARTS
	armor = list(melee = 5, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)
	coverage = 0.4

/obj/item/clothing/head/beret/sec
	name = "corporate security beret"
	desc = "A beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_red"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/head/beret/sec/navy/officer
	name = "corporate security officer beret"
	desc = "A navy blue beret with an officer's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_navy_officer"

/obj/item/clothing/head/beret/sec/navy/hos
	name = "corporate security commander beret"
	desc = "A navy blue beret with a commander's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_navy_hos"

/obj/item/clothing/head/beret/sec/navy/warden
	name = "corporate security warden beret"
	desc = "A navy blue beret with a warden's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_navy_warden"

/obj/item/clothing/head/beret/sec/corporate/officer
	name = "corporate security officer beret"
	desc = "A corporate black beret with an officer's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_officer"

/obj/item/clothing/head/beret/sec/corporate/hos
	name = "corporate security commander beret"
	desc = "A corporate black beret with a commander's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_hos"

/obj/item/clothing/head/beret/sec/corporate/warden
	name = "corporate security warden beret"
	desc = "A corporate black beret with a warden's rank emblem. For officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_warden"

/obj/item/clothing/head/beret/engineering
	name = "corporate engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "beret_orange"

/obj/item/clothing/head/beret/purple
	name = "purple beret"
	desc = "A stylish, if purple, beret. For personnel that are more inclined towards style than safety."
	icon_state = "beret_purple"

/obj/item/clothing/head/beret/centcom/officer
	name = "ERT beret"
	desc = "A navy blue beret adorned with the crest of NanoTrasen's elite Emergency Response Teams. For ERT officers that are more inclined towards style than safety."
	icon_state = "beret_corporate_navy"

/obj/item/clothing/head/beret/centcom/captain
	name = "ERT commander beret"
	desc = "A white beret adorned with the crest of NanoTrasen's elite Emergency Response Teams. For ERT commanders that are more inclined towards style than safety."
	icon_state = "beret_corporate_white"

/obj/item/clothing/head/beret/deathsquad
	name = "Death Squad beret"
	desc = "An armored red beret adorned with the crest of NanoTrasen's infamous Death Squad. Doesn't sacrifice style or safety."
	icon_state = "beret_corporate_red"
	armor = list(melee = 120, bullet = 150, laser = 150, energy = 65, bomb = 90, bio = 50)
	siemens_coefficient = 0.9
	coverage = 1.0

/obj/item/clothing/head/beret/guard
	name = "corporate security beret"
	desc = "A white beret adorned with the crest of NanoTrasen. For security guards that are more inclined towards style than safety."
	icon_state = "beret_corporate_whitered"
	armor = list(melee = 10, bullet = 5, laser = 5,energy = 0, bomb = 0, bio = 0)

/obj/item/clothing/head/beret/plaincolor
	name = "beret"
	desc = "A simple, solid color beret. This one has no emblems or insignia on it."
	icon_state = "beret_white"

/obj/item/clothing/head/beret/classique
	name = "classic beret"
	desc = "For artists only!"
	icon_state = "beret_classique"

//iogacool 's custom item
/obj/item/clothing/head/beret/sec/tactical
	name = "tactical beret"
	desc = "A green beret with an officer's rank emblem."
	icon_state = "beret_tactical"

//Some retard put these in /under/jobs/security.dm. What a shame.
/obj/item/clothing/head/det
	name = "fedora"
	desc = "A brown fedora - either the cornerstone of a detective's style or a poor attempt at looking cool, depending on the person wearing it."
	icon_state = "detective"
	item_state_slots = list(
		slot_l_hand_str = "det_hat",
		slot_r_hand_str = "det_hat",
		)
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 20, bomb = 25, bio = 0)
	siemens_coefficient = 0.9
	coverage = 0.7

/obj/item/clothing/head/det/attack_self(mob/user)
	flags_inv ^= BLOCKHEADHAIR
	to_chat(user, "<span class='notice'>[src] will now [flags_inv & BLOCKHEADHAIR ? "hide" : "show"] hair.</span>")
	..()

/obj/item/clothing/head/det/grey
	desc = "A grey fedora - either the cornerstone of a detective's style or a poor attempt at looking cool, depending on the person wearing it."
	icon_state = "detective2"
	item_state_slots = list(
		slot_l_hand_str = "det_hat_grey",
		slot_r_hand_str = "det_hat_grey",
		)

/obj/item/clothing/head/HoS
	name = "Head of Security Hat"
	desc = "The hat of the Head of Security, reinforced with a plasteel plate. For showing the officers who's in charge."
	icon_state = "hoscap"
	body_parts_covered = HEAD
	armor = list(melee = 90, bullet = 130, laser = 120, energy = 35, bomb = 55, bio = 20)
	siemens_coefficient = 0.6
	coverage = 1.0 // Magic of coolness

/obj/item/clothing/head/HoS/dermal
	name = "Dermal Armour Patch"
	desc = "You're not quite sure how you manage to take it on and off, but it implants nicely in your head."
	icon_state = "dermal"

/obj/item/clothing/head/warden
	name = "warden's hat"
	desc = "It's a special helmet issued to the Warden of a securiy force."
	icon_state = "policehelm"
	body_parts_covered = NO_BODYPARTS
	coverage = 0.7

/obj/item/clothing/head/warden/drill
	name = "warden's drill hat"
	desc = "You've definitely have seen that hat before."
	icon_state = "wardendrill"
