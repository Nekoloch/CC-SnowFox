-- SNOWFOX
-- Developed by Nekoloch

-- Protocol Documentation: https://raw.github.com/Nekoloch/CC-SnowFox/master/protocol_doc.txt

local cli_version = "Version 0.1.0 Beta - Initial Release"
local serv_version = "Version 0.1.0 Beta - Initial Release"
protocol_version = "SnowNet Protocol Version 0.1.0 Beta - Initial Release"

USER_AGENT = "SnowFox v0.1.0b <early> User Client A - Web Browser by Nekoloch"

-- SNOWNET PROTOCOL
snownet = {}
snownet.open = function ()
	local modem = false
	for k,v in pairs(rs.getSides()) do
		if peripheral.getType(v) == "modem" then
			if rednet.isOpen(v) then
				modem=true
				break
			else
				modem=true
				rednet.open(v)
				break
			end
		end
	end
	if not modem then
		return false
	else
		return true
	end
end
snownet.broadcast = function ( tab )
	rednet.broadcast(textutils.serialize(tab))
end
snownet.decode = function ( str )
	-- Prevent errors from happening.
	local status, err = pcall(textutils.unserialize,str)
	if err then
		return false
	else
		return textutils.unserialize(str)
	end
end
snownet.defaults = {

}
snownet.get = function ( protocol, site , subdomain , get , post )
	protocol = protocol or "snow://"
	get = get or "/"
	post = post or ""
	subdomain = subdomain or "www."
	local getP = { ["protocol"]=protocol, ["sub"]=subdomain, ["host"]=site, ["GET"]=get, ["POST"]=post, ["user-agent"]=USER_AGENT, ["protocol_version"]=protocol_version, ["hostname"]=os.getComputerID() }
	if getP.protocol == "snow://" then
		snownet.broadcast(getP)
		id, msg = rednet.receive(1)
		if id == nil then
			return false
		else
			return msg
		end
	elseif getP.protocol == "http://" or getP.protocol == "https://" then
		if getP.POST:len() > 0 then
			resp = http.post( getP.protocol .. getP.sub .. getP.host .. getP.GET , getP.POST )
			if resp then
				return resp:readAll()
			else
				return false
			end
		else
			resp = http.get( getP.protocol .. getP.sub .. getP.host .. getP.GET )
			if resp then
				return resp:readAll()
			else
				return false
			end
		end
	elseif getP.protocol == "SELF://" then
		return snownet.defaults[ getP.host ]
	end
end

-- CLIENT

function PROGRAM ()
ctimeout = [[]]

function errorPage ( err )
	
end

function avfilter ( sresp ) -- Checks if content is malicious, however, atm it is not going to do anything. PLANNED
	return sresp
end

function displaySite ( siteresp )
	if siteresp == false then
		func, err = loadstring(ctimeout)
		func()
	else
		if type(siteresp) ~= "table" then -- For whatever reason
			return nil
		else
			if siteresp.code == "200 OK" then
				if type(siteresp.content) == "string" then
					func, err = loadstring(avfilter(siteresp.content))
					if func then
						status, err = pcall(func)
						if err then
							return errorPage(err)
						end
						return nil
					else
						return errorPage(err)
					end
					return nil
				else
					return errorPage("Invalid type of content")
				end
			else
				return errorPage("Response Code: "..tostring(siteresp.code))
			end
		end
	end
	return nil
end

function redirect ( sub , site , get , post )
	local webResp = snownet.get(nil,site,sub,get,post)
	displaySite(webResp)	
end

function getTypes ( nStr )
	local _begin, _end = string.find(nStr,"://")
	local sT = {}
	if _begin == nil then
		sT.protocol = "SELF://"
	else
		sT.protocol = string.sub(nStr,1,_end)
		nStr=nStr:sub(_end+1)
	end
	local _begin, _end = string.find(nStr,".")
	if _begin then
		_begin2, _end2 = string.find(nStr:sub(_end+1),".")
		if _begin2 then
			sT.sub=nStr:sub(1,_end)
			nStr = nStr:sub(_end+1)
		end
	end
	local _begin, _end = string.find(nStr,"/")
	if _begin then
		sT.host=nStr:sub(1,_end-1)
		nStr = nStr:sub(_end)
		sT.GET=nStr
		return sT
	else
		sT.host=nStr
		return sT
	end
end

function fRead ()
	local inpstr = ""
	while true do
		action, key = os.pullEvent()
		if action == "char" then
			inpstr=inpstr..key
		elseif action == "key" then
			if key == 28 then
				break
			end
		end
	end
	return inpstr
end

function mainMenu () -- The main loop
	while true do
		-- Place GUI stuff here!
		input=fRead()
		redirect(getTypes(input))
		sleep(0)
	end
end

end

function doCrash ( err )

end

function thanks ()

end

local stat, erx = pcall(PROGRAM)
if erx then
	doCrash(erx)
else
	thanks()
end