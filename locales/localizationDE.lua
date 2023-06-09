local addonInfo, privateVars = ...

if ( EnKai.tools.lang.getLanguage()  == "German") then
	
	privateVars.langTexts = {
		areaQuestUIHeader		= 'Gebietsquest',
		autoHideCheckbox		= 'Tracker automatisch verstecken',
		questGiver				= 'Questgeber: <font color="#0094FF">%s</font>',
		scene					= 'Questort: <font color="#0094FF">%s</font>',
		colorByLevelCheckbox	= 'Nach Schwierigkeit färben',
		tooManyMissing1			= '%d Quests sind im aktuellen Gebiet noch offen',
		tooManyMissing2			= 'Die Liste wird erst ermittelt, wenn im aktuellen',
		tooManyMissing3			= 'Gebiet weniger als 50 Quests offen sind',
		showLevelCheckbox		= 'Zeige Level',
		showZoneCheckbox		= 'Zeige Gebiet',
		sortBy					= 'Aufbau des Titels',
		sortBySelection			= {{label = "Name - Level - Gebiet", value = "name"}, {label="Level - Gebiet - Name", value = "lvl"}, { label="Gebiet - Level - Name", value = "zone"}},
		txtVersion				= 'Version %s',
		zoneFilter				= "Klicke hier um die Liste auf die aktuelle Zone zu filtern",
		crafting				= "Klicke hier um eine Liste der benötigten Gegenstände für die Täglichen Handwerksquest anzuzeigen",
		missingList				= "Klicke hier um eine Liste der fehlenden Quests in der aktuellen Zone zu erhalten",
		useUseFrameCheckbox		= "Quest Gegenstand UI",
		track					= "Quest verfolgen",
		btCopy					= "Global setzen",
		btPaste					= "Global verwend.",
		copyMessage				= "Die globalen Einstellungen wurden gesetzt.",
		pasteMessage			= "Die globalen Einstellungen wurden geladen. Bitte führen Sie ein /reloadui aus.",
		buttonMenuConfig		= "Konfiguration",
		buttonMenuToggle		= "Anzeigen / Verstecken",
		abandon					= 'Abbrechen',
		share					= 'Teilen',
		abandonQuestConfirm		= 'Bist Du sicher, dass Du den Quest %s abrechen willst?',
		abandonAllQuestsConfirm = 'Bist Du sicher, dass Du Quests der Kategorie %s abrechen willst?',
		labelGenericSettings	= 'Basiseinstellungen',
		showHeaderCheckbox		= 'Titelleiste anzeigen',
		usePluginCheckbox		= 'nkPanel Plugin verwenden',
		useAreaQuestUICheckbox	= 'Gebietsquest UI verwenden',
		labelCategorySettings	= 'Quest Kategorien',
		tabHeaderSettings		= 'Einstellungen',
		tabHeaderAbout			= 'Über',
		btClose					= 'Schliessen',
		btDonate				= 'Spenden',
		alphaSlider				= 'Sichtbarkeit Hintergrund %d%%',
		headerShowCategory		= 'Kategorie anzeigen',
		headerCategoryColor		= 'Farbe',
		headerCategoryTitleSize	= 'Titel',
		headerCategoryBodySize	= 'Text',
		bodyColorLabel			= 'Farbe der offenen Questziele',
		bodyCompleteColorLabel	= 'Farbe der fertigen Questziele',
		completeInfo			= '%s <font color="#FF0000">(fertig)</font>',
		categoryHeaderSize		= 'Grösse Kategorietitel %d',
		abandonAll				= 'Alle abbrechen',
		identifierCarnage		= 'Massaker',
		missingQuests			= 'Fehlende Quests',
		
		showCategoryCheckbox	= {	area = "Gebiet", 
									guild = "Gilde", 
									crafting = "Handwerk", 
									instant = "Instanz",
									carnage = "Massaker", 
									personal = "Normal",
									pvp="PvP", 
									raid = "Schlachtzug",  
									ia = "Sofort-Abenteuer", 
									daily = "Täglich", 
									world = "Welt", 
									weekly = "Wöchentlich", 
									monthly = "Monatlich",
									story	= "Geschichte",
									zone = "Zone"},
	}
end