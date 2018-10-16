-- MinMax.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/16/2018, 12:50:59 PM

local ns     = select(2, ...)
local Addon  = ns.Addon
local GUI    = ns.GUI
local MinMax = Addon:NewClass('MinMax', 'Frame')

function MinMax:Constructor(_, text, minValue, maxValue, step)
    local Max = GUI:GetClass('NumericBox'):New(self) do
        Max:SetPoint('RIGHT')
        Max:SetSize(50, 20)
        Max:SetMinMaxValues(minValue, maxValue)
        Max:SetValueStep(step)
    end

    local Desc = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight') do
        Desc:SetPoint('RIGHT', Max, 'LEFT', -2, 0)
        Desc:SetText('-')
    end

    local Min = GUI:GetClass('NumericBox'):New(self) do
        Min:SetPoint('RIGHT', Desc, 'LEFT', -2, 0)
        Min:SetSize(50, 20)
        Min:SetMinMaxValues(minValue, maxValue)
        Min:SetValueStep(step)
    end

    local Label = self:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightLeft') do
        Label:SetPoint('LEFT')
        Label:SetPoint('RIGHT', Min, 'LEFT', -5, 0)
        Label:SetText(text)
    end

    self.Min = Min
    self.Max = Max
    self:SetHeight(22)
end
