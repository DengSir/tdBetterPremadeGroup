-- AutoComplete.lua
-- @Author : DengSir (tdaddon@163.com)
-- @Link   : https://dengsir.github.io
-- @Date   : 10/16/2018, 9:33:42 AM

local ns            = select(2, ...)
local Addon         = ns.Addon
local AUTOCOMPLETES = {}

local AutoComplete = Addon:NewModule('AutoComplete', 'AceEvent-3.0')

local C_LFGList_GetAvailableActivities = C_LFGList.GetAvailableActivities

function AutoComplete:OnEnable()
    local hookedEnv = setmetatable({
        C_LFGList = setmetatable({
            GetAvailableActivities = function(...)
                return self:GetAvailableActivities(...)
            end
        }, {__index = C_LFGList})
    }, {__index = _G})

    pcall(setfenv, LFGListSearchPanel_UpdateAutoComplete, hookedEnv)
    pcall(setfenv, LFGListEntryCreationActivityFinder_UpdateMatching, hookedEnv)
end

function AutoComplete:GetAvailableActivities(categoryId, groupId, filters, text)
    if not text or text == '' then
        return C_LFGList_GetAvailableActivities(categoryId, groupId, filters, text)
    end

    local activities = C_LFGList_GetAvailableActivities(categoryId, groupId, filters)
    local results = {}
    text = text:lower()

    for _, activityId in ipairs(activities) do
        local name = C_LFGList.GetActivityInfo(activityId)
        local autoCompletes = AUTOCOMPLETES[activityId]

        if name:lower():find(text, nil, true) then
            table.insert(results, activityId)
        elseif autoCompletes then
            for abbr in pairs(autoCompletes) do
                if abbr:find(text, nil, true) then
                    table.insert(results, activityId)
                    break
                end
            end
        end
    end
    return results
end

local function IterateSplit(text, pattern)
    return coroutine.wrap(function()
        local ofs = 1
        local i = 1
        while true do
            local over = text:find(pattern, ofs, true)
            local item = text:sub(ofs, over and over - 1 or nil)

            coroutine.yield(i, item)

            if not over then
                return
            end
            ofs = over + 1
            i   = i + 1
        end
    end)
end

local function AddAbbreviation(id, item)
    if item ~= '' then
        AUTOCOMPLETES[id] = AUTOCOMPLETES[id] or {}
        AUTOCOMPLETES[id][item] = true
    end
end

local function RegisterString(data)
    for id, v in IterateSplit(data, '/') do
        for _, item in IterateSplit(v, '+') do
            AddAbbreviation(id, item)
        end
    end
end

function AutoComplete:Register(data)
    if type(data) == 'string' then
        return RegisterString(data)
    end
end
