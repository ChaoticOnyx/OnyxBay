/obj/structure/onyxawards2018
	name = "statue of Onyx"
	icon_state = "onyx2018"
	icon = 'icons/obj/onyxaward2018.dmi'
	anchored = 1
	density = 1
	opacity = 0
	var/info

/obj/structure/onyxawards2018/attack_hand(mob/user as mob)
	if(user.a_intent == I_HELP)
		visible_message("<span class='notice'>[user] touches [src].</span>")
		to_chat(user, "<span class='notice'>This is [info]</span>")
	else
		return ..()

/obj/structure/onyxawards2018/shadow_lead
	name = "statue of Plin"
	icon_state = "plinlead2018"
	info = "statue of Plin, the shadow lead of Chaotic Onyx and the best developer of 2018.<br>I'm just a vision. </br>"
	desc = "A big... Snail?"

/obj/structure/onyxawards2018/shadow_lead/attack_hand(mob/user as mob)
	if(user.a_intent == I_HELP)
		visible_message("<span class='notice'>[user] touches [src].</span>")
		to_chat(user, "<span class='notice'>This is [info]</span>")
	else
		visible_message("<span class='danger'><b><i>I AM THE KING.</i></b></span>")
		to_chat(user, "<span class='notice'>What the fuck.</span>")
		icon_state = ":king:"
		desc = "A rainbow king!"
		return ..()

/obj/structure/onyxawards2018/buguser
	name = "statue of NanoAnon"
	icon_state = "nanoanon2018"
	info = "statue of Nanoanon, the best Chaotic Onyx buguser of 2018.<br>Enjoy your infinite pressure! </br>"
	desc = "What a nice hairstyle."

/obj/structure/onyxawards2018/disappointment
	name = "statue of IGRALO"
	icon_state = "cheburek2018"
	info = "statue of IGRALO, the biggest Chaotic Onyx disappointment and the worst traitor of 2018.<br>Each voter will recieve one E-ball! </br>"
	desc = "Is it a taco?.."

/obj/structure/onyxawards2018/roll_and_play
	name = "statue of Voldirs"
	icon_state = "voldirs2018"
	info = "statue of Voldirs, the best Chaotic Onyx player and roleplayer of 2018.<br>Did you call me a weak trap? </br>"
	desc = "It seems that even being a statue she is able to break your neck."

/obj/structure/onyxawards2018/developer
	name = "statue of Plin"
	icon_state = "plin2018"
	info = "statue of Plin, the shadow lead of Chaotic Onyx and the best developer of 2018.<br>Remember - no one pushes to release branch except for snail.</br>"
	desc = "A big... Snail?.."

/obj/structure/onyxawards2018/pedal
	name = "statue of LegatePritcher."
	icon_state = "legate2018"
	info = "statue of LegatePritcher, the best Chaotic Onyx admin of 2018.<br>R u my bro, or not my bro, bro?</br>"
	desc = "That guy have an axe. What if I just..."

/obj/structure/onyxawards2018/traitor
	name = "statue of IGRALO"
	icon_state = "cheburektraitor2018"
	info = "statue of IGRALO, the biggest Chaotic Onyx disappointment and the worst traitor of 2018.<br>It was said that you would destroy the debili. Not join them.</br>"
	desc = "Is it a angry taco?.."

/obj/structure/onyxawards2018/robuster
	name = "statue of Sranklin"
	icon_state = "sranklinrobuster2018"
	info = "statue of Sranklin, the best Chaotic Onyx robuster and the fastest ERP-policeman of 2018.<br>I'm not lurching, cyka.</br>"
	desc = "He is some kind of angry guy."

/obj/structure/onyxawards2018/shitcurity
	name = "statue of Schutze88"
	icon_state = "schutze2018"
	info = "statue of Schutze88, the best Chaotic Onyx shitcurity of 2018.<br>ZATIRANENO.</br>"
	desc = "He make wrong choices."

/obj/structure/onyxawards2018/medic
	name = "statue of SolarEclipse84"
	icon_state = "solare2018"
	info = "statue of SolarEclipse84, the best Chaotic Onyx medic of 2018.<br>Get off me, and my medbay.</br>"
	desc = "MUDOEBI MUDOEBI MUDOEBI MUDOEBI MUDOEBI MUDOEBI MUDOEBI MUDOEBI MUDOEBI MUDOEBI"

/obj/structure/onyxawards2018/assistant
	name = "statue of AnotherAssistant"
	icon_state = "walruser2018"
	info = "statue of AnotherAssistant, the best Chaotic Onyx assistant and cooper of 2018.<br>It was better the way it was.</br>"
	desc = "He's totally not a bad guy."

/obj/structure/onyxawards2018/erp_er
	name = "statue of VaxEx"
	icon_state = "vaxex2018"
	info = "statue of VaxEx, the malicious Chaotic Onyx ERP-er of 2018.<br>I am NOT a Trapenberger.</br>"
	desc = "Nice top-hat, really."

/obj/structure/onyxawards2018/erp_police
	name = "statue of Sranklin"
	icon_state = "sranklin2018"
	info = "statue of Sranklin, the best Chaotic Onyx robuster and the fastest ERP-police of 2018.<br>I'm not lurching, cyka.</br>"
	desc = "He is some kind of angry."

/obj/structure/onyxawards2018/player_of_year
	name = "statue of Voldirs"
	icon_state = "voldirsbest2018"
	info = "statue of Voldirs, the best Chaotic Onyx player and roleplayer of 2018.<br>Did you call me a weak trap?</br>"
	desc = "It seems that even being a statue she is able to break your neck."

/obj/structure/onyxawards2018/cooper
	name = "statue of AnotherAssistant"
	icon_state = "walruser2018"
	info = "statue of AnotherAssistant, the best Chaotic Onyx assistant and cooper of 2018. <br>It was better the way it was.</br>"
	desc = "He's totally not a bad guy."

/obj/structure/onyxawards2018/fail
	name = "statue of REBOLUTION228"
	icon_state = "reba2018"
	info = "statue of REBOLUTION228, the best Chaotic Onyx fail of 2018.<br>Pick me, please!</br>"
	desc = "Just a big clown. Nothing to see here."

/obj/structure/onyxawards2018/xeno
	name = "statue of unknown tayara"
	icon_state = "tayara2018"
	info = "statue of unknown tayara, the best Chaotic Onyx xenos of 2018.<br>Please, pokin`te a room, I here rabotau.</br>"
	desc = "Big cat in cook clothes."

/obj/structure/onyxawards2018/trap
	name = "statue of TobyThorne"
	icon_state = "toby2018"
	info = "statue of TobyThorne, the best Chaotic Onyx trap of 2018.<br>I take no offence.</br>"
	desc = "Nice girl. Wait, what the..."

/obj/structure/onyxawards2018/vaxter
	name = "statue of Maglaj"
	icon_state = "stas2018"
	info = "statue of Majlaj, the strongest Chaotic Onyx VAXTER of 2018.<br>Everyone can be a trap.</br>"
	desc = "Looking at this statue, you hear the cries of hundreds of unjustly banned."

/obj/structure/onyxawards2018/toxic
	name = "statue of Gremy4uu"
	icon_state = "gre4a2018"
	info = "statue of Gremu4uu, the biggest Chaotic Onyx toxic of 2018. <br>You motherfucker, come on you little asshole!Try to fuck with me, eh? You fucking little asshole, dickhead cocksucker!</br>"
	desc = "Looking at this guy, you want to breathe some fresh air."

/obj/structure/onyxawards2018/dead
	name = "statue of Rodial"
	icon_state = "rodial2018"
	info = "statue of Rodial, the most decomposed Chaotic Onyx corpse of 2018.<br>Don`t wake me up.</br>"
	desc = "A coffin. What if I open it?"

/obj/structure/onyxawards2018/dead/opened
	icon_state = "rodialopen2018"
	desc = "Oh God."

/obj/structure/onyxawards2018/dead/opened/attack_hand(mob/user as mob)
	return 1

/obj/structure/onyxawards2018/dead/attack_hand(mob/user as mob)
	if(user.a_intent != I_HELP)
		visible_message("<span class='danger'>[user] open [src]!</span>")
		to_chat(user, "<span class='notice'>You open the admiral coffin.</span>")
		new /obj/structure/onyxawards2018/dead/opened(get_turf(src))
		qdel(src)
	else
		return ..()

/obj/structure/onyxawards2018/trend
	name = "statue of JamsMor"
	icon_state = "jamsmor2018"
	info = "statue of Jamsmor, the best Chaotic Onyx trend of 2018.<br>It`s me, and my website!</br>"
	desc = "What a cool guy."

/obj/structure/onyxawards2018/ficha
	name = "statue of EAMS"
	icon_state = "eams2018"
	info = "statue of EAMS, the best(nope) Chaotic Onyx feature of 2018.<br>It`s (not) working!</br>"
	desc = "Hey, what with the letter E?"

/obj/structure/onyxawards2018/bug
	name = "statue of BlueBay`s pipes"
	icon_state = "pipes2018"
	info = "statue of BlueBay`s pipes, the worst Chaotic Onyx bug of 2018.<br>Do you... Remember me?..</br>"
	desc = "Cross made by pipes."

/obj/structure/onyxawards2018/chelovek
	name = "statue of Rampo"
	icon_state = "rampo2018"
	info = "statue of Rampo, the best Chaotic Onyx man of 2018.<br>And ever.</br>"
	desc = "A big spider-rabbit. Fuck."

/obj/structure/onyxawards2018/plate
	density = 0
	name = "information plate"
	icon_state = "tablichka"
	desc = "Welcome to the Museum of Chaotic Onyx Awards. Everything you've ever wanted to know about here, within arm's reach.<br>Go ahead, feel free to touch the statues.</br>"

/obj/structure/onyxawards2018/plate/attack_hand(mob/user as mob)
	return 1

/obj/structure/onyxawards2018/plate/ooc
	name = "information plate"
	desc = "Section of Out-of-Character winners."

/obj/structure/onyxawards2018/plate/ic
	name = "information plate"
	desc = "Section of In-Character winners."

/obj/structure/onyxawards2018/plate/funshit
	name = "information plate"
	desc = "Section of Fun-Shit winners."

/obj/structure/onyxawards2018/plate/special
	name = "information plate"
	desc = "Section of Special winners."
