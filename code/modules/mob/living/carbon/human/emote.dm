/mob/living/carbon/human/emote(var/act)

	if(src.stat == 2 && act != "deathgasp")
		return

	var/param = null

	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1 //visible emote (1), or hearable emote (2)

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	var/message = ""
	switch(act)

		if ("blink")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> blinks incredulously at [M]."
			else
				message = "<B>[src]</B> blinks incredulously."
			m_type = 1

		if ("blink_r" || "rapidblink")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> blinks rapidly at [M]."
			else
				message = "<B>[src]</B> blinks rapidly."
			m_type = 1

		if ("bow")
			if (!buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (findtext(A.name,param,1,0))
							M = A
							break
				if (!M)
					param = null

				if (M)
					message = "<B>[src]</B> bows respectfully to [M]."
				else
					message = "<B>[src]</B> bows deeply with a flourish of \his arm."
			m_type = 1

		if ("custom")
			if(copytext(param,1,2) == "v")
				m_type = 1
			else if(copytext(param,1,2) == "h")
				m_type = 2
			else
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible")
					m_type = 1
				else if (input2 == "Hearable")
					m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
			param = trim(copytext(param,2))
			var/input
			if(param == "")
				input = input("Choose an emote to display.")
			else
				input = param
			if(input != "")
				message = "<B>[src]</B> [input]"

		if ("salute")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> gives a sharp salute to [param]."
			else
				message = "<B>[src]</b> gives a sharp salute."
			m_type = 1

		if ("militarysalute" || "attention")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> clicks \his heels together and gives a sharp salute to [param]."
			else
				message = "<B>[src]</B> clicks \his heels together and gives a sharp salute."
			m_type = 1

		if ("choke")
			if (!muzzled)
				message = "<B>[src]</B> chokes!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2

		if ("clap")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> claps for [param]."
			else
				message = "<B>[src]</B> claps."
			m_type = 2

		if ("flap")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> flaps \his arms wildly at [param]!"
			else
				message = "<B>[src]</B> flaps \his arms wildly!"
			m_type = 1

		if ("drool")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> drools at the sight of [param]."
			else
				message = "<B>[src]</B> drools."
			m_type = 1

		if ("eyebrow")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> raises an eyebrow questioningly at [param]."
			else
				message = "<B>[src]</B> raises an eyebrow questioningly."
			m_type = 1

		if ("chuckle")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (!muzzled)
				if (M)
					message = "<B>[src]</B> chuckles heartily at [param]."
				else
					message = "<B>[src]</B> chuckles heartily."
			else
				message = "<B>[src]</B> makes a repeating noise."
			m_type = 2

		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1

		if ("twitch_s")
			message = "<B>[src]</B> twitches spasmodically."
			m_type = 1

		if ("faint")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> faints at the sight of [param]."
				sleeping = 5
			else
				message = "<B>[src]</B> suddenly faints!"
				sleeping = 5
			m_type = 1

		if ("cough")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (!muzzled)
				if (M)
					message = "<B>[src]</B> coughs softly at [param]."
				else
					message = "<B>[src]</B> coughs softly."
			else
				message = "<B>[src]</B> makes a soft noise."
			m_type = 2

		if ("frown")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> frowns disapprovingly at [param]."
			else
				message = "<B>[src]</B> frowns disapprovingly."
			m_type = 1

		if ("nod")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> nods \his acknowledgment of [param]."
			else
				message = "<B>[src]</B> nods \his head."
			m_type = 1

		if ("blush")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> blushes at [param] furiously."
			else
				message = "<B>[src]</B> blushes."
			m_type = 1

		if ("gasp")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> gives [param] a horrified gasp!"
			else
				message = "<B>[src]</B> gasps!"
			m_type = 2

		if ("deathgasp")
			message = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = 1

		if("struckdown")
			message = "<B>[src]</B>, Station Dweller, has been struck down."
			m_type = 2

		if ("giggle")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> giggles happily at [param]!"
			else
				message = "<B>[src]</B> giggles happily!"
			m_type = 2

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> glares angrily at [param]."
			else
				message = "<B>[src]</B> glares angrily."
			m_type = 1

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> stares implacably at [param]."
			else
				message = "<B>[src]</B> stares."
			m_type = 1

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break

			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> looks at [param]."
			else
				message = "<B>[src]</B> looks around for a moment."
			m_type = 1

		if ("grin")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> grins mischievously at [param]."
			else
				message = "<B>[src]</B> grins mischievously."
			m_type = 1

		if ("cry")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> collapses into [param]'s arms and begins to cry."
			else
				message = "<B>[src]</B> cries."
			m_type = 1

		if ("sigh")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> gives [param] a pained sigh."
			else
				message = "<B>[src]</B> gives a pained sigh."
			m_type = 2

		if ("laugh")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> laughs at [param]!"
			else
				message = "<B>[src]</B> laughs!"
			m_type = 2

		if ("mumble")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> mumbles incoherently at [param]."
			else
				message = "<b>[src]</B> mumbles incoherently."
			m_type = 2

		if ("grumble")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> grumbles angrily at [param]."
			else
				message = "<B>[src]</B> grumbles angrily."
			m_type = 2

		if ("groan")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> groans loudly at [param]!"
			else
				message = "<B>[src]</B> groans loudly!"

			m_type = 2

		if ("howl")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> tilts \his head back and howls like a wolf at [param]!"
			else
				message = "<B>[src]</B> tilts \his head back and howls like a wolf!"

			m_type = 2


		if ("moan")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> moans at [param]!"
			else
				message = "<B>[src]</B> moans!"
			m_type = 2

		if ("point")
			if (!restrained())
				var/mob/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (findtext(A.name,param,1,0))
							M = A
							break

				if (!M)
					message = "<B>[src]</B> points."
				else
					M.point()

				if (M)
					message = "<B>[src]</B> points to [M]."
				else
			m_type = 1

		if ("raise" || "raisehand")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> raises \his hand and waves it around, hoping [param] will notice."
			else
				message = "<B>[src]</B> raises \his hand."
			m_type = 1

		if("shake" || "no")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> shakes \his head at [param]."
			else
				message = "<B>[src]</B> shakes \his head."
			m_type = 1

		if ("shrug")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> shrugs helplessly at [param]."
			else
				message = "<B>[src]</B> shrugs helplessly."
			m_type = 1

		if ("signal")
			if (!restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!r_hand || !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!r_hand && !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1

		if ("smile")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> smiles at [param]."
			else
				message = "<B>[src]</B> smiles."
			m_type = 1

		if ("shiver")
			message = "<B>[src]</B> shivers violently."
			m_type = 2

		if ("pale")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> shivers as a chill runs down \his spine, and \his face pales considerably at the sight of [param]."
			else
				message = "<B>[src]</B> shivers as a chill runs down \his spine, and \his face pales considerably."
			m_type = 1

		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1

		if ("sneeze")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> fails to cover \his nose and sneezes all over [param]!"
			else
				message = "<B>[src]</B> covers \his mouth and sneezes."
			m_type = 2

		if ("sniff")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> sniffs [param]."
			else
				message = "<B>[src]</B> sniffs idly."
			m_type = 2

		if ("snore")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> snores loudly at [param], for whatever reason."
			else
				message = "<B>[src]</B> snores loudly."
			m_type = 2

		if ("whimper")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> whimpers at [param] like a wounded puppy."
			else
				message = "<B>[src]</B> whimpers like a wounded puppy."
			m_type = 2

		if ("wink")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> winks at [param]."
			else
				message = "<B>[src]</B> winks."
			m_type = 1

		if ("yawn")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> yawns at [param] in utter boredom."
			else
				message = "<B>[src]</B> lets out a big, wide yawn, resisting the urge to fall asleep."
			m_type = 2

		if ("collapse")
			message = "<B>[src]</B> collapses!"
			m_type = 2

		if("hug")
			m_type = 1
			if (!restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (findtext(A.name,param,1,0))
							M = A
							break
				if (M == src)
					M = null

				if (M)
					message = "<B>[src]</B> hugs [M]."
				else
					message = "<B>[src]</B> hugs \himself."
			m_type = 1

		if ("handshake")
			m_type = 1
			if (!restrained() && !r_hand)
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (findtext(A.name,param,1,0))
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.r_hand && !M.restrained())
						message = "<B>[src]</B> shakes hands with [M]."
					else
						message = "<B>[src]</B> holds out \his hand to [M]."
				m_type = 1

		if ("scream")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> screams agonizingly at the sight of [param]!"
			else
				message = "<B>[src]</B> screams agonizingly!"
			m_type = 2

		if ("ack")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> looks at [param] and says, \"Ack.\""
			else
				message = "<B>[src]</B> sticks out \his tongue and says, \"Ack.\""

			m_type = 2 // 1 for visual, 2 for audible

		if ("adulate")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				if (M.gender == MALE)
					message = "<B>[src]</B> kneels before [param] and praises him extravagantly."
				else if (M.gender == FEMALE)
					message = "<B>[src]</B> kneels before [param] and praises her extravagantly."
				else
					message = "<B>[src]</B> kneels before [param] and praises it extravagantly."
			else
				message = "<B>[src]</B> falls to \his kneels and praises everyone extravagantly."

			m_type = 2

		if ("agree")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> nods \his head at [param], showing \his acceptance."
			else
				message = "<B>[src]</B> nods \his head in agreement."

			m_type = 2

		if ("ah")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> nods at [param] as comprehension flashes across \his face."
			else
				message = "<B>[src]</B> nods as comprehension flashes across \his face."

			m_type = 2

		if ("aha" || "ahah")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> triumphantly exclaims, \"Aha!\" at [param]."
			else
				message = "<B>[src]</B> triumphantly exclaims, \"Aha!\""

			m_type = 2

		if ("ahem" || "clearthroat")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> clears \his throat in an attempt to get the attention of [param]."
			else
				message = "<B>[src]</B> clears \his throat in an attempt to get everyone's attention."

			m_type = 2

		if ("ahem" || "clearthroat")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> clears \his throat in an attempt to get the attention of [param]."
			else
				message = "<B>[src]</B> clears \his throat in an attempt to get everyone's attention."

			m_type = 2

		if ("ahoy")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> waves \his hand in the air and shouts a hearty, \"Ahoy!\" at [param]."
			else
				message = "<B>[src]</B> waves \his hand in the air and shouts a hearty, \"Ahoy!\""

			m_type = 2

		if ("applaud")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> gives a round of applause for [param]!"
			else
				message = "<B>[src]</B> gives a round of applause!"

			m_type = 2

		if ("argh")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> cries, \"Argh!\" and tears at \his hair at the sight of [param]."
			else
				message = "<B>[src]</B> cries, \"Argh!\" and tears at \his hair."

			m_type = 2

		if ("aww")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> says, \"Aww!\" to [param]."
			else
				message = "<B>[src]</B> says, \"Aww!\""

			m_type = 2

		if ("aye")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> mutters, \"Aye,\" to [param], shaking \his head unhappily."
			else
				message = "<B>[src]</B> mutters, \"Aye,\" shaking \his head unhappily."

			m_type = 2

		if ("babble")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> babbles incoherently at [param]."
			else
				message = "<B>[src]</B> babbles incoherently."

			m_type = 2

		if ("bah")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> disgustedly retorts, \"Bah!\" to [param]."
			else
				message = "<B>[src]</B> disgustedly returns, \"Bah!\""

			m_type = 2

		if ("bawl")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> looks at [param] and begins bawling \his eyes out, face streaked with tears.."
			else
				message = "<B>[src]</B> begins bawling \his eyes out, face streaked with tears."

			m_type = 1

		if ("beam")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> beams broadly at [param] with a sunny smile."
			else
				message = "<B>[src]</B> beams broadly with a sunny smile."

			m_type = 1

		if ("bearhug")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				if (M.gender == MALE)
					message = "<B>[src]</B> runs up to [param] and envelops him in a massive bear hug."
				else if (M.gender == FEMALE)
					message = "<B>[src]</B> runs up to [param] and envelops her in a massive bear hug."
				else
					message = "<B>[src]</B> runs up to [param] and envelops it in a massive bear hug."
			else
				message = "<B>[src]</B> gives \himself a massive bear hug because no one else will."

			m_type = 1

		if ("beckon")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				if (M.gender == MALE)
					message = "<B>[src]</B> makes a beckoning motion to [param], bidding him to follow."
				else if (M.gender == FEMALE)
					message = "<B>[src]</B> makes a beckoning motion to [param], bidding her to follow."
				else
					message = "<B>[src]</B> makes a beckoning motion to [param], bidding it to follow."
			else
				message = "<B>[src]</B> makes a beckoning motion to nobody in particular."

			m_type = 1

		if ("beam")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> beams broadly at [param] with a sunny smile."
			else
				message = "<B>[src]</B> beams broadly with a sunny smile."

			m_type = 1

		if ("belch")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> belches obscenely in [param]'s face!"
			else
				message = "<B>[src]</B> belches obscenely!"

			m_type = 1

		if ("bird")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> flips [param] the bird!"
			else
				message = "<B>[src]</B> flips everyone the bird!"

			m_type = 1

		if ("bitelip")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> looks up at [param] nervously, biting \his lip with nervous indecision."
			else
				message = "<B>[src]</B> bites \his lip with nervous indecision."

			m_type = 1

		if ("blankstare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				if (M.gender == MALE)
					message = "<B>[src]</B> stares blankly at [param], disbelieving of what he just said."
				else if (M.gender == FEMALE)
					message = "<B>[src]</B> stares blankly at [param], disbelieving of what she just said."
				else
					message = "<B>[src]</B> stares blankly at [param], disbelieving of what it just said."
			else
				message = "<B>[src]</B> stares blankly, disbelieving of what \he just heard."

			m_type = 1

		if ("bleh")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> rolls \his eyes in disgust at [param] and says, \"Bleh.\""
			else
				message = "<B>[src]</B> rolls \his eyes in disgust and says, \"Bleh.\""

			m_type = 2

		if ("blowkiss")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> lifts \his hand and blows a flying kiss to [param]."
			else
				message = "<B>[src]</B> lifts \his hand and blows a flying kiss."

			m_type = 1

		if ("bob")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> bobs up and down in front of [param]."
			else
				message = "<B>[src]</B> bobs up and down."

			m_type = 1

		if ("bitelip")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> looks up at [param] nervously, biting \his lip with nervous indecision."
			else
				message = "<B>[src]</B> bites \his lip with nervous indecision."

			m_type = 1

		if ("boggle")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> boggles \his eyes as \he gapes at [param] in amazement!"
			else
				message = "<B>[src]</B> boggles \his eyes in amazement!"

			m_type = 1

		if ("bollocks" || "bollox")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> exclaims to [param], with a derisive sneer, \"Bollocks!\""
			else
				message = "<B>[src]</B> exclaims, with a derisive sneer, \"Bollocks!\""

			m_type = 2

		if ("bop")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M)
				param = null

			if (M)
				message = "<B>[src]</B> bops [param] on the head!"
			else
				message = "<B>[src]</B> bops \himself on the head!"

			m_type = 1



		if ("vomit")
			message = vomit(1) //this way it can do all of food and thign overeating
			m_type = 1

		if ("help")
			src << "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn\n\nThis is currently incomplete while I update the emotes. - Foxingly"

		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if (isobj(src.loc)) // In case the mob is located in an object which may alter sounds coming from it (bodybags for instance)
		message = src.loc:alterMobEmote(message, act, m_type, src)

		if (message != "")
			if (m_type & 1)
				for (var/mob/O in viewers(src.loc, null))
					O.show_message(message, m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src.loc, null))
					O.show_message(message, m_type)

	else if (message != "")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src, null))
				O.show_message(message, m_type)