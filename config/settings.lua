local addonInfo, privateVars = ...

---------- init namespace ---------

local internal		= privateVars.internal
local uiElements	= privateVars.uiElements

---------- init local variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function internal.ConfigTabSettings (parent)

	local name = 'internal.Config.TabPane.TabSettings'

	local tabPane = UI.CreateFrame ("Frame", name, parent)
	local labelGeneric, showHeaderCheckbox, autoHideCheckbox, alphaSlider, bodyColor, bodyCompleteColor, categoryHeaderSize
	local usePluginCheckbox, headerShowCategory, headerCategoryColor, headerCategoryTitleSize, headerCategoryBodySize, labelCategories
	local useUseFrameCheckbox, showLevelCheckbox, showZoneCheckbox, sortBySelect, colorByLevelCheckbox, useAreaQuestUICheckbox

	function tabPane:build ()
	
		labelGeneric = EnKai.uiCreateFrame("nkText", name .. '.labelGeneric', tabPane)
		labelGeneric:SetPoint("TOPLEFT", tabPane, "TOPLEFT")
		labelGeneric:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelGeneric:SetText(privateVars.langTexts.labelGenericSettings)
		labelGeneric:SetFontSize(16)

		
		showHeaderCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'showHeaderCheckbox', tabPane)	
		showHeaderCheckbox:SetPoint("TOPLEFT", labelGeneric, "BOTTOMLEFT", 0, 10)
		showHeaderCheckbox:SetLabelWidth(185)
		showHeaderCheckbox:SetText(privateVars.langTexts.showHeaderCheckbox)
		showHeaderCheckbox:SetChecked(nkQuestTrackerSetup.displayHeader)
		showHeaderCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[name .. 'showHeaderCheckbox'].CheckboxChanged, function (_, newValue)		
			nkQuestTrackerSetup.displayHeader = newValue			
			uiElements.questLog:DisplayHeader(newValue)
			if uiElements.areaQuestUI ~= nil then uiElements.areaQuestUI:DisplayHeader(newValue) end
		end, name .. 'showHeaderCheckbox' ..".CheckboxChanged")
		
		autoHideCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'autoHideCheckbox', tabPane) 
		autoHideCheckbox:SetPoint("TOPLEFT", showHeaderCheckbox, "BOTTOMLEFT", 0, 10)
		autoHideCheckbox:SetLabelWidth(185)
		autoHideCheckbox:SetText(privateVars.langTexts.autoHideCheckbox)
		autoHideCheckbox:SetChecked(nkQuestTrackerSetup.autoHide)
		autoHideCheckbox:SetLabelInFront(true)

		Command.Event.Attach(EnKai.events[name .. 'autoHideCheckbox'].CheckboxChanged, function (_, newValue)   
			nkQuestTrackerSetup.autoHide = newValue
			uiElements.questLog:SetAutoHideHeader(newValue, 2, 30)      
		end, name .. 'autoHideCheckbox' ..".CheckboxChanged")
		
		alphaSlider = EnKai.uiCreateFrame("nkSlider", name .. 'alphaSlider', tabPane)
		alphaSlider:SetPoint("TOPLEFT", autoHideCheckbox, "BOTTOMLEFT", 0, 9)
		alphaSlider:SetWidth(300)
		alphaSlider:SetRange(1, 100)
		alphaSlider:SetLabelWidth(190)
		alphaSlider:SetText(privateVars.langTexts.alphaSlider)
		alphaSlider:SetPrecision(0.1)
		alphaSlider:AdjustValue(nkQuestTrackerSetup.bgAlpha * 100)
		
		Command.Event.Attach(EnKai.events[name .. 'alphaSlider'].SliderChanged, function (_, newValue)
			nkQuestTrackerSetup.bgAlpha = newValue / 100
			uiElements.questLog:SetBackgroundColor(0, 0, 0, newValue / 100)
			uiElements.useUI:SetBackgroundColor(0, 0, 0, newValue / 100)
		end, name .. 'alphaSlider' .. ".SliderChanged")
		
		bodyColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.bodyColorPicker', tabPane)
		bodyColor:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", 0, 8)
		bodyColor:SetText(privateVars.langTexts.bodyColorLabel)
		bodyColor:SetWidth(205)
		bodyColor:SetHeight(15)
		bodyColor:SetColor(nkQuestTrackerSetup.bodyColor[1], nkQuestTrackerSetup.bodyColor[2], nkQuestTrackerSetup.bodyColor[3], 1)
		
		Command.Event.Attach(EnKai.events[name .. '.bodyColorPicker'].ColorChanged, function (_, r, g, b, a)
			nkQuestTrackerSetup.bodyColor = { r, g, b}
			uiElements.questLog:UpdateDesign(true)
		end, name .. ".bodyColorPicker.ColorChanged")
		
		bodyCompleteColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.bodyCompleteColorPicker', tabPane)
		bodyCompleteColor:SetPoint("TOPLEFT", bodyColor, "BOTTOMLEFT", 0, 8)
		bodyCompleteColor:SetText(privateVars.langTexts.bodyCompleteColorLabel)
		bodyCompleteColor:SetWidth(205)
		bodyCompleteColor:SetHeight(15)
		bodyCompleteColor:SetLayer(2)
		bodyCompleteColor:SetColor(nkQuestTrackerSetup.bodyCompleteColor[1], nkQuestTrackerSetup.bodyCompleteColor[2], nkQuestTrackerSetup.bodyCompleteColor[3], 1)
		
		Command.Event.Attach(EnKai.events[name .. '.bodyCompleteColorPicker'].ColorChanged, function (_, r, g, b, a)
			nkQuestTrackerSetup.bodyCompleteColor = { r, g, b}
			uiElements.questLog:UpdateDesign(true)
		end, name .. ".bodyCompleteColorPicker.ColorChanged")
		
		categoryHeaderSize = EnKai.uiCreateFrame("nkSlider", name .. 'categoryHeaderSize', tabPane)	
		categoryHeaderSize:SetPoint("TOPLEFT", bodyCompleteColor, "BOTTOMLEFT", 0, 10)
		categoryHeaderSize:SetWidth(300)
		categoryHeaderSize:SetRange(1, 24)
		categoryHeaderSize:SetLabelWidth(190)
		categoryHeaderSize:SetText(privateVars.langTexts.categoryHeaderSize)
		categoryHeaderSize:SetPrecision(1)
		categoryHeaderSize:AdjustValue(nkQuestTrackerSetup.categoryHeaderSize)
		categoryHeaderSize:SetLayer(1)
		
		Command.Event.Attach(EnKai.events[name .. 'categoryHeaderSize'].SliderChanged, function (_, newValue)
			nkQuestTrackerSetup.categoryHeaderSize = newValue
			uiElements.questLog:UpdateDesign()
		end, name .. 'categoryHeaderSize.SliderChanged')
		
		sortBySelect = EnKai.uiCreateFrame("nkCombobox", name .. "sortBySelect", tabPane)
		sortBySelect:SetPoint("TOPLEFT", categoryHeaderSize, "BOTTOMLEFT", 0, 6)
		sortBySelect:SetLayer(9)
		sortBySelect:SetWidth(350)
		sortBySelect:SetLabelWidth(190)
		sortBySelect:SetSelection(privateVars.langTexts.sortBySelection)
		sortBySelect:SetSelectedValue(nkQuestTrackerSetup.sortBy, false)
		sortBySelect:SetText(privateVars.langTexts.sortBy)
    		
		Command.Event.Attach(EnKai.events[name .. "sortBySelect"].ComboChanged, function (_, newValue)
			nkQuestTrackerSetup.sortBy = newValue.value
			internal.clearLog(internal.fillLog)
		end, name .. "sortBySelect.ComboChanged")
				
		useAreaQuestUICheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'useAreaQuestUICheckbox', tabPane)
		useAreaQuestUICheckbox:SetPoint("CENTERLEFT", showHeaderCheckbox, "CENTERRIGHT", 175, 0)
		useAreaQuestUICheckbox:SetLabelWidth(190)
		useAreaQuestUICheckbox:SetText(privateVars.langTexts.useAreaQuestUICheckbox)
		useAreaQuestUICheckbox:SetChecked(nkQuestTrackerSetup.useareaquestui)
		useAreaQuestUICheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[name .. 'useAreaQuestUICheckbox'].CheckboxChanged, function (_, newValue)
			nkQuestTrackerSetup.useareaquestui = newValue
			if newValue == true then
				if uiElements.areaQuestUI ~= nil then 
					uiElements.areaQuestUI:SetVisible(true) 
				else
					uiElements.areaQuestUI = internal.buildAreaQuestUI()
				end
			else
				if uiElements.areaQuestUI ~= nil then uiElements.areaQuestUI:SetVisible(false) end
			end
			
		end, name .. 'useAreaQuestUICheckbox' ..".CheckboxChanged")
		
		usePluginCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'usePluginCheckbox', tabPane)	
		usePluginCheckbox:SetPoint("TOPLEFT", useAreaQuestUICheckbox, "BOTTOMLEFT", 0, 10)
		usePluginCheckbox:SetLabelWidth(190)
		usePluginCheckbox:SetText(privateVars.langTexts.usePluginCheckbox)
		usePluginCheckbox:SetChecked(nkQuestTrackerSetup.nkPanel)
		usePluginCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[name .. 'usePluginCheckbox'].CheckboxChanged, function (_, newValue)
			nkQuestTrackerSetup.nkPanel = newValue
			if nkPanel ~= nil then
				if uiElements.panel ~= nil then
					if nkPanel.api.togglePanel ~= nil then -- nkPanel V1.1.1 check, can be removed later
						nkPanel.api.togglePanel('nkQuestTracker', newValue)
					end
				elseif newValue == true then
					local items = {
						{ label = privateVars.langTexts.buttonMenuConfig, callBack = function () internal.ShowConfig() end},
					}

					uiElements.panel = internal.nkPanelPlugin(items)
					nkPanel.api.registerPlugin('nkQuestTracker', uiElements.panel)
				end
			end
		end, name .. 'usePluginCheckbox' ..".CheckboxChanged")
		
		colorByLevelCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'colorByLevelCheckbox', tabPane)
		colorByLevelCheckbox:SetPoint("TOPLEFT", usePluginCheckbox, "BOTTOMLEFT", 0, 10)
		colorByLevelCheckbox:SetLabelWidth(190)
		colorByLevelCheckbox:SetText(privateVars.langTexts.colorByLevelCheckbox)
		colorByLevelCheckbox:SetChecked(nkQuestTrackerSetup.colorByLevel)
		colorByLevelCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[name .. 'colorByLevelCheckbox'].CheckboxChanged, function (_, newValue)
			nkQuestTrackerSetup.colorByLevel = newValue
			internal.clearLog(internal.fillLog)
		end, name .. 'colorByLevelCheckbox' ..".CheckboxChanged")
		
		showLevelCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'showLevelCheckbox', tabPane)	
		showLevelCheckbox:SetPoint("TOPLEFT", colorByLevelCheckbox, "BOTTOMLEFT", 0, 10)
		showLevelCheckbox:SetLabelWidth(190)
		showLevelCheckbox:SetText(privateVars.langTexts.showLevelCheckbox)
		showLevelCheckbox:SetChecked(nkQuestTrackerSetup.showLevel)
		showLevelCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[name .. 'showLevelCheckbox'].CheckboxChanged, function (_, newValue)
			nkQuestTrackerSetup.showLevel = newValue
			internal.clearLog(internal.fillLog)
		end, name .. 'showLevelCheckbox' ..".CheckboxChanged")
		
		showZoneCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'showZoneCheckbox', tabPane)
		showZoneCheckbox:SetPoint("TOPLEFT", showLevelCheckbox, "BOTTOMLEFT", 0, 10)
		showZoneCheckbox:SetLabelWidth(190)
		showZoneCheckbox:SetText(privateVars.langTexts.showZoneCheckbox)
		showZoneCheckbox:SetChecked(nkQuestTrackerSetup.showZone)
		showZoneCheckbox:SetLabelInFront(true)
		
		Command.Event.Attach(EnKai.events[name .. 'showZoneCheckbox'].CheckboxChanged, function (_, newValue)
			nkQuestTrackerSetup.showZone = newValue
			internal.clearLog(internal.fillLog)
		end, name .. 'showZoneCheckbox' ..".CheckboxChanged")
	
		labelCategories = EnKai.uiCreateFrame("nkText", name .. '.labelCategories', tabPane)
		labelCategories:SetPoint("TOPLEFT", sortBySelect, "BOTTOMLEFT", 0, 15)
		labelCategories:SetEffectGlow({ offsetX = 2, offsetY = 2})
		labelCategories:SetText(privateVars.langTexts.labelCategorySettings)
		labelCategories:SetFontSize(16)
		
		headerShowCategory = EnKai.uiCreateFrame("nkText", name ..'.headerShowCateogry', tabPane)
		headerShowCategory:SetPoint("TOPLEFT", labelCategories, "BOTTOMLEFT", 0, 5)
		headerShowCategory:SetText(privateVars.langTexts.headerShowCategory)
		headerShowCategory:SetFontSize(13)
		headerShowCategory:SetWidth(200)
				
		headerCategoryColor = EnKai.uiCreateFrame("nkText", name ..'.headerCategoryColor', tabPane)
		headerCategoryColor:SetPoint("CENTERLEFT", headerShowCategory, "CENTERRIGHT", 10, 0)
		headerCategoryColor:SetText(privateVars.langTexts.headerCategoryColor)
		headerCategoryColor:SetFontSize(13)
		headerCategoryColor:SetWidth(50)
		
		headerCategoryTitleSize = EnKai.uiCreateFrame("nkText", name ..'.headerCategoryTitleSize', tabPane)
		headerCategoryTitleSize:SetPoint("CENTERLEFT", headerCategoryColor, "CENTERRIGHT", 10, 0)
		headerCategoryTitleSize:SetText(privateVars.langTexts.headerCategoryTitleSize)
		headerCategoryTitleSize:SetFontSize(13)
		headerCategoryTitleSize:SetWidth(100)
		
		headerCategoryBodySize = EnKai.uiCreateFrame("nkText", name ..'.headerCategoryBodySize', tabPane)
		headerCategoryBodySize:SetPoint("CENTERLEFT", headerCategoryTitleSize, "CENTERRIGHT", 10, 0)
		headerCategoryBodySize:SetText(privateVars.langTexts.headerCategoryBodySize)
		headerCategoryBodySize:SetFontSize(13)
				
		local anchor, x, y = headerShowCategory, 0, 5
		
		for k, v in pairs(nkQuestTrackerSetup.categoryOrder) do
			
			local showCategoryCheckbox = EnKai.uiCreateFrame("nkCheckbox", name .. 'showCategoryCheckbox.' .. v, tabPane)	
			showCategoryCheckbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", x, y)
			showCategoryCheckbox:SetWidth(200)
			
			showCategoryCheckbox:SetText(privateVars.langTexts.showCategoryCheckbox[v])
			showCategoryCheckbox:SetChecked(nkQuestTrackerSetup.categoryShow[v])
			showCategoryCheckbox:SetLabelInFront(true)
			showCategoryCheckbox:SetLayer(1)
			
			anchor, x, y = showCategoryCheckbox, 0, 5
			
			Command.Event.Attach(EnKai.events[name .. 'showCategoryCheckbox.' .. v].CheckboxChanged, function (_, newValue)
				nkQuestTrackerSetup.categoryShow[v] = newValue
				uiElements.questLog:UpdateDesign(false)
			end, name .. 'showCategoryCheckbox.' .. v ..".CheckboxChanged")
			
			local categoryColor = EnKai.uiCreateFrame("nkColorPicker", name .. '.colorPicker.' .. v, tabPane)
			categoryColor:SetPoint("CENTERLEFT", showCategoryCheckbox, "CENTERRIGHT", 20, 0)
			categoryColor:SetWidth(15)
			categoryColor:SetHeight(15)
			categoryColor:SetColor(nkQuestTrackerSetup.categoryColor[v][1], nkQuestTrackerSetup.categoryColor[v][2], nkQuestTrackerSetup.categoryColor[v][3], 1)
			categoryColor:SetLayer(2)
			
			Command.Event.Attach(EnKai.events[name .. '.colorPicker.' .. v].ColorChanged, function (_, r, g, b, a)
				nkQuestTrackerSetup.categoryColor[v] = { r, g, b}
				uiElements.questLog:UpdateDesign(true)
			end, name .. '.colorPicker.' .. v ..".ColorChanged")
			
			local categorySize = EnKai.uiCreateFrame("nkSlider", name .. 'categorySize.' .. v, tabPane)	
			categorySize:SetPoint("CENTERLEFT", categoryColor, "CENTERRIGHT", 20, 0)
			categorySize:SetWidth(100)
			categorySize:SetRange(1, 24)
			categorySize:SetLabelWidth(25)
			categorySize:SetText("%d")
			categorySize:SetPrecision(1)
			categorySize:AdjustValue(nkQuestTrackerSetup.categoryFontSize[v].header)
			categorySize:SetLayer(1)
			
			Command.Event.Attach(EnKai.events[name .. 'categorySize.' .. v].SliderChanged, function (_, newValue)
				nkQuestTrackerSetup.categoryFontSize[v].header = newValue
				uiElements.questLog:UpdateDesign(true)
			end, name .. 'categorySize.' .. v .. ".SliderChanged")
			
			local categoryBodySize = EnKai.uiCreateFrame("nkSlider", name .. 'categoryBodySize.' .. v, tabPane)	
			categoryBodySize:SetPoint("CENTERLEFT", categorySize, "CENTERRIGHT", 10, 0)
			categoryBodySize:SetWidth(100)
			categoryBodySize:SetRange(1, 24)
			categoryBodySize:SetLabelWidth(25)
			categoryBodySize:SetText("%d")
			categoryBodySize:SetPrecision(1)
			categoryBodySize:AdjustValue(nkQuestTrackerSetup.categoryFontSize[v].body)
			categoryBodySize:SetLayer(1)
			
			Command.Event.Attach(EnKai.events[name .. 'categoryBodySize.' .. v].SliderChanged, function (_, newValue)
				nkQuestTrackerSetup.categoryFontSize[v].body = newValue
				uiElements.questLog:UpdateDesign(true)
			end, name .. 'categoryBodySize.' .. v .. ".SliderChanged")
			
			
		end
	
	end
	
	return tabPane
	
end