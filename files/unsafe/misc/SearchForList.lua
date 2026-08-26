dofile_once("mods/conjurer_reborn/files/unsafe/unsafe.lua")
dofile_once("mods/conjurer_reborn/files/unsafe/fn.lua")
dofile_once("mods/conjurer_reborn/files/unsafe_gui/utilities.lua")

---创建一个搜索输入框
---@param UI Gui
---@param id string
---@param list table
---@param x number
---@param y number
---@param width number
---@param refresh boolean
---@param callback function
---@return table list, string keyword
function SearchInputBox(UI, id, list, x, y, width, refresh, callback)
    local keyword = UI.TextInput(id, x, y, width, -1, "", nil, "$conjurer_reborn_search_no_text_tip")
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
    if keyword == "" or keyword == nil then
        cacheList = list
        UI.UserData[cacheListKey] = list
    elseif cacheList == nil or LastKeyword ~= keyword or refresh then
        cacheList = callback(keyword)
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
