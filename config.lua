local LFClean = LFClean
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local shortcutsOptions = {
    entryButtons = {
        name = "Entry Buttons",
        desc = "Add one button for each entry of the group finder.",
        type = "toggle",
        width = 1.5,
        order = 10,
        set = function(info, val)
            LFClean.conf.profile.entryButtons = val
            LFClean:GenerateEntryButtons()
        end,
        get = function(info)
            return LFClean.conf.profile.entryButtons
        end
    },
    selectedButton = {
        name = "Selected Button",
        desc = "Add a button to report the selected group entry, nect to the refresh button.",
        type = "toggle",
        width = 1.5,
        order = 20,
        set = function(info, val)
            LFClean.conf.profile.selectedButton = val
            LFClean:GenerateSelectedButton()
        end,
        get = function(info)
            return LFClean.conf.profile.selectedButton
        end
    },
    reportType = {
        name = "Report Groups For",
        desc = "Defines what the groups should be reported for when using the shortcut buttons",
        type = "select",
        order = 30,
        set = function(info, val)
            LFClean.conf.profile.reportType = val
        end,
        get = function(info)
            return LFClean.conf.profile.reportType
        end,
        values = {
            ["lfglistspam"] = "Advertisement",
            ["lfglistname"] = "Group Name",
            ["lfglistcomment"] = "Description",
            ["badplayername"] = "Leader Name"
        }
    }
}

local blacklistOptions = {
    manageBlacklist = {
        name = "Manage Blacklist",
        type = "select",
        order = 10,
        set = function(info, val)
            LFClean.blmSelect = val
        end,
        get = function(info)
            return LFClean.blmSelect
        end,
        values = function()
            local blacklist = {}
            for k, _ in pairs(LFClean.conf.profile.blacklist) do
                blacklist[k] = k
            end
            return blacklist
        end
    },
    deleteEntry = {
        name = "Remove",
        type = "execute",
        order = 20,
        func = function()
            if LFClean.blmSelect then
                LFClean.conf.profile.blacklist[LFClean.blmSelect] = nil
                LFClean.blmSelect = nil
            else
                LFClean:Print("No blacklist entry selected")
            end
        end
    },
    wipeBlacklist = {
        name = "Clear Blacklist",
        type = "execute",
        order = 30,
        confirm = true,
        confirmText = "This will completely wipe the blacklist!",
        func = function()
            LFClean.conf.profile.blacklist = {}
        end
    }
}

local options = {
    type = "group",
    args = {
        shortcuts = {
            type = "group",
            name = "Shortcuts",
            order = 10,
            inline = true,
            args = shortcutsOptions
        },
        blacklist = {
            type = "group",
            name = "Blacklist",
            order = 20,
            inline = true,
            args = blacklistOptions
        }
    }
}

function LFClean:InitConfig()
    C:RegisterOptionsTable("LFClean", options, nil)
    CD:AddToBlizOptions("LFClean", "LFClean")
end

local defaults = {
    profile = {
        entryButtons = true,
        selectedButton = false,
        buttonsReport = true,
        reportType = "lfglistspam",
        blacklist = {}
    }
}

function LFClean:InitDB()
    self.conf = DB:New("LFCleanConf", defaults, true)
end

-- * --------------------------------------------------------------------------
-- * Slash commands
-- * --------------------------------------------------------------------------

LFClean:RegisterChatCommand("lfclean", "ChatCommand")
LFClean:RegisterChatCommand("lfc", "ChatCommand")

function LFClean:ChatCommand(input)
    CD:Open("LFClean")
end
