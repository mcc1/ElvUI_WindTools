local W, F, E, L = unpack(select(2, ...))
local TI = W:NewModule("TurnIn", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local strmatch, tonumber, next, select, tonumber, wipe = strmatch, tonumber, next, select, tonumber, wipe
local GetNumTrackingTypes, GetTrackingInfo = GetNumTrackingTypes, GetTrackingInfo
local GetNumAutoQuestPopUps, GetAutoQuestPopUp = GetNumAutoQuestPopUps, GetAutoQuestPopUp
local UnitGUID, UnitIsDeadOrGhost = UnitGUID, UnitIsDeadOrGhost
local AcceptQuest, CloseQuest, QuestGetAutoAccept = AcceptQuest, CloseQuest, QuestGetAutoAccept
local ShowQuestOffer, ShowQuestComplete = ShowQuestOffer, ShowQuestComplete
local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_GossipInfo_GetActiveQuests = C_GossipInfo.GetActiveQuests
local C_GossipInfo_GetNumActiveQuests = C_GossipInfo.GetNumActiveQuests
local C_GossipInfo_SelectActiveQuest = C_GossipInfo.SelectActiveQuest
local C_GossipInfo_GetAvailableQuests = C_GossipInfo.GetAvailableQuests
local C_GossipInfo_GetNumAvailableQuests = C_GossipInfo.GetNumAvailableQuests
local C_GossipInfo_SelectAvailableQuest = C_GossipInfo.SelectAvailableQuest
local C_GossipInfo_GetNumOptions = C_GossipInfo.GetNumOptions
local C_GossipInfo_GetOptions = C_GossipInfo.GetOptions
local C_GossipInfo_SelectOption = C_GossipInfo.SelectOption

local C_Timer_After = C_Timer.After

local ignoreQuestNPC = {
    [88570] = true, -- Fate-Twister Tiklal
    [87391] = true, -- Fate-Twister Seress
    [111243] = true, -- Archmage Lan'dalock
    [108868] = true, -- Hunter's order hall
    [101462] = true, -- Reaves
    [43929] = true, -- 4000
    [14847] = true, -- DarkMoon
    [119388] = true, -- 酋长哈顿
    [114719] = true, -- 商人塞林
    [121263] = true, -- 大技师罗姆尔
    [126954] = true, -- 图拉扬
    [124312] = true, -- 图拉扬
    [103792] = true, -- 格里伏塔
    [101880] = true, -- 泰克泰克
    [141584] = true, -- 祖尔温
    [142063] = true, -- 特兹兰
    [143388] = true, -- 德鲁扎
    [98489] = true, -- 海难俘虏
    [135690] = true, -- 亡灵舰长
    [105387] = true, -- 安杜斯
    [93538] = true, -- 达瑞妮斯
    [154534] = true, -- 大杂院阿畅
    [150987] = true, -- 肖恩·维克斯，斯坦索姆
    [150563] = true, -- 斯卡基特，麦卡贡订单日常
    [143555] = true -- 山德·希尔伯曼，祖达萨PVP军需官
}

local ignoreGossipNPC = {
    -- Bodyguards
    [86945] = true, -- Aeda Brightdawn (Horde)
    [86933] = true, -- Vivianne (Horde)
    [86927] = true, -- Delvar Ironfist (Alliance)
    [86934] = true, -- Defender Illona (Alliance)
    [86682] = true, -- Tormmok
    [86964] = true, -- Leorajh
    [86946] = true, -- Talonpriest Ishaal
    -- Sassy Imps
    [95139] = true,
    [95141] = true,
    [95142] = true,
    [95143] = true,
    [95144] = true,
    [95145] = true,
    [95146] = true,
    [95200] = true,
    [95201] = true,
    -- Misc NPCs
    [79740] = true, -- Warmaster Zog (Horde)
    [79953] = true, -- Lieutenant Thorn (Alliance)
    [84268] = true, -- Lieutenant Thorn (Alliance)
    [84511] = true, -- Lieutenant Thorn (Alliance)
    [84684] = true, -- Lieutenant Thorn (Alliance)
    [117871] = true, -- War Councilor Victoria (Class Challenges @ Broken Shore)
    [155101] = true, -- 元素精华融合器
    [155261] = true, -- 肖恩·维克斯，斯坦索姆
    [150122] = true, -- 荣耀堡法师
    [150131] = true -- 萨尔玛法师
}

local rogueClassHallInsignia = {
    [97004] = true, -- "Red" Jack Findle
    [96782] = true, -- Lucian Trias
    [93188] = true -- Mongar
}

local followerAssignees = {
    [138708] = true, -- 半兽人迦罗娜
    [135614] = true -- 马迪亚斯·肖尔大师
}

local darkmoonNPC = {
    [57850] = true, -- Teleportologist Fozlebub
    [55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
    [54334] = true -- Darkmoon Faire Mystic Mage (Alliance)
}

local itemBlacklist = {
    -- Inscription weapons
    [31690] = 79343, -- Inscribed Tiger Staff
    [31691] = 79340, -- Inscribed Crane Staff
    [31692] = 79341, -- Inscribed Serpent Staff
    -- Darkmoon Faire artifacts
    [29443] = 71635, -- Imbued Crystal
    [29444] = 71636, -- Monstrous Egg
    [29445] = 71637, -- Mysterious Grimoire
    [29446] = 71638, -- Ornate Weapon
    [29451] = 71715, -- A Treatise on Strategy
    [29456] = 71951, -- Banner of the Fallen
    [29457] = 71952, -- Captured Insignia
    [29458] = 71953, -- Fallen Adventurer's Journal
    [29464] = 71716, -- Soothsayer's Runes
    -- Tiller Gifts
    ["progress_79264"] = 79264, -- Ruby Shard
    ["progress_79265"] = 79265, -- Blue Feather
    ["progress_79266"] = 79266, -- Jade Cat
    ["progress_79267"] = 79267, -- Lovely Apple
    ["progress_79268"] = 79268, -- Marsh Lily
    -- Garrison scouting missives
    ["38180"] = 122424, -- Scouting Missive: Broken Precipice
    ["38193"] = 122423, -- Scouting Missive: Broken Precipice
    ["38182"] = 122418, -- Scouting Missive: Darktide Roost
    ["38196"] = 122417, -- Scouting Missive: Darktide Roost
    ["38179"] = 122400, -- Scouting Missive: Everbloom Wilds
    ["38192"] = 122404, -- Scouting Missive: Everbloom Wilds
    ["38194"] = 122420, -- Scouting Missive: Gorian Proving Grounds
    ["38202"] = 122419, -- Scouting Missive: Gorian Proving Grounds
    ["38178"] = 122402, -- Scouting Missive: Iron Siegeworks
    ["38191"] = 122406, -- Scouting Missive: Iron Siegeworks
    ["38184"] = 122413, -- Scouting Missive: Lost Veil Anzu
    ["38198"] = 122414, -- Scouting Missive: Lost Veil Anzu
    ["38177"] = 122403, -- Scouting Missive: Magnarok
    ["38190"] = 122399, -- Scouting Missive: Magnarok
    ["38181"] = 122421, -- Scouting Missive: Mok'gol Watchpost
    ["38195"] = 122422, -- Scouting Missive: Mok'gol Watchpost
    ["38185"] = 122411, -- Scouting Missive: Pillars of Fate
    ["38199"] = 122409, -- Scouting Missive: Pillars of Fate
    ["38187"] = 122412, -- Scouting Missive: Shattrath Harbor
    ["38201"] = 122410, -- Scouting Missive: Shattrath Harbor
    ["38186"] = 122408, -- Scouting Missive: Skettis
    ["38200"] = 122407, -- Scouting Missive: Skettis
    ["38183"] = 122416, -- Scouting Missive: Socrethar's Rise
    ["38197"] = 122415, -- Scouting Missive: Socrethar's Rise
    ["38176"] = 122405, -- Scouting Missive: Stonefury Cliffs
    ["38189"] = 122401, -- Scouting Missive: Stonefury Cliffs
    -- Misc
    [31664] = 88604 -- Nat's Fishing Journal
}

local ignoreProgressNPC = {
    [119388] = true,
    [127037] = true,
    [126954] = true,
    [124312] = true,
    [141584] = true,
    [326027] = true, -- 运输站回收生成器DX-82
    [150563] = true -- 斯卡基特，麦卡贡订单日常
}

local cashRewards = {
    [45724] = 1e5, -- Champion's Purse
    [64491] = 2e6, -- Royal Reward
    -- Items from the Sixtrigger brothers quest chain in Stormheim
    [138127] = 15, -- Mysterious Coin, 15 copper
    [138129] = 11, -- Swatch of Priceless Silk, 11 copper
    [138131] = 24, -- Magical Sprouting Beans, 24 copper
    [138123] = 15, -- Shiny Gold Nugget, 15 copper
    [138125] = 16, -- Crystal Clear Gemstone, 16 copper
    [138133] = 27 -- Elixir of Endless Wonder, 27 copper
}

local function IsTrackingHidden()
    for index = 1, GetNumTrackingTypes() do
        local name, _, active = GetTrackingInfo(index)
        if name == (_G.MINIMAP_TRACKING_TRIVIAL_QUESTS or _G.MINIMAP_TRACKING_HIDDEN_QUESTS) then
            return active
        end
    end
end

local function IsWorldQuestType(questID)
    local tagInfo = C_QuestLog_GetQuestTagInfo(questID)
    return tagInfo.worldQuestType and true or false
end

local function IsIgnored()
    local npcID = TI:GetNPCID()

    if ignoreQuestNPC[npcID] then
        return true
    end

    if TI.db and TI.db.customIgnoreNPCs and TI.db.customIgnoreNPCs[npcID] then
        return true
    end

    return false
end

local function GetAvailableGossipQuestInfo(index)
    return select(((index * 7) - 7) + 1, C_GossipInfo_GetAvailableQuests())
end

local function GetActiveGossipQuestInfo(index)
    return select(((index * 6) - 6) + 1, C_GossipInfo_GetActiveQuests())
end

local function AttemptAutoComplete(event)
    if GetNumAutoQuestPopUps() > 0 then
        if UnitIsDeadOrGhost("player") then
            TI:RegisterEvent("PLAYER_REGEN_ENABLED")
            return
        end

        local questID, popUpType = GetAutoQuestPopUp(1)
        local tagInfo = C_QuestLog_GetQuestTagInfo(questID)
        if not tagInfo.worldQuestType then
            if popUpType == "OFFER" then
                ShowQuestOffer(C_QuestLog_GetLogIndexForQuestID(questID))
            else
                ShowQuestComplete(C_QuestLog_GetLogIndexForQuestID(questID))
            end
        end
    else
        C_Timer_After(1, AttemptAutoComplete)
    end

    if event == "PLAYER_REGEN_ENABLED" then
        TI:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

local function GetQuestLogQuests(onlyComplete)
    wipe(quests)

    for index = 1, C_QuestLog_GetNumQuestLogEntries() do
        local questInfo = C_QuestLog_GetInfo(questIndex)
        if not questInfo.isHeader then
            if onlyComplete and questInfo.isComplete or not onlyComplete then
                quests[questInfo.title] = questInfo.questID
            end
        end
    end

    return quests
end

function TI:GetNPCID(unit)
    return tonumber(strmatch(UnitGUID(unit or "npc") or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function TI:QUEST_GREETING()
    if IsIgnored() then
        return
    end

    local active = C_GossipInfo_GetNumActiveQuests()
    if active > 0 then
        local logQuests = GetQuestLogQuests(true)
        for index = 1, active do
            local info = C_GossipInfo_GetActiveQuests(index)
            if info.isComplete then
                local questID = logQuests[info.title]
                if not questID then
                    C_GossipInfo_SelectActiveQuest(index)
                else
                    if not IsWorldQuestType(questID) then
                        C_GossipInfo_SelectActiveQuest(index)
                    end
                end
            end
        end
    end

    local available = C_GossipInfo_GetNumAvailableQuests()
    if available > 0 then
        for index = 1, available do
            local info = C_GossipInfo_GetAvailableQuests(index)
            if not info.isTrivial and not info.isIgnored or IsTrackingHidden() then
                C_GossipInfo_SelectActiveQuest(index)
            end
        end
    end
end

function TI:GOSSIP_SHOW()
    if IsIgnored() then
        return
    end

    print(self:GetNPCID())

    local active = C_GossipInfo_GetNumActiveQuests()
    if active > 0 then
        local logQuests = GetQuestLogQuests(true)
        for index = 1, active do
            local info = GetActiveGossipQuestInfo(index)
            if info.isComplete then
                local questID = logQuests[info.title]
                if not questID then
                    C_GossipInfo_SelectActiveQuest(index)
                else
                    if not IsWorldQuestType(questID) then
                        C_GossipInfo_SelectActiveQuest(index)
                    end
                end
            end
        end
    end

    local available = C_GossipInfo_GetNumAvailableQuests()
    if available > 0 then
        for index = 1, available do
            local info = GetAvailableGossipQuestInfo(index)
            if not info.isTrivial and not info.isIgnored or IsTrackingHidden() then
                C_GossipInfo_SelectAvailableQuest(index)
            elseif info.isTrivial and npcID == 64337 then
                C_GossipInfo_SelectAvailableQuest(index)
            end
        end
    end

    if rogueClassHallInsignia[npcID] then
        if not self.db or not self.db.rogueClassHallInsignia then
            return
        end
        return C_GossipInfo_SelectOption(1)
    end

    if available == 0 and active == 0 then
        if C_GossipInfo_GetNumOptions() == 1 then
            if npcID == 57850 then
                return C_GossipInfo_SelectOption(1)
            end

            local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
            if instance ~= "raid" and not ignoreGossipNPC[npcID] and not (instance == "scenario" and mapID == 1626) then
                local info = C_GossipInfo_GetOptions()
                if info.type == "gossip" then
                    C_GossipInfo_SelectOption(1)
                    return
                end
            end
        elseif followerAssignees[npcID] and C_GossipInfo_GetNumOptions() > 1 and self.db and self.db.followerAssignees then
            return C_GossipInfo_SelectOption(1)
        end
    end
end

function TI:GOSSIP_CONFIRM()
    local npcID = self:GetNPCID()
    if npcID and darkmoonNPC[npcID] and self.db and self.db.darkmoon then
        local dialog = StaticPopup_FindVisible("GOSSIP_CONFIRM")
        StaticPopup_OnClick(dialog, 1)
    end
end

function TI:QUEST_DETAIL()
    if IsIgnored() then
        return
    end

    if not QuestGetAutoAccept() then
        AcceptQuest()
    end
end

function TI:QUEST_ACCEPT_CONFIRM()
    AcceptQuest()
end

function TI:QUEST_ACCEPTED()
    if QuestFrame:IsShown() and QuestGetAutoAccept() then
        CloseQuest()
    end
end

function TI:QUEST_ITEM_UPDATE()
    if choiceQueue and self[choiceQueue] then
        self[choiceQueue]()
    end
end

function TI:QUEST_PROGRESS()
    if IsQuestCompletable() then
        local tagInfo = C_QuestLog_GetQuestTagInfo(GetQuestID())
        if tagInfo.tagID == 153 or tagInfo.worldQuestType then
            return
        end

        if IsIgnored() then
            return
        end

        local requiredItems = GetNumQuestItems()
        if requiredItems > 0 then
            for index = 1, requiredItems do
                local link = GetQuestItemLink("required", index)
                if link then
                    local id = tonumber(strmatch(link, "item:(%d+)"))
                    for _, itemID in next, itemBlacklist do
                        if itemID == id then
                            return
                        end
                    end
                else
                    choiceQueue = "QUEST_PROGRESS"
                    return
                end
            end
        end

        CompleteQuest()
    end
end

function TI:QUEST_COMPLETE()
    if IsIgnored() then
        return
    end

    -- Blingtron 6000 only!
    local npcID = self:GetNPCID()
    if npcID == 43929 or npcID == 77789 then
        return
    end

    local choices = GetNumQuestChoices()
    if choices <= 1 then
        GetQuestReward(1)
    elseif choices > 1 and self.db and self.db.selectReward then
        local bestSellPrice, bestIndex = 0

        for index = 1, choices do
            local link = GetQuestItemLink("choice", index)
            if link then
                local itemSellPrice = select(11, GetItemInfo(link))
                itemSellPrice = cashRewards[tonumber(strmatch(link, "item:(%d+):"))] or itemSellPrice

                if itemSellPrice > bestSellPrice then
                    bestSellPrice, bestIndex = itemSellPrice, index
                end
            else
                choiceQueue = "QUEST_COMPLETE"
                return GetQuestItemInfo("choice", index)
            end
        end

        local button = bestIndex and QuestInfoRewardsFrame.RewardButtons[bestIndex]
        if button then
            QuestInfoItem_OnClick(button)
        end
    end
end

function TI:PLAYER_LOGIN()
    AttemptAutoComplete("PLAYER_LOGIN")
end

function TI:QUEST_AUTOCOMPLETE()
    AttemptAutoComplete("QUEST_AUTOCOMPLETE")
end

function TI:PLAYER_REGEN_ENABLED()
    AttemptAutoComplete("PLAYER_REGEN_ENABLED")
end

function TI:Initialize()
    self.db = E.db.WT.quest.turnIn
    if not self.db.enable or self.initialized then
        return
    end

    self:RegisterEvent("QUEST_GREETING")
    self:RegisterEvent("GOSSIP_SHOW")
    self:RegisterEvent("GOSSIP_CONFIRM")
    self:RegisterEvent("QUEST_DETAIL")
    self:RegisterEvent("QUEST_ACCEPT_CONFIRM")
    self:RegisterEvent("QUEST_ACCEPTED")
    self:RegisterEvent("QUEST_ITEM_UPDATE")
    self:RegisterEvent("QUEST_PROGRESS")
    self:RegisterEvent("QUEST_COMPLETE")
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("QUEST_AUTOCOMPLETE")

    self.initialized = true
end

function TI:ProfileUpdate()
    self:Initialize()

    if self.initialized and not self.db.enable then
        self:UnregisterEvent("QUEST_GREETING")
        self:UnregisterEvent("GOSSIP_SHOW")
        self:UnregisterEvent("GOSSIP_CONFIRM")
        self:UnregisterEvent("QUEST_DETAIL")
        self:UnregisterEvent("QUEST_ACCEPT_CONFIRM")
        self:UnregisterEvent("QUEST_ACCEPTED")
        self:UnregisterEvent("QUEST_ITEM_UPDATE")
        self:UnregisterEvent("QUEST_PROGRESS")
        self:UnregisterEvent("QUEST_COMPLETE")
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("QUEST_AUTOCOMPLETE")
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

W:RegisterModule(TI:GetName())
