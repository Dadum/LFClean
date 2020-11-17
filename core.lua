LFClean = LibStub("AceAddon-3.0"):NewAddon("LFClean", "AceConsole-3.0",
                                           "AceEvent-3.0")
GUI = LibStub("AceGUI-3.0")

-- * --------------------------------------------------------------------------
-- * Init
-- * --------------------------------------------------------------------------

function LFClean:OnInitialize()
    self.buttons = {}
    self.selectedButton = nil

    LFClean:InitConfig()
    LFClean:InitDB()
end

-- * --------------------------------------------------------------------------
-- * LFClean utility
-- * --------------------------------------------------------------------------

function LFClean:Report(id)
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

function LFClean:GenerateReportTooltip(id)
    local details = C_LFGList.GetSearchResultInfo(id)
    GameTooltip:AddLine("Hide group: " .. id, nil, nil, nil, --[[wrapText]] true)
    GameTooltip:AddLine(details.name, 1, 1, 1, --[[wrapText]] true)
    GameTooltip:Show()
end

function LFClean:GenerateEntryButtons()
    local panel = _G.LFGListFrame.SearchPanel
    local buttons = panel.ScrollFrame.buttons
    if (self.conf.profile.entryButtons) then
        for i = 1, #buttons do
            -- Only generate a button if it is missing
            if self.buttons[i] == nil then
                self.buttons[i] = CreateFrame("Button", "btn" .. i, buttons[i],
                                              "UIPanelSquareButton")
                self.buttons[i]:SetPoint("RIGHT", buttons[i], "RIGHT", -1, -1)
                self.buttons[i]:SetSize(25, 25)
                self.buttons[i]:SetAlpha(1)
                self.buttons[i]:SetScript("OnClick", function(self)
                    LFClean:Report(self:GetParent().resultID)
                end)
                self.buttons[i]:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                    LFClean:GenerateReportTooltip(self:GetParent().resultID)
                end)
                self.buttons[i]:SetScript("OnLeave", GameTooltip_Hide)
            end

            -- Hide the button if currently queued for the group
            if buttons[i].PendingLabel:IsShown() then
                self.buttons[i]:Hide()
            else
                self.buttons[i]:Show()
            end

            -- Anchor DataDisplay to the report button
            buttons[i].DataDisplay:ClearAllPoints()
            buttons[i].DataDisplay:SetPoint("RIGHT", self.buttons[i], "LEFT",
                                            10, -1)

            -- Set new max name width
            if buttons[i].resultID then
                local details = _G.C_LFGList.GetSearchResultInfo(
                                    buttons[i].resultID)
                local nameWidth = details.voiceChat == "" and 155 or 133
                if (buttons[i].Name:GetWidth() > nameWidth) then
                    buttons[i].Name:SetWidth(nameWidth)
                end
            end
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

function LFClean:GenerateSelectedButton()
    if (self.conf.profile.selectedButton) then
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
                LFClean:Report(id)

                -- Remove selection
                panel.selectedResult = nil
            end)
            self.selectedButton:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
                if (panel.selectedResult) then
                    LFClean:GenerateReportTooltip(panel.selectedResult)
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

function LFClean:OnReceiveSearchResults()
    self:GenerateSelectedButton()
    self:GenerateEntryButtons()

    -- Include button generation in scroll update function. This is required to
    -- ensure buttons are properly hidden for queued entries when scrolling.
    local panel = _G.LFGListFrame.SearchPanel
    panel.ScrollFrame.update = function()
        _G.LFGListSearchPanel_UpdateResults(panel)
        LFClean:GenerateEntryButtons()
    end
end

LFClean:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED",
                      "OnReceiveSearchResults")

function LFClean:OnApplicationStatusUpdate() self:GenerateEntryButtons() end

LFClean:RegisterEvent("LFG_LIST_APPLICATION_STATUS_UPDATED",
                      "OnApplicationStatusUpdate")
