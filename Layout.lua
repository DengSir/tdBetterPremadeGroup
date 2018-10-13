-- Width.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/12/2018, 12:37:49 PM

local ns    = select(2, ...)
local Addon = ns.Addon
local WIDTH = ns.WIDTH

local Layout = Addon:NewModule('Layout', 'AceHook-3.0', 'AceEvent-3.0')

function Layout:OnEnable()
    self:SecureHook('GroupFinderFrame_ShowGroupFrame')
    self:SecureHook('PVEFrame_ShowFrame')
    self:RegisterEvent('ADDON_LOADED')

    self:AddRegionWidth(LFGListPVEStub)

    self:AddRegionWidth(LFGListFrame.CategorySelection.Inset.CustomBG)
    self:AddRegionWidth(LFGListFrame.NothingAvailable.Inset.CustomBG)
    self:AddRegionWidth(LFGListFrame.EntryCreation.Inset.CustomBG)

    -- self:AddRegionWidth(LFGListFrame.SearchPanel.CategoryName)

    self:AddRegionWidth(LFGListFrame.ApplicationViewer.InfoBackground)
    self:AddRegionWidth(LFGListFrame.ApplicationViewer.DescriptionFrame)

    self:MoveRegionX(LFGListFrame.EntryCreation.TypeLabel)
    self:MoveRegionX(LFGListFrame.EntryCreation.NameLabel)
    self:MoveRegionX(LFGListFrame.EntryCreation.DescriptionLabel)
    self:MoveRegionX(LFGListFrame.EntryCreation.Description)
    self:MoveRegionX(LFGListFrame.EntryCreation.ItemLevel)

    -- GroupFinderFrameGroupButton4:Hide()

    -- local env = setmetatable({
    --     pairs = function(panels)
    --         table.insert(panels, {
    --             name = 'LFGListParent'
    --         })
    --         setfenv(PVEFrame_OnShow, _G)
    --         return pairs(panels)
    --     end
    -- }, {__index = _G})

    -- dump(env)

    -- setfenv(PVEFrame_OnShow, env)

    -- local Parent = CreateFrame('Frame', 'LFGListParent', PVEFrame)
    -- Parent:Hide()
    -- Parent:SetPoint('TOPLEFT', 4, -20)
    -- Parent:SetPoint('BOTTOMRIGHT', -4, 4)
    -- Parent:SetScript('OnShow', function()
    --     PVEFrame_HideLeftInset()
    -- end)
    -- Parent:SetScript('OnHide', function()
    --     PVEFrame_ShowLeftInset()
    -- end)

    -- LFGListFrame:SetParent(Parent)
    -- LFGListFrame:ClearAllPoints()
    -- LFGListFrame:SetAllPoints(Parent)

    -- local Tab = CreateFrame('Button', 'PVEFrameTab4', PVEFrame, 'CharacterFrameTabButtonTemplate')
    -- Tab:SetPoint('LEFT', PVEFrameTab3, 'RIGHT', -16, 0)
    -- Tab:SetScript('OnClick', PVEFrame_TabOnClick)
    -- Tab:SetID(4)
    -- PVEFrame.tab4 = Tab

    -- PanelTemplates_SetNumTabs(PVEFrame, 4)
end

function Layout:GroupFinderFrame_ShowGroupFrame(frame)
    if frame == LFGListPVEStub then
        PVEFrame:SetWidth(PVE_FRAME_BASE_WIDTH + 225)
    else
        PVEFrame:SetWidth(PVE_FRAME_BASE_WIDTH)
    end
end

function Layout:PVEFrame_ShowFrame(frameName)
    if frameName == 'ChallengesFrame' then
        PVEFrame:SetWidth(PVE_FRAME_BASE_WIDTH)
    elseif LFGListFrame:IsVisible() then
        PVEFrame:SetWidth(PVE_FRAME_BASE_WIDTH + WIDTH)
    end
end

function Layout:PVPQueueFrame_ShowFrame(frame)
    if frame == LFGListPVPStub then
        PVEFrame:SetWidth(PVE_FRAME_BASE_WIDTH + WIDTH)
    end
end

function Layout:ADDON_LOADED(event, addon)
    if addon ~= 'Blizzard_PVPUI' then
        return
    end
    self:UnregisterEvent(event)
    self:AddRegionWidth(LFGListPVPStub)
    -- PVPQueueFrameCategoryButton3:Hide()
    self:SecureHook('PVPQueueFrame_ShowFrame')
end
