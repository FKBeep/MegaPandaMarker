


DEBUG_MODE = false
function debugPrint(str) 
	if DEBUG_MODE then
		if str == nil then
			print("Value is nil!")
			return true
		end
		print("MegaPandaMarker: " .. str)
	end
end

function formatMobName(mob_name)
    --return mob_name:gsub("[^%w ]", "") 
    return mob_name:lower()
end


local frame = CreateFrame("Frame")



-- Array to hold current marker assignments for each marker (index 1 to 8)
local markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}  -- Initialize with nil

-- Variable to track if clear mode is active
local clearMarksToggle = false

local markingDisabled = true

function printPanda()

end



local function ClearRaidMarkerWithRetry(retryCount, delay)
    C_Timer.After(delay, function()
        local currentMarker = GetRaidTargetIndex("player")
        if currentMarker ~= 0 then
            --print("Clearing marker attempt. Current marker: " .. (currentMarker or "none"))
            SetRaidTarget("player", 0) -- Attempt to clear the marker

            -- Retry if the marker is not cleared
            if retryCount > 0 then
                ClearRaidMarkerWithRetry(retryCount - 1, 0.1) -- Retry with a delay
            else
                --print("Final attempt to clear marker failed.")
            end
        else
            --print("Marker cleared successfully.")
        end
    end)
end

local function SetRaidMarkersSequentially(mark_index, delay)
    if mark_index > 0 then
        C_Timer.After(delay, function()
            SetRaidTarget("player", mark_index) -- Set the current raid marker
            --print("raidmark set: " .. mark_index)
            SetRaidMarkersSequentially(mark_index - 1, delay) -- Chain the next marker
        end)
    else
        -- Clear the marker after all are set
        C_Timer.After(delay, function()
            --print("Attempting to clear raid marker...")
            ClearRaidMarkerWithRetry(3, delay) -- 3 retries with a delay of 0.2 seconds between attempts
        end)
    end
end

local function ClearAllMarksWithDelay()
    --print("Starting raid marker sequence...")
    SetRaidMarkersSequentially(8, 0.01) -- Start the chain
end


local function setMark(index, target_name, guid, is_extra)
	markerAssignments[tonumber(index)] = {guid = guid, name = target_name}
    SetRaidTarget("mouseover", 9 - index)  -- Mark the target
end


-- Function to find the next available marker index using a for loop
local function FindNextAvailableIndex(guid, tname, npc_data)
	local current_name = tname
	--local npc_data = MegapandaMarkerDB[current_name]
	local current_prio = npc_data.priority
	local current_role = tonumber(npc_data.role[1])

	if current_role > 12 then
		return nil
	end 

	if current_role > 4 then
		return {index = current_role-4};
	end 
	
	local current_sequence = ROLE_LISTS[current_role]
	
	--local current_sequence = ROLE_LISTS[current_role]
	if current_sequence and #current_sequence > 0 then
		local loop_index = 1		
	    for _, index in ipairs(current_sequence) do
		    local assigned_entry = markerAssignments[tonumber(index)]
		    		    
		    if assigned_entry == nil then
		    	debugPrint("ASSIGNED ENTRY IS NIL")
	            return {index = index}  -- Return the first empty slot
	        end    
	        	        
	        local assigned_prio = 100
	        local assigned_role = 1
	        
	        local db_entry = formatMobName(assigned_entry.name)
	        
	        if MegapandaMarkerDB[db_entry] then
	            assigned_prio = MegapandaMarkerDB[db_entry].priority
	            assigned_role = tonumber(MegapandaMarkerDB[db_entry].role[1])
	            
	            if assigned_entry.override_role ~= nil then
				    assigned_role = tonumber(assigned_entry.override_role)
				end
    	    end
		
			if assigned_role == current_role then
				if current_prio < assigned_prio then
	        		return {index = index}
    	    	end
        	elseif assigned_role < current_role then
        		return {index = index}
        	end
        	
        	-- If no mark found for this role try if empty mark in markerAssignments
        	if loop_index == #current_sequence then
        		for i = 1, 8 do
				    local v = markerAssignments[i]
				    if v == nil then
				        return {index = i, override_role = 1}
				    end
				end
        	end
        	
        	loop_index = loop_index + 1
        end
    end
    return nil  -- Return nil if no empty slot is found
end


local function clearNilMarks()
--    for index = 1, 8 do
 --       local assignment = markerAssignments[index]
--
--        if assignment then
--            local guid = assignment.guid
--
            -- Check if the GUID is a valid target
--            if isValidTarget(guid) then
 --               markerAssignments[index] = nil
--                print("Cleared marker assignment for GUID:", guid)
--            else
--                print("GUID is not a valid target:", guid)
--            end
--        end
--    end
end

-- Function to mark the mouseover target based on priority

local raidMarkers = {
        [1] = "STAR",
        [2] = "CIRCLE",
        [3] = "DIAMOND",
        [4] = "TRIANGLE",
        [5] = "MOON",
        [6] = "SQUARE",
        [7] = "CROSS",
        [8] = "SKULL",
}

local last_mark_id = -1

local function MarkMouseoverTarget()
    if UnitExists("mouseover") and not UnitIsDead("mouseover") then
        local target_name = UnitName("mouseover")
        local guid = UnitGUID("mouseover")
        local current_mark = GetRaidTargetIndex("mouseover")
        
        if current_mark == nil then
	        if last_mark_id ~= guid then
	        
		        -- reaply if last marking of this guid failed
	        	for i = 1, 8 do
				    local mark = markerAssignments[i]
				    if mark ~= nil then
				        if mark.guid == guid then			        		
			        		if GetTime() - mark.last_check > 0.1 then
				        		--print("Removed empty cash mark.. " .. raidMarkers[i])
			        			SetRaidTarget("mouseover", 9 - i)
			        			mark.last_check = GetTime()
			        		end
			        		return nil
			        	end
			    	end
				end
	        
        		debugPrint("MarkMouseoverTarget:: No mark found")
        		local tdata = MegapandaMarkerDB[formatMobName(target_name)]
        		if tdata then
        			clearNilMarks()
        			local next_mark = FindNextAvailableIndex(guid, target_name, tdata)
        			
        			if next_mark ~= nil then
        				--debugPrint("Marking: " .. next_mark)
        				local entry = {guid = guid, name = target_name, last_check = GetTime() }
        				if next_mark.override_role ~= nil then
        					entry.override_role = tonumber(next_mark.override_role)
        				end
        				markerAssignments[tonumber(next_mark.index)] = entry
        				SetRaidTarget("mouseover", 9 - next_mark.index)  -- Mark the target
        			
        			end
        		end
        	end
        else 
        	-- Correct markerAssignments if put wrong place
	        for mi = 1, 8 do
			    local m = markerAssignments[mi]
			    if mi == tonumber(9 - current_mark) then
			    	if m ~= nil then
			       		if m.guid ~= guid then
			        		markerAssignments[mi] = {guid = guid, name = target_name, last_check = GetTime() }
			        	end
        			else
	        			markerAssignments[mi] = {guid = guid, name = target_name, last_check = GetTime() }
    				end
			   	else
			   		if m ~= nil then
			       		if m.guid == guid then
			        		markerAssignments[mi] = nil
			        	end
    				end
			   	end
			end
        end
        
        last_mark_id = guid
    end
end


local last_clear_id = -1
-- Function to clear all marks from the mouseover target
local function UnMark()
    if UnitExists("mouseover") and not UnitIsDead("mouseover") then
        local mouseoverName = UnitName("mouseover")
        local guid = UnitGUID("mouseover")
        local current_mark = GetRaidTargetIndex("mouseover")
        
		if current_mark then
			if last_clear_id ~= guid then
				SetRaidTarget("mouseover", 0) 
				debugPrint("Cleaing mark")
			
	        	for index = 1, 8 do  -- Loop from 1 to 8
    	    		if markerAssignments[index] then
		           		if markerAssignments[index].guid == guid then
                			markerAssignments[index] = nil  -- Reset the assignment for this NPC
            		    	break
        		    	end
    		        end
		        end
	        end
		end 
		
		last_clear_id = guid
    end
end


-- Set up OnUpdate to continuously check the mouseover target
frame:SetScript("OnUpdate", function(self, elapsed)
	if not markingDisabled then
   		if clearMarksToggle then
       		UnMark()  -- If in clear mode, clear the marks
    	else
        	MarkMouseoverTarget()  -- Otherwise, mark the target
    	end
    end
end)




-- Register the slash command
SLASH_MPM1 = "/mpm"

-- Define the slash command handler function
SlashCmdList["MPM"] = function(msg)
    local command, subCommand = msg:match("^(%S*)%s*(.-)$")

    -- Convert command to lowercase for case-insensitive matching
    command = command:lower()

    -- Handle subcommands
    if command == "help" then
        MPM_ShowHelp()
    elseif command == "show" then
        pandaWindow:Show()
        MegapandaVisible = true
    elseif command == "hide" then
        pandaWindow:Hide()
        MegapandaVisible = false
    elseif command == "unmark" then
        MPM_Unmark()
    elseif command == "mark" then
        MPM_SetMarks(subCommand)  -- Pass additional arguments to set marks
    elseif command == "enable" then
        MPM_Enable()
    elseif command == "stop" then
        MPM_Disable()
    elseif command == "setting" then
        frame_ui_settings:Show()
    elseif command == "clear" then
        MPM_Clear()
    else
        MPM_ShowHelp()
    end
end

-- Define the functions for each subcommand

-- Help function
function MPM_ShowHelp()
    
    
    if markingDisabled then
	    debugPrint("Status: Not marking")
	end
	
	if not markingDisabled then
		if clearMarksToggle then
       		debugPrint("Status: Clearing marks")
    	else
        	debugPrint("Status: Marking!")
    	end
	end
	
    print("(o.O) MegaPandaMarker commands:")
	print("/mpm - Displays this help message")
	print("/mpm mark - Marks targets (mode)")
	print("/mpm unmark - Removes marks (mode)")
	print("/mpm clear - Removes all marks immediately")
	print("/mpm stop - Stops marking or unmarking")
	print("/mpm show - Displays the mini-bar")
	print("/mpm hide - Hides the mini-bar")
	print("/mpm setting - Opens the settings window")
end

-- Clear function
function MPM_Unmark()
	ActivateUnmarkingMode()
end

-- Clear function
function MPM_Clear()
	ClearAllMarksNow()
end

-- SetMarks function
function MPM_SetMarks(args)
	ActivateMarkingMode()
end

-- Disable function
function MPM_Disable()
	DeactivateCurrentMode()
end



-- COMBATLOG

local combatframe = CreateFrame("Frame")
--combatframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
combatframe:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

combatframe:SetScript("OnEvent", function(self, event)
    local _, subEvent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, spellId, spellName = CombatLogGetCurrentEventInfo()

    if subEvent == "UNIT_DIED" then
        debugPrint("Mob died:", destName, "GUID:", destGUID)
        -- You can add your custom logic here for when a mob dies
        
        for index = 1, 8 do
            local assignment = markerAssignments[index]
            
            if assignment and assignment.guid == destGUID then
                markerAssignments[index] = nil
                debugPrint("Cleared marker assignment for GUID:", destGUID)
            end
        end
        
    end
end)

-- UI -------
-- Frame to hold everything
pandaWindow = CreateFrame("Frame", "PandaWindow", UIParent, "BackdropTemplate")
pandaWindow:SetSize(200, 40)
pandaWindow:SetPoint("CENTER")
pandaWindow:SetMovable(true)
pandaWindow:EnableMouse(true)
pandaWindow:RegisterForDrag("LeftButton")
pandaWindow:SetScript("OnDragStart", pandaWindow.StartMoving)
pandaWindow:SetScript("OnDragStop", pandaWindow.StopMovingOrSizing)
pandaWindow:SetClipsChildren(true)  -- This clips the children of the window to its boundaries


local show_sub_menu = false;
pandaWindow:SetScript("OnMouseUp", function()
	show_sub_menu = not show_sub_menu
    if show_sub_menu == true then
    	pandaWindow:SetSize(200, 80)
    else
    	pandaWindow:SetSize(200, 40)
    end
end)


for i = 1, 8 do
    local sub_button = CreateFrame("Button", nil, pandaWindow)
    sub_button:SetSize(22, 22)  -- Size of the button
    sub_button:SetPoint("CENTER", pandaWindow, "TOPLEFT", 21 + (i - 1) * 23, -57)  -- Adjust x position for each button
    sub_button:SetNormalTexture("Interface\\TARGETINGFRAME\\UI-RaidTargetingIcon_" .. (9-i))
    sub_button:SetAlpha(0.5)  -- Set transparency
    
    sub_button:SetScript("OnClick", function()
        	local name = UnitName("target")
	        local guid = UnitGUID("target")
	
	        if name and guid then
		        local current_mark = GetRaidTargetIndex("target")
		        if current_mark == nil then
		        	markerAssignments[i] = {guid = guid, name = name, last_check = GetTime() }
		        else
		        	if current_mark == i then
		        		markerAssignments[i] = nil
		        	else
		        		if markerAssignments[9 - current_mark] ~= nil then
		        			if markerAssignments[9 - current_mark].guid == guid then
			        			markerAssignments[9 - current_mark] = nil
			        		end
		        		end
		        		markerAssignments[i] = {guid = guid, name = name, last_check = GetTime() }
		        	end
		        end
	            SetRaidTarget("target", 9-i)  -- Set raid target on the target with the corresponding mark (i)
			end
    end)
end




-- Define and set a black background with 50% transparency
pandaWindow:SetBackdrop({
    bgFile = "Interface/ChatFrame/ChatFrameBackground",
})
pandaWindow:SetBackdropColor(0, 0, 0, 0.5)



local logo = pandaWindow:CreateTexture(nil, "OVERLAY")  -- Changed to OVERLAY
logo:SetTexture("Interface\\AddOns\\MegaPandaMarker\\logo.png")
logo:SetSize(35, 35)
logo:SetPoint("TOPLEFT", pandaWindow, "TOPLEFT", 10, -3)


-- === Utility: Create a styled icon button ===
local function CreateIconButton(parent, xOffset, texture)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(30, 30)
    btn:SetPoint("CENTER", parent, "TOPRIGHT", xOffset, -20)
    btn:SetNormalTexture(texture)
    btn:SetAlpha(0.5)
    btn:EnableMouse(true)
    return btn
end

-- === Create UI Buttons ===
markToggleButton   = CreateIconButton(pandaWindow, -127, "Interface\\AddOns\\MegaPandaMarker\\mark.png")
unmarkToggleButton = CreateIconButton(pandaWindow, -92,  "Interface\\AddOns\\MegaPandaMarker\\unmark.png")
clearButton        = CreateIconButton(pandaWindow, -57,  "Interface\\Icons\\Spell_Shadow_Teleport")
local settingsButton = CreateIconButton(pandaWindow, -22, "Interface\\Icons\\Inv_misc_gear_01")

-- === State Tracking ===
local currentActiveButton = nil
isMarkingModeActive = false
isUnmarkingModeActive = false
isSettingsOpen = false

-- === Shared state reset ===
local function ResetAllModes()
    isMarkingModeActive = false
    isUnmarkingModeActive = false
    isSettingsOpen = false
    markingDisabled = true
    clearMarksToggle = false

    markToggleButton:SetAlpha(0.5)
    unmarkToggleButton:SetAlpha(0.5)
    clearButton:SetAlpha(0.5)
end

local function ResetLastIDs()
    last_mark_id = -1
    last_clear_id = -1
end

-- === Public Functions ===

function ActivateMarkingMode()
    ResetAllModes()
    ResetLastIDs()

    isMarkingModeActive = true
    markingDisabled = false
    markToggleButton:SetAlpha(1)
    currentActiveButton = markToggleButton

    debugPrint("(o.O) MegaPandaMarker: Marking enabled. Mouseover and mark!")
end

function ActivateUnmarkingMode()
    ResetAllModes()
    ResetLastIDs()

    isUnmarkingModeActive = true
    clearMarksToggle = true
    markingDisabled = false
    unmarkToggleButton:SetAlpha(1)
    currentActiveButton = unmarkToggleButton

    debugPrint("(o.O) MegaPandaMarker: Clearing enabled. Mouseover to clear marks!")
end

function DeactivateCurrentMode()
    ResetAllModes()
    ResetLastIDs()

    currentActiveButton = nil
    debugPrint("(o.O) MegaPandaMarker: All modes deactivated.")
end

function ClearAllMarksNow()
    ResetLastIDs()
    markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
    ClearAllMarksWithDelay()

    clearButton:SetAlpha(1)
    C_Timer.After(0.1, function()
        clearButton:SetAlpha(0.5)
    end)
end

function OpenSettings()
    settingsButton:SetAlpha(1)
    C_Timer.After(0.1, function()
        settingsButton:SetAlpha(0.5)
    end)
    frame_ui_settings:Show()
end

-- === Button Bindings ===

markToggleButton:SetScript("OnClick", function()
    if currentActiveButton == markToggleButton then
        DeactivateCurrentMode()
    else
        ActivateMarkingMode()
    end
end)

unmarkToggleButton:SetScript("OnClick", function()
    if currentActiveButton == unmarkToggleButton then
        DeactivateCurrentMode()
    else
        ActivateUnmarkingMode()
    end
end)

clearButton:SetScript("OnMouseDown", function()
    clearButton:SetAlpha(1)
end)

clearButton:SetScript("OnMouseUp", ClearAllMarksNow)

settingsButton:SetScript("OnMouseDown", function()
    settingsButton:SetAlpha(1)
end)

settingsButton:SetScript("OnMouseUp", OpenSettings)

-- === Event Handler for ADDON_LOADED ===
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "MegaPandaMarker" then
        InitializeMarkers()

        print(MegapandaVisible)

        if MegapandaVisible == nil then
            MegapandaVisible = true
        end

        if MegapandaVisible then
            pandaWindow:Show()
        else
            pandaWindow:Hide()
        end

        print('(o.O) MegaPandaMarker 1.0 addOn loaded. Write /mpm to show help')
    end
end)

-- === Optional: Reset State On Spell Cast or Zone Change ===
pandaWindow:SetScript("OnEvent", function(self, event, unit, _, spellID)
    if spellID and spellID ~= 8690 then return end -- Ignore non-relevant spells

    last_mark_id = -1
    last_clear_id = -1

    markToggleButton:SetAlpha(0.5)
    unmarkToggleButton:SetAlpha(0.5)
    clearButton:SetAlpha(0.5)

    isMarkingModeActive = false
    isUnmarkingModeActive = false
    isSettingsOpen = false
    currentActiveButton = nil

    markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
    markingDisabled = true
    clearMarksToggle = false
end)




