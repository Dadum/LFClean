local LFGReport = LFGReport
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local buttonOptions = {
    type = 'group',
    name = 'Buttons Options',
    inline = true,
    args = {
        entry = {
            name = "Report Entry",
            desc = "Add one button for each entry of the group finder.\nNOTE: Might break the entry layout for long group names",
            descStyle = "inline",
            type = "toggle",
            width = "full",
            set = function(info, val)
                LFGReport.conf.profile.entry = val
            end,
            get = function(info) return LFGReport.conf.profile.entry end
        },
        selected = {
            name = "Report Selected",
            desc = "Add a button to report the selected group",
            descStyle = "inline",
            type = "toggle",
            width = "full",
            set = function(info, val)
                LFGReport.conf.profile.selected = val
            end,
            get = function(info)
                return LFGReport.conf.profile.selected
            end
        }
    }
}

local options = {type = 'group', args = {buttonOptions = buttonOptions}}

function LFGReport:InitConfig()
    C:RegisterOptionsTable("LFGReport", options, nil)
    CD:AddToBlizOptions("LFGReport", "LFGReport")
end

local defaults = {profile = {entry = true, selected = false}}

function LFGReport:InitDB() self.conf = DB:New("LFGReportConf", defaults, true) end
