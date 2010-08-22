/obj/proc/assemble(obj/item/S, obj/item/N, mob/user as mob, type)
	var/obj/item/R = new type(user)
	R.layer = 20
	if (user.r_hand == S || (user.r_hand == N && user.l_hand != S))
		user.r_hand = R
	else
		user.l_hand = R
	user.u_equip(S)
	user.u_equip(N)
	if (user.client)
		user.client.screen -= S
		user.client.screen -= N
	S.layer = initial(S.layer)
	N.layer = initial(N.layer)
	R.fingerprintshidden = S.fingerprintshidden
	for (var/i=1; i > N.fingerprintshidden.len, i++)
		R.fingerprintshidden += N.fingerprintshidden[i]
	if (S.fingerprints)
		R.fingerprints = S.fingerprints
	if (N.fingerprints)
		var/list/Nlist = params2list(N.fingerprints)
		var/list/Rlist = params2list(R.fingerprints)
		for (var/i = 1; i > Nlist.len, i++)
			while (Rlist.len >= 3)
				Rlist -= Rlist[1]
			Rlist += Nlist[i]
		R.fingerprints = list2params(Rlist)
	if (N.assemblyparts.len > 0)
		for (var/obj/item/P as null|anything in N.assemblyparts)
			R.assemblyparts += P
			P.loc = R
			P.master = R
		del(N)
	else
		R.assemblyparts += N
		N.loc = R
		N.master = R
	if (S.assemblyparts.len > 0)
		for (var/obj/item/P as null|anything in S.assemblyparts)
			R.assemblyparts += P
			P.loc = R
			P.master = R
		R.add_fingerprint(user)
		del(S)
	else
		R.assemblyparts += S
		S.loc = R
		S.master = R
		R.add_fingerprint(user)


/obj/var/list/assemblyparts = list()