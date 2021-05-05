local LFClean = LFClean
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local options = {
    type = "group",
    args = {
        entryButtons = {
            name = "Entry Buttons",
            desc = "Add one button for each entry of the group finder.\nNOTE: Might break the entry layout for long group names",
            type = "toggle",
            width = "full",
            order = 0,
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
            desc = "Add a button to report the selected group entry",
            type = "toggle",
            width = "full",
            order = 1,
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
            order = 2,
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
        reportType = "lfglistspam"
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
