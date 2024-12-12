---获取是否当怪物掉落黄金
function GetDropGold()
	return GlobalsGetValue("conjurer_reborn_animals_spawn_gold", "0") == "1"
end

---设置是否当怪物掉落黄金
---@param value boolean
function SetDropGold(value)
    local text = "0"
	if value then
		text = "1"
	end
	GlobalsSetValue("conjurer_reborn_animals_spawn_gold", text)
end
