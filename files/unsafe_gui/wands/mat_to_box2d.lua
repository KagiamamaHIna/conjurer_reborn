
function ConvertMaterial()
	local x, y = DEBUG_GetMouseWorld()
	local material = GlobalsGetValue("conjurer_reborn_TempBox2DMaterialID", "__conjurer_reborn_no_mat")
	if material == "__conjurer_reborn_no_mat" then
		return
	end
	-- Instead of tracking everywhere where the player drew, we just
	-- take a huge area where we convert everything. Lazy, but covers 99% of
	-- the legit cases (which wouldn't crash the game anyway).
	ConvertMaterialOnAreaInstantly(
		x - 1000, y - 1000,
		2000, 2000,
		CellFactory_GetType("conjurer_reborn_construction_steel"), CellFactory_GetType(material),
		true,
		false
	)
end
