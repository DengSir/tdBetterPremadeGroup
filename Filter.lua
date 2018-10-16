-- Filter.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/15/2018, 11:45:49 PM

local ns     = select(2, ...)
local Addon  = ns.Addon
local GUI    = ns.GUI
local Inset  = Addon:GetClass('Inset')
local MinMax = Addon:GetClass('MinMax')

local Filter = Addon:NewModule('Filter', 'AceEvent-3.0')

function Filter:OnEnable()
    local SearchPanel = LFGListFrame.SearchPanel
    local Frame = CreateFrame('Frame', nil, SearchPanel) do
        GUI:Embed(Frame, 'Refresh')
        Frame:SetPoint('TOPLEFT', SearchPanel, 'TOPRIGHT', -5, -18)
        Frame:SetSize(250, 10)
        Frame:SetFrameLevel(SearchPanel:GetFrameLevel() + 10)
        Frame:SetBackdrop{
            edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
            bgFile = [[Interface\FrameGeneral\UI-Background-Rock]],
            edgeSize = 16, tileSize = 5,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        }
        Frame.Update = function()
            return self:Update()
        end
        Frame:SetScript('OnShow', Frame.Refresh)
    end

    local function CreateMinMax(...)
        return MinMax:New(Frame, ...)
    end

    local function CreateRoleFilter(role)
        return CreateMinMax(_G['INLINE_' .. role .. '_ICON'] .. _G[role], 0, 40, 1)
    end

    local function CreateCheck(text)
        return Addon:GetClass('Check'):New(Frame, text)
    end

    local function CreateLang(lang)
        return CreateCheck(_G['LFG_LIST_LANGUAGE_' .. lang:upper()])
    end

    local General = Addon:GetClass('Inset'):New(Frame, 'General') do
        General:AddWidget(CreateMinMax('Item level', 0, 500, 5))
        General:AddWidget(CreateMinMax('Age', 0, 3600, 10))
        -- General:AddWidget(CreateCheck('Voice'))
    end

    local Members = Addon:GetClass('Inset'):New(Frame, 'Members') do
        Members:AddWidget(CreateMinMax('Members', 0, 40, 1))
        Members:AddWidget(CreateRoleFilter('TANK'))
        Members:AddWidget(CreateRoleFilter('HEALER'))
        Members:AddWidget(CreateRoleFilter('DAMAGER'))
    end

    local Languages = Addon:GetClass('Inset'):New(Frame, 'Languages') do
        Languages:SetColumnCount(2)

        local langs = C_LFGList.GetAvailableLanguageSearchFilter()

        for _, lang in ipairs(langs) do
            Languages:AddWidget(CreateLang(lang))
        end
    end

    self.insets = {}
    self.Frame  = Frame

    self:AddInset(General)
    self:AddInset(Members)
    self:AddInset(Languages, function()
        local availableLanguages = C_LFGList.GetAvailableLanguageSearchFilter()
        local defaultLanguages = C_LFGList.GetDefaultLanguageSearchFilter()
        for _, lang in ipairs(availableLanguages) do
            if not defaultLanguages[lang] then
                return true
            end
        end
    end)
end

function Filter:TogglePanel()
    self.Frame:SetShown(not self.Frame:IsShown())
end

function Filter:AddInset(widget, check)
    table.insert(self.insets, {
        widget = widget,
        check = check
    })
    widget:HookScript('OnSizeChanged', function()
        self.Frame:Refresh()
    end)
end

function Filter:Update()
    local height = 10
    local prevWidget
    local widget
    for _, v in ipairs(self.insets) do
        if not v.check or v.check() then
            widget = v.widget

            if not prevWidget then
                widget:SetPoint('TOPLEFT', 10, -30)
                widget:SetPoint('TOPRIGHT', -10, -30)
                height = height + widget:GetHeight() + 30
            else
                widget:SetPoint('TOPLEFT', prevWidget, 'BOTTOMLEFT', 0, -25)
                widget:SetPoint('TOPRIGHT', prevWidget, 'BOTTOMRIGHT', 0, -25)
                height = height + widget:GetHeight() + 25
            end
            prevWidget = widget
        end
    end
    self.Frame:SetHeight(height)
end
