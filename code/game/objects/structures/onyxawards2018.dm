/obj/structure/onyxawards2018
	name = "statue of Onyx"
	icon_state = "onyx2018"
	icon = 'icons/obj/onyxaward2018.dmi'
	anchored = 1
	density = 1
	opacity = 0
	var/health = 250
	var/info

/obj/structure/onyxawards2018/attack_hand(mob/user as mob)
	if(user.a_intent == I_HELP)
		visible_message("<span class='notice'>[user] touches [src].</span>")
		to_chat(user, "<span class='notice'>This is [info] </span>")
	else
		return ..()
	sleep(30)

/obj/structure/onyxawards2018/shadow_lead
	name = "statue of Plin"
	icon_state = "plin2018"
	info = "Statue of Plin, the shadow lead of Chaotic Onyx and a best developer of 2018. <cr> Remember - no one pushes to release before snail."
	desc = "A big... Snail?.."

/obj/structure/onyxawards2018/buguser
	name = "statue of NanoAnon"
	icon_state = "nanoanon2018"
	info = "Statue of Nanoanon,the best buguser of Chaotic Onyx at 2018. <cr> Enjoy your infinity pressure!"
	desc = "What a nice hairstyle."

/obj/structure/onyxawards2018/disappointment
	name = "statue of IGRALO"
	icon_state = "cheburek2018"
	info = "Statue of IGRALO, the biggest Chaotic Onyx disappointment and the worst traitor of 2018. <cr> Each voter will recieve a E-ball!"
	desc = "Is it taco?.."

/obj/structure/onyxawards2018/roll_and_play
	name = "statue of Voldirs"
	icon_state = "voldirs2018"
	info = "Statue of Voldirs, the best player and roleplayer of Chaotic Onyx at 2018. <cr> Did you call me a weak trap?"
	desc = "It seems that even being a statue she is able to break your neck."

/obj/structure/onyxawards2018/developer
	name = "statue of Plin"
	icon_state = "plin2018"
	info = "Statue of Plin,the shadow lead of Chaotic Onyx and a best developer for 2018. <cr> Remember - no one pushes to release toward snail."
	desc = "A big... Snail?.."

/obj/structure/onyxawards2018/pedal
	name = "statue of LegatePritcher."
	icon_state = "legate2018"
	info = "Statue of LegatePritcher, best admin of Chaotic Onyx for 2018. <cr> U my bro, or not my bro, bro?"
	desc = "That guy have an axe. What if I just..."

/obj/structure/onyxawards2018/traitor
	name = "statue of IGRALO"
	icon_state = "cheburek2018"
	info = "Statue of IGRALO, the biggest desappoiment and the worst traitor of Chaotic Onyx at 2018. <cr> Each voter  will recieve a E-ball!"
	desc = "Is it a taco?.."

/obj/structure/onyxawards2018/robuster
	name = "statue of Sranklin"
	icon_state = "sranklin2018"
	info = "Statue of Sranklin, best robuster and the fastest ERP-police of Chaotic Onyx for 2018. <cr> I'm not lurching, suka."
	desc = "He is some kind of angry."

/obj/structure/onyxawards2018/shitcurity
	name = "statue of Schutze88"
	icon_state = "schutze2018"
	info = "Statue of Schutze88, best shitcurity of Chaotic Onyx for 2018. <cr> ZATIRANENO."
	desc = "He make wrong choice."

/obj/structure/onyxawards2018/medic
	name = "statue of SolarEclipse84"
	icon_state = "solare2018"
	info = "Statue of SolarEclipse84, best medic of Chaotic Onyx for 2018. <cr> Get out from me, and my medbay."
	desc = "That guy too have an axe. What if I just... "

/obj/structure/onyxawards2018/assistant
	name = "statue of AnotherAssistant"
	icon_state = "walruser2018"
	info = "Statue of AnotherAssistant, best assistant and cooper of Chaotic Onyx for 2018. <cr> But earlier it was better. "
	desc = "He a totally not bad guy."

/obj/structure/onyxawards2018/erp_er
	name = "statue of VaxEx"
	icon_state = "vaxex2018"
	info = "Statue of VaxEx, malicious ERP-er of Chaotic Onyx for 2018. <cr> I am NOT a Trapenberger."
	desc = "Nice top-hat, really."

/obj/structure/onyxawards2018/erp_police
	name = "statue of Sranklin"
	icon_state = "sranklin2018"
	info = "Statue of Sranklin, best robuster and the fastest ERP-police of Chaotic Onyx for 2018. <cr> I'm not lurching, suka."
	desc = "He is some kind of angry."

/obj/structure/onyxawards2018/player_of_year
	name = "statue of Voldirs"
	icon_state = "voldirs2018"
	info = "Statue of Voldirs, the best player and roleplayer of Chaotic Onyx at 2018. <cr> Did you call me a weak trap?"
	desc = "It seems that even being a statue she is able to break your neck."

/obj/structure/onyxawards2018/cooper
	name = "statue of AnotherAssistant"
	icon_state = "walruser2018"
	info = "Statue of AnotherAssistant, the best assistant and cooper of Chaotic Onyx for 2018. <cr> But earlier it was better. "
	desc = "He a totally not bad guy."

/obj/structure/onyxawards2018/fail
	name = "statue of REBOLUTION228"
	icon_state = "reba2018"
	info = "Statue of REBOLUTION228, the best fail of Chaotic Onyx for 2018. <cr> Choose me, please!"
	desc = "Just a big clown. Nothing to see here."

/obj/structure/onyxawards2018/xeno
	name = "statue of unknown tayara"
	icon_state = "tayara2018"
	info = "Statue of unknown tayara, the best xenos of Chaotic Onyx for 2018. <cr> Please, pokin`te a room, I here rabotau."
	desc = "Big cat in cook clothes.  "

/obj/structure/onyxawards2018/trap
	name = "statue of TobyThorne"
	icon_state = "toby2018"
	info = "Statue of TobyThorne, the best trap of Chaotic Onyx for 2018. <cr> I take no offence."
	desc = "Nice girl. Wait, what the..."

/obj/structure/onyxawards2018/vaxter
	name = "statue of Maglaj"
	icon_state = "stas2018"
	info = "Statue of Majlaj, the strongest VAXTER of Chaotic Onyx for 2018. <cr> Everyone can be a trap. "
	desc = "Looking at this statue, you hear the cries of hundreds of unjustly banned."

/obj/structure/onyxawards2018/toxic
	name = "statue of Gremy4uu"
	icon_state = "gre4a2018"
	info = "Statue of Gremu4uu, the biggest toxic of Chaotic Onyx for 2018. <cr> Bastard, your mother, and come here shit dog, decided to climb me?.."
	desc = "Looking at this guy, you want to breathe some fresh air."

/obj/structure/onyxawards2018/dead
	name = "statue of Rodial"
	icon_state = "rodial2018"
	info = "Statue of Rodial, most decomposed corpse of Chaotic Onyx for 2018. <cr> Don`t wake me up."
	desc = "A coffin. What if open it?"

/obj/structure/onyxawards2018/dead/opened
	icon_state = "rodialopen2018"
	desc = "Oh, God."

/obj/structure/onyxawards2018/dead/attack_hand(mob/user as mob)
	if(user.a_intent != I_HELP)
		visible_message("<span class='danger'>[user] open [src]!</span>")
		to_chat(user, "<span class='danger'>You open the coffin. </span>")
		new /obj/structure/onyxawards2018/dead/opened(get_turf(src))
		qdel(src)
	else
		return ..()

/obj/structure/onyxawards2018/trend
	name = "statue of JamsMor"
	icon_state = "jamsmor2018"
	info = "Statue of Jamsmor, the best trend of Chaotic Onyx for 2018. <cr> It`s me, and my website!"
	desc = "What a cool guy."

/obj/structure/onyxawards2018/ficha
	name = "statue of EAMS"
	icon_state = "eams2018"
	info = "Statue of EAMS, the best(no) fitch of Chaotic Onyx for 2018. <cr> It`s (not) working!"
	desc = "Hey, what with the letter E?"


/obj/structure/onyxawards2018/bug
	name = "statue of BlueBay`s pipes"
	icon_state = "pipes2018"
	info = "Statue of BlueBay`s pipes, the worstest bug of Chaotic Onyx for 2018. <cr> Do you... Remember me?.."
	desc = "Cross from pipes."

/obj/structure/onyxawards2018/chelovek
	name = "statue of Rampo"
	icon_state = "rampo2018"
	info = "Statue of Rampo, the best man of Chaotic Onyx for 2018. <cr> And whenever."
	desc = "A big spider-rabbit."

/obj/structure/onyxawards2018/plate
	density = 0
	name = "information plate"
	icon_state = "tablichka"
	desc = "Welcome to the Museum of Chaotic Onyx Awards. Everything you've ever wanted to know about here, within arm's reach. Go ahead, feel free to touch the statues."

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
