MarkRoleOptions = {"Tank", "Warlock", "Mage", "Druid", "Skull", "Cross", "Square", "Moon", "Triangle", "Diamond", "Circle", "Star", "Disabled"}

-- Function to capitalize the first letter of each word and after an apostrophe
function toTitleCase(str)
    return str:lower()
end

function formatMobName(mob_name)
    --return mob_name:gsub("[^%w ]", "") 
    return mob_name:lower()
end


-- Initialize your addon namespace
local MyAddon = {}

-- Frame to hold everything
frame_ui_settings = CreateFrame("Frame", "MyAddonFrame", UIParent, "BasicFrameTemplateWithInset")
frame_ui_settings:SetSize(500, 570)  -- Increased width
frame_ui_settings:SetPoint("CENTER")
frame_ui_settings:SetMovable(true)
frame_ui_settings:EnableMouse(true)
frame_ui_settings:RegisterForDrag("LeftButton")
frame_ui_settings:SetScript("OnDragStart", frame_ui_settings.StartMoving)
frame_ui_settings:SetScript("OnDragStop", frame_ui_settings.StopMovingOrSizing)





frame_ui_settings:SetPropagateKeyboardInput(true)  -- Allow the frame to detect keyboard input

frame_ui_settings:SetScript("OnKeyDown", function(self, key)
	if key == "ESCAPE" then
		if self:IsVisible() then
			self:Hide()  -- Hides the frame if it's currently shown
			self:SetPropagateKeyboardInput(false)
		--else
		--	self:Show()  -- Shows the frame if it's hidden
		end
	else
		frame_ui_settings:SetPropagateKeyboardInput(true)  -- Allow the frame to detect keyboard input
	end
end)



-- Export/Import text field

-- Create a container frame for the text field
local containerFrame = CreateFrame("Frame", nil, frame_ui_settings)
containerFrame:SetSize(454, 24)
containerFrame:SetPoint("BOTTOM", frame_ui_settings, "BOTTOM", 0, 40)
containerFrame:SetClipsChildren(true)  -- Enable clipping to cut off overflow

local importExportField = CreateFrame("EditBox", nil, containerFrame, "InputBoxTemplate")
importExportField:SetSize(440, 20)
importExportField:SetPoint("BOTTOM", containerFrame, "BOTTOM", 0, 5)
importExportField:SetMultiLine(true)
importExportField:SetAutoFocus(false)
importExportField:SetFontObject("GameFontHighlight")  -- Set font color to white
importExportField:Hide()


--frame_ui_settings:SetClipsChildren(true)



-- Export button
local exportButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
exportButton:SetSize(100, 25)
exportButton:SetPoint("BOTTOMLEFT", frame_ui_settings, "BOTTOMLEFT", 17, 70)
exportButton:SetText("Export")
exportButton:SetScript("OnClick", function()
	
    local serializedData = ""
    
    for key, value in pairs(MegapandaMarkerDB) do
        serializedData = serializedData .. key .. "," .. tostring(value.priority) .. "," .. value.role[1] .. ";"
    end
    
    importExportField:SetText(serializedData) --
    importExportField:HighlightText()
end)
exportButton:Hide()

-- Import button
local importButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
importButton:SetSize(100, 25)
importButton:SetPoint("BOTTOMLEFT", frame_ui_settings, "BOTTOMLEFT", 120, 70)
importButton:SetText("Import")
importButton:SetScript("OnClick", function()
    local dataString = importExportField:GetText()
    --dataString = dataString:match("^%s*(.-)%s*$") 
    
    -- Validation
    --local pattern = "([^;\s]+),\d+,\d+;"
    --if not string.match(dataString, pattern) then
    --    print("Invalid data format. Please check your input.")
    --    return
    --end
    
    
    MegapandaMarkerDB = {}  -- Clear existing data
    for entry in string.gmatch(dataString, "([^;]+)") do
        local key, priority, role = string.match(entry, "([^,]+),([^,]+),([^,]+)")
        if key and priority and role then
            MegapandaMarkerDB[key] = {priority = tonumber(priority), role = {role}}
        end
    end
    FilterItems()  -- Refresh the displayed list
end)

importButton:Hide()



-- Import button
local defaultButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
defaultButton:SetSize(100, 25)
defaultButton:SetPoint("BOTTOMRIGHT", frame_ui_settings, "BOTTOMRIGHT", -20, 70)
defaultButton:SetText("Default")
defaultButton:SetScript("OnClick", function()
    InitializeMarkers(true)
    FilterItems()
end)
defaultButton:Hide()

local importexportLabel = frame_ui_settings:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
importexportLabel:SetPoint("BOTTOMLEFT", frame_ui_settings, "BOTTOMLEFT", 20, 100)
importexportLabel:SetText("Import / Export")
importexportLabel:Hide()







-- Title text
local title = frame_ui_settings:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOP", frame_ui_settings, "TOP", 0, -4)
title:SetText("MegaPandaMarker")


-- Add Entry Section
local newEntryLabel = frame_ui_settings:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
newEntryLabel:SetPoint("TOPLEFT", frame_ui_settings, "TOPLEFT", 20, -45)
newEntryLabel:SetText("Search")

-- Search box
local searchBox = CreateFrame("EditBox", nil, frame_ui_settings, "InputBoxTemplate")
searchBox:SetSize(300, 20)
searchBox:SetPoint("TOP", title, "BOTTOM", 0, -20)
searchBox:SetAutoFocus(false)


-- Add button to fill new entry key with the target name
local searchFillTargetButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
searchFillTargetButton:SetSize(60, 25)
searchFillTargetButton:SetPoint("LEFT", searchBox, "RIGHT", 6, 0)  -- Position it next to the Add button
searchFillTargetButton:SetText("Target")
searchFillTargetButton:SetScript("OnClick", function()
    local targetName = UnitName("target")  -- Get the name of the current target
    if targetName then
        searchBox:SetText(toTitleCase(targetName))  -- Set the text of newKeyBox to the target name
    else
        --print("No target selected!")  -- Optional feedback if there is no target
    end
end)

-- Scroll frame and scroll bar
local scrollFrame = CreateFrame("ScrollFrame", nil, frame_ui_settings, "UIPanelScrollFrameTemplate")
scrollFrame:SetSize(450, 350)  -- Adjusted width
scrollFrame:SetPoint("TOP", searchBox, "BOTTOM", -10, -10)

local content = CreateFrame("Frame", nil, scrollFrame)
content:SetSize(450, 350)  -- Adjusted width
scrollFrame:SetScrollChild(content)












-- add entry



-- Add Entry Section
local newEntryLabel = frame_ui_settings:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
newEntryLabel:SetPoint("TOPLEFT", scrollFrame, "BOTTOMLEFT", 6, -20)
newEntryLabel:SetText("Add New Entry")

-- Key field for new entry
local newKeyBox = CreateFrame("EditBox", nil, frame_ui_settings, "InputBoxTemplate")
newKeyBox:SetSize(200, 20)
newKeyBox:SetAutoFocus(false)
newKeyBox:SetPoint("TOPLEFT", newEntryLabel, "BOTTOMLEFT", 0, -3)

-- Priority field for new entry
local newPriorityBox = CreateFrame("EditBox", nil, frame_ui_settings, "InputBoxTemplate")
newPriorityBox:SetSize(20, 20)
newPriorityBox:SetAutoFocus(false)
newPriorityBox:SetPoint("LEFT", newKeyBox, "RIGHT", 10, 0)
newPriorityBox:SetNumeric(true)  -- Only allow numbers
newPriorityBox:SetText("1")

-- Role dropdown for new entry
local newRoleDropdown = CreateFrame("Frame", nil, frame_ui_settings, "UIDropDownMenuTemplate")
newRoleDropdown:SetPoint("LEFT", newPriorityBox, "RIGHT", -10, 0)

-- Role options
local roleOptions = MarkRoleOptions --{"Tank", "Warlock", "Mage", "Druid", "Disabled"}
local newSelectedRole = roleOptions[1]  -- Default selection

-- Dropdown initialization
UIDropDownMenu_SetWidth(newRoleDropdown, 70)
UIDropDownMenu_Initialize(newRoleDropdown, function(self, level, menuList)
    for _, role in ipairs(roleOptions) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = role
        info.value = role
        info.func = function(self)
            newSelectedRole = self.value  -- Save selected role for new entry
            UIDropDownMenu_SetSelectedValue(newRoleDropdown, self.value)
        end
        UIDropDownMenu_AddButton(info)
    end
end)
UIDropDownMenu_SetSelectedValue(newRoleDropdown, newSelectedRole)



-- Add button to fill new entry key with the target name
local fillTargetButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
fillTargetButton:SetSize(60, 25)
fillTargetButton:SetPoint("LEFT", newRoleDropdown, "RIGHT", -6, 0)  -- Position it next to the Add button
fillTargetButton:SetText("Target")
fillTargetButton:SetScript("OnClick", function()
    local targetName = UnitName("target")  -- Get the name of the current target
    if targetName then
        newKeyBox:SetText(toTitleCase(targetName))  -- Set the text of newKeyBox to the target name
    else
        --print("No target selected!")  -- Optional feedback if there is no target
    end
end)


-- Add Button to add the new entry
local addButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
addButton:SetSize(50, 25)
addButton:SetPoint("LEFT", fillTargetButton, "RIGHT", 3, 0)
addButton:SetText("Add")
addButton:SetScript("OnClick", function()
    local newKey = newKeyBox:GetText()
    local newPriority = tonumber(newPriorityBox:GetText())

    -- Validate inputs
    if newKey and newPriority then
        
        if newKey == "" then
        	return true
        end
        
        newKeyBox:SetText("")  -- Clear key input
        newPriorityBox:SetText("1")  -- Clear priority input
        
        -- Loop through roleOptions to find the index of the selected role
		for index, role in ipairs(roleOptions) do
		    if role == newSelectedRole then
    	    	intRole = index  -- Set intRole to the index of the matched role
	        	break  -- Exit the loop once we find a match
	    	end
		end

		if intRole == nil then
		    intRole = 1  -- Default to the index of "Default"
		end
        
        
        UIDropDownMenu_SetSelectedValue(newRoleDropdown, roleOptions[1])  -- Reset dropdown to default
        
        MegapandaMarkerDB[formatMobName(toTitleCase(newKey))] = {priority = newPriority, role = {intRole}}
        FilterItems()  -- Refresh the displayed list
    else
        print("Please enter a valid key and priority.")
    end
end)






-----
--Roles


-- Labels and Input fields for Tank, Warlock, Mage, Druid with data from ROLE_LISTS
local labels = MarkRoleOptions --{"Tank", "Warlock", "Mage", "Druid"}
role_fields = {}

for i, label in ipairs(labels) do
	
    -- Create label
    local fieldLabel = frame_ui_settings:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fieldLabel:SetPoint("TOPLEFT", newEntryLabel, "BOTTOMLEFT", (i-1) * 118+3, -33)
    fieldLabel:SetText(label)
    
    -- Create input field
    local inputField = CreateFrame("EditBox", nil, frame_ui_settings, "InputBoxTemplate")
    inputField:SetSize(100, 20)
    inputField:SetPoint("TOPLEFT", fieldLabel, "BOTTOMLEFT", 0, -5)
    inputField:SetAutoFocus(false)

    -- Set the comma-separated values for each role
    local values = table.concat(ROLE_LISTS[i], ",")
    inputField:SetText(values)
    
    inputField:SetScript("OnEditFocusLost", function(self)
        local text = self:GetText():gsub("%s", "")
	    local isValid = string.match(text, "([0-9,]+)") ~= nil -- Adjust regex based on required format
		if not isValid then
			loadRoles()
		end
    end)

    role_fields[i] = inputField  -- Store the field for potential further reference
    
    if i >= 4 then
		break
	end
end

-- Function to set values for existing fields based on ROLE_LISTS
function loadRoles()
    for index, field in ipairs(role_fields) do
        if ROLE_LISTS[index] then
            local values = table.concat(ROLE_LISTS[index], ",")
            field:SetText(values)
        end
    end
end

function saveRoles()
	if validateFields() then
	    for index, field in ipairs(role_fields) do
        	local text = field:GetText()
        	ROLE_LISTS[index] = {strsplit(",", text)} -- Split text by commas and assign to ROLE_LISTS
    	end
    else
    	loadRoles()
    end
end

function validateFields()
    local allValid = true
    for _, field in ipairs(role_fields) do
        local text = field:GetText():gsub("%s", "")
        local isValid = string.match(text, "([0-9,]+)") ~= nil  -- Adjust regex based on required format
		
        if not isValid then
            allValid = false             -- Mark as invalid if any field fails
            break
        end
    end

    return allValid
end










-- Table to hold filtered entries
local filteredEntries = {}

-- Function to update displayed items with editable key-value fields
local function UpdateList()
	loadRoles()
    -- Clear existing entry frames
    for i, entryFrame in ipairs(content.entryFrames or {}) do
        entryFrame:Hide()
    end

    -- Reset entry frames table
    content.entryFrames = {}
    local yOffset = -5

    -- Display each filtered entry
    for i, key in ipairs(filteredEntries) do
        local value = MegapandaMarkerDB[key]

        -- Create new entry frame
        local entryFrame = CreateFrame("Frame", nil, content)
        entryFrame:SetSize(450, 30)  -- Adjusted width
        entryFrame:SetPoint("TOPLEFT", 0, yOffset)

        -- Editable key field
        local keyBox = CreateFrame("EditBox", nil, entryFrame, "InputBoxTemplate")
        keyBox:SetSize(200, 20)
        keyBox:SetAutoFocus(false)
        keyBox:SetText(key)
        keyBox:SetPoint("LEFT", entryFrame, "LEFT", 5, 0)
        entryFrame.keyBox = keyBox

        -- Editable value field (Priority)
        local valueBox = CreateFrame("EditBox", nil, entryFrame, "InputBoxTemplate")
        valueBox:SetSize(30, 20)  -- Reduced width for one-digit priority
        valueBox:SetAutoFocus(false)
        valueBox:SetText(tostring(value.priority))  -- Display the priority
        valueBox:SetPoint("LEFT", keyBox, "RIGHT", 10, 0)
        entryFrame.valueBox = valueBox

        -- Role dropdown
        local roleDropdown = CreateFrame("Frame", nil, entryFrame, "UIDropDownMenuTemplate")
        roleDropdown:SetPoint("LEFT", valueBox, "RIGHT", 10, 0)
        entryFrame.roleDropdown = roleDropdown

        local roleOptions = MarkRoleOptions --{"Tank", "Warlock", "Mage", "Druid", "Disabled"}

        local function OnRoleSelected(selectedRole)
            UIDropDownMenu_SetSelectedValue(roleDropdown, selectedRole)  -- Set selected value
            value.role = selectedRole  -- Save selected role to the NPC entry
        end

        -- Dropdown initialization
        UIDropDownMenu_SetWidth(roleDropdown, 100)
        UIDropDownMenu_Initialize(roleDropdown, function(self, level, menuList)
            for _, role in ipairs(roleOptions) do
                local info = UIDropDownMenu_CreateInfo()
                info.text = role
                info.value = role
                info.func = function(self)
                    OnRoleSelected(self.value)  -- Pass selected role
                end
                UIDropDownMenu_AddButton(info)
            end
        end)

        -- Set the currently selected role, defaulting to "Default" if none exists
        --local currentRole = value.role and value.role[1] or "Default"  -- Assuming role is stored as a table
        --local currentRole = value.role and value.role[1] or 1
        
		local currentRoleIndex = 1  -- Default index if role is not found

		if value.role and value.role[1] then
    		currentRoleIndex = tonumber(value.role[1]) or 1  -- Use 1 as fallback if conversion fails
		end

		-- Ensure currentRoleIndex is within the valid range of roleOptions
		if currentRoleIndex < 1 or currentRoleIndex > #roleOptions then
		    currentRoleIndex = 1  -- Fallback to the default index
		end

		local string_role = roleOptions[currentRoleIndex]

        UIDropDownMenu_SetSelectedValue(roleDropdown, string_role)  -- Set the selected value

        -- Delete button (cross button)
        local deleteButton = CreateFrame("Button", nil, entryFrame, "UIPanelButtonTemplate")
        deleteButton:SetSize(20, 20)
        deleteButton:SetPoint("LEFT", roleDropdown, "RIGHT", 10, 0)
        deleteButton:SetText("X")

        -- Closure to capture the current key for deletion
        deleteButton:SetScript("OnClick", function()
            -- Debug print to see what key is being deleted
            print("Attempting to delete key:", key)

            -- Check if the key exists before deletion
            if MegapandaMarkerDB[key] then
                -- Remove the entry from the database
                MegapandaMarkerDB[key] = nil
                --print("Deleted key:", key) -- Confirmation of deletion
            else
                --print("Key not found:", key) -- Debug message if key doesn't exist
            end

            -- Refresh the filter and update the list
            FilterItems() -- Ensure this is called right after deletion
        end)

        -- Store the entry frame
        content.entryFrames[i] = entryFrame
        entryFrame:Show()

        yOffset = yOffset - 30
    end

    -- Adjust the size of the content frame based on the number of entries
    content:SetHeight(math.max(-yOffset + 5, 0)) -- +5 to keep some padding
end

-- Filter function for search, only showing keys containing the search string
function FilterItems()
    local query = searchBox:GetText():lower() -- Get lowercase search query
    filteredEntries = {}

    -- Populate filteredEntries with keys matching the search query
    for key, _ in pairs(MegapandaMarkerDB) do
        if string.find(key:lower(), query) then
            table.insert(filteredEntries, key)
        end
    end
    
    -- Sort filteredEntries alphabetically
    table.sort(filteredEntries)

    -- Update list with filtered results
    UpdateList()
end

-- Save button to update MegapandaMarkerDB array with edited key-value pairs
local saveButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
saveButton:SetSize(100, 25)
saveButton:SetPoint("BOTTOMRIGHT", frame_ui_settings, "BOTTOMRIGHT", -15, 10)
saveButton:SetText("Save Changes")
saveButton:SetScript("OnClick", function()
	saveRoles()
    for i, key in ipairs(filteredEntries) do
        local keyBox = content.entryFrames[i].keyBox
        local valueBox = content.entryFrames[i].valueBox
        local roleDropdown = content.entryFrames[i].roleDropdown

        -- Get updated key and value
        local newKey = keyBox:GetText()
        local newValue = tonumber(valueBox:GetText())
        local selectedRole = UIDropDownMenu_GetSelectedValue(roleDropdown)
        local roleOptions = MarkRoleOptions --{"Tank", "Warlock", "Mage", "Druid", "Disabled"}
        
        -- Loop through roleOptions to find the index of the selected role
		for index, role in ipairs(roleOptions) do
		    if role == selectedRole then
    	    	intRole = index  -- Set intRole to the index of the matched role
	        	break  -- Exit the loop once we find a match
	    	end
		end

		if intRole == nil then
		    intRole = 1  -- Default to the index of "Default"
		end
        

        -- Only update if newValue is valid
        if newValue then
            -- Update MegapandaMarkerDB by removing the old key and setting the new key-value pair
            MegapandaMarkerDB[key] = nil  -- Remove the old key
            MegapandaMarkerDB[newKey] = {priority = newValue, role = {intRole}}  -- Store role as a table
        end
    end
    FilterItems() -- Refresh the list with saved changes
end)

-- Set up search box to update on text change
searchBox:SetScript("OnTextChanged", function(self)
    FilterItems() -- Call the filter function
end)


-- Event handler for ADDON_LOADED
frame_ui_settings:RegisterEvent("ADDON_LOADED")
local initialized = false
frame_ui_settings:SetScript("OnEvent", function(self, event, addon)
    --if addon == "MegaPandaMarker" then
	    InitializeMarkers()
		FilterItems()
		--frame_ui_settings:Show()
		if not initialized then
			frame_ui_settings:Hide()
		end
		initialized = true
    --end
end)



-- IMPORT EXPORT WINDOW FRAME !!!!




-- Create Import/Export Window
local importExportWindow = CreateFrame("Frame", "ImportExportWindow", UIParent, "BasicFrameTemplateWithInset")
importExportWindow:SetSize(500, 400)
importExportWindow:SetPoint("CENTER")
importExportWindow:SetMovable(true)
importExportWindow:EnableMouse(true)
importExportWindow:RegisterForDrag("LeftButton")
importExportWindow:SetScript("OnDragStart", importExportWindow.StartMoving)
importExportWindow:SetScript("OnDragStop", importExportWindow.StopMovingOrSizing)
importExportWindow:Hide()  -- Start as hidden


-- Create the explanatory text
local explanatoryText = importExportWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
explanatoryText:SetPoint("BOTTOM", importExportWindow, "BOTTOM", 0, 65)
explanatoryText:SetText("Press Ctrl + A and Ctrl + C to copy data to clipboard")

-- Create the explanatory text
local importExportStatusText = importExportWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")

importExportStatusText:SetPoint("BOTTOM", importExportWindow, "BOTTOM", 0, 45)
importExportStatusText:SetText("")


-- Title for Import/Export Window
local importExportTitle = importExportWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
importExportTitle:SetPoint("TOP", importExportWindow, "TOP", 0, -4)
importExportTitle:SetText("Import/Export Data")

-- Create the scroll frame for the text area
local importExportScrollFrame = CreateFrame("ScrollFrame", nil, importExportWindow, "UIPanelScrollFrameTemplate")
importExportScrollFrame:SetSize(440, 260)
importExportScrollFrame:SetPoint("TOP", importExportWindow, "TOP", 0, -40)

-- Create the text area (EditBox)
local importExportTextArea = CreateFrame("EditBox", nil, importExportScrollFrame)
importExportTextArea:SetSize(440, 260)
importExportTextArea:SetMultiLine(true)
importExportTextArea:SetAutoFocus(false)
importExportTextArea:SetFontObject("GameFontHighlight")
importExportTextArea:SetTextInsets(5, 5, 5, 5)  -- Padding for better visual appearance
importExportTextArea:SetMaxLetters(10000)  -- Adjust as needed
importExportTextArea:SetScript("OnEscapePressed", function() importExportWindow:Hide() end)  -- Close on Escape

-- Set the scroll child to the text area
importExportScrollFrame:SetScrollChild(importExportTextArea)

-- Optionally, set the scrollbar visibility and properties
importExportScrollFrame.ScrollBar:SetWidth(16)




-- Function to show the Import/Export window
local function showImportExportWindow()
    importExportWindow:Show()
     importExportStatusText:SetText("")
end

-- Modify existing Export button script to open Import/Export window
local function exportToWindow()
    local serializedData = ""
    for key, value in pairs(MegapandaMarkerDB) do
        serializedData = serializedData .. key .. "," .. tostring(value.priority) .. "," .. value.role[1] .. ";"
    end

    importExportTextArea:SetText(serializedData)
    importExportTextArea:HighlightText()
    --showImportExportWindow()  -- Open the window
end






-- Add button to close the Import/Export window
local exportWindowExportButton = CreateFrame("Button", nil, importExportWindow, "UIPanelButtonTemplate")
exportWindowExportButton:SetSize(80, 25)
exportWindowExportButton:SetPoint("BOTTOM", importExportWindow, "BOTTOM", -200, 10)
exportWindowExportButton:SetText("Export")
exportWindowExportButton:SetScript("OnClick", function()
    exportToWindow()
    importExportStatusText:SetText("Data exported")
end)

-- Add button to close the Import/Export window
local exportWindowImportButton = CreateFrame("Button", nil, importExportWindow, "UIPanelButtonTemplate")
exportWindowImportButton:SetSize(80, 25)
exportWindowImportButton:SetPoint("BOTTOM", importExportWindow, "BOTTOM", 200, 10)
exportWindowImportButton:SetText("Import")
exportWindowImportButton:SetScript("OnClick", function()
    
    
    local dataString = importExportTextArea:GetText()
    --dataString = dataString:match("^%s*(.-)%s*$") 
    
    -- Validation
    --local pattern = "([^;\s]+),\d+,\d+;"
    --if not string.match(dataString, pattern) then
    --    print("Invalid data format. Please check your input.")
    --    return
    --end
    
    
    MegapandaMarkerDB = {}  -- Clear existing data
    for entry in string.gmatch(dataString, "([^;]+)") do
        local key, priority, role = string.match(entry, "([^,]+),([^,]+),([^,]+)")
        if key and priority and role then
            MegapandaMarkerDB[key] = {priority = tonumber(priority), role = {role}}
        end
    end
    FilterItems()  -- Refresh the displayed list
    
    importExportStatusText:SetText("Data Imported successfully")
end)


-- Add button to close the Import/Export window
local exportWindowDefaultButton = CreateFrame("Button", nil, importExportWindow, "UIPanelButtonTemplate")
exportWindowDefaultButton:SetSize(120, 25)
exportWindowDefaultButton:SetPoint("BOTTOM", importExportWindow, "BOTTOM", 0, 10)
exportWindowDefaultButton:SetText("Restore Defaults")
exportWindowDefaultButton:SetScript("OnClick", function()
    InitializeMarkers(true)
    FilterItems()
    exportToWindow()
    importExportStatusText:SetText("All data restored to default")
end)


-- Modify existing Import button script to process input and close the window
importButton:SetScript("OnClick", function()
    local dataString = importExportTextArea:GetText()
    MegapandaMarkerDB = {}  -- Clear existing data
    for entry in string.gmatch(dataString, "([^;]+)") do
        local key, priority, role = string.match(entry, "([^,]+),([^,]+),([^,]+)")
        if key and priority and role then
            MegapandaMarkerDB[key] = {priority = tonumber(priority), role = {role}}
        end
    end
    FilterItems()  -- Refresh the displayed list
    importExportWindow:Hide()  -- Close the window after import
end)

-- Import button to show the Import/Export window
local importWindowButton = CreateFrame("Button", nil, frame_ui_settings, "UIPanelButtonTemplate")
importWindowButton:SetSize(120, 25)
importWindowButton:SetPoint("BOTTOMLEFT", frame_ui_settings, "BOTTOMLEFT", 15, 10)
importWindowButton:SetText("Import/Export")
importWindowButton:SetScript("OnClick", function()
    showImportExportWindow()
    exportToWindow()
end)













































