-- Inset.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/16/2018, 12:49:06 PM

local ns    = select(2, ...)
local Addon = ns.Addon
local GUI   = ns.GUI
local Inset = Addon:NewClass('Inset', 'Frame.InsetFrameTemplate')

GUI:Embed(Inset, 'Refresh')

function Inset:Constructor(_, text)
    self.widgets = {}

    local Label = self:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLargeLeft') do
        Label:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 3, 5)
        Label:SetText(text)
    end

    local Inset = GUI:GetClass('GridView'):New(self) do
        Inset:SetPoint('TOPLEFT')
        Inset:SetPoint('TOPRIGHT')
        Inset:SetHeight(1)
        Inset:SetColumnCount(1)
        Inset:SetItemHeight(22)
        Inset:SetItemSpacing(5)
        Inset:SetPadding(10)
        Inset:SetAutoSize(true)
        Inset:SetItemList(self.widgets)
        Inset:SetCallback('OnItemFormatting', function(_, button, widget)
            widget:SetParent(button)
            widget:SetAllPoints(button)
        end)
        Inset:SetCallback('OnRefresh', function(Inset)
            self:SetHeight(Inset:GetHeight())
        end)
    end

    self.Inset = Inset
    self:SetHeight(10)
    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function Inset:OnSizeChanged()
    self:Refresh()
end

function Inset:SetColumnCount(...)
    self.Inset:SetColumnCount(...)
end

function Inset:AddWidget(widget)
    table.insert(self.widgets, widget)
end

function Inset:Update()
    local left, right     = self.Inset:GetPadding()
    local _, itemSpacingH = self.Inset:GetItemSpacing()
    local columnCount     = self.Inset:GetColumnCount()
    local width           = self.Inset:GetWidth() - left - right - (columnCount-1) * itemSpacingH - self.Inset:GetScrollBarFixedWidth()

    self.Inset:SetItemWidth(width / columnCount)
    self.Inset:Refresh()
end
