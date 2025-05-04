# Conjurer Reborn扩展接口系统

Conjurer Reborn提供了一系列接口来控制游戏中的某些方面。其中一些接口只需进行少量修改，即可使 Conjurer 的实现适配 Conjurer Reborn 的实现。

## 实体

向实体面板增加自定义的实体选项卡

grid_size字段将不再有任何效果:
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/wandhelper/ent_list_pre.lua",
    "path/to/my_entities.lua"
  )
end


-- my_entities.lua
--
table.insert(ALL_ENTITIES, {
  name="The Category Pane Name",
  desc="Voluntary tooltip description",
  icon="path/to/category_icon.png",
  icon_off="path/to/category_icon_off.png",  --灰色的图标，用于表示未选中状态
  entities={
    {
      name="My Entity",
      desc="Voluntary tooltip description",
      image="path/to/my/entity_icon.png",  -- 这必须是16x16px的图标
      path="path/to/my/entity.xml",
      spawn_func=function(x, y)
        -- 当简单的路径操作无法完成需求时使用，可以在此处执行任何自定义的实体加载操作（如天赋生成）
        -- 完全覆盖path字段
        -- 必须 返回你加载的实体id
        return EntityLoad("myentity.xml", x, y)
      end,
      post_processor=function(entity, x, y)
        -- 在实体生成后，你可以在这里对这个新生成的实体做你想做的处理
      end,
    },
    {
      name="My Second entity",
      path="path/to/my/entity2.xml",
      image="path/to/my/entity_icon2.png",  -- 这必须是16x16px的图标
    },
    -- ...... 等等
  },
})
```

## 敌人
敌人的id通常是他的文件名

### 不会显示的敌人

如果你想让某个特定的敌人不会显示在entwand中，你可以通过此接口设置
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/IgnoreEnemies.lua",
    "path/to/my_ignore_enemies.lua"
  )
end


-- my_ignore_enemies.lua
--
table.insert(IgnoreEnemies, "enemy_id")
```

### 增加额外的敌人文件

如果需要添加自动生成的敌人列表之外的文件，可以通过此接口添加，并可以将新添加的文件放置在列表最前面
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/ExtraEnemiesFile.lua",
    "path/to/my_extra_enemies.lua"
  )
end


-- my_extra_enemies.lua
--
ExtraEnemiesFile["enemy_id"] = {
  first = true, -- 如果设置为假，这些文件就会放在自动生成的列表之后
  list = {
    "path/to/enemy.xml"
  }
}
```

### 增加额外的敌人描述

增加一些描述，并且你可以设置其颜色
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/EnemiesDesc.lua",
    "path/to/my_enemies_desc.lua"
  )
end


-- my_enemies_desc.lua
--
EnemiesDesc["enemy_id"] = {
  text = "enemy_id's desc", -- 这里可以使用本地化Key
  rgba = "ff4500ff" -- #ff4500ff rgba颜色
}

EnemiesDesc["enemy_id2"] = {
  text = "enemy_id2's desc", -- 这里可以使用本地化Key
  argb = "ffff4500" -- #ff4500ff argb颜色
}

```

### 指定新敌人

增加一个不会被自动生成器生成的敌人的方法
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/NewOtherEnemies.lua",
    "path/to/my_new_enemies.lua"
  )
end


-- my_new_enemies.lua
--
table.insert(NewOtherEnemies,{
  id = "enemy_id",
  from_id = "modid",
  tags = nil, -- 当前未使用，以后也很有可能不会使用
  png = "path/to/enemy_icon.png",
  files = {
    "path/to/enemy.xml"
  }
})
```


## 材料

目前采用自动生成的方式，不支持添加新的材料选项卡

### 材料图标生成模式

在某些特殊情况下，最邻近插值缩放算法比平铺算法更适合材料图标生成。如果你有这样的需求，可以使用这里提供的接口
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/NearestMaterials.lua",
    "path/to/my_mats.lua"
  )
end


-- my_mats.lua
--
table.insert(NearestMaterials, "material_id")

```

### 强制设置材料的 from_id 字段

如果由于某种原因，你的mod中某些材料的mod ID设置不正确，而你想手动设置，那么你可以使用这个接口
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/MatModidSet.lua",
    "path/to/my_mats.lua"
  )
end


-- my_mats.lua
--
MatModidSet["material_id"] = "modid"

```

### 增加额外的材料描述

增加一些描述，并且你可以设置其颜色
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/unsafe/DataInterface/MaterialsDesc.lua",
    "path/to/my_mat_desc.lua"
  )
end


-- my_mat_desc.lua
--
MaterialsDesc["material_id"] = {
  text = "material_id's desc", -- 这里可以使用本地化Key
  rgba = "ff4500ff" -- #ff4500ff rgba颜色
}

MaterialsDesc["material_id2"] = {
  text = "material_id's desc", -- 这里可以使用本地化Key
  argb = "ffff4500" -- #ff4500ff argb颜色
}

```

## 画刷

增加自定义的画刷进画刷选中列表中。暂时没有选项卡
```lua
-- init.lua
--
if ModIsEnabled("conjurer_reborn") then
  ModLuaFileAppend(
    "mods/conjurer_reborn/files/scripts/lists/new_brushes.lua",
    "path/to/my_brushes.lua"
  )
end


-- my_brushes.lua
--
table.insert(BRUSHES, {
  name="My Custom Hexagonal Filler Brush",
  desc="Voluntary extra description",
  offset_x=2,  -- 预览标记(reticle)的手动偏移，因为并非所有标记都是要居中的
  offset_y=2,
  reticle_file="path/to/my/reticle2.png",
  brush_file="path/to/my/brush2.png",
  icon_file="path/to/my/icon.png",
  click_to_use=true,  -- 画刷是否应在按住或点击时激活。自己填写，默认为false。
  action=function(material, brush, x, y)
    -- 自己考虑，如果你想完全覆盖基本画刷机制的话
    -- 适用于 click_to_use 字段的设置

    GamePrint("Active material: " .. active_material)
    GamePrint("Brush name: " .. brush.name)
    GamePrint("Mouse: "..tostring(x)..", "..tostring(y))
  end,
  release_action=function(material, brush, x, y)
    -- 自己考虑，这里是后于action执行完成后执行的
    -- 在松开/点击 后执行的操作
    GamePrint("Active material: " .. active_material)
    GamePrint("Brush name: " .. brush.name)
    GamePrint("Mouse: "..tostring(x)..", "..tostring(y))
  end
})

table.insert(BRUSHES, {
  name="My Custom 5px Brush",
  offset_x=4,
  offset_y=4,
  reticle_file="path/to/my/reticle2.png",
  brush_file="path/to/my/brush2.png",
  icon_file="path/to/my/icon.png",
})
```
