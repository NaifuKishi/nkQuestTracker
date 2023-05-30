local addonInfo, privateVars = ...

---------- init namespace ---------

local internal		= privateVars.internal
local uiElements	= privateVars.uiElements

---------- init local variables ---------

---------- init variables ---------

---------- local function block ---------

---------- addon internal function block ---------

function internal.Config ()

	local name = 'internal.Config'

	local config = EnKai.uiCreateFrame("nkWindowMetro", name, uiElements.configContext)
	local tabPane = EnKai.uiCreateFrame("nkTabPaneMetro", name .. ".tabPane", config:GetContent())

	local paneTabSettings = internal.ConfigTabSettings(tabPane)

	config:SetPoint("CENTER", UIParent, "CENTER")
	config:SetWidth(650)
	config:SetHeight(665) 
	config:SetTitle(addonInfo.toc.Name)
	config:SetCloseable(true)

	local EnKaiLogo = EnKai.uiCreateFrame("nkTexture", name .. ".EnKaiLogo", config)
	EnKaiLogo:SetTextureAsync(EnKai.art.GetThemeLogo()[1],EnKai.art.GetThemeLogo()[2])
	EnKaiLogo:SetPoint("BOTTOMLEFT", config:GetContent(), "BOTTOMLEFT", 10, -5)
	EnKaiLogo:SetWidth(125)
	EnKaiLogo:SetHeight(33)

	tabPane:SetBorder(false)
	tabPane:SetPoint("TOPLEFT", config:GetContent(), "TOPLEFT", 10, 10)
	tabPane:SetPoint("BOTTOMRIGHT", config:GetContent(), "BOTTOMRIGHT", -10, -50)
	tabPane:SetLayer(1)

	tabPane:AddPane( { label = privateVars.langTexts.tabHeaderSettings, frame = paneTabSettings, initFunc = function() paneTabSettings:build() end}, true)

	local closeButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".closeButton", config:GetContent())

	closeButton:SetPoint("BOTTOMRIGHT", config:GetContent(), "BOTTOMRIGHT", -10, -10)
	closeButton:SetText(privateVars.langTexts.btClose)
	closeButton:SetIcon("EnKai", "gfx/icons/close.png")
	closeButton:SetScale(.8)
	closeButton:SetLayer(9)

	Command.Event.Attach(EnKai.events[name .. ".closeButton"].Clicked, function (_, newValue)
		config:SetVisible(false) 
	end, name .. ".closeButton.Clicked")

	local pasteButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".pasteButton", config:GetContent())
	pasteButton:SetPoint("CENTERRIGHT", closeButton, "CENTERLEFT", -5, 0)
	pasteButton:SetText(privateVars.langTexts.btPaste)
	pasteButton:SetIcon("EnKai", "gfx/icons/ok.png")
	pasteButton:SetWidth(200)
	pasteButton:SetScale(.8)  
	pasteButton:SetLayer(9)

	Command.Event.Attach(EnKai.events[name .. ".pasteButton"].Clicked, function (_, newValue)
		nkQuestTrackerSetup = nkQuestTrackerGlobal
		EnKai.ui.messageDialog (privateVars.langTexts.pasteMessage)
	end, name .. ".pasteButton.Clicked")

	local copyButton = EnKai.uiCreateFrame("nkButtonMetro", name .. ".copyButton", config:GetContent())
	copyButton:SetPoint("CENTERRIGHT", pasteButton, "CENTERLEFT", -5, 0)
	copyButton:SetText(privateVars.langTexts.btCopy)
	copyButton:SetIcon("EnKai", "gfx/icons/turnRight.png")
	copyButton:SetLayer(9)
	copyButton:SetWidth(200)
	copyButton:SetScale(.8)

	Command.Event.Attach(EnKai.events[name .. ".copyButton"].Clicked, function (_, newValue)
		nkQuestTrackerGlobal = nkQuestTrackerSetup
		EnKai.ui.messageDialog (privateVars.langTexts.copyMessage)
	end, name .. '.copyButton.Left.Click')
	
	local versionText = EnKai.uiCreateFrame("nkText", name .. ".versionText", config)
	versionText:SetFontSize(11)
	versionText:SetText(string.format(privateVars.langTexts.txtVersion, addonInfo.toc.Version))
	versionText:SetPoint("BOTTOMRIGHT", tabPane, "BOTTOMRIGHT", -5, -5)
	versionText:SetLayer(98)

	config:SetVisible(true)

	return config
	
end