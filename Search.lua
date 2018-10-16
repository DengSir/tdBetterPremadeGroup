-- Search.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/12/2018, 12:24:16 PM

local ns          = select(2, ...)
local Addon       = ns.Addon
local Filter      = ns.Filter
local GUI         = ns.GUI
local SortType    = ns.SortType
local WIDTH       = ns.WIDTH
local ITEM_HEIGHT = 22

local Search = Addon:NewModule('Search', 'AceHook-3.0', 'AceEvent-3.0')

function Search:OnEnable()
    self.headers     = {}
    self.sets        = self.profile.search
    self.SearchPanel = LFGListFrame.SearchPanel

    self:InitUI()
    self:InitHook()
end

function Search:InitUI()
    local ScrollFrame  = self.SearchPanel.ScrollFrame
    local ResultsInset = self.SearchPanel.ResultsInset
    local FilterButton = self.SearchPanel.FilterButton

    ScrollFrame.buttons[1]:SetHeight(ITEM_HEIGHT)
    HybridScrollFrame_CreateButtons(ScrollFrame, 'LFGListSearchEntryTemplate')

    for _, button in ipairs(ScrollFrame.buttons) do
        self:AddRegionWidth(button)

        button:SetHeight(ITEM_HEIGHT)

        button.Name:ClearAllPoints()
        button.Name:SetPoint('LEFT', 10, 0)
        button.Name:SetFontObject('GameFontNormalSmallLeft')

        button.ActivityName:ClearAllPoints()
        button.ActivityName:SetPoint('LEFT', 185, 0)

        button.ItemLevel = button:CreateFontString(nil, 'ARTWORK', 'GameFontDisableSmall')
        button.ItemLevel:SetPoint('LEFT', 360, 0)
        button.ItemLevel:SetWidth(60)
    end

    local headers = {
        {
            text  = LFG_LIST_TITLE,
            width = 170
        },
        {
            text     = LFG_LIST_ACTIVITY,
            width    = 170,
            sortType = SortType.Activity
        },
        {
            text     = ITEM_LEVEL_ABBR,
            width    = 60,
            sortType = SortType.ItemLevel
        }
    }

    local function HeaderOnClick(header)
        if not header.sortType then
            return
        end

        if self.sets.sortType == header.sortType then
            self.sets.sortDesc = not self.sets.sortDesc
        else
            self.sets.sortType = header.sortType
            self.sets.sortDesc = false
        end

        self:UpdateHeaders()
        self:UpdateResults()
    end

    ResultsInset:SetPoint('TOPLEFT', -1, -105)

    for i, v in ipairs(headers) do
        local header = CreateFrame('Button', nil, ResultsInset, 'LFGListColumnHeaderTemplate')

        if i == 1 then
            header:SetPoint('BOTTOMLEFT', ResultsInset, 'TOPLEFT', 5, 0)
        else
            header:SetPoint('LEFT', self.headers[i-1], 'RIGHT', 0, 0)
        end

        if v.sortType then
            header.Arrow = header:CreateTexture(nil, 'OVERLAY')
            header.Arrow:Hide()
            header.Arrow:SetTexture([[Interface\Buttons\UI-SortArrow]])
            header.Arrow:SetSize(9, 8)
            header.Arrow:SetPoint('RIGHT', -5, 0)
        else
            header:Disable()
        end

        header.sortType = v.sortType
        header:SetText(v.text)
        header:SetWidth(v.width + 5)
        header:SetScript('OnClick', HeaderOnClick)
        table.insert(self.headers, header)
    end

    local CategoryButton = CreateFrame('Button', nil, self.SearchPanel) do
        CategoryButton:SetPoint('RIGHT', self.SearchPanel.CategoryName, 'LEFT', 0, 0)
        CategoryButton:SetSize(32, 32)
        CategoryButton:SetNormalTexture([[Interface\Buttons\UI-SquareButton-Up]])
        CategoryButton:SetPushedTexture([[Interface\Buttons\UI-SquareButton-Down]])
        CategoryButton:SetDisabledTexture([[Interface\Buttons\UI-SquareButton-Disabled]])
        CategoryButton:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], 'ADD')
        CategoryButton:SetScript('OnClick', function(CategoryButton)
            PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
            self:ToggleCategroyDropdown(CategoryButton)
        end)
        CategoryButton:SetScript('OnMouseDown', self.SearchPanel.RefreshButton:GetScript('OnMouseDown'))
        CategoryButton:SetScript('OnMouseUp', self.SearchPanel.RefreshButton:GetScript('OnMouseUp'))

        local Icon = CategoryButton:CreateTexture(nil, 'OVERLAY') do
            Icon:SetPoint('CENTER', -1, 0)
            Icon:SetSize(16, 16)
            Icon:SetTexture([[Interface\Buttons\Arrow-Down-Down]])
            Icon:SetTexCoord(0, 1, 0, 0.7)
        end

        CategoryButton.Icon = Icon

        self:MoveRegionX(self.SearchPanel.CategoryName, 28)
        self:AddRegionWidth(self.SearchPanel.CategoryName, WIDTH - 28)
    end
    -- self.CategoryButton = CategoryButton

    FilterButton:SetScript('OnClick', function(FilterButton)
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        Filter:TogglePanel()
    end)
end

local function optvalue(value)
    if type(value) == 'function' then
        return value()
    end
    return value
end

function Search:CreateCategoryInfo(id, baseFilters, filters)
    return {
        checkable = true,
        text = LFGListUtil_GetDecoratedCategoryName(C_LFGList.GetCategoryInfo(id), filters),
        checked = function()
            return  id == self.SearchPanel.categoryID and
                    filters == self.SearchPanel.filters and
                    optvalue(baseFilters) == self.SearchPanel.preferredFilters
        end,
        func = function()
            local baseFilters = optvalue(baseFilters)
            LFGListFrame.baseFilters = baseFilters
            LFGListSearchPanel_SetCategory(self.SearchPanel, id, filters, baseFilters)
            LFGListSearchPanel_DoSearch(self.SearchPanel)

            if baseFilters == LE_LFG_LIST_FILTER_PVE then
                PVEFrame_ShowFrame('GroupFinderFrame', 'LFGListPVEStub')
            else
                PVEFrame_ShowFrame('PVPUIFrame', 'LFGListPVPStub')
            end
        end
    }
end

function Search:GetAvailableCategories()
    if not self.categoryMenuList then
        local categories = {}
        local foundCustom = false

        local function ScanBaseFilter(baseFilters)
            for _, id in ipairs(C_LFGList.GetAvailableCategories(baseFilters)) do
                if id == 6 then
                    foundCustom = 6
                else
                    local name, separateRecommended = C_LFGList.GetCategoryInfo(id)
                    if separateRecommended then
                        table.insert(categories, self:CreateCategoryInfo(id, baseFilters, LE_LFG_LIST_FILTER_RECOMMENDED))
                        table.insert(categories, self:CreateCategoryInfo(id, baseFilters, LE_LFG_LIST_FILTER_NOT_RECOMMENDED))
                    else
                        table.insert(categories, self:CreateCategoryInfo(id, baseFilters, 0))
                    end
                end
            end
        end

        ScanBaseFilter(LE_LFG_LIST_FILTER_PVE)
        ScanBaseFilter(LE_LFG_LIST_FILTER_PVP)

        if foundCustom then
            table.insert(categories, self:CreateCategoryInfo(6, function() return LFGListFrame.baseFilters end, 0))
        end

        self.categoryMenuList = categories
    end
    return self.categoryMenuList
end

function Search:InitHook()
    self:RegisterEvent('LFG_LIST_AVAILABILITY_UPDATE')
    self:SecureHook('LFGListSearchEntry_Update')
    self:SecureHook('LFGListUtil_SortSearchResults')
    self.SearchPanel:HookScript('OnShow', function()
        self:OnSearchPanelShow()
    end)
end

function Search:LFG_LIST_AVAILABILITY_UPDATE()
    self.categoryMenuList = nil
end

function Search:OnSearchPanelShow()
    self:UpdateHeaders()

    local SearchBox = self.SearchPanel.SearchBox
    local FilterButton = self.SearchPanel.FilterButton

    self:AddRegionWidth(SearchBox, WIDTH - FilterButton:GetWidth())

    SearchBox:ClearAllPoints()
    SearchBox:SetParent(self.SearchPanel)
    SearchBox:SetPoint('TOPLEFT', self.SearchPanel.CategoryName, 'BOTTOMLEFT', 4 - 28, -7)

    FilterButton:Show()
end

function Search:LFGListSearchEntry_Update(button)
    local _, activityId, _, _, voiceChat, itemLevel,
          _, _, _, _, _, isDelisted = C_LFGList.GetSearchResultInfo(button.resultID)
    local isPvp = select(11, C_LFGList.GetActivityInfo(activityId))
    local playerItemLevel = select(isPvp and 3 or 1, GetAverageItemLevel())

    local color
    local text

    if itemLevel and itemLevel > 0 then
        text = floor(itemLevel)
    else
        text = ''
    end

    if isDelisted then
        color = LFG_LIST_DELISTED_FONT_COLOR
    elseif playerItemLevel < itemLevel then
        color = RED_FONT_COLOR
    else
        color = GREEN_FONT_COLOR
    end

    button.ItemLevel:SetText(text)
    button.ItemLevel:SetTextColor(color.r, color.g, color.b)

    self:AdjustLabelWidth(button.Name, voiceChat == '' and 168 or 146)
    self:AdjustLabelWidth(button.ActivityName, 168)
    self:AdjustLabelWidth(button.ItemLevel, 60)
end

function Search:LFGListUtil_SortSearchResults(results)
    local sortKeys = {}
    local sortType = self.sets.sortType
    local sortDesc = self.sets.sortDesc

    for i = #results, 1, -1 do
        local id, activityId, name, comment, voiceChat, itemLevel, honorLevel, age,
            numBNetFriends, numCharFriends, numGuildMates, isDelisted, numMembers = C_LFGList.GetSearchResultInfo(results[i])

        if not activityId or itemLevel < 0 then
            tremove(results, i)
        else
            local base = id
            local important = 0

            if sortType == SortType.Activity then
                important = activityId
            elseif sortType == SortType.ItemLevel then
                important = itemLevel
            end

            if sortDesc then
                base = 99999999 - base
                important = 99999999 - important
            end

            sortKeys[id] = format('%d-%08d-%08d-%08d',
                isDelisted and 0 or 1,
                numBNetFriends + numCharFriends + numGuildMates,
                important,
                id
            )
        end
    end

    table.sort(results, function(lhs, rhs)
        return sortKeys[lhs] > sortKeys[rhs]
    end)
end

function Search:UpdateHeaders()
    local sortType = self.sets.sortType
    local sortDesc = self.sets.sortDesc

    for _, header in ipairs(self.headers) do
        if header.sortType then
            header.Arrow:SetShown(header.sortType == sortType)
            header.Arrow:SetTexCoord(0, 0.5625, sortDesc and 1 or 0, sortDesc and 0 or 1)
        end
    end
end

function Search:UpdateResults()
    LFGListSearchPanel_UpdateResultList(self.SearchPanel)
    LFGListSearchPanel_UpdateResults(self.SearchPanel)
end

function Search:ToggleCategroyDropdown(anchor)
    GUI:ToggleMenu(anchor, self:GetAvailableCategories())
end
