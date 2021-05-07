LFClean =
    LibStub("AceAddon-3.0"):NewAddon(
    "LFClean",
    "AceConsole-3.0",
    "AceEvent-3.0"
)
GUI = LibStub("AceGUI-3.0")

-- * --------------------------------------------------------------------------
-- * Init
-- * --------------------------------------------------------------------------

function LFClean:OnInitialize()
    self.buttons = {}
    self.selectedButton = nil

    LFClean:InitConfig()
    LFClean:InitDB()
    self:SetUpdatefunction()
end

-- * --------------------------------------------------------------------------
-- * LFClean utility
-- * --------------------------------------------------------------------------

function LFClean:SetUpdatefunction()
    local panel = _G.LFGListFrame.SearchPanel
    local oldUpdate = panel.ScrollFrame.update
    panel.ScrollFrame.update = function()
        oldUpdate()
        LFClean:GenerateButtons()
    end
end

-- * Report the group with the given id.
function LFClean:Report(id)
    local panel = _G.LFGListFrame.SearchPanel
    if id then
        local details = C_LFGList.GetSearchResultInfo(id)

        C_LFGList.ReportSearchResult(id, self.conf.profile.reportType)
        self:Print("Reported group: " .. details.name)

        LFGListSearchPanel_UpdateResultList(panel)
        LFGListSearchPanel_UpdateResults(panel)
    else
        self:Print("No group selected")
    end
end

-- * Generate a tooltip to show the selected group id
function LFClean:GenerateReportTooltip(id)
    local details = C_LFGList.GetSearchResultInfo(id)
    GameTooltip:AddLine(
        "Report group: " .. details.name,
        nil,
        nil,
        nil --[[wrapText]],
        true
    )
    GameTooltip:AddLine("Group id: " .. id, 1, 1, 1 --[[wrapText]], true)
    if (details.leaderName) then
        GameTooltip:AddLine(
            "Leader: " .. details.leaderName,
            1,
            1,
            1 --[[wrapText]],
            true
        )
    else
        GameTooltip:AddLine("Leader: not found", 1, 1, 1 --[[wrapText]], true)
    end
    GameTooltip:AddLine(
        "Voice: " .. details.voiceChat,
        1,
        1,
        1 --[[wrapText]],
        true
    )
    GameTooltip:Show()
end

-- * Generate report button for each entry in the LFG list
function LFClean:GenerateEntryButtons()
    local panel = _G.LFGListFrame.SearchPanel
    if (self.conf.profile.entryButtons) then
        for i = 1, #panel.ScrollFrame.buttons do
            -- Only generate a button if it is missing
            if self.buttons[i] == nil then
                self.buttons[i] =
                    CreateFrame(
                    "Button",
                    "entryButton" .. i,
                    panel.ScrollFrame.buttons[i],
                    "LFClean_ReportButton"
                )
                self.buttons[i]:SetPoint(
                    "RIGHT",
                    panel.ScrollFrame.buttons[i],
                    "RIGHT",
                    -1,
                    -1
                )
                self.buttons[i]:SetScript(
                    "OnClick",
                    function(self)
                        LFClean:Report(self:GetParent().resultID)
                    end
                )
                self.buttons[i]:SetScript(
                    "OnEnter",
                    function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        LFClean:GenerateReportTooltip(self:GetParent().resultID)
                    end
                )
                self.buttons[i]:SetScript("OnLeave", GameTooltip_Hide)
            end

            -- Hide the button if currently queued for the group
            if panel.ScrollFrame.buttons[i].PendingLabel:IsShown() then
                self.buttons[i]:Hide()
            else
                self.buttons[i]:Show()
            end

            -- Anchor DataDisplay to the report button
            panel.ScrollFrame.buttons[i].DataDisplay:ClearAllPoints()
            panel.ScrollFrame.buttons[i].DataDisplay:SetPoint(
                "RIGHT",
                self.buttons[i],
                "LEFT",
                10,
                -1
            )

            -- Set new max name width to avoid overlapping
            if panel.ScrollFrame.buttons[i].resultID then
                local details =
                    _G.C_LFGList.GetSearchResultInfo(
                    panel.ScrollFrame.buttons[i].resultID
                )
                local nameWidth = details.voiceChat == "" and 155 or 133
                if (panel.ScrollFrame.buttons[i].Name:GetWidth() > nameWidth) then
                    panel.ScrollFrame.buttons[i].Name:SetWidth(nameWidth)
                end
            end
        end
    else
        for i = 1, #self.buttons do
            self.buttons[i] = nil
            -- Reset DataDisplay to original anchor
            panel.ScrollFrame.buttons[i].DataDisplay:ClearAllPoints()
            panel.ScrollFrame.buttons[i].DataDisplay:SetPoint(
                "RIGHT",
                panel.ScrollFrame.buttons[i],
                "RIGHT",
                0,
                -1
            )
        end
    end
end

-- * Generate button to report the selected group
function LFClean:GenerateSelectedButton()
    if (self.conf.profile.selectedButton) then
        local panel = _G.LFGListFrame.SearchPanel
        if (self.selectedButton == nil) then
            self.selectedButton =
                CreateFrame(
                "Button",
                "selectedButton",
                _G.LFGListFrame.SearchPanel,
                "LFClean_ReportButton"
            )
            self.selectedButton:SetPoint(
                "RIGHT",
                _G.LFGListFrame.SearchPanel.RefreshButton,
                "LEFT",
                -5,
                0
            )
            self.selectedButton:SetScript(
                "OnClick",
                function()
                    -- Report currently selected entry
                    local id = panel.selectedResult
                    LFClean:Report(id)

                    -- Remove selection
                    panel.selectedResult = nil
                end
            )
            self.selectedButton:SetScript(
                "OnEnter",
                function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                    if (panel.selectedResult) then
                        LFClean:GenerateReportTooltip(panel.selectedResult)
                    else
                        GameTooltip:SetText("Select a group to report")
                    end
                end
            )
            self.selectedButton:SetScript("OnLeave", GameTooltip_Hide)
        end

        -- Disable selected button if no entry is selected
        if (panel.selectedResult) then
            self.selectedButton:Enable()
        else
            self.selectedButton:Disable()
        end
        self.selectedButton:Show()
    else
        if (self.selectedButton) then
            self.selectedButton:Hide()
        end
    end
end

-- * --------------------------------------------------------------------------
-- * Events handling
-- * --------------------------------------------------------------------------

function LFClean:GenerateButtons()
    self:GenerateSelectedButton()
    self:GenerateEntryButtons()
end

LFClean:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED", "GenerateButtons")

LFClean:RegisterEvent("LFG_LIST_SEARCH_RESULT_UPDATED", "GenerateButtons")
