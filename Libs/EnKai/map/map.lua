local addonInfo, privateVars = ...

---------- init namespace ---------

if not EnKai then EnKai = {} end
if not EnKai.map then EnKai.map = {} end

local internal    = privateVars.internal
local data        = privateVars.data
local mapData     = privateVars.mapData
local colossusData= privateVars.colossusData
local NPCData	  = privateVars.NPCData
local lang        = privateVars.langTexts
local oFuncs	  = privateVars.oFuncs

internal.mapEvent = {}

---------- make global functions local ---------

local _sMatch  = string.match
local _sFind   = string.find

---------- init local variables ---------

local _mapPoints = {}
local _wayPoints = {}
local _mapUnits = {}
--local _lastUpdate = nil
local _mapColossus = nil
local _mapNPC = {}
local _mapEvents = false
local _playerDeath = false

local _InspectMapDetail = Inspect.Map.Detail
local _InspectMapList = Inspect.Map.List
  
---------- local function block ---------

local function _fctCheckForColossus (values)

  if _mapColossus == nil then
    local data = EnKai.zip.uncompress (colossusData)
    local err, func = pcall(loadstring, "return {" .. data .. "}")
    if func ~= nil then _mapColossus = func() end
    
    if _mapColossus == nil then
      EnKai.tools.error.display ("EnKai", "Could not unzip colossus data", 1)
      return values.type
    end 
  end
 
--	EnKaiDebug = { colossus = _mapColossus }
 
  for k, v in pairs (_mapColossus) do
    
    local name = v[EnKai.tools.lang.getLanguageShort()]
    
    if values.name == name then
      local plane = _sMatch (values.type, "RIFT.INVASION.(.+)")
      return "RIFT.COLOSSUS." .. plane
    end
  end

  return values.type

end

local function _fctCheckForNPC (values)

	local zone = EnKai.map.getZoneByUnit (EnKai.unit.getPlayerDetails().id)
	
	if _mapNPC [zone] == nil then
		if NPCData[zone] == nil then return false end
		local data = EnKai.zip.uncompress (NPCData[zone])
		local err, func = pcall(loadstring, "return " .. data .. "")
		if func ~= nil then _mapNPC[zone] = func() end

		if _mapNPC[zone] == nil then
			EnKai.tools.error.display ("EnKai", "Could not unzip npc data", 1)
			return false
		end 
	end

	for k, v in pairs (_mapNPC[zone]) do
		if values == v[EnKai.tools.lang.getLanguageShort()] then
			return true
		end	
	end

	return false

end

local function _fctCheckPattern (value)

	local checkValue = string.gsub(value, "\n", "")

	for idx = 1, #lang.mapIdentifiers, 1 do

		local details = lang.mapIdentifiers[idx]
		local pattern = details.pattern

		if details.regExCompute ~= nil then
			local value1, _ = _sMatch(checkValue, pattern)
			--print (value1, checkValue, pattern)      
			if value1 ~= nil then return idx, details, details.type end             
		elseif details.regExValues ~= nil then
			local subValue = _sMatch(checkValue, pattern)

			--print (subValue, checkValue, pattern)
			
			if subValue ~= nil then
				--if string.find(value, "Bolidium") ~= nil then print (subValue, checkValue, pattern) end
				--print (value, pattern, subValue)
				for k, v in pairs(details.regExValues) do
					if _sMatch(subValue, k) then return idx, details, details.type .. "." .. v end
				end

				--EnKai.tools.error.display ("EnKai", subValue .. " not found in " .. EnKai.tools.table.serialize(details.regExValues), 2)
				--dump (checkValue)

			end          
		elseif details.exact == false then
			if _sFind(checkValue, pattern) ~= nil then return idx, details, details.type end 
		else
			if _sFind(checkValue, pattern, 1, true) ~= nil then return idx, details, details.type end
		end
	end

	for idx = 1, #lang.mapIdentifiersVendors, 1 do
		if _sFind(checkValue, lang.mapIdentifiersVendors[idx]) ~= nil then return 9999, lang.mapIdentifiersGeneric["VENDORGENERIC"], "VENDOR.OTHER" end
	end

	for k, v in pairs (lang.factionNames) do
		if _sFind(checkValue, v) ~= nil then return 9999, lang.mapIdentifiersGeneric["FACTION"], "VARIA.NPC" end
	end

	return 0

end

local function _fctGetSubValue (values, pattern)
  
  if values == nil then return nil end

  if _sFind(pattern, "DESC") ~= nil then
    local index = _sMatch(pattern, "DESC(%d)")
    return values[tonumber(index)]
  end
  
  return nil  

end

local function _fctIdentify(values)

	--print ('-----------')

	--local thisPattern = nil
	local mapIdentifier = nil
	local titleIdentifier, titleType
	local descIdentifier, descType
	local descIndex, titleIndex = 0, 0

	if values.title ~= nil then 

		--if values.title ~= nil then print ("titel: " .. string.gsub(values.title, "\n", "@@")) end

		values.titleList = EnKai.strings.split(values.title, "\n")

		for idx = 1, #values.titleList, 1 do
			local thisTitle = values.titleList[idx]
			if _sFind(thisTitle, lang.mapIdentifiersExcludeLevel, 1, true) == nil then -- exclude level info
				--mapIdentifier, values.type = _fctCheckPattern (thisTitle)        
				--if mapIdentifier ~= nil then break end
				titleIndex, titleIdentifier, titleType = _fctCheckPattern (thisTitle)
				if titleIdentifier ~= nil then break end
			end
		end

	end

	if values.description ~= nil then
	
		values.descList = EnKai.strings.split(values.description, "\n")

		if mapIdentifier == nil then 

			--print ("desc: " .. string.gsub(values.description, "\n", "@@"))
			--dump (values.descList)

			for idx = 1, #values.descList, 1 do
				local thisDesc = values.descList[idx]
				if _sFind(thisDesc, lang.mapIdentifiersExcludeLevel, 1, true) == nil then -- exclude level info
					--mapIdentifier, values.type = _fctCheckPattern (thisDesc)
					--if mapIdentifier ~= nil then break end
					descIndex, descIdentifier, descType = _fctCheckPattern (thisDesc)
					if descIdentifier ~= nil then break end
				end      
			end
		end
	end
	
	if titleIndex == 0 and descIndex == 0 and values.descList ~= nil then 

		-- last resort: try to find NPC in known NPC list for zone
	
		for idx = 1, #values.descList, 1 do
			local thisDesc = values.descList[idx]
			local found = _fctCheckForNPC (thisDesc)
			if found then descIndex, descIdentifier, descType = 9999, thisDesc, "VARIA.NPC" end
			break
		end

	end
	
	
	if titleIndex == 0 and descIndex == 0 then
		if nkDebug then
			EnKai.tools.error.display ("EnKai", "Could not identify map entry", 2)
			nkDebug.logEntry (Inspect.Addon.Current(), "_fctIdentify", "Unidentified map entry", values)
			--dump (values)
		end
		mapIdentifier = lang.mapIdentifiersGeneric["UNKNOWN"]
		values.type = "UNKNOWN"
		--return nil
	elseif titleIndex == 0 then
		mapIdentifier = descIdentifier
		values.type = descType
	elseif descIndex == 0 then
		mapIdentifier = titleIdentifier
		values.type = titleType
	elseif descIndex < titleIndex then
		mapIdentifier = descIdentifier
		values.type = descType
	else
		mapIdentifier = titleIdentifier
		values.type = titleType
	end

	--local mapIdentifier = lang.mapIdentifiers[thisPattern]

	if mapIdentifier.regExCompute ~= nil and values.descList ~= nil then
		for idx = 1, #values.descList, 1 do
			local value1, value2, value3 = string.match(values.descList[idx], mapIdentifier.pattern)
			if value1 ~= nil then
				if  #mapIdentifier.regExCompute >= 1 then values[mapIdentifier.regExCompute[1]] = value1 end
				if  #mapIdentifier.regExCompute >= 2 then values[mapIdentifier.regExCompute[2]] = value2 end
				if  #mapIdentifier.regExCompute >= 3 then values[mapIdentifier.regExCompute[3]] = value3 end
			break
			end
		end
	end

	if mapIdentifier.level ~= nil then
		values.level = _fctGetSubValue (values.descList, mapIdentifier.level)
	end

	if mapIdentifier.faction ~= nil then
		values.faction = _fctGetSubValue (values.descList, mapIdentifier.faction)
	end

	if mapIdentifier.name ~= nil then
		values.name = _fctGetSubValue (values.descList, mapIdentifier.name)
	end

	if mapIdentifier.info ~= nil then
		values.info = _fctGetSubValue (values.descList, mapIdentifier.info)
	end

	if _sFind(values.type, "RIFT.INVASION") ~= nil then
		if values.name ~= nil then
			values.type = _fctCheckForColossus (values)
			if (_sFind(values.type, "RIFT.COLOSSUS")) ~= nil then
				local tempName = values.name
				values.name = values.descList[1]
				values.descList[1] = values.name
			end      
		else
			--dump (values)
		end
	end 

	return values

end

local function _fctMapEventRemove (_, info)

  local temp, hasRemoves = {}, false

  for k, v in pairs (info) do
    if _mapPoints[k] ~= nil then
      temp[k] = v
      _mapPoints[k] = nil
      hasRemoves = true
    end
  end
  
  if hasRemoves == true then EnKai.eventHandlers["EnKai.map"]["remove"](temp) end

end

local function _fctMapEventChange (_, info)

  local addList, newlyAdded, counter = {}, 0, 0

  for k, v in pairs (info) do
    counter = counter + 1
    if _mapPoints[k] == nil then
      addList[k] = v
      newlyAdded = newlyAdded+1
    end    
  end
  
  if newlyAdded > 0 then
    internal.mapEvent.add(_, addList)
    
    if newlyAdded == counter then return end
    for k, v in pairs(addList) do info[k] = nil end    
  end
  
  local thisMapData = _InspectMapDetail(info)
  local changeList, removeList = {}, {}
  local descTitleChange, hasChange = false, false
  addList = {}
  
  for key, values in pairs(thisMapData) do
    local point = _mapPoints[key]
    if values.description ~= point.description or values.title ~= point.title then
      local identifiedValues = _fctIdentify(values)
      _mapPoints[key] = identifiedValues
      
      removeList[key] = true
      addList[key] = identifiedValues
      descTitleChange = true
    else
      _mapPoints[key].coordX = thisMapData.coordX
      _mapPoints[key].coordY = thisMapData.coordY
      _mapPoints[key].coordZ = thisMapData.coordZ
            
      changeList[key] = _mapPoints[key]
      
      hasChange = true      
    end
  end
  
  if descTitleChange == true then
    _fctMapEventRemove (_, removeList)
    EnKai.eventHandlers["EnKai.map"]["add"](addList)
  end
  
  if hasChange == true then
    --print ("----------------- change ----------------")
    --dump (changeList)
    EnKai.eventHandlers["EnKai.map"]["change"](changeList)
  end

end

local function _fctMapEventCoord  (_, x, y, z)

  local changeList, addList = {}, {}
  local hasChanges, hasAdd = false, false
  
  for key, xpos in pairs(x) do
    if _mapPoints[key] ~= nil then
      hasChanges = true
      
      _mapPoints[key].coordX = xpos
      _mapPoints[key].coordY = y[key]
      _mapPoints[key].coordZ = z[key]
      
      changeList[key] = _mapPoints[key]
      
    else
      --print ("unknown coord change: " ..key)
    
      hasAdd = true
      addList[key] = true
    end
  end
  
  if hasAdd == true then internal.mapEvent.add (_, addList) end
  if hasChanges == true then EnKai.eventHandlers["EnKai.map"]["coord"](changeList) end

end

local function _fctMapEventUnitCoordChange (_, x, y, z)

  local addUnit, changeUnit = {}, {}
  local hasAdd, hasChange = false, false
  
  for unit, _ in pairs(x) do
    if _mapUnits[unit] == nil then
      addUnit[unit] = {id = unit, type = "UNKNOWN", coordX = x[unit], coordY = y[unit], coordZ = z[unit]}
      _mapUnits[unit] = addUnit[unit]
	  _mapUnits[unit].lastUpdate = oFuncs.oInspectTimeReal()
      hasAdd = true
    else
      if string.find(_mapUnits[unit].type, "group..%.target") == nil then
        changeUnit[unit] = {id = unit, type = _mapUnits[unit].type, coordX = x[unit], coordY = y[unit], coordZ = z[unit]}
        _mapUnits[unit].coordX = x[unit]
        _mapUnits[unit].coordY = y[unit]
        _mapUnits[unit].coordZ = z[unit]
		_mapUnits[unit].lastUpdate = oFuncs.oInspectTimeReal()
        hasChange = true
      end
    end
  end
  
  if hasAdd then EnKai.eventHandlers["EnKai.map"]["unitAdd"](addUnit) end
  if hasChange then EnKai.eventHandlers["EnKai.map"]["unitChange"](changeUnit) end

end

local function _fctMapEventUnitUnavailable (_, info)

  local removeUnit = {}
  local hasRemoves = false
  
  for k, v in pairs (info) do
    if _mapUnits[k] ~= nil then
      removeUnit[k] = _mapUnits[k]
      _mapUnits[k] = nil
      if _wayPoints[k] ~= nil then internal.MapEventWaypoint (_, {[k] = true}) end
      hasRemoves = true
    end
  end 
  
  if hasRemoves == true then EnKai.eventHandlers["EnKai.map"]["unitRemove"](removeUnit) end
  
end

local function _fctMapEventUnitAvailable (_, info)

  local addUnit = {}
  local hasAdds = false
  
  for unit, unitType in pairs (info) do
    if _mapUnits[unit] == nil then
      local details = oFuncs.oInspectUnitDetail(unit)
      addUnit[unit] = {id = unit, type = unitType, coordX = details.coordX, coordY = details.coordY, coordZ = details.coordZ}
      _mapUnits[unit] = addUnit[unit]
	  _mapUnits[unit].lastUpdate = oFuncs.oInspectTimeReal()
      hasAdds = true
    end
  end 
  
  if hasAdds == true then EnKai.eventHandlers["EnKai.map"]["unitAdd"](addUnit) end

end

local function _fctMapEventCombatDeath (_, info)
  
  if data.playerDetails == nil or data.playerDetails.id == nil then return end
  
  if info.target == data.playerDetails.id then
    _playerDeath = true
    local details = oFuncs.oInspectUnitDetail('player')
    local addInfo = {}
    addInfo["pb" .. data.playerDetails.id] = {id = "pb" .. data.playerDetails.id, type = "UNIT.BODY", coordX = details.coordX, coordY = details.coordY, coordZ = details.coordZ}
    EnKai.eventHandlers["EnKai.map"]["add"](addInfo)
  end
  
end

local function _fctMapEventUnitHealth (_, info)
  
  if data.playerDetails == nil or data.playerDetails.id == nil then return end
  if _playerDeath ~= true then return end  
  if info[data.playerDetails.id] == nil or info[data.playerDetails.id] == 0 then return end
  
  _playerDeath = false
  EnKai.eventHandlers["EnKai.map"]["remove"]({["pb" .. data.playerDetails.id] = true})
  
end 

---------- library public function block ---------

function EnKai.map.replaceData (key, data)        mapData.mapData[key] = data     end
function EnKai.map.replaceMapElement (key, data)  mapData.mapElements[key] = data end
function EnKai.map.getAll()                       return _mapPoints, _mapUnits    end
function EnKai.map.addMapElement (key, data)      mapData.mapElements[key] = data end
function EnKai.map.getMapData (id)					return mapData.mapData[id] end

function EnKai.map.GetMapElementbyType (typeString)

	local retTable = {}

	for key, details in pairs(mapData.mapElements) do
		if string.find(key, typeString) == 1 then
			retTable[key] = details
		end
	end
	
	return retTable

end

function EnKai.map.clearAll()
  _mapPoints = {}
  _mapUnits = {}
end

function EnKai.map.refresh()
  
  EnKai.map.clearAll()
  internal.mapEvent.add (_, _InspectMapList())

end

--function EnKai.map.getMapElements ()              return data.mapElements                               end

function EnKai.map.init(flag)

  if flag == true and _mapEvents == false then
    Command.Event.Attach(Event.Map.Add, internal.mapEvent.add, "EnKai.Map.Add")
    Command.Event.Attach(Event.Map.Change, _fctMapEventChange, "EnKai.Map.Change")
    Command.Event.Attach(Event.Map.Remove, _fctMapEventRemove, "EnKai.Map.Remove")
    Command.Event.Attach(Event.Map.Detail.Coord, _fctMapEventCoord, "EnKai.Map.Detail.Coord")
    Command.Event.Attach(Event.Map.Waypoint.Update, internal.MapEventWaypoint, "EnKai.Map.Waypoint.Update")
    Command.Event.Attach(Event.Unit.Detail.Coord, _fctMapEventUnitCoordChange, "EnKai.Map.Unit.Detail.Coord")
    Command.Event.Attach(Event.Unit.Detail.Health, _fctMapEventUnitHealth, "EnKai.Map.Unit.Detail.Health")    
    Command.Event.Attach(Event.Unit.Availability.None, _fctMapEventUnitUnavailable, "EnKai.Map.Unit.Unavailable")
    Command.Event.Attach(Event.Unit.Availability.Full, _fctMapEventUnitAvailable, "EnKai.Map.Unit.Full")
    Command.Event.Attach(Event.Combat.Death, _fctMapEventCombatDeath, "EnKai.Map.Combat.Death")    
  elseif flag == false and _mapEvents == true then
    Command.Event.Detach(Event.Map.Add, nil, "EnKai.Map.Add")
    Command.Event.Detach(Event.Map.Change, nil, "EnKai.Map.Change")
    Command.Event.Detach(Event.Map.Remove, nil, "EnKai.Map.Remove")
    Command.Event.Detach(Event.Map.Detail.Coord, nil, "EnKai.Map.Detail.Coord")
    Command.Event.Detach(Event.Unit.Detail.Health, nil, "EnKai.Map.Unit.Detail.Health")
    Command.Event.Detach(Event.Map.Waypoint.Update, nil, "EnKai.Map.Waypoint.Update")
    Command.Event.Detach(Event.Unit.Detail.Coord, nil, "EnKai.Map.Unit.Detail.Coord")
    Command.Event.Detach(Event.Unit.Availability.None, nil, "EnKai.Map.Unit.Unavailable") 
    Command.Event.Detach(Event.Unit.Availability.Full, nil, "EnKai.Map.Unit.Full")
    Command.Event.Attach(Event.Combat.Death, nil, "EnKai.Map.Combat.Death")
  end
  
  Command.Map.Monitor(flag)
  _mapEvents = flag
  
  if flag == true then internal.mapEvent.add (_, _InspectMapList()) end

end

---------- addon internal function block ---------

function internal.processMap()

	local debugId  
	if nkDebug then debugId = nkDebug.traceStart (oFuncs.oInspectAddonCurrent(), "EnKai internal.processMap") end

	if _mapEvents == false then return end

	if data.playerDetails ~= nil and _wayPoints[data.playerDetails.id] ~= nil then
		internal.MapEventWaypoint (_, {[data.playerDetails.id] = true})
	end

	local curTime = oFuncs.oInspectTimeReal()

	local list = _InspectMapList()

	local hasAdds, hasRemoves = false, false
	local addList, removeList = {}, {}

	for key, v in pairs(list) do
		if _mapPoints[key] == nil then
			addList[key] = v
			hasAdds = true
		end
	end

	for k, v in pairs(_mapPoints) do
		if list[k] == nil then
			removeList[k] = v
			hasRemoves = true
		end
	end

	if hasRemoves then _fctMapEventRemove (_, removeList) end
	if hasAdds then internal.mapEvent.add (_, addList) end

	for k, v in pairs(_mapUnits) do
		if curTime - v.lastUpdate > 1 and string.find(v.type, "UNIT.PLAYER") == nil then
			local details = oFuncs.oInspectUnitDetail(k)
			if details ~= nil then
				_fctMapEventUnitCoordChange(_, {[k] = details.coordX}, {[k] = details.coordY}, {[k] = details.coordZ} )
			end
		end
	end

	if nkDebug then nkDebug.traceEnd (oFuncs.oInspectAddonCurrent(), "EnKai internal.processMap", debugId) end

end

function internal.MapEventWaypoint (_, info)

	local add, removes, change = {}, {}, {}
	local hasAdd, hasRemove, hasChange = false, false, false

	local _wayPointGet = Inspect.Map.Waypoint.Get

	for unit, _ in pairs (info) do
		local flag, x, z = pcall(_wayPointGet, unit)

		if flag == false or x == nil then

			if _wayPoints[unit] ~= nil then
				removes[unit] = true
				hasRemove = true
				_wayPoints[unit] = nil
			end
		else

			if _wayPoints[unit] == nil then
				_wayPoints[unit] = { coordX = x, coordZ = z}
				add[unit] = _wayPoints[unit]
				hasAdd = true
			elseif _wayPoints[unit].coordX ~= x or _wayPoints[unit].coordZ ~= z then
				_wayPoints[unit] = { coordX = x, coordZ = z}
				change[unit] = _wayPoints[unit]
				hasChange = true
			else
				-- another rift api thingy happening if the player creates a way point .. oh well
			end  
		end
	end

	if hasRemove == true then EnKai.eventHandlers["EnKai.waypoint"]["remove"](removes) end
	if hasAdd == true then EnKai.eventHandlers["EnKai.waypoint"]["add"](add) end
	if hasChange == true then EnKai.eventHandlers["EnKai.waypoint"]["change"](change) end
  
end

function internal.mapEvent.add (_, info)

  local thisMapData = _InspectMapDetail(info)
  
  local changeList = {}
  local addList = {}
  local hasAdds, hasChanges = false, false
  
  for key, values in pairs(thisMapData) do
  
    local identifiedValues = _fctIdentify(values)
    
    if _mapPoints[key] ~= nil then
      changeList[key] = identifiedValues
      hasChanges = true
    else
      addList[key] = identifiedValues
	  hasAdds = true
    end

    _mapPoints[key] = identifiedValues
    
  end
  
  if hasAdds then EnKai.eventHandlers["EnKai.map"]["add"](addList) end
  if hasChanges then EnKai.eventHandlers["EnKai.map"]["change"](changeList) end

end