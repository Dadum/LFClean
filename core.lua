LFClean =
    LibStub("AceAddon-3.0"):NewAddon(
    "LFClean",
    "AceConsole-3.0",
    "AceEvent-3.0",
    "AceTimer-3.0"
)
GUI = LibStub("AceGUI-3.0")

-- * --------------------------------------------------------------------------
-- * Init
-- * --------------------------------------------------------------------------

function LFClean:OnInitialize()
    self.buttons = {}
    self.selectedButton = nil

    self:InitConfig()
    self:InitDB()
    self:SetupHooks()
end

-- * --------------------------------------------------------------------------
-- * LFClean utility
-- * --------------------------------------------------------------------------

-- * Hook the LFGList SearchPanel update function to generate buttons.
function LFClean:SetupHooks()
    hooksecurefunc(
        "LFGListSearchPanel_UpdateResults",
        function(panel)
            self:GenerateButtons()
        end
    )
    hooksecurefunc(
        "LFGListUtil_SortSearchResults",
        function(results)
            self:AnalyzeResults(results)
        end
    )
    _G.LFGListFrame.SearchPanel:HookScript(
        "OnShow",
        function(panel)
            -- Launch the blacklist analysis with a delay. This seems to be
            -- necessary as results are loading for the first time, and group
            -- leaders names are not yet available
            self:ScheduleTimer("DelayedAnalysis", 1, panel)
        end
    )
end

-- * Add the given name to the blacklist
function LFClean:BlacklistName(name)
    self.conf.profile.blacklist[name] = true
    self:PrintV(name .. " blacklisted", 1)
end

-- * Print fiunction considering verbosity
function LFClean:PrintV(message, verbosity)
    if self.conf.profile.verbosity >= verbosity then
        self:Print(message)
    end
end

-- * Report the group with the given id.
function LFClean:Report(id)
    local panel = _G.LFGListFrame.SearchPanel
    if id then
        local details = C_LFGList.GetSearchResultInfo(id)

        C_LFGList.ReportSearchResult(id, self.conf.profile.reportType)
        self:PrintV("Reported group: " .. details.name, 1)

        LFGListSearchPanel_UpdateResultList(panel)
        self:GenerateButtons()
    else
        self:PrintV("No group selected", 0)
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
    GameTooltip:AddLine(
        "Blacklisted: " ..
            (self.conf.profile.blacklist[details.leaderName] and "yes" or "no"),
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
                    function(self, arg1)
                        local id = self:GetParent().resultID
                        if arg1 == "LeftButton" then
                            LFClean:Report(id)
                            -- Add leader to the blacklist if option is enabled
                            if LFClean.conf.profile.reportBL then
                                local details =
                                    C_LFGList.GetSearchResultInfo(id)
                                LFClean:BlacklistName(details.leaderName)
                            end
                        elseif
                            arg1 == "RightButton" and
                                LFClean.conf.profile.rightClickBL
                         then
                            -- Add leader to the blacklist if option is enabled
                            local details = C_LFGList.GetSearchResultInfo(id)
                            LFClean:BlacklistName(details.leaderName)
                        end
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
            if panel.ScrollFrame.buttons[i].isApplication then
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
                function(self, arg1)
                    local id = panel.selectedResult

                    if arg1 == "LeftButton" then
                        -- Report currently selected entry
                        LFClean:Report(id)
                        -- Add leader to the blacklist if option is enabled
                        if LFClean.conf.profile.reportBL then
                            local details = C_LFGList.GetSearchResultInfo(id)
                            LFClean:BlacklistName(details.leaderName)
                        end
                    elseif
                        arg1 == "RightButton" and
                            LFClean.conf.profile.rightClickBL
                     then
                        -- Blacklist leader of currently selected entry-- Add leader to the blacklist if option is enabled
                        local details = C_LFGList.GetSearchResultInfo(id)
                        LFClean:BlacklistName(details.leaderName)
                    end

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

-- * Launch the analysis with a delay.
function LFClean:DelayedAnalysis(panel)
    self:AnalyzeResults(panel.results, true --[[forcePrint]])
    LFGListSearchPanel_UpdateResults(panel)
end

-- * Analyze the LFG search results, reporting/hiding all groups with a blacklisted
-- * leader (if the option is enabled).
function LFClean:AnalyzeResults(results, forcePrint)
    -- Exit if there are no results or auto-hide is diabled
    if #results == 0 or not self.conf.profile.hideBL then
        return
    end

    -- Count how many entries were hidden
    local hidden = 0

    -- Loop through the results in search of blacklisted leaders
    local i = 1
    while i <= #results do
        local details = C_LFGList.GetSearchResultInfo(results[i])
        if self.conf.profile.blacklist[details.leaderName] then
            hidden = hidden + 1
            table.remove(results, i)

            if forcePrint or self.printHidden then
                -- Declare hidden group details if verbosity is pedantic
                self:PrintV("Hidden group: " .. details.name, 2)
            end
        else
            i = i + 1
        end
    end

    if hidden > 0 then
        if forcePrint or self.printHidden then
            -- Declare amount of hidden groups if verbosity is verbose
            self:PrintV("Hidden " .. hidden .. " groups", 1)
        end
        -- Toggle or init print toggle
        self.printHidden = self.printHidden == nil or not self.printHidden
        -- Update the total results
        _G.LFGListFrame.SearchPanel.totalResults =
            _G.LFGListFrame.SearchPanel.totalResults - hidden
    end
end

-- * Helper to generate both the entry buttons and the select button
function LFClean:GenerateButtons()
    self:GenerateSelectedButton()
    self:GenerateEntryButtons()
end
