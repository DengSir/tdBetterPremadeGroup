-- Filter.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/15/2018, 11:45:49 PM

local ns    = select(2, ...)
local Addon = ns.Addon
local GUI   = ns.GUI

local Filter = Addon:NewModule('Filter', 'AceEvent-3.0') ns.Filter = Filter

function Filter:OnEnable()
    local SearchPanel = LFGListFrame.SearchPanel
    local Frame = CreateFrame('Frame', nil, SearchPanel) do
        Frame:SetPoint('TOPLEFT', SearchPanel, 'TOPRIGHT', -5, -18)
        Frame:SetPoint('BOTTOMLEFT', SearchPanel, 'BOTTOMLEFT', -5, 10)
        Frame:SetWidth(270)
        Frame:SetBackdrop{
            edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
            bgFile = [[Interface\FrameGeneral\UI-Background-Rock]],
            edgeSize = 16, tileSize = 5,
            insets = {left = 4, right = 4, top = 4, bottom = 4}
        }
    end

    local Inset = CreateFrame('Frame', nil, Frame, 'InsetFrameTemplate') do
        Inset:SetPoint('TOPLEFT', 8, -30)
        Inset:SetPoint('BOTTOMRIGHT', -8, 10)
    end

    local Title = Frame:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge') do
        Title:SetPoint('TOPLEFT', 12, -8)
        Title:SetText('Filters')
    end

    local function CreateMinMax(text, min, max, step)
        local Container = CreateFrame('Frame', nil, Inset) do
            Container:SetHeight(20)
        end

        local Max = GUI:GetClass('NumericBox'):New(Container) do
            Max:SetPoint('RIGHT')
            Max:SetSize(50, 20)
            Max:SetMinMaxValues(min, max)
            Max:SetValueStep(step)
            Max:EnableControl()
        end

        local Desc = Container:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
            Desc:SetPoint('RIGHT', Max, 'LEFT', -2, 0)
            Desc:SetText('-')
        end

        local Min = GUI:GetClass('NumericBox'):New(Container) do
            Min:SetPoint('RIGHT', Desc, 'LEFT', -2, 0)
            Min:SetSize(50, 20)
            Min:SetMinMaxValues(min, max)
            Min:SetValueStep(step)
            Min:EnableControl()
        end

        local Label = Container:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightLeft') do
            Label:SetPoint('LEFT')
            Label:SetPoint('RIGHT', Min, 'LEFT', -5, 0)
            Label:SetText(text)
        end

        Container.Min = Min
        Container.Max = Max
        return Container
    end

    local function CreateRoleFilter(role)
        return CreateMinMax(_G['INLINE_' .. role .. '_ICON'] .. _G[role], 0, 40, 1)
    end

    local objects = {
        CreateRoleFilter('TANK'),
        CreateRoleFilter('HEALER'),
        CreateRoleFilter('DAMAGER'),
        CreateMinMax('Item level', 0, 500, 5),
    }

    for i, widget in ipairs(objects) do
        if i == 1 then
            widget:SetPoint('TOPLEFT', 10, -10)
            widget:SetPoint('TOPRIGHT', -10, -10)
        else
            widget:SetPoint('TOPLEFT', objects[i-1], 'BOTTOMLEFT', 0, -7)
            widget:SetPoint('TOPRIGHT', objects[i-1], 'BOTTOMRIGHT', 0, -7)
        end
    end

    self.Frame = Frame
end

function Filter:TogglePanel()
    self.Frame:SetShown(not self.Frame:IsShown())
end
