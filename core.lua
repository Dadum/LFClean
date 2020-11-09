LFGReport = LibStub("AceAddon-3.0"):NewAddon("LFGReport", "AceConsole-3.0",
                                             "AceEvent-3.0")
GUI = LibStub("AceGUI-3.0")

-- * --------------------------------------------------------------------------
-- * Init
-- * --------------------------------------------------------------------------

function LFGReport:OnInitialize() self.buttons = {} end

-- * --------------------------------------------------------------------------
-- * LFGReport utility
-- * --------------------------------------------------------------------------

function LFGReport:Report(id)
    local panel = _G.LFGListFrame.SearchPanel
    if id then
        local r = C_LFGList.GetSearchResultInfo(id)
        LFGReport:Print("Reported group: " .. r.name)

        -- Report group
        C_LFGList.ReportSearchResult(id, "lfglistspam");
        LFGListSearchPanel_AddFilteredID(panel, id);
        LFGListSearchPanel_UpdateResultList(panel);
        LFGListSearchPanel_UpdateResults(panel);

    else
        LFGReport:Print("No group selected")
    end
end

function LFGReport:GenerateEntryButtons()
    local panel = _G.LFGListFrame.SearchPanel
    local buttons = _G.LFGListFrame.SearchPanel.ScrollFrame.buttons
    for i = 1, #buttons do
        -- Only generate a button if it is missing
        if LFGReport.buttons[i] == nil then
            LFGReport.buttons[i] = CreateFrame("Button", "btn" .. i, buttons[i],
                                               "UIPanelSquareButton")
            LFGReport.buttons[i]:SetPoint("RIGHT", buttons[i], "RIGHT", -1, -1)
            LFGReport.buttons[i]:SetSize(25, 25)
            LFGReport.buttons[i]:SetAlpha(1)
            LFGReport.buttons[i]:SetScript("OnClick", function(self)
                LFGReport:Report(self:GetParent().resultID)
            end)
            LFGReport.buttons[i].id = buttons[i].resultID
            LFGReport.buttons[i].tooltipText = "test"

            buttons[i].DataDisplay:ClearAllPoints()
            buttons[i].DataDisplay:SetPoint("RIGHT", buttons[i], "RIGHT", -20,
                                            -1)
        end
    end
end

function LFGReport:GenerateSelectedButton()
    local panel = _G.LFGListFrame.SearchPanel
    self.button = CreateFrame("Button", "btn", _G.LFGListFrame.SearchPanel,
                              "UIPanelSquareButton")
    self.button:SetPoint("RIGHT", _G.LFGListFrame.SearchPanel.RefreshButton,
                         "LEFT", -5, 0)
    self.button:SetSize(25, 25)
    self.button:SetScript("OnClick", function()
        -- Report currently selected entry
        local id = panel.selectedResult
        LFGReport:Report(id)

        -- Remove selection
        panel.selectedResult = nil
    end)
end

-- * --------------------------------------------------------------------------
-- * Events handling
-- * --------------------------------------------------------------------------

function LFGReport:OnReceiveSearchResults() LFGReport:GenerateButtons() end

LFGReport:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED",
                        "OnReceiveSearchResults")

-- * --------------------------------------------------------------------------
-- * Slash commands
-- * --------------------------------------------------------------------------

LFGReport:RegisterChatCommand("lfgreport", "TestSlash")

function LFGReport:TestSlash(input) LFGReport:Print("helo") end
