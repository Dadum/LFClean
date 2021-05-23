local LFClean = LFClean
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local defaults = {
    profile = {
        entryButtons = true,
        selectedButton = false,
        buttonsReport = true,
        reportType = "lfglistspam",
        blacklist = {},
        autoBL = false,
        rightClickBL = true,
        hideBL = true,
        verbosity = 1
    }
}

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
    reportBlacklists = {
        name = "Reporting Blacklists",
        desc = "Reporting a group through a shortcut button automatically blacklists the leader",
        type = "toggle",
        width = 1.5,
        order = 10,
        set = function(info, val)
            LFClean.conf.profile.autoBL = val
        end,
        get = function(info)
            return LFClean.conf.profile.autoBL
        end
    },
    rightClickBlacklists = {
        name = "Right Click Blacklists",
        desc = "Right clicking a report shortcut adds the leader to the blacklist",
        type = "toggle",
        width = 1.5,
        order = 20,
        set = function(info, val)
            LFClean.conf.profile.rightClickBL = val
        end,
        get = function(info)
            return LFClean.conf.profile.rightClickBL
        end
    },
    autoHide = {
        name = "Hide Blacklisted Entries",
        desc = "Automatically hide any group from a blacklisted leader",
        type = "toggle",
        width = 1.5,
        order = 30,
        set = function(info, val)
            LFClean.conf.profile.hideBL = val
        end,
        get = function(info)
            return LFClean.conf.profile.hideBL
        end
    },
    manageBlacklist = {
        name = "Manage Blacklist",
        order = 40,
        type = "group",
        inline = true,
        args = {
            blacklist = {
                name = "Blacklist",
                desc = "Select a blacklist entry to remove",
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
                end,
                disabled = function()
                    if next(LFClean.conf.profile.blacklist, nil) then
                        return false
                    end
                    return true
                end
            },
            deleteEntry = {
                name = "Remove",
                desc = "Remove the entry from the blacklist",
                type = "execute",
                order = 20,
                func = function()
                    LFClean.conf.profile.blacklist[LFClean.blmSelect] = nil
                    LFClean.blmSelect = nil
                end,
                disabled = function()
                    if LFClean.blmSelect then
                        return false
                    end
                    return true
                end
            },
            wipeBlacklist = {
                name = "Clear Blacklist",
                desc = "Completely wipe the blacklist clean",
                type = "execute",
                order = 30,
                confirm = true,
                confirmText = "This will completely wipe the blacklist!",
                func = function()
                    LFClean.conf.profile.blacklist = {}
                end
            },
            nameInput = {
                name = "Add to Blacklist",
                desc = "Manually add a character name to the blacklist",
                type = "input",
                order = 40,
                get = function(info)
                    return LFClean.addBL
                end,
                set = function(info, val)
                    LFClean.addBL = val
                end
            },
            addToBL = {
                name = "Add",
                type = "execute",
                order = 50,
                func = function()
                    LFClean.conf.profile.blacklist[LFClean.addBL] = true
                    LFClean.addBL = nil
                end,
                disabled = function()
                    if LFClean.addBL then
                        return false
                    end
                    return true
                end
            }
        }
    }
}

local otherOptions = {
    verbosity = {
        name = "Verbosity",
        desc = "Determine the level of verbosity of the addon messages",
        type = "select",
        order = 10,
        set = function(info, val)
            LFClean.conf.profile.verbosity = val
        end,
        get = function(info)
            return LFClean.conf.profile.verbosity
        end,
        values = {[0] = "Quiet", [1] = "Verbose", [2] = "Pedantic"}
    },
    restoreDefaults = {
        name = "Restore Defaults",
        desc = "Restore the default options.\nNOTE: This also resets the blacklist!",
        type = "execute",
        order = 20,
        confirm = true,
        confirmText = "This will reset all the addon options and also wipe the blacklist.\nAre you sure?",
        func = function()
            LFClean.conf.profile = defaults.profile
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
        },
        other = {
            type = "group",
            name = "Other",
            order = 30,
            inline = true,
            args = otherOptions
        }
    }
}

function LFClean:InitConfig()
    C:RegisterOptionsTable("LFClean", options, nil)
    CD:AddToBlizOptions("LFClean", "LFClean")
end

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
