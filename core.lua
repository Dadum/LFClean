LFGReport = LibStub("AceAddon-3.0"):NewAddon("LFGReport", "AceConsole-3.0",
                                             "AceEvent-3.0")
GUI = LibStub("AceGUI-3.0")

-- * Init ----------------------------------------------------------------------
function LFGReport:OnInitialize()
    -- self.db = LibStub("AceDB-3.0"):New("GuildDepositDB", self.defaults, true)
    -- self.conf = self.db.profile
    self.buttons = {}
end

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

function LFGReport:GenerateButtons()
    local panel = _G.LFGListFrame.SearchPanel
    local buttons = _G.LFGListFrame.SearchPanel.ScrollFrame.buttons
    for i = 1, #buttons do
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
            -- LFGReport.buttons[i]:Show()
            LFGReport.buttons[i].tooltipText = "test"

            -- LFGReport:Print("generated button " .. i)
            -- LFGReport:Print(LFGReport.buttons[i])

            buttons[i].DataDisplay:ClearAllPoints()
            buttons[i].DataDisplay:SetPoint("RIGHT", buttons[i], "RIGHT", -20,
                                            -1)
        end
    end
end

-- * Events ----------------------------------------------------------------------

function LFGReport:OnReceiveSearchResults()
    numResults, resultIDTable = C_LFGList.GetSearchResults()
    -- for k, v in pairs(resultIDTable) do
    --     local res = C_LFGList.GetSearchResultInfo(v)

    --     LFGReport:Print(res["searchResultID"])
    --     LFGReport:Print(res.name)
    --     LFGReport:Print("-----")
    -- end
    LFGReport:Print("Results: " .. numResults)
    local panel = _G.LFGListFrame.SearchPanel

    -- self.testF = GUI:Create("SimpleGroup")
    self.testF = CreateFrame("Frame")
    self.testF:SetParent(_G.LFGListFrame)
    self.testF:Size(25, 25)
    -- self.testF:SetWidth(25)
    -- self.testF:SetHeight(25)
    self.testF:Point("RIGHT", _G.LFGListFrame.SearchPanel.RefreshButton, "LEFT",
                     -5, 0)
    self.testF:CreateBackdrop("Solid")
    self.testF:SetAlpha(0)

    self.button = CreateFrame("Button", "btn", _G.LFGListFrame.SearchPanel,
                              "UIPanelSquareButton")
    self.button:SetPoint("RIGHT", _G.LFGListFrame.SearchPanel.RefreshButton,
                         "LEFT", -5, 0)
    self.button:SetSize(25, 25)
    self.button:SetScript("OnClick", function()
        local id = panel.selectedResult
        -- LFGReport:Print(id)
        LFGReport:Report(id)
        panel.selectedResult = nil
    end)

    --   self.button = GUI:Create("Button")
    -- self.button:SetParent(_G.LFGListFrame)
    -- self.button:SetWidth(25)
    -- self.button:SetText("X")
    -- self.button:SetAlpha(1)
    -- self.testF:AddChild(self.button)

    -- LFGReport:Print(_G.LFGListFrame.RefreshButton)
    -- for e in pairs(_G.LFGListFrame) do LFGReport:Print(e) end
    -- LFGReport:Print("---")
    -- for e in pairs(_G.LFGListFrame.SearchPanel) do LFGReport:Print(e) end
    -- LFGReport:Print("---")
    -- for e in pairs(_G.LFGListFrame.SearchPanel.ScrollFrame) do
    --     LFGReport:Print(e)
    -- end
    -- LFGReport:Print("---")
    -- for e in pairs(_G.LFGListFrame.SearchPanel.ResultsInset) do
    --     LFGReport:Print(e)
    -- end
    -- LFGReport:Print("---")
    -- for k, v in pairs(_G.LFGListFrame.SearchPanel.ScrollFrame.buttons) do
    --     LFGReport:Print(k)
    --     LFGReport:Print(v)
    --     for e in pairs(v) do LFGReport:Print(e) end
    -- end

    local buttons = _G.LFGListFrame.SearchPanel.ScrollFrame.buttons

    -- for i = 1, #buttons do
    --     local btn = CreateFrame("Button", "btn" .. i, buttons[i],
    --                             "UIPanelSquareButton")
    --     btn:SetPoint("RIGHT", btn, "RIGHT", -1, -1)
    --     btn:SetSize(25, 25)
    --     btn:SetAlpha(1)
    --     btn:SetScript("OnClick", function() LFGReport:Print(self.id) end)
    --     btn.buttons[i].id = buttons[i].resultID
    --     btn.buttons[i]:Show()

    --     LFGReport:Print("generated button " .. i)
    --     LFGReport:Print(LFGReport.buttons[i])

    --     buttons[i].DataDisplay:ClearAllPoints()
    --     buttons[i].DataDisplay:SetPoint("RIGHT", buttons[i], "RIGHT", -20, -1)
    -- end

    LFGReport:GenerateButtons()
    -- panel.ScrollFrame.update = function()
    --     LFGReport:Print("scrol")
    --     local results = panel.results
    --     local apps = panel.applications
    --     for i = 1, #buttons do
    --         local offset = HybridScrollFrame_GetOffset(panel.ScrollFrame);
    --         local idx = i + offset
    --         local btn = buttons[i]
    --         -- local LFGReport.buttons[i] = LFGReport.buttons[i]
    --         local id = btn.resultID

    --         LFGReport:Print("i: " .. i)
    --         LFGReport:Print("idx: " .. idx)
    --         LFGReport:Print("tot buttons: " .. #buttons)

    --         -- buttons[i].DataDisplay:ClearAllPoints()
    --         -- buttons[i].DataDisplay:SetPoint("RIGHT", buttons[i], "RIGHT", -20,
    --         --                                 -1)

    --         local result = (idx <= #apps) and apps[idx] or results[idx - #apps];

    --         if (result) then
    --             -- if LFGReport.buttons[i] == nil then
    --             --     LFGReport.buttons[i] = CreateFrame("Button", "btn", buttons[i],
    --             --                          "UIPanelSquareButton")
    --             --     LFGReport.buttons[i]:SetPoint("RIGHT", btn, "RIGHT", -1, -1)
    --             --     LFGReport.buttons[i]:SetSize(25, 25)
    --             --     LFGReport.buttons[i]:SetScript("OnClick",
    --             --                      function()
    --             --         LFGReport:Print LFGReport.buttons[i].id)
    --             --     end)
    --             -- end
    --             LFGReport.buttons[i].id = result
    --             LFGReport.buttons[i]:Show()
    --             LFGReport:Print("should show")
    --         else
    --             LFGReport.buttons[i].id = nil
    --             LFGReport.buttons[i]:Hide()
    --         end
    --     end
    --     _G.LFGListSearchPanel_UpdateResults(panel);
    -- end
    -- TODO: MOVE THIS TO SCROLL UPDATE
end

LFGReport:RegisterEvent("LFG_LIST_SEARCH_RESULTS_RECEIVED",
                        "OnReceiveSearchResults")

-- * Slash Commands ----------------------------------------------------------------------
LFGReport:RegisterChatCommand("lfgreport", "TestSlash")

function LFGReport:TestSlash(input)
    LFGReport:Print("helo")
    -- Process the slash command ('input' contains whatever follows the slash command)
end
