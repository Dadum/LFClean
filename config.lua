local LFClean = LFClean
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local options = {
    type = 'group',
    args = {
        entryButtons = {
            name = 'Entry Buttons',
            desc = 'Add one button for each entry of the group finder.\nNOTE: Might break the entry layout for long group names',
            type = 'toggle',
            width = 'full',
            set = function(info, val)
                LFClean.conf.profile.entryButtons = val
                LFClean:GenerateEntryButtons()
            end,
            get = function(info)
                return LFClean.conf.profile.entryButtons
            end
        },
        selectedButton = {
            name = 'Selected Button',
            desc = 'Add a button to report the selected group entry',
            type = 'toggle',
            width = 'full',
            set = function(info, val)
                LFClean.conf.profile.selectedButton = val
                LFClean:GenerateSelectedButton()
            end,
            get = function(info)
                return LFClean.conf.profile.selectedButton
            end
        },
        buttonsReport = {
            name = 'Buttons Report',
            desc = 'When hiding an entry through a button, also report it for spam',
            type = 'toggle',
            width = 'full',
            set = function(info, val)
                LFClean.conf.profile.buttonsReport = val
            end,
            get = function(info)
                return LFClean.conf.profile.buttonsReport
            end
        }
    }
}

function LFClean:InitConfig()
    C:RegisterOptionsTable("LFClean", options, nil)
    CD:AddToBlizOptions("LFClean", "LFClean")
end

local defaults = {
    profile = {entryButton = true, selectedButton = false, buttonsReport = true}
}

function LFClean:InitDB() self.conf = DB:New("LFCleanConf", defaults, true) end

-- * --------------------------------------------------------------------------
-- * Slash commands
-- * --------------------------------------------------------------------------

LFClean:RegisterChatCommand("lfclean", "ChatCommand")
LFClean:RegisterChatCommand("lfc", "ChatCommand")

function LFClean:ChatCommand(input) CD:Open("LFClean") end
