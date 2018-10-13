-- Addon.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/12/2018, 12:16:08 PM

local ADDON_NAME, ns = ...

local Addon           = LibStub('AceAddon-3.0'):NewAddon(ADDON_NAME)
local WIDTH           = 225
local HALF_WIDTH      = 225 / 2
local ModulePrototype = {}

ns.GUI      = LibStub('tdGUI-1.0')
ns.WIDTH    = WIDTH
ns.Addon    = Addon
ns.SortType = {
    Activity  = 1,
    ItemLevel = 2,
}

Addon:SetDefaultModulePrototype(ModulePrototype)

function Addon:OnInitialize()
    local defaults = {
        profile = {
            search = {
                sortType = ns.SortType.ItemLevel,
                sortDesc = false,
            }
        }
    }

    self.db = LibStub('AceDB-3.0'):New('TD_DB_BETTERPREMADEGROUP', defaults, true)

    ns.GUI = LibStub('tdGUI-1.0')
    ns.DropMenu = ns.GUI:GetClass('DropMenu'):New(nil)
end

-- function Addon:OnModuleCreated(module)
--     ns[module:GetName()] = module
-- end

function ModulePrototype:AddRegionWidth(region, width)
    region:SetWidth(region:GetWidth() +(width or WIDTH))
end

function ModulePrototype:MoveRegionX(region, offset)
    local point, relative, relativePoint, x, y = region:GetPoint(1)
    region:SetPoint(point, relative, relativePoint, x + (offset or HALF_WIDTH), y)
end

function ModulePrototype:AdjustLabelWidth(label, width)
    label:SetWidth(0)
    if label:GetWidth() > width then
        label:SetWidth(width)
    end
end

function ModulePrototype:OnInitialize()
    self.profile = Addon.db.profile
end
