-- Application.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/12/2018, 12:41:06 PM

local ns = select(2, ...)
local Addon = ns.Addon

local Application = Addon:NewModule('Application', 'AceHook-3.0')

function Application:OnEnable()
    self:InitUI()
    self:InitHook()
end

function Application:InitUI()
    local ApplicationViewer = LFGListFrame.ApplicationViewer
    local ScrollFrame       = ApplicationViewer.ScrollFrame

    ApplicationViewer.NameColumnHeader:SetWidth(170)

    for _, button in ipairs(ScrollFrame.buttons) do
        self:AddRegionWidth(button)

        button.Comment = button:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightSmall')
        button.Comment:SetPoint('TOPLEFT', 280, -3)
        button.Comment:SetPoint('BOTTOMLEFT', 280, 3)
        button.Comment:SetWidth(140)
        button.Comment:SetWordWrap(true)
    end
end

function Application:InitHook()
    self:SecureHook('LFGListApplicationViewer_UpdateApplicantMember')
    self:SecureHook('LFGListApplicationViewer_UpdateApplicant')
end

function Application:LFGListApplicationViewer_UpdateApplicantMember(button, id, index)
    if not button.hooked then
        self:AddRegionWidth(button)

        button.RoleIcon1:SetPoint('LEFT', 174, 0)
        button.ItemLevel:SetPoint('LEFT', 244, 0)
        button.hooked = true
    end

    self:AdjustLabelWidth(button.Name, button.FriendIcon:IsShown() and 148 or 170)
end

function Application:LFGListApplicationViewer_UpdateApplicant(button, id)
    local id, status, pendingStatus, numMembers, isNew, comment = C_LFGList.GetApplicantInfo(id)

    button.Comment:SetText(comment or '')
end
