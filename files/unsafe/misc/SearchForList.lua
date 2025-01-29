dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")

---搜索列表
---@param list table
---@param keyword string
---@param score_min number
---@param callback function 回调函数应该返回分数
---@return table
local function SearchList(list, keyword, score_min, callback)
    if keyword == "" or keyword == nil then
        return list
    end
    local SearchItemList
    if ModSettingGet("conjurer_reborn.split_search_text") then
		SearchItemList = split(string.lower(keyword), " ")
    else
        SearchItemList = { string.lower(keyword) }
	end
    local ScoreToItem = {}      --分数转列表项
    local ScoreToItemCount = {} --优化用，是计数器
    local ScoreList = {}        --分数列表
    local ScoreListCount = 1    --优化用
    local HasScore = {}         --判断是否存在分数
    local ItemToScore = {}      --搜索项目转分数，缓存优化
    for _, v in pairs(list) do
        if ItemToScore[v] then  --排除已搜索过的项目
            goto continue
        end
		local score
		for _, ikeyword in ipairs(SearchItemList) do
            local new_score = callback(v, ikeyword)
			if score == nil then
                score = new_score
            elseif new_score and new_score > score then
				score = new_score
			end
		end
        if score == nil or not (score > score_min) then --返回nil代表这次无效或分数小于需求的时候直接下一次循环
            goto continue
        end
        if ScoreToItem[score] == nil then --如果为空，那么新建一个表，用于存储分数对列表
            ScoreToItem[score] = {}
            ScoreToItemCount[score] = 1
        end
		ItemToScore[v] = true
        ScoreToItem[score][ScoreToItemCount[score]] = v --新增项目到分数对列表中
        ScoreToItemCount[score] = ScoreToItemCount[score] + 1 --计数器优化
        if HasScore[score] == nil then                  --如果不存在，那么就将分数加入到列表中，方便后续排序
            ScoreList[ScoreListCount] = score
            ScoreListCount = ScoreListCount + 1
            HasScore[score] = true
        end
        ::continue::
    end
    --搜索完成后进行排序
    table.sort(ScoreList)
    local result = {}
    local resultCount = 1
    for i = #ScoreList, 1, -1 do --排序后遍历，将符合条件的加入结果项，因为之前有排除的地方，所以这里可以全部深拷贝
		for _, v in pairs(ScoreToItem[ScoreList[i]]) do
			result[resultCount] = v
			resultCount = resultCount + 1
		end
    end
    return result
end

---创建一个搜索输入框
---@param UI Gui
---@param id string
---@param list table
---@param x number
---@param y number
---@param width number
---@param score_min number
---@param refresh boolean
---@param callback function
---@return table list, string keyword
function SearchInputBox(UI, id, list, x, y, width, score_min, refresh, callback)
    local keyword = UI.TextInput(id, x, y, width, -1, "")
    local _, _, hover = UI.WidgetInfo()
    local LastKeyword = UI.UserData["LastSearchKeyword" .. id]
    UI.UserData["LastSearchKeyword" .. id] = keyword
	UI.UserData["HasInputBoxHover"] = UI.UserData["HasInputBoxHover"] or hover

    if hover and InputIsMouseButtonJustDown(Mouse_right) then
		ClickSound()
		UI.TextInputRestore(id)
	end

    local cacheListKey = "SearchListCache" .. id
	local cacheList = UI.UserData[cacheListKey]
    if cacheList == nil or LastKeyword ~= keyword or refresh then
        cacheList = SearchList(list, keyword, score_min, callback)
		UI.UserData[cacheListKey] = cacheList
    end
    local SavedKey = "SavedSearchHistory" .. id
	local SavedListKey = "SavedSearchHistoryList" .. id
    local HistoryPosKey = "SearchHistoryPos" .. id
	--初始化表
    if UI.UserData[SavedListKey] == nil then
        UI.UserData[SavedListKey] = {}
    end
	
    if hover then
        UI.UserData[SavedKey] = false
        if UI.UserData[HistoryPosKey] == nil and keyword ~= "" and InputIsKeyJustDown(Key_DOWN) then
            if keyword ~= UI.UserData[SavedListKey][#UI.UserData[SavedListKey]] then --需要判断是否是刚才保存过的，避免重复
                PushValueOnList(UI.UserData[SavedListKey], keyword)
                if #UI.UserData[SavedListKey] > 20 then                              --移除过多内容
                    table.remove(UI.UserData[SavedListKey], 1)
                end
            end
            UI.SetInputText(id, "")
        elseif #UI.UserData[SavedListKey] > 0 then --当列表有可选内容时会进行的操作
            if InputIsKeyJustDown(Key_UP) then
                if keyword ~= "" and UI.UserData[HistoryPosKey] == nil then
                    if keyword ~= UI.UserData[SavedListKey][#UI.UserData[SavedListKey]] then --需要判断是否是刚才保存过的，避免重复
                        PushValueOnList(UI.UserData[SavedListKey], keyword)
                        if #UI.UserData[SavedListKey] > 20 then                              --移除过多内容
                            table.remove(UI.UserData[SavedListKey], 1)
                        end
                    end
                    UI.UserData[HistoryPosKey] = math.max(1, #UI.UserData[SavedListKey] - 1)
                elseif UI.UserData[HistoryPosKey] == nil then
                    UI.UserData[HistoryPosKey] = #UI.UserData[SavedListKey]
                else
                    UI.UserData[HistoryPosKey] = math.max(1, UI.UserData[HistoryPosKey] - 1)
                end
                UI.SetInputText(id, UI.UserData[SavedListKey][UI.UserData[HistoryPosKey]])
            elseif InputIsKeyJustDown(Key_DOWN) and UI.UserData[HistoryPosKey] then
                UI.UserData[HistoryPosKey] = UI.UserData[HistoryPosKey] + 1
                if UI.UserData[HistoryPosKey] <= #UI.UserData[SavedListKey] then
                    UI.SetInputText(id, UI.UserData[SavedListKey][UI.UserData[HistoryPosKey]])
                else
                    UI.UserData[HistoryPosKey] = nil
                    UI.SetInputText(id, "")
                end
            end
        end
    end
	if not hover and not UI.UserData[SavedKey] then --历史搜索数据存储
        if (#UI.UserData[SavedListKey] > 0 and UI.UserData[SavedListKey][#UI.UserData[SavedListKey]] ~= keyword) or #UI.UserData[SavedListKey] == 0 then
            if keyword ~= "" and UI.UserData[HistoryPosKey] == nil then
                PushValueOnList(UI.UserData[SavedListKey], keyword)
                if #UI.UserData[SavedListKey] > 20 then --移除过多内容
                    table.remove(UI.UserData[SavedListKey], 1)
                end
            end
            if UI.UserData[SavedListKey][UI.UserData[HistoryPosKey]] ~= keyword then --文本不相同时再清除搜索key用于记录新的搜索文本
                UI.UserData[HistoryPosKey] = nil
            end
        end
        UI.UserData[SavedKey] = true
    end

    if hover and (InputIsKeyDown(Key_LCTRL) or InputIsKeyDown(Key_RCTRL)) and InputIsKeyJustDown(Key_v) then
		local Clipboard = Cpp.GetClipboard()
        Clipboard = Cpp.ANSIToUTF8(Clipboard)
		if Clipboard and Clipboard ~= "" then
			UI.SetInputText(id, keyword..Clipboard)
		end
	end
	return cacheList, keyword
end

return
