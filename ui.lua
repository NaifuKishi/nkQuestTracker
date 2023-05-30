local addonInfo, privateVars = ...

---------- init namespace ---------

local internal		= privateVars.internal
local uiElements	= privateVars.uiElements
local data			= privateVars.data
local events		= privateVars.events

local oInspectMouse			= Inspect.Mouse
local oInspectSystemSecure	= Inspect.System.Secure

---------- init local variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function internal.buildUI ()

	local name = "nkQuestTrackerUI"
	local scrollPane, content
	
	local ui = EnKai.uiCreateFrame("nkWindowElement", name, uiElements.context)
	
	ui:SetReverseAtBorder(false)
	ui:SetPoint("TOPLEFT", UIParent, "TOPLEFT", nkQuestTrackerSetup.xpos, nkQuestTrackerSetup.ypos)
	ui:SetWidth(nkQuestTrackerSetup.width)
	ui:SetHeight(nkQuestTrackerSetup.height)
	ui:SetBackgroundColor(0, 0, 0, nkQuestTrackerSetup.bgAlpha)
	ui:SetLayer(1)
	ui:SetTitle(addonInfo.name)
	ui:SetTitleColor(1, 1 ,1 ,1)
	ui:SetTitleAlign("right", -30)
	ui:SetCloseable(false)
	ui:ShowMoveToggle(true)
	ui:SetDragable(nkQuestTrackerSetup.moveable)
	ui:SetCollapseable(true)
	ui:SetAutoHideHeader(nkQuestTrackerSetup.autoHide, 2, 30)
	ui:SetFontSize(14)
	
	Command.Event.Attach(EnKai.events[name].HeaderHide, function (_)
	  EnKai.events.addInsecure(
	    function()
	      if uiElements.useUI ~= nil then uiElements.useUI:SetVisible(false) end
    	  ui:getUseItemButton():SetAlpha(0.5)
    	end)
	end, name .. '.HeaderHide')
	
	Command.Event.Attach(EnKai.events[name].HeaderShown, function (_)
		EnKai.events.addInsecure(
			function() ui:getUseItemButton():SetAlpha(1) end
		)
	end, name .. '.HeaderShown')
	 
	Command.Event.Attach(EnKai.events[name].Moved, function (_, xpos, ypos)
		nkQuestTrackerSetup.xpos = xpos
		nkQuestTrackerSetup.ypos = ypos
	end, name .. '.Moved')
	
	Command.Event.Attach(EnKai.events[name].Dragable, function (_, dragable)
		nkQuestTrackerSetup.moveable = dragable
	end, name .. '.Dragable')
	
	local zoneFilterIcon = UI.CreateFrame('Texture', name .. '.zoneFilterIcon', ui:GetHeader())
	zoneFilterIcon:SetPoint("CENTERLEFT", ui:GetHeader(), "CENTERLEFT", 43, 0)
	zoneFilterIcon:SetTextureAsync("nkQuestTracker", "gfx/zoneFilterOff.png");
	zoneFilterIcon:SetWidth(12)
	zoneFilterIcon:SetHeight(12)
	
	zoneFilterIcon:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)
		if data.zoneFilter == true then data.zoneFilter = false else data.zoneFilter = true end
		
		if data.zoneFilter then
			zoneFilterIcon:SetTextureAsync("nkQuestTracker", "gfx/zoneFilterOn.png")
		else
			zoneFilterIcon:SetTextureAsync("nkQuestTracker", "gfx/zoneFilterOff.png")
		end
		
		ui:GetContent():SetVisible(false)
		internal.clearLog( internal.fillLog )
		
	end, name .. ".zoneFilterIcon.Mouse.Left.Down")
	 	
	EnKai.ui.attachGenericTooltip (zoneFilterIcon, "nkQuestTracker", privateVars.langTexts.zoneFilter)

	local missingIcon = UI.CreateFrame('Texture', name .. '.missingIcon', ui:GetHeader())
	missingIcon:SetPoint("CENTERLEFT", zoneFilterIcon, "CENTERRIGHT", 5, 0)
	missingIcon:SetTextureAsync("nkQuestTracker", "gfx/missingIcon.png");
	missingIcon:SetWidth(12)
	missingIcon:SetHeight(12)
	
	missingIcon:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)
		internal.missingList()
	end, name .. ".missingIcon.Mouse.Left.Down")
	
	EnKai.ui.attachGenericTooltip (missingIcon, "nkQuestTracker", privateVars.langTexts.missingList)
	
	local refreshIcon = UI.CreateFrame('Texture', name .. '.refreshIcon', ui:GetHeader())
	refreshIcon:SetPoint("CENTERLEFT", missingIcon, "CENTERRIGHT", 5, 0)
	refreshIcon:SetTextureAsync("nkQuestTracker", "gfx/refreshIcon.png");
	refreshIcon:SetWidth(12)
	refreshIcon:SetHeight(12)
	
	refreshIcon:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)
		internal.clearLog(internal.fillLog)
	end, name .. ".refreshIcon.Mouse.Left.Down")
	
	EnKai.ui.attachGenericTooltip (missingIcon, "nkQuestTracker", privateVars.langTexts.missingList)
		
	-- ********* RESIZE ICON
	
	local resizeIcon = UI.CreateFrame('Texture', name .. '.resizeIcon', ui:GetContent())
	resizeIcon:SetPoint("BOTTOMRIGHT", ui:GetContent(), "BOTTOMRIGHT")
	resizeIcon:SetTextureAsync("nkQuestTracker", "gfx/resizeIcon.png")
	resizeIcon:SetWidth(20)
	resizeIcon:SetHeight(20)
	resizeIcon:SetAlpha(0)
	resizeIcon:SetLayer(2)
	
	resizeIcon:EventAttach(Event.UI.Input.Mouse.Cursor.In, function (self) resizeIcon:SetAlpha(1) end, name .. ".resizeIcon.Mouse.Cursor.In")
	resizeIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function (self) resizeIcon:SetAlpha(0) end, name .. ".resizeIcon.Mouse.Cursor.Out")
	
	resizeIcon:EventAttach(Event.UI.Input.Mouse.Left.Down, function (self)
		self.leftDown = true		
		
		local mouse = oInspectMouse()
		
		self.origX = mouse.x
		self.origY = mouse.y
		self.origWidth = ui:GetWidth()
		self.origHeight= ui:GetHeight()	
	end, name .. ".resizeIcon.Mouse.Left.Down")
	
	resizeIcon:EventAttach(Event.UI.Input.Mouse.Cursor.Move, function (self, _, x, y)	
		if self.leftDown ~= true then return end
		
		local mouse = oInspectMouse()
		
		local newHeight = self.origHeight + (mouse.y - self.origY)
		if newHeight < 100 then newHeight = 100 end
		
		local newWidth = self.origWidth + (mouse.x - self.origX)
		if newWidth < 100 then newWidth = 100 end
		
		ui:SetHeight(newHeight)
		ui:SetWidth(newWidth)
		
		nkQuestTrackerSetup.width = newWidth
		nkQuestTrackerSetup.height = newHeight
		
		scrollPane:SetWidth(ui:GetContent():GetWidth())
		scrollPane:SetHeight(ui:GetContent():GetHeight())

		ui:RecalcDimensions()
	end, name .. ".header.Cursor.Move")
	
	resizeIcon:EventAttach(Event.UI.Input.Mouse.Left.Up, function (self) 
		self.leftDown = false 
	end, name .. ".resizeIcon.Mouse.Left.Up")
	
	resizeIcon:EventAttach(Event.UI.Input.Mouse.Left.Upoutside, function (self) 
		self.leftDown = false
	end, name .. ".resizeIcon.Mouse.Left.UpOutside")
			
	-- ********* SCROLL PANE
			
	scrollPane = EnKai.uiCreateFrame("nkScrollPane", name .. 'scrollPane', ui:GetContent())
	scrollPane:SetPoint("TOPLEFT", ui:GetContent(), "TOPLEFT", -2, 0)
	scrollPane:SetWidth(ui:GetContent():GetWidth())
	scrollPane:SetHeight(ui:GetContent():GetHeight())
	scrollPane:SetColor({r = 0.153, g = 0.314, b = 0.490, a = 1})
	
	scrollPane:SetColorInner({r = 0, g = 0, b = 0, a = 1})
	scrollPane:SetColorHighlight({r = 0.153, g = 0.314, b = 0.490, a = 1})
	scrollPane:SetLayer(1)	
		
	content = UI.CreateFrame("Frame", name .. '.content', scrollPane)
	content:SetWidth(ui:GetContent():GetWidth())
		
	local questCategories = {}
			
	for idx = 1, #nkQuestTrackerSetup.categoryOrder, 1 do
		local thisCategory = internal.questCategory(nkQuestTrackerSetup.categoryOrder[idx], content, ui)
		thisCategory:SetVisible(false)
		thisCategory:SetHeight(0)
		
		if idx == 1 then
			thisCategory:SetPoint("TOPLEFT", content, "TOPLEFT")
		else
			thisCategory:SetPoint("TOPLEFT", questCategories[idx-1], "BOTTOMLEFT")
		end
		
		local categoryName = content:GetName() .. ".questCategory." .. nkQuestTrackerSetup.categoryOrder[idx]
		
		table.insert(questCategories, thisCategory)
	end	
	
	-- ********* QUEST ITEM BUTTON
	
	local useButton = EnKai.uiCreateFrame("nkActionButtonMetro", name .. "questIconButton", uiElements.secureContext)
	useButton:SetScale(.25)
	useButton:SetPoint("CENTERRIGHT", ui:GetHeader(), "CENTERRIGHT", -3, 0)
	useButton:SetSecureMode("restricted")

	local checkAlpha = nil

	useButton:EventAttach(Event.UI.Input.Mouse.Cursor.In, function (self)
		if oInspectSystemSecure() == false then
			checkAlpha = useButton:GetAlpha()
			useButton:SetAlpha(1)
		end
	end, name .. ".resizeIcon.Mouse.Cursor.In")

	useButton:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function (self)
		if oInspectSystemSecure() == false and checkAlpha ~= nil then
			useButton:SetAlpha(checkAlpha)
		end
	end, name .. ".resizeIcon.Mouse.Cursor.Out")

	useButton:EventAttach(Event.UI.Input.Mouse.Right.Down, function (self)
		if oInspectSystemSecure() then return end

		if uiElements.useUI:GetVisible() == true then
			uiElements.useUI:SetVisible(false)
		else
			uiElements.useUI:SetVisible(true)
		end
	end, name .. ".resizeIcon.Mouse.Right.Down")

	function ui:getUseItemButton () return useButton end
	
	---------------------------------------
	----- UI dimension recalculations -----
	
	function ui:RecalcDimensions()
		content:SetWidth(ui:GetContent():GetWidth()	)
    
		for idx = 1, #questCategories, 1 do
			questCategories[idx]:SetWidth(ui:GetContent():GetWidth())
	    end
		
		ui:RecalcHeight()
	end
	
	function ui:RecalcHeight()
		local height = 0
    
		for idx = 1, #questCategories, 1 do
			if questCategories[idx]:GetVisible() == true then
		   	height = height + questCategories[idx]:GetHeight()
			end
		end

		content:SetHeight(height) 

		local value = scrollPane:GetLanePosition()
		scrollPane:SetContent(content)
		if value ~= nil then scrollPane:SetLanePosition(value) end
	end
	
	function content:RecalcHeight()
		ui:RecalcHeight()
	end
	
	---------------------------------------
  ------------ helper methods -----------
	
	function ui:GetCategory(category)
		for k, v in pairs(questCategories) do
			if v:GetCategory() == category then return v end
		end
	end
		
	---------------------------------------
	------------ Quest methods ------------
	
	function ui:AddQuest(key, questCategory, title, objectives, complete, level, zone)
		for k, v in pairs(questCategories) do
			if v:GetCategory() == questCategory then
				v:AddQuest(key, title, objectives, complete, level, zone)
				if nkQuestTrackerSetup.categoryShow[questCategory] == true then
					v:RecalcHeight() 
					v:SetVisible(true)
				else
					v:SetHeight(0)
					v:SetVisible(false)
				end

				ui:RecalcHeight()
				break
			end
		end
	end
	
	function ui:RemoveQuest(key)
		for k, v in pairs(questCategories) do
			if v:HasQuest(key) then 
				v:RemoveQuest(key)
				if v:GetQuestCount() == 0 then
					v:SetHeight(0)
					v:SetVisible(false)
				else
					v:RecalcHeight()
				end
				ui:RecalcHeight()
			end
		end
	end
	
	function ui:UpdateQuest(key, questCategory, title, objectives, complete, level)
		for k, v in pairs(questCategories) do
			if v:GetCategory() == questCategory and v:HasQuest(key) then 
				if v:UpdateQuest(key, title, objectives, complete, level) == false then
					if v:GetVisible() == true then
						v:RecalcHeight()
						ui:RecalcHeight()
					end
				end
			end
		end
	end
	
	-- function ui:CompleteQuest(key) -- vermutlich nicht mehr in Gebrauch
		-- for k, v in pairs(questCategories) do
			-- if v:HasQuest(key) then 
				-- v:CompleteQuest(key)
				-- v:RecalcHeight()
				-- ui:RecalcHeight() 
			-- end
		-- end
	-- end
	
	---------------------------------------
	------------ design update ------------
	
	function ui:UpdateDesign(updateContent)
		for k, v in pairs(questCategories) do
			if nkQuestTrackerSetup.categoryShow[v:GetCategory()] == true and v:GetQuestCount() > 0 then
				v:SetVisible(true)
				v:UpdateDesign(updateContent)
			else
				v:SetHeight(0)
				v:SetVisible(false)
			end
		end
		
		ui:RecalcHeight()
	end

	local oDisplayHeader = ui.DisplayHeader
	function ui:DisplayHeader(flag)
		oDisplayHeader(self, flag)
		EnKai.events.addInsecure( function() useButton:SetVisible(flag) end )
	end
	
	ui:DisplayHeader(nkQuestTrackerSetup.displayHeader)
	
	return ui

end

