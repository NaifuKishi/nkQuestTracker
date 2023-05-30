local addonInfo, privateVars = ...

---------- init namespace ---------

local internal		= privateVars.internal
local uiElements	= privateVars.uiElements

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function internal.nkPanelPlugin (menuItems)

	local plugin = nkPanel.api.plugin('nkQuestTracker', true, false)

	plugin:SetTitle('nkQuestTrackerPlugin')
	plugin:SetSecureMode('restricted')
	
	plugin:SetThumb('nkQuestTracker', 'gfx/nkPanelIcon.png')

	local body = plugin:CreateBody()
	
	local menu = EnKai.uiCreateFrame("nkMenu", 'nkQuestTracker.panelMenu', body)
		
	menu:SetFontSize(13)
	menu:SetWidth(120)
	menu:SetBackgroundColor(0, 0, 0, 0)
	menu:SetLabelColor(1, 1, 1, 1)
	menu:SetBorderColor(0, 0, 0, 0)
	menu:SetPoint("TOPLEFT", body, "TOPLEFT", 2, 2)
	
	local items = {}
	local subMenus
	
	for k, v in pairs(menuItems) do
		if v.seperator == true then
			menu:AddSeparator()
		elseif v.callBack ~= nil then
			menu:AddEntry({ closeOnClick = true, label = v.label, macro = v.macro, callBack = function() v.callBack() end })
		else
			menu:AddEntry({ closeOnClick = true, label = v.label, macro = v.macro, callBack = nil })
		end
	end
	
	body:SetHeight(menu:GetHeight()+4)
	body:SetWidth(menu:GetWidth()+4)
	
	function plugin:UpdateTitle()
		local text = ""
	
		for k, v in pairs(nkQuestTrackerSetup.categoryOrder) do
			local category = uiElements.questLog:GetCategory(v)
			if category ~= nil and category:GetVisible() == true then
				if text ~= "" then text = text .. "/" end
				local color = nkQuestTrackerSetup.categoryColor[v]
				local hexColor = EnKai.tools.color.RGBToHex(color[1] * 255, color[2] * 255, color[3] * 255)
				text = string.format ("%s<font color='#%s'>%s</font>", text, hexColor, category:GetQuestCount())
			end
		end
		
		plugin:SetTitle(text)
	end
	
	function plugin:GetMenu() return menu end
	function plugin:GetBody() return body end
	
	return plugin

end