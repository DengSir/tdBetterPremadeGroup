-- Check.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/16/2018, 1:35:44 PM

local ns    = select(2, ...)
local Addon = ns.Addon
local Check = Addon:NewClass('Check', 'Frame')

function Check:Constructor(_, text)
    local Check = CreateFrame('CheckButton', nil, self, 'UICheckButtonTemplate') do
        Check:SetPoint('TOPLEFT')
        Check:SetPoint('BOTTOMLEFT')
        Check.text:SetText(text)
    end

    self.Check = Check
    self:SetScript('OnSizeChanged', self.OnSizeChanged)
end

function Check:OnSizeChanged()
    self.Check:SetWidth(self:GetHeight())
end
