datum/dir
	var/name = "dir"
	var/datum/dir/holder
	var/list/contents = list()
	var/list/permissions = list()
	var/datum/user/owned
	var/path
datum/dir/file
	name = "file"
	contents = ""

datum/dir/New(namez,var/datum/dir/H)
	src.name = namez
	src.permissions["root"] = RW
	if(H)
		src.holder = H
		makepath()
datum/dir/proc/makepath()
	var/done = 1
	var/paths = ""
	var/datum/dir/D = src.holder
	if(D.name)
		var/list/x = list()
		if(D.name != "root")
			x += D.name
		while(done)
			if(!D.holder)
				done = 0
				break
			if(!D.name == "root")
				x += D.name
			D = D.holder
		for(var/A in x)
			paths += "/[A]"
		paths += "/[src.name]"
	else
		paths = "/[src.name]"
	src.path = paths
	// << paths
datum/dir/file/program
	name = "program"
	var/progname = "test"
	var/datum/packet/lastpacket
datum/dir/file/program/New(namez)
	..()
datum/dir/file/program/test
	progname = "test app"
datum/dir/file/program/background
	progname = "background app"
datum/dir/file/program/background/proc/process()
datum/dir/file/program/background/emailserver
	progname = "emailserver"
	var/list/users = list()
	var/servername = "herpderp.com"
datum/dir/file/program/background/emailserver/ForwardPacket(var/datum/packet/P)
	var/list/info = P.extrainfo
	if(P.info == "EMAILSEND")
		if(!info)
			return
		var/user = info["user"]
		var/pass = info["pass"]
		var/datum/emailuser/X = users[user]
		if(!X)
			return
		if(pass != X.pass)
			return
		var/content = info["content"]
		var/subject = info["subject"]
		var/too = info["too"]
		var/datum/emailuser/Y = users[too]
		if(!Y)
			return
		var/datum/email/E = new()
		E.subject = subject
		E.contains = content
		E.from = X.name
		Y.emails += E
		return
	if(P.info == "EMAILGET")
		var/user = info["user"]
		var/pass = info["pass"]
		var/datum/emailuser/X = users[user]
		if(!X)
			return
		if(pass != X.pass)
			return
		var/list/emails = list()
		for(var/datum/email/Y in X.emails)
			emails += Y
		new /datum/packet("EMAILRECV",P.from,P.where,emails)
		return // This will send all the emails to the client
	if(P.info == "EMAILREG")
		world << info["user"]
		var/user = info["user"]
		var/X = users[user]
		if(X)
			return // NOTEIFY THEM SOMEHOW LATER
		var/datum/emailuser/ZX = new()
		ZX.name = "[user]"
		ZX.fullname = "[user]@[servername]"
		ZX.pass = info["pass"]
		var/list/xd = list("okay")
		new /datum/packet("EMAILREG",P.from,P.where,xd)
		return
datum/emailuser
	var/name = "nick"
	var/fullname
	var/pass = "pass"
	var/list/emails = list()
datum/email
	var/subject
	var/contains
	var/from
datum/dir/file/program/proc/ForwardPacket(var/datum/packet/P)
	return 0
datum/dir/file/program/emailclient
	progname = "emailclient"
datum/dir/file/program/emailclient/Run()
	return 1

datum/dir/file/program
	var/is_script = 0
	var/script = ""
	var/running = 0
	var/datum/praser/PP

datum/dir/file/program/proc/Run(var/datum/os/client)
	running = 1
	if(is_script)
		PP = new(client,src.script,null,1,1)
		// client.process += PP // Praser take's care of this
//		if(PP)
		//	world << "PP :D"
		return
	return
datum/dir/file/program/proc/Stop(var/datum/os/client)
	if(!PP)
		world << "NO PP"
	client.process.Remove(PP)
	running = 0
datum/os
	var/getnextpacket = 0
datum/os/proc/GetPacket()
	while(getnextpacket)
		if(latepacket)
			var/datum/packet/P = src.latepacket
			latepacket = null
			return P
		else
			sleep(10)
//datum/os/proc/SendPacket(

/*
datum/dir/file/program
	name = "program"
	var/progname = "test" // not really needed
datum/dir/file/program/New(namez)
	src.name = namez // This is the file name
datum/dir/file/program/proc/Run(var/datum/os/client) // this is runned when run is called on it duh..
	return 1
datum/dir/file/program/proc/ForwardPacket(var/datum/packet/P) // when the client recieves a package program needs to be in the clients task list
	return 0


//////////Client//////////////
client.owner == player
client.pwd == current dir
client.GetInput() // returns a string typed in by the user.
FindAny(Name) = Find any files in PWD
FindProg(Name) etc
FindDir(Name)  etc
FindFile(Name) etc //textfiles cannot be runned
//////////////////////////////////

Sending packets
		new /datum/packet(TAG(INFO VAR),TOO,FROM,LIST)
Packets variables
P.info == The tag eg "PING" // Note always lowercase
P.from == sent from ip
P.where == destination ip
P.extrainfo = a list
*/

datum/os/proc/Compile(path)
	var/datum/dir/file/F = FindFile(path)
	if(!F)
		Message("Cannot find [path]")
		return
	var/datum/dir/file/program/P = new(path,src.pwd)
	P.is_script = 1
	P.script = F.contents
	P.holder = src.pwd
	src.pwd.contents += P
	del(F)
	Message("[path] has been compiled..")