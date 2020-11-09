local LFClean = LFClean
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local buttonOptions = {
    type = 'group',
    name = 'Buttons Options',
    inline = true,
    args = {
        entry = {
            name = "Entry Button",
            desc = "Add one button for each entry of the group finder.\nNOTE: Might break the entry layout for long group names",
            descStyle = "inline",
            type = "toggle",
            width = "full",
            set = function(info, val)
                LFClean.conf.profile.entry = val
                LFClean:GenerateEntryButtons()
            end,
            get = function(info) return LFClean.conf.profile.entry end
        },
        selected = {
            name = "Selected Button",
            desc = "Add a button to report the selected group entry",
            descStyle = "inline",
            type = "toggle",
            width = "full",
            set = function(info, val)
                LFClean.conf.profile.selected = val
                LFClean:GenerateSelectedButton()
            end,
            get = function(info) return LFClean.conf.profile.selected end
        },
        buttonsReport = {
            name = 'Buttons Report',
            desc = 'When hiding an entry through a button, also report it for spam',
            descStyle = 'inline',
            type = 'toggle',
            width = 'full',
            set = function(info, val)
                LFClean.conf.profile.buttonsReport = val
            end,
            get = function(info)
                return LFClean.conf.profile.buttonsReport
            end
        },
        hideNote = {
            type = 'description',
            name = 'NOTE: Manually hidden entries will show up again on the next login',
            order = -1
        }
    }
}

local options = {type = 'group', args = {buttonOptions = buttonOptions}}

function LFClean:InitConfig()
    C:RegisterOptionsTable("LFClean", options, nil)
    CD:AddToBlizOptions("LFClean", "LFClean")
end

local defaults = {
    profile = {entry = true, selected = false, buttonsReport = true}
}

function LFClean:InitDB() self.conf = DB:New("LFCleanConf", defaults, true) end

-- * --------------------------------------------------------------------------
-- * Slash commands
-- * --------------------------------------------------------------------------

LFClean:RegisterChatCommand("lfclean", "ChatCommand")
LFClean:RegisterChatCommand("lfc", "ChatCommand")

function LFClean:ChatCommand(input) CD:Open("LFClean") end
