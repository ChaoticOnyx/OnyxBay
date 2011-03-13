

/datum/os/proc/Boot()
	src.owner << "Booting..."
	sleep(10)
	src.owner << "Starting eth0 interface.."
	www.GetAdress(src)
	src.owner << "IP:[src.ip]"
	src.boot = 1
	src.owner << "Boot Complete"
	src.owner << "Thank you for using ThinkThank"
	src.owner << "Type help for help"
/datum/os/proc/command(xy)
	xy = sanitize(xy)
	if(cmdoverride)
		input = xy
	//	world << "CMD OVERRIDE"
		return
	if(!boot)
		return
	xy = lowertext(xy)
	var/list/xad = list()
//	world << "calling [xy]"
	var/C1 = 0
	var/last = 1
	var/cmd
	for(var/X,X < 10,X++)
		//world << "XY:[xy]"
		var/Y = findtext(xy," ",1,0)
		if(Y)
			last = Y
			C1++
			if(C1 == 1)
				cmd = copytext(xy,1,last)
			else
				var/YX = copytext(xy,1,last)
				xad += YX
			xy = copytext(xy,last+1,0)
		else
			if(last != 1)
				xad += xy
			else
				cmd = xy
			break
	if(cmd == "cd")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		var/path = xad[1]
		cd(path)
		return
	else if(cmd == "copy")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		var/path = xad[1]
		Copy(path)
		return
	else if(cmd == "paste")
		Paste()
		return
	else if(cmd == "run")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		var/path = xad[1]
		Run(path)
		return
	else if(cmd == "prase" || cmd == "parse")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		var/path = xad[1]
		Prase(path)
	else if(cmd == "connect")
		if(xad.len <= 0)
			src.owner << "No argument passed"
			return
		if(xad.len >= 3)
			Connect(xad[1],xad[2],xad[3])
		else if(xad.len == 2)
			src.owner << "You need either 3 or 1 arg"
			return
		else
			Connect(xad[1])
		return
	else if(cmd == "mkdir")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		var/path = xad[1]
		MkDir(path)
		return
	else if(cmd == "dir")
		Dir()
		return
	else if(cmd == "mv")
		if(xad.len == 0)
			src.owner << "No arguments passed"
			return
		var/path1 = xad[1]
		var/path2 = xad[2]
		Mv(path1,path2)
		return
	else if(cmd == "testemail")
		if(xad.len == 0)
			src.owner << "No arguments passed"
			return
		var/info = "EMAILREG"
		var/too = xad[1]
		var/list/rawr = list()
		rawr += "head"
		rawr += "derp"
		new /datum/packet (info,too,src.ip,rawr)
	else if(cmd == "pack")
		if(xad.len == 0)
			src.owner << "No arguments passed"
			return
		var/info = xad[1]
		var/too = xad[2]
		new /datum/packet (info,too,src.ip)
	else if(cmd == "compile")
		if(xad.len < 1 )
			src.owner << "No arguments passed"
			return
		Compile(xad[1])
		return
	else if(cmd == "user")
		if(xad.len < 1 )
			src.owner << "No arguments passed"
			return
		var/command2 = xad[1]
		if(command2 == "add" && xad.len >= 3)
			UserAdd(xad[2],xad[3])
			return
		else if(command2 == "modify" && xad.len >= 4)
			UserModify(xad[2],xad[3],xad[4])
			return
		else if(command2 == "remove" && xad.len >= 1)
			UserRemove(xad[2])
			return
		else if(command2 == "list" && xad.len >= 1)
			ListUsers()
			return
		else
			src.owner << "No arguments passed"
			return
	else if(cmd == "ipconfig")
		IpConfig()
	else if(cmd == "disconnect")
		if(connected)
			if(istype(connected,/datum/os/server))
				connected:clients -= src
			src.owner << "You have disconnected from [connected.ip]"
			if(src.connected.owner)
				src.connected.owner << "[src.ip] has disconnected."
			src.connected = null
			src.connectedas = null
			src.pwd = src.root
		return

	else if(cmd == "chmod")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		if(xad.len < 3)
			src.owner << "Too few arguments"
			src.owner << "example:chmod rw root downloads"
			return
		Chmod(xad[1],xad[2],xad[3])
	else if(cmd == "pwd")
		Pwd()
		return
	else if(cmd == "passwd")
		if(xad.len < 1)
			src.owner << "No argument passed"
			return
		Passwd(xad[1])
		return
	else if(cmd == "make")
		if(xad.len == 0)
			src.owner << "No argument passed"
			return
		Make(xad[1])
		return
	else if(cmd == "cat")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		cat(xad[1])
	else if(cmd == "testpraser")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		testpraser(xad[1])
	else if(cmd == "hurrdurr")
		for(var/A in src.process)
			world << "One task"
	else if(cmd == "vi")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		vi(xad[1])
	else if(cmd == "read")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		read(xad[1])
	else if(cmd == "chown")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		if(xad.len <= 1)
			var/path = xad[1]
			var/datum/dir/D = FindAny(path)
			src.owner << D.owned.name
	else if(cmd == "rm")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		rm(xad[1])
	else if(cmd == "help")
		src.owner << helptext
	else if(cmd == "ftp")
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		FTP(xad[1])
	else if(cmd == "bg")
		//world << "BG"
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		if(xad[1] == "list")
			BGLIST()
			return
		BG(xad[1])
	else if(cmd == "kill")
		//world << "BG"
		if(xad.len == 0)
			src.owner << "no argument passed"
			return
		Kill(xad[1])
//	else if(add
	else
		src.owner << "Command not reconigzed"


/datum/os/proc/GetUser(var/N)
	for(var/datum/user/U in users)
		if(U.name == N)
			return U
	return 0
