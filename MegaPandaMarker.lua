


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
        MPM_Clear()
    elseif command == "mark" then
        MPM_SetMarks(subCommand)  -- Pass additional arguments to set marks
    elseif command == "enable" then
        MPM_Enable()
    elseif command == "stop" then
        MPM_Disable()
    elseif command == "setting" then
        frame_ui_settings:Show()
    elseif command == "clear" then
        MPM_Wipe()
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
function MPM_Clear()
	last_mark_id = -1
	last_clear_id = -1
	
	markToggleButton:SetAlpha(0.5)
    unmarkToggleButton:SetAlpha(1)
    clearButton:SetAlpha(0.5)
    button2_enabled = true
	button1_enabled = false
	button4_enabled = false
	activeButton = unmarkToggleButton

	--markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
	markingDisabled = false
    debugPrint("(o.O) MegaPandaMarker: Clearing enabled. Mouseover to clear marks!")
    clearMarksToggle = true
    -- Add your clearing logic here
end

-- Clear function
function MPM_Wipe()
	last_mark_id = -1
	last_clear_id = -1
	
	markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
	ClearAllMarksWithDelay()
end

-- SetMarks function
function MPM_SetMarks(args)
	last_mark_id = -1
	last_clear_id = -1
	
	markToggleButton:SetAlpha(1)
    unmarkToggleButton:SetAlpha(0.5)
    clearButton:SetAlpha(0.5)
    button2_enabled = false
	button1_enabled = true
	button4_enabled = false
	activeButton = markToggleButton

	markingDisabled = false
	clearMarksToggle = false
    debugPrint("(o.O) MegaPandaMarker: Marking enabled. Mouseover and mark!")
    -- Add your logic to set marks here
end

-- Disable function
function MPM_Disable()
	markToggleButton:SetAlpha(0.5)
    unmarkToggleButton:SetAlpha(0.5)
    clearButton:SetAlpha(0.5)
    button2_enabled = false
	button1_enabled = false
	button4_enabled = false
	activeButton = nil

	markingDisabled = true
    debugPrint("(o.O) MegaPandaMarker: Marking disabled!")
    -- Add disable logic here
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


-- Create the marker icon button
markToggleButton = CreateFrame("Button", nil, pandaWindow)
markToggleButton:SetSize(30, 30)
markToggleButton:SetPoint("CENTER", pandaWindow, "TOPRIGHT", -127, -20)
markToggleButton:SetNormalTexture("Interface\\AddOns\\MegaPandaMarker\\mark.png")
markToggleButton:SetAlpha(0.5)

-- Create the unmarking icon button
unmarkToggleButton = CreateFrame("Button", nil, pandaWindow)
unmarkToggleButton:SetSize(30, 30)
unmarkToggleButton:SetPoint("CENTER", pandaWindow, "TOPRIGHT", -92, -20)
unmarkToggleButton:SetNormalTexture("Interface\\AddOns\\MegaPandaMarker\\unmark.png")
unmarkToggleButton:SetAlpha(0.5)


-- Create the clear icon button
clearButton = CreateFrame("Button", nil, pandaWindow)
clearButton:SetSize(30, 30)
clearButton:SetPoint("CENTER", pandaWindow, "TOPRIGHT", -57, -20)
clearButton:SetNormalTexture("Interface\\Icons\\Spell_Shadow_Teleport")
clearButton:SetAlpha(0.5)

-- Create the settings icon button
local settingsButton = CreateFrame("Button", nil, pandaWindow)
settingsButton:SetSize(30, 30)
settingsButton:SetPoint("CENTER", pandaWindow, "TOPRIGHT", -22, -20)
settingsButton:SetNormalTexture("Interface\\Icons\\Inv_misc_gear_01")
settingsButton:SetAlpha(0.5)

-- Variable to track the active button
local activeButton = nil

-- Function to handle button click and update active state
local function handleButtonClick(button)
    if activeButton ~= button then
        activeButton = button
        markToggleButton:SetAlpha(button == markToggleButton and 1 or 0.5)
        unmarkToggleButton:SetAlpha(button == unmarkToggleButton and 1 or 0.5)
        clearButton:SetAlpha(button == clearButton and 1 or 0.5)
        --settingsButton:SetAlpha(button == settingsButton and 1 or 0.5)
        debugPrint(button == markToggleButton and "Button 1 activated!" or button == unmarkToggleButton and "Button 2 activated!" or "Button 3 activated!")
    else
        activeButton = nil
        button:SetAlpha(0.5)
        debugPrint(button == markToggleButton and "Button 1 deactivated!" or button == unmarkToggleButton and "Button 2 deactivated!" or "Button 3 deactivated!")
    end
end

button1_enabled = false
button2_enabled = false
button4_enabled = false

-- Set click events for marker button
markToggleButton:SetScript("OnClick", function() handleButtonClick(markToggleButton) 
	last_mark_id = -1
	last_clear_id = -1
	
	button1_enabled = not button1_enabled
	button2_enabled = false;
	button4_enabled = false
	
	if button1_enabled then
		markingDisabled = false
		clearMarksToggle = false
   		debugPrint("(o.O) MegaPandaMarker: Marking enabled. Mouseover and mark!")
   		markToggleButton:SetAlpha(1)
	else
		clearMarksToggle = false
		markingDisabled = true
		markToggleButton:SetAlpha(0.5)
	end
end)


unmarkToggleButton:SetScript("OnClick", function() handleButtonClick(unmarkToggleButton) 
	last_mark_id = -1
	last_clear_id = -1
	
	
	button2_enabled = not button2_enabled
	button1_enabled = false
	button4_enabled = false
	if button2_enabled then
		--markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
		markingDisabled = false
    	debugPrint("(o.O) MegaPandaMarker: Clearing enabled. Mouseover to clear marks!")
    	clearMarksToggle = true
    	unmarkToggleButton:SetAlpha(1)
	else
		clearMarksToggle = false
		markingDisabled = true
		unmarkToggleButton:SetAlpha(0.5)
	end
end)



-- Button 3 specific functionality for highlight on press and reset on release
clearButton:SetScript("OnMouseDown", function()
    clearButton:SetAlpha(1)  -- Highlight to full alpha when pressed
end)

clearButton:SetScript("OnMouseUp", function()
    clearButton:SetAlpha(0.5)  -- Reset to 50% alpha when released
    
    last_mark_id = -1
	last_clear_id = -1
	
	markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
	ClearAllMarksWithDelay()
end)

-- Button 3 specific functionality for highlight on press and reset on release
settingsButton:SetScript("OnMouseDown", function()
    settingsButton:SetAlpha(1)  -- Highlight to full alpha when pressed
end)
settingsButton:SetScript("OnMouseUp", function()
    settingsButton:SetAlpha(0.5)  -- Reset to 50% alpha when released
    --handleButtonClick(settingsButton)
    frame_ui_settings:Show()
end)

-- Enable mouse clicks on all buttons
markToggleButton:EnableMouse(true)
unmarkToggleButton:EnableMouse(true)
settingsButton:EnableMouse(true)



-- Event handler for ADDON_LOADED
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
    if addon == "MegaPandaMarker" then
    	InitializeMarkers()
    	
    	print (MegapandaVisible)
    	
    	if MegapandaVisible == nil then
			MegapandaVisible = true
		end
		
		if MegapandaVisible then
			pandaWindow:Show()  -- Ensure the window is shown
		else 
			pandaWindow:Hide()
		end
    	
		print('(o.O) MegaPandaMarker 1.0 addOn loaded. Write /mpm to show help')
    end
end)


--pandaWindow:RegisterEvent("PLAYER_ENTERING_WORLD")
--pandaWindow:RegisterEvent("ZONE_CHANGED_NEW_AREA")
--pandaWindow:RegisterEvent("ZONE_CHANGED")
--pandaWindow:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

pandaWindow:SetScript("OnEvent",  function(self, event, unit, _, spellID)

    if spellID and spellID ~= 8690 then -- Example spellID check, like Hearthstone
        return
    end
		
    last_mark_id = -1
	last_clear_id = -1
	
	markToggleButton:SetAlpha(0.5)
    unmarkToggleButton:SetAlpha(0.5)
    clearButton:SetAlpha(0.5)
    button2_enabled = false
	button1_enabled = false
	button4_enabled = false
	activeButton = nil

	markerAssignments = {nil, nil, nil, nil, nil, nil, nil, nil}
	markingDisabled = true
    clearMarksToggle = false
end)



