---DDA画线算法
---@param px number
---@param py number
---@param mx number
---@param my number
---@param implement fun(x: number,y: number)
function DDA(px, py, mx, my, implement)
    local dx = mx - px
    local dy = my - py
    local k = dy / dx
    local direction = math.abs(k) > 1 and math.abs(dy) or math.abs(dx)
    local xadd = dx / direction
    local yadd = dy / direction
    local cx = px
    local cy = py
    for i = 0, direction do
        implement(cx, cy)
        cx = cx + xadd
        cy = cy + yadd
    end
end

---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@param implement fun(x: number,y: number)
local function nomodfCommonBresenham(p1x, p1y, p2x, p2y, implement)
    local dx = p2x - p1x
    local dy = p2y - p1y
    local stepX = dx >= 0 and 1 or -1
    local stepY = dy >= 0 and 1 or -1

    dx = math.abs(dx)
    dy = math.abs(dy)

    if dx > dy then
        local p = 2 * dy - dx
        local y = p1y
        for x = p1x, p2x, stepX do
            implement(x, y)
            if p > 0 then
                y = y + stepY
                p = p - 2 * dx
            end
            p = p + 2 * dy
        end
    else
        local p = 2 * dx - dy
        local x = p1x
        for y = p1y, p2y, stepY do
            implement(x, y)
            if p > 0 then
                x = x + stepX
                p = p - 2 * dy
            end
            p = p + 2 * dx
        end
    end
end

---通用的Bresenham画线算法，输入参数会取为整数
---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@param implement fun(x: number,y: number)
function CommonBresenham(p1x, p1y, p2x, p2y, implement)
    p1x = math.modf(p1x)
    p1y = math.modf(p1y)
    p2x = math.modf(p2x)
    p2y = math.modf(p2y)
    nomodfCommonBresenham(p1x, p1y, p2x, p2y, implement)
end

function GetDeduplicationBresenham()
    local map1 = {}
    local map2 = {}
    local map3 = {}
    local map4 = {}
    local function result(p1x, p1y, p2x, p2y, implement)
        p1x = math.modf(p1x)
        p1y = math.modf(p1y)
        p2x = math.modf(p2x)
        p2y = math.modf(p2y)
        if map1[p1x] and map2[p1y] and map3[p2x] and map4[p2y] then
            return
        end
        map1[p1x] = true
        map2[p1y] = true
        map3[p2x] = true
        map4[p2y] = true
        nomodfCommonBresenham(p1x, p1y, p2x, p2y, implement)
    end
    return result
end

---@param pAx number
---@param pAy number
---@param pBx number
---@param pBy number
---@param tA number
---@param tB number
---@param t number
---@return number
---@return number
local function lerpPoint(pAx, pAy, pBx, pBy, tA, tB, t)
    --避免重合点导致的除以零 (NaN) 错误
    if math.abs(tB - tA) < 1e-6 then
        return pAx, pAy
    end
    
    local factor = (t - tA) / (tB - tA)
    return pAx + (pBx - pAx) * factor,
           pAy + (pBy - pAy) * factor
end

--计算两点间欧氏距离的 alpha 次方，作为节点时间间隔
---@param tPrev number
---@param pAx number
---@param pAy number
---@param pBx number
---@param pBy number
---@param alpha number
---@return number
local function getT(tPrev, pAx, pAy, pBx, pBy, alpha)
    local dx = pBx - pAx
    local dy = pBy - pAy
    local dist = math.sqrt(dx * dx + dy * dy)
    -- dist^alpha: 当 alpha=0.5 时就是 sqrt(dist)
    return tPrev + math.pow(dist, alpha)
end

---向心CatmullRom
---@param p0x number
---@param p0y number
---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@param p3x number
---@param p3y number
---@param u number
---@param alpha number?
---@return number
---@return number
local function getCentripetalCatmullRomPoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, u, alpha)
    if alpha == nil then
        alpha = 0.5
    end
	local t0 = 0
    local t1 = getT(t0, p0x, p0y, p1x, p1y, alpha)
    local t2 = getT(t1, p1x, p1y, p2x, p2y, alpha)
    local t3 = getT(t2, p2x, p2y, p3x, p3y, alpha)

    --如果 p1 和 p2 重合，直接返回
    if math.abs(t2 - t1) < 1e-6 then
        return p1x, p1y
    end

    --将 u ∈ [0, 1] 映射到实际时间范围 t ∈ [t1, t2]
    local t = t1 + u * (t2 - t1)

    --金字塔三层线性插值 (Barry and Goldman 算法)
    --第一层插值
    local A1x, A1y = lerpPoint(p0x, p0y, p1x, p1y, t0, t1, t)
    local A2x, A2y = lerpPoint(p1x, p1y, p2x, p2y, t1, t2, t)
    local A3x, A3y = lerpPoint(p2x, p2y, p3x, p3y, t2, t3, t)

    --第二层插值
    local B1x, B1y = lerpPoint(A1x, A1y, A2x, A2y, t0, t2, t)
    local B2x, B2y = lerpPoint(A2x, A2y, A3x, A3y, t1, t3, t)

    --第三层插值 (最终在 P1 到 P2 上的曲线点)
    return lerpPoint(B1x, B1y, B2x, B2y, t1, t2, t)
end

---均匀CatmullRom
---@param p0x number
---@param p0y number
---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@param p3x number
---@param p3y number
---@param t number
---@return number
---@return number
local function getCatmullRomPoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, t)
    local t2 = t * t
    local t3 = t2 * t

    -- 分别计算 x 和 y 坐标
    local x = 0.5 * (
        (2 * p1x) +
        (-p0x + p2x) * t +
        (2 * p0x - 5 * p1x + 4 * p2x - p3x) * t2 +
        (-p0x + 3 * p1x - 3 * p2x + p3x) * t3
    )

    local y = 0.5 * (
        (2 * p1y) +
        (-p0y + p2y) * t +
        (2 * p0y - 5 * p1y + 4 * p2y - p3y) * t2 +
        (-p0y + 3 * p1y - 3 * p2y + p3y) * t3
    )

    return x, y
end

---均匀CatmullRom
---@param p0x number
---@param p0y number
---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@param p3x number
---@param p3y number
---@param implement fun(x: number,y: number)
function CatmullRomDrawSegment(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, implement)
    local lastX, lastY = p1x, p1y
    local steps = 20
    local DCB = GetDeduplicationBresenham()
	for i=1,steps do
		local t = i/steps
        local tx, ty = getCatmullRomPoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, t)
        DCB(lastX, lastY, tx, ty, implement)
        lastX = tx
		lastY = ty
	end
end

---向心CatmullRom
---@param p0x number
---@param p0y number
---@param p1x number
---@param p1y number
---@param p2x number
---@param p2y number
---@param p3x number
---@param p3y number
---@param implement fun(x: number,y: number)
---@param alpha number?
function CentripetalCatmullRomDrawSegment(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, implement, alpha)
    local lastX, lastY = p1x, p1y
    local steps = 20
    local DCB = GetDeduplicationBresenham()
	for i=1,steps do
		local t = i/steps
        local tx, ty = getCentripetalCatmullRomPoint(p0x, p0y, p1x, p1y, p2x, p2y, p3x, p3y, t, alpha)
        DCB(lastX, lastY, tx, ty, implement)
        lastX = tx
		lastY = ty
	end
end

---@alias __GDLPred fun():boolean
---@alias __GDLGetPos fun():x:integer,y:integer

---获取一个画线函数
---<br>第一个参数是谓词，用于启用判断
---<br>第二个参数是获取坐标函数
---<br>第三个参数是栅格化函数，用于实现功能
---<br>第四个参数是触发器，当满足触发条件时被调用
---@return fun(pred:__GDLPred, getPos: __GDLGetPos, implement:fun(x:integer, y:integer), trigger:fun()?) DrawLineInMouse
function GetDrawLine()
    local pushFr = 0
    local Pos1X, Pos1Y
    local Pos2X, Pos2Y
    local Pos3X, Pos3Y
    return function(pred, getPos, implement, trigger)
        if pred() or pushFr > 0 then
            if trigger then
                trigger()
            end
            local p1x, p1y
            local p2x, p2y
            local p3x, p3y
            local p4x, p4y = getPos()
            pushFr = pushFr + 1
            if pushFr == 1 then     --四点相同
                implement(p4x, p4y)
            elseif pushFr == 2 then --已知起始点和终止点，将怕p1设为起始，p4为终止
                p2x, p2y = Pos3X, Pos3Y
                p1x, p1y = p2x, p2y
                p3x, p3y = p4x, p4y
            elseif pushFr == 3 then --已知上一点 起始点 终止点 下一点p4设为终止
                p1x, p1y = Pos2X, Pos2Y
                p2x, p2y = Pos3X, Pos3Y
                p3x, p3y = p4x, p4y
            elseif pushFr >= 4 then --已知完整的4点
                p1x, p1y = Pos1X, Pos1Y
                p2x, p2y = Pos2X, Pos2Y
                p3x, p3y = Pos3X, Pos3Y
            end
            if pushFr ~= 1 then
                CentripetalCatmullRomDrawSegment(p1x, p1y, p2x, p2y, p3x, p3y, p4x, p4y, implement)
            end
            --退出条件
            if not pred() then
                pushFr = 0
            end
            Pos1X = Pos2X
            Pos1Y = Pos2Y
            Pos2X = Pos3X
            Pos2Y = Pos3Y
            Pos3X, Pos3Y = getPos()
        end
    end
end
