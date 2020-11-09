local LFGReport = LFGReport
local C = LibStub("AceConfig-3.0")
local CD = LibStub("AceConfigDialog-3.0")
local DB = LibStub("AceDB-3.0")

local options = {
    type = 'group',
    args = {
        selected = {
            name = "Report Selected",
            desc = "Add a button to report the selected group",
            type = "toggle",
            set = function(info, val)LFGReport.conf.profile.selected = val end,
            get = function(info) return LFGReport.conf.profile.selected end
        },
        entry = {
            name = "Report Entry",
            desc = "Add one button for each entry of the group finder. NOTE: This might mess up the layout of the entries and make elements overlap",
            type = "toggle",
            set = function(info, val)
                LFGReport.conf.profile.entry = val
            end,
            get = function(info)
                return LFGReport.conf.profile.entry
            end
        }
    }
}

function LFGReport:InitConfig()
    C:RegisterOptionsTable("LFGReport", options, nil)
    CD:AddToBlizOptions("LFGReport", "LFGReport")
end

local defaults = {profile = {selected = true, entry = false}}

function LFGReport:InitDB()
    self.conf = LibStub("AceDB-3.0"):New("LFGReportConf", defaults, true)
end
