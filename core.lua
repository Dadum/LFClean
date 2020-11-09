LFGReport = LibStub("AceAddon-3.0"):NewAddon("LFGReport", "AceConsole-3.0",
                                             "AceEvent-3.0")
GUI = LibStub("AceGUI-3.0")

-- * --------------------------------------------------------------------------
-- * Init
-- * --------------------------------------------------------------------------

function LFGReport:OnInitialize()
    self.buttons = {}
    self.selectedButton = nil

    LFGReport:InitConfig()
    LFGReport:InitDB()
end

-- * --------------------------------------------------------------------------
-- * LFGReport utility
-- * --------------------------------------------------------------------------

function LFGReport:Report(id)
    local panel = _G.LFGListFrame.SearchPanel
    if id then
        local details = C_LFGList.GetSearchResultInfo(id)
        self:Print("Hidden group: " .. details.name)

        if (self.conf.profile.buttonsReport) then
            -- Report listing
            C_LFGList.ReportSearchResult(id, "lfglistspam");
        end
        -- Hide listing 
        LFGListSearchPanel_AddFilteredID(panel, id);
        LFGListSearchPanel_UpdateResultList(panel);
        LFGListSearchPanel_UpdateResults(panel);
    else
        self:Print("No group selected")
    end
end

function LFGReport:GenerateReportTooltip(id)
    local details = C_LFGList.GetSearchResultInfo(id)
    GameTooltip:AddLine("Report group: " .. id, nil, nil, nil, --[[wrapText]]
                        true)
    GameTooltip:AddLine(details.name, 1, 1, 1, --[[wrapText]] true)
    GameTooltip:Show()
end

function LFGReport:GenerateEntryButtons()
    local panel = _G.LFGListFrame.SearchPanel
    local buttons = _G.LFGListFrame.SearchPanel.ScrollFrame.buttons
    if (self.conf.profile.entry) then
        for i = 1, #buttons do
            -- Only generate a button if it is missing
            if self.buttons[i] == nil then
                self.buttons[i] = CreateFrame("Button", "btn" .. i, buttons[i],
                                              "UIPanelSquareButton")
                self.buttons[i]:SetPoint("RIGHT", buttons[i], "RIGHT", -1, -1)
                self.buttons[i]:SetSize(25, 25)
                self.buttons[i]:SetAlpha(1)
                self.buttons[i]:SetScript("OnClick", function(self)
                    LFGReport:Report(self:GetParent().resultID)
                end)
                self.buttons[i]:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    LFGReport:GenerateReportTooltip(self:GetParent().resultID)
                end)
                self.buttons[i]:SetScript("OnLeave", GameTooltip_Hide)
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
        if (self.selectedButton == nil) then
            self.selectedButton = CreateFrame("Button", "btn",
                                              _G.LFGListFrame.SearchPanel,
                                              "UIPanelSquareButton")
            self.selectedButton:SetPoint("RIGHT", _G.LFGListFrame.SearchPanel
                                             .RefreshButton, "LEFT", -5, 0)
            self.selectedButton:SetSize(25, 25)
            self.selectedButton:SetScript("OnClick", function()
                -- Report currently selected entry
                local id = panel.selectedResult
                LFGReport:Report(id)

                -- Remove selection
                panel.selectedResult = nil
            end)
            self.selectedButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                if (panel.selectedResult) then
                    LFGReport:GenerateReportTooltip(panel.selectedResult)
                else
                    GameTooltip:SetText("Select a group to report")
                end
            end)
            self.selectedButton:SetScript("OnLeave", GameTooltip_Hide)
        end
        self.selectedButton:Show()
    else
        if (self.selectedButton) then self.selectedButton:Hide() end
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
