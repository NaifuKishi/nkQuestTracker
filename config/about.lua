local addonInfo, privateVars = ...

function nkQuestTracker.ConfigTabAbout (parent)

	local name = 'nkQuestTracker.Config.TabPane.Tab.About'
	
	local about = UI.CreateFrame('Frame', name, parent)
	local addonName
	local version
	local writtenBy
	local copyright
	local help
	local donate1
	local donate2
	local donate3

	function about:build()
	
		addonName	= UI.CreateFrame("Text", name .. ".addonName", about)
		version		= UI.CreateFrame("Text", name .. ".version", about)
		writtenBy	= UI.CreateFrame("Text", name .. ".writteBy", about)
		copyright	= UI.CreateFrame("Text", name .. ".copyright", about)
		help		= UI.CreateFrame("Text", name .. ".help", about)
		donate1		= UI.CreateFrame("Text", name .. ".donate1", about)
		donate2		= UI.CreateFrame("Text", name .. ".donate2", about)
		donate3		= UI.CreateFrame("Text", name .. ".donate3", about)
				
		addonName:SetPoint("TOPCENTER", about, "TOPCENTER", 0, 60)
		addonName:SetText(string.format(privateVars.langTexts.about.addonName, addonInfo.identifier))		
		addonName:SetFontSize(30)
		addonName:SetFontColor(0.906, 0.784, 0.471, 1)
		addonName:SetEffectGlow({ offsetX = 2, offsetY = 2})

		EnKai.ui.setFont(addonName, addonInfo.id, "Montserrat")
		
		version:SetPoint("TOPCENTER", addonName, "BOTTOMCENTER")
		version:SetText(string.format(privateVars.langTexts.about.version, addonInfo.toc.Version))
		version:SetFontSize(18)
		version:SetFontColor(0.906, 0.784, 0.471, 1)
		version:SetEffectGlow({ offsetX = 2, offsetY = 2})

		EnKai.ui.setFont(version, addonInfo.id, "Montserrat")

		writtenBy:SetPoint("TOPCENTER", version, "BOTTOMCENTER", 0, 10)
		writtenBy:SetText(privateVars.langTexts.about.writtenBy)
		writtenBy:SetFontSize(16)
		writtenBy:SetFontColor(1, 1, 1, 1)

		EnKai.ui.setFont(writtenBy, addonInfo.id, "Montserrat")
		
		copyright:SetPoint("TOPCENTER", writtenBy, "BOTTOMCENTER", 0, 10)
		copyright:SetText(privateVars.langTexts.about.copyright)
		copyright:SetFontSize(16)
		copyright:SetFontColor(1, 1, 1, 1)

		EnKai.ui.setFont(copyright, addonInfo.id, "Montserrat")
		
		help:SetPoint("TOPCENTER", copyright, "BOTTOMCENTER", 0, 20)
		help:SetText(privateVars.langTexts.about.help)
		help:SetFontSize(16)
		help:SetFontColor(1, 1, 1, 1)

		EnKai.ui.setFont(help, addonInfo.id, "Montserrat")
				
		donate1:SetPoint("TOPCENTER", help, "BOTTOMCENTER", 0, 20)
		donate1:SetText(privateVars.langTexts.about.donate1)
		donate1:SetFontSize(20)
		donate1:SetFontColor(0.906, 0.784, 0.471, 1)
		donate1:SetEffectGlow({ offsetX = 2, offsetY = 2})

		EnKai.ui.setFont(donate1, addonInfo.id, "Montserrat")
		
		donate2:SetPoint("TOPCENTER", donate1, "BOTTOMCENTER")
		donate2:SetText(privateVars.langTexts.about.donate2)
		donate2:SetFontSize(20)
		donate2:SetFontColor(0.906, 0.784, 0.471, 1)
		donate2:SetEffectGlow({ offsetX = 2, offsetY = 2})

		EnKai.ui.setFont(donate2, addonInfo.id, "Montserrat")
		
		donate3:SetPoint("TOPCENTER", donate2, "BOTTOMCENTER")
		donate3:SetText(privateVars.langTexts.about.donate3)
		donate3:SetFontSize(20)
		donate3:SetFontColor(0.906, 0.784, 0.471, 1)
		donate3:SetEffectGlow({ offsetX = 2, offsetY = 2})

		EnKai.ui.setFont(donate3 addonInfo.id, "Montserrat")
		
	end
	
	return about
	
end