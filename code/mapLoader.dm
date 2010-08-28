/proc/QML_parseFunc(var/func, var/args)
	switch(func)
		if("newlist")
			var/list/l = list()
			for(var/s in args)
				if(ispath(s))
					l += new s()
			return l
		if("list")
			return args
	//DEBUG
	//world << "Unknown func in map load: [func]"

/proc/QML_parseSettings(var/dat)
	if(isnum(text2num(dat)))
		return text2num(dat)
	else if(cmptext(copytext(dat,1,2),"\"") || cmptext(copytext(dat,1,2),"\'"))
		return copytext(dat, 2, lentext(dat))
	else if(cmptext(copytext(dat,1,2),"/"))
		return text2path(dat)
	else if(findtext(dat,"("))
		var/func=copytext(dat, 1, findtext(dat, "("))
		var/params=copytext(dat, findtext(dat, "(")+1, lentext(dat))
		var/list/l=QML_splitObjects(params)
		var/list/l2 = list()
		for(var/a in l)
			var/o=QML_parseSettings(a)
			l2+=o
		return QML_parseFunc(func,l2)

/proc/QML_splitSettings(var/dat)
	var/list/l = list()
	if(findtext(dat,";"))
		var/index = QML_objectExtent(dat,";")
		while(index)
			l+=copytext(dat,1,index)
			dat=copytext(dat,index+1,0)
			index = QML_objectExtent(dat,";")
		l+=copytext(dat,1,index)
	else
		l += dat
	return l

/proc/QML_applySettings(var/datum/obj, var/dat)
	var/list/settings = QML_splitSettings(dat)
	for(var/statement in settings)
		var/split = findtext(statement," = ")
		if(split)
			var/varName=copytext(statement,1,split)
			while(cmptext(copytext(varName,1,2)," "))
				varName=copytext(varName,2,0)
			if(varName in obj.vars)
				var/result = QML_parseSettings(copytext(statement,split+3,0))
				obj.vars[varName] = result

/proc/QML_makeObject(var/turf/loc,var/dat)
	if(findtext(dat,"{"))
		var/type = text2path(copytext(dat, 1, findtext(dat, "{")))
		if(ispath(type))
			var/obj = new type(loc)
			if(isobj(obj))
				QML_applySettings(obj, copytext(dat,findtext(dat,"{")+1, lentext(dat)))
	else
		var/type = text2path(dat)
		if(ispath(type))
			new type(loc)
		//DEBUG
		//else world << "Not type: [dat]"

/proc/QML_objectExtent(var/dat, var/end)
	var/quote = 0
	var/bracket = 0
	var/i = 0
	var/char
	var/q=text2ascii("\"")
	var/l=text2ascii("{")
	var/r=text2ascii("}")
	var/c=text2ascii(end)
	var/e=text2ascii("\\")
	for(i=0, i<lentext(dat), i++)
		char = text2ascii(dat,i+1)
		if(quote)
			if(char==e)
				i++
			else if(char==q)
				quote=0
		else if(char==c && bracket==0)
			return i+1
		else
			if(char==l)
				bracket++
			else if(char==q)
				quote = 1
			else if(char==r && bracket>0)
				bracket--

/proc/QML_splitObjects(var/dat)
	var/list/l = list()
	var/index = QML_objectExtent(dat,",")
	while(index)
		l+=copytext(dat,1,index)
		dat=copytext(dat,index+1,0)
		index = QML_objectExtent(dat,",")
	l += dat
	return l

/proc/QML_makeObjects(var/turf/loc, var/dat)
	if(text2ascii(dat,1)==text2ascii("("))
		var/list/l=QML_splitObjects(copytext(dat,2,lentext(dat)))
		if(l)
			var/i
			for(i = 0, i<l.len, i++)
				QML_makeObjects(loc,l[l.len-i])
	else
		QML_makeObject(loc,dat)

/proc/QML_loadMap(var/mapName, var/offset_x=0, var/offset_y=0, var/offset_z=0)
	//world.log_game("QML_loadMap([mapName], [offset_x], [offset_y], [offset_z])")
	var/mapText = file2text(mapName)
	var/list/map = list()
	var/str
	str = findtext(mapText,"\n")
	while(str>=0 && lentext(mapText)>1)
		map += copytext(mapText,1,str)
		mapText = copytext(mapText,str+1,0)
		str = findtext(mapText,"\n")
	var/list/types = list()
	var/stage = 0
	var/base_x
	var/base_y
	var/base_z
	var/size = 1
	var/list/collect
	for(var/s in map)
		if(lentext(s) == 0)
			stage=1
		else if(stage == 0)
			var/id = copytext(s, 2, 0)
			id = copytext(id, 1, findtext(id, "\""))
			if(lentext(id)>size)
				size=lentext(id)
			types[id] = copytext(s, findtext(s,"=")+2)
		else if(stage == 1)
			var/coords = copytext(s, findtext(s,"(")+1, findtext(s, ")"))
			base_x = text2num(copytext(coords, 1, findtext(coords, ",")))
			coords=copytext(coords, findtext(coords, ",")+1, 0)
			base_y = text2num(copytext(coords, 1, findtext(coords, ",")))
			coords=copytext(coords, findtext(coords, ",")+1, 0)
			base_z = text2num(coords)
			collect = list()
			stage = 2
		else if(stage == 2)
			if(s=="\"}")
				var/j
				for(j = 0, j<collect.len, j++)
					s=collect[collect.len-j]
					var x = 0
					var i = 0
					var/len = lentext(s)
					for(i=1, i<=len, i+=size)
						var/id = copytext(s,i,i+size)
						if(types[id])
							if(world.maxx<base_x+x)
								world.maxx=base_x+x
							if(world.maxy<base_y)
								world.maxy=base_y
							if(world.maxz<base_z)
								world.maxz=base_z
							var/turf/loc=locate(base_x+x+offset_x,base_y+offset_y,base_z+offset_z)
							if(loc)
								QML_makeObjects(loc,types[id])
						x++
					base_y++
				stage = 3
			else
				collect += s