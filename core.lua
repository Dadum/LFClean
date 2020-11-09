LFGReport = LibStub("AceAddon-3.0"):NewAddon("LFGReport", "AceConsole-3.0",
                                             "AceEvent-3.0")
GUI = LibStub("AceGUI-3.0")

-- * --------------------------------------------------------------------------
-- * Init
-- * --------------------------------------------------------------------------

function LFGReport:OnInitialize()
    self.buttons = {}
    self.selected = nil

    LFGReport:InitConfig()
    LFGReport:InitDB()
end

-- * --------------------------------------------------------------------------
-- * LFGReport utility
-- * --------------------------------------------------------------------------

function LFGReport:Report(id)
    local panel = _G.LFGListFrame.SearchPanel
    if id then
        local r = C_LFGList.GetSearchResultInfo(id)
        LFGReport:Print("Reported group: " .. r.name)

        -- Report group as per blizz dropdown handler
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
    if (self.conf.profile.entry) then
        for i = 1, #buttons do
            -- Only generate a button if it is missing
            if LFGReport.buttons[i] == nil then
                LFGReport.buttons[i] = CreateFrame("Button", "btn" .. i,
                                                   buttons[i],
                                                   "UIPanelSquareButton")
                LFGReport.buttons[i]:SetPoint("RIGHT", buttons[i], "RIGHT", -1,
                                              -1)
                LFGReport.buttons[i]:SetSize(25, 25)
                LFGReport.buttons[i]:SetAlpha(1)
                LFGReport.buttons[i]:SetScript("OnClick", function(self)
                    LFGReport:Report(self:GetParent().resultID)
                end)
                LFGReport.buttons[i].id = buttons[i].resultID
                LFGReport.buttons[i].tooltipText = "test"

            else
                self.buttons[i]:Show()
            end

            -- Anchor DataDisplay to the report button
            buttons[i].DataDisplay:ClearAllPoints()
            buttons[i].DataDisplay:SetPoint("RIGHT", self.buttons[i], "LEFT",
                                            10, -1)
        end
    else
        for i = 1, #self.buttons do
            self.buttons[i]:Hide()
            -- Reset DataDisplay to original anchor
            buttons[i].DataDisplay:ClearAllPoints()
            buttons[i].DataDisplay:SetPoint("RIGHT", buttons[i], "RIGHT", 0, -1)
        end
    end
end

function LFGReport:GenerateSelectedButton()
    if (self.conf.profile.selected) then
        local panel = _G.LFGListFrame.SearchPanel
        if (self.selected == nil) then
            self.selected = CreateFrame("Button", "btn",
                                        _G.LFGListFrame.SearchPanel,
                                        "UIPanelSquareButton")
            self.selected:SetPoint("RIGHT",
                                   _G.LFGListFrame.SearchPanel.RefreshButton,
                                   "LEFT", -5, 0)
            self.selected:SetSize(25, 25)
            self.selected:SetScript("OnClick", function()
                -- Report currently selected entry
                local id = panel.selectedResult
                LFGReport:Report(id)

                -- Remove selection
                panel.selectedResult = nil
            end)
        end
        self.selected:Show()
    else
        if (self.selected) then self.selected:Hide() end
    end
end

-- * --------------------------------------------------------------------------
-- * Events handling
-- * --------------------------------------------------------------------------

function LFGReport:OnReceiveSearchResults()
    LFGReport:GenerateSelectedButton()
    LFGReport:GenerateEntryButtons()
end

LFGReport:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED",
                        "OnReceiveSearchResults")

-- * --------------------------------------------------------------------------
-- * Slash commands
-- * --------------------------------------------------------------------------

LFGReport:RegisterChatCommand("lfgreport", "TestSlash")

function LFGReport:TestSlash(input) LFGReport:Print("helo") end
