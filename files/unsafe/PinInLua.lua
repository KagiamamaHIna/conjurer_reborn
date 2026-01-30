---@module 'PinInLua'

local ffi = require("ffi")

ffi.cdef([[
   	struct PinInCpp_PinIn_NULL;
	typedef struct PinInCpp_PinIn_NULL* PinInCpp_PinIn;//PinInCpp_PinIn == std::shared_ptr<PinInCpp::PinIn> *
	//需要在C++层面共享所有权，所以是套的智能指针，但是一定要记得回收这个智能指针，不然会内存泄漏

	struct PinInCpp_TreeSearcher_NULL;
	typedef struct PinInCpp_TreeSearcher_NULL* PinInCpp_TreeSearcher;//PinInCpp_TreeSearcher == PinInCpp::TreeSearcher * 

    
	enum PinInCpp_TreeSeracher_Keyboard {//不提供C情况下的自定义方案，因为那可能过于麻烦，预设的也足够好了
		PinInCpp_NULLKeyboard,	//代表不改变Keyboard，特殊的枚举量
		PinInCpp_QUANPIN,		//基础的全拼方案 PinIn类的默认方案
		PinInCpp_DAQIAN,		//注音（大千）输入法方案
		PinInCpp_XIAOHE,		//小鹤双拼方案
		PinInCpp_ZIRANMA,		//自然码双拼方案
		PinInCpp_SOUGOU,		//搜狗双拼方案
		PinInCpp_ZHINENG_ABC,	//智能ABC双拼方案
		PinInCpp_GUOBIAO,		//国标双拼方案
		PinInCpp_MICROSOFT,		//微软双拼方案
		PinInCpp_PINYINPP,		//拼音加加双拼方案
		PinInCpp_ZIGUANG,		//紫光双拼方案
	};
	typedef enum PinInCpp_TreeSeracher_Keyboard PinInCpp_TreeSeracher_Keyboard;

	enum PinInCpp_TreeSeracher_Logic {
		PinInCpp_BEGIN,
		PinInCpp_CONTAIN,
		PinInCpp_EQUAL,
	};
	typedef enum PinInCpp_TreeSeracher_Logic PinInCpp_TreeSeracher_Logic;

	enum PinInCpp_DeserializeError {
		PinInCpp_DeserNormal,
		PinInCpp_FileNotOpen,
		PinInCpp_DeserBinaryVersionInvalidException,
		PinInCpp_DeserOutOfRange,
		PinInCpp_DeserBadAlloc
	};
	typedef enum PinInCpp_DeserializeError PinInCpp_DeserializeError;

	struct PinInCpp_Config {
		PinInCpp_TreeSeracher_Keyboard keyboard;//返回的时候默认 PinInCpp_NULLKeyboard 因为我也没办法确定Keyboard是谁
		char fZh2Z;//把他们当成bool用(
		char fSh2S;
		char fCh2C;
		char fAng2An;
		char fIng2In;
		char fEng2En;
		char fU2V;
		char fFirstChar;
	};
	typedef struct PinInCpp_Config PinInCpp_Config;

	//用PinInCpp_SearchResult_Free回收内存
	struct PinInCpp_SearchResult {
		size_t* ids;
		size_t size;
	};
	typedef struct PinInCpp_SearchResult PinInCpp_SearchResult;
	void PinInCpp_SearchResult_Free(PinInCpp_SearchResult result);

	//依赖字典文件路径初始化。获取资源时需要检查空指针
	PinInCpp_PinIn PinInCpp_PinIn_New(const char* path);
	void PinInCpp_PinIn_Free(PinInCpp_PinIn pinin);

	//依赖序列化文件初始化，第三个参数承担返回值的工作
	PinInCpp_DeserializeError PinInCpp_PinIn_Deserialize(const char* path, PinInCpp_TreeSeracher_Keyboard keyboard, PinInCpp_PinIn* pinin);
	int PinInCpp_PinIn_Serialize(PinInCpp_PinIn pinin, const char* path);//返回值为真则写入成功

	//检查有效性
	int PinInCpp_PinIn_Empty(PinInCpp_PinIn pinin);

	//配置接口
	PinInCpp_Config PinInCpp_PinIn_GetConfig(PinInCpp_PinIn pinin);
	void PinInCpp_PinIn_ConfigCommit(PinInCpp_PinIn pinin, PinInCpp_Config cfg);

	//PinIn缓存控制接口
	void PinInCpp_PinIn_PreCacheString(PinInCpp_PinIn pinin, const char* str);
	void PinInCpp_PinIn_PreNullPinyinIdCache(PinInCpp_PinIn pinin);
	int PinInCpp_PinIn_IsCharCacheEnabled(PinInCpp_PinIn pinin);
	void PinInCpp_PinIn_SetCharCache(PinInCpp_PinIn pinin, int enable);

	//获取资源时需要检查空指针
	PinInCpp_TreeSearcher PinInCpp_TreeSearcher_NewPath(PinInCpp_TreeSeracher_Logic logic, const char* path);
	PinInCpp_TreeSearcher PinInCpp_TreeSearcher_NewPinIn(PinInCpp_TreeSeracher_Logic logic, PinInCpp_PinIn pinin);
	void PinInCpp_TreeSearcher_Free(PinInCpp_TreeSearcher pinin);

	//依赖序列化文件初始化，第三个参数承担返回值的工作
	PinInCpp_DeserializeError PinInCpp_TreeSearcher_Deserialize(const char* path, PinInCpp_PinIn pinin, PinInCpp_TreeSearcher* tree);
	int PinInCpp_TreeSearcher_Serialize(PinInCpp_TreeSearcher tree, const char* path);//返回值为真则写入成功

	//需要检查空指针，从搜索树上获取PinIn
	PinInCpp_PinIn PinInCpp_TreeSearcher_GetPinIn(PinInCpp_TreeSearcher tree);

	//搜索树的搜索API
	size_t PinInCpp_TreeSearcher_PutString(PinInCpp_TreeSearcher tree, const char* str);//插入待搜索项
	PinInCpp_SearchResult PinInCpp_TreeSearcher_ExecuteSearch(PinInCpp_TreeSearcher tree, const char* str);//获取结果列表，需要手动调用PinInCpp_SearchResultFree
	size_t PinInCpp_TreeSearcher_GetStrSizeById(PinInCpp_TreeSearcher tree, size_t id);//使用PinInCpp_SearchResult里的id
	int PinInCpp_TreeSearcher_PutToCharBuf(PinInCpp_TreeSearcher tree, size_t id, char* buf, size_t bufSize);//根据提供的缓冲区填充字符串，如果数据因为缓冲区大小被截断了，那么返回的是-1。完整的插入了则是0

	//搜索树的其他控制接口
	void PinInCpp_TreeSearcher_StrPoolReserve(PinInCpp_TreeSearcher tree, size_t _Newcapacity);
	void PinInCpp_TreeSearcher_Refresh(PinInCpp_TreeSearcher tree);//手动尝试刷新
	void PinInCpp_TreeSearcher_ClearFreeList(PinInCpp_TreeSearcher tree);
	void PinInCpp_TreeSearcher_ShrinkToFit(PinInCpp_TreeSearcher tree);
]])
local PinInCpp = ffi.load("mods/conjurer_unsafe/files/module/PinIn4Cpp")

local function FreePinIn(cdata)
    PinInCpp.PinInCpp_PinIn_Free(cdata)
end

local function FreeTreeSearcher(cdata)
    PinInCpp.PinInCpp_TreeSearcher_Free(cdata)
end

local function FreeSearchResult(cdata)
    PinInCpp.PinInCpp_SearchResult_Free(cdata)
end

local PinInLua = {}

---@class PinIn
---@field cdata ffi.cdata*
local PinInFuncs = {}

local function CreatePinIn(pinin)
    if pinin == nil then
        return
    end
    pinin = ffi.gc(pinin, FreePinIn)
    return setmetatable({cdata = pinin}, {__index = PinInFuncs})
end

---@class PinIn.Logic: integer // == int

PinInLua.Logic = {
    ---@type PinIn.Logic
    ---@diagnostic disable-next-line: assign-type-mismatch
    BEGIN = PinInCpp.PinInCpp_BEGIN,    --前缀匹配
    ---@type PinIn.Logic
    ---@diagnostic disable-next-line: assign-type-mismatch
    CONTAIN = PinInCpp.PinInCpp_CONTAIN,--包含匹配
    ---@type PinIn.Logic
    ---@diagnostic disable-next-line: assign-type-mismatch
    EQUAL = PinInCpp.PinInCpp_EQUAL     --相等匹配
}

---@class PinIn.Keyboard: integer // == int

PinInLua.Keyboard = {
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
    NULLKeyboard = PinInCpp.PinInCpp_NULLKeyboard, --代表不改变Keyboard，特殊的枚举量
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
    QUANPIN = PinInCpp.PinInCpp_QUANPIN,           --基础的全拼方案 PinIn类的默认方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
    DAQIAN = PinInCpp.PinInCpp_DAQIAN,             --注音（大千）输入法方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
    XIAOHE = PinInCpp.PinInCpp_XIAOHE,             --小鹤双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
	ZIRANMA = PinInCpp.PinInCpp_ZIRANMA,		    --自然码双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
	SOUGOU = PinInCpp.PinInCpp_SOUGOU,		        --搜狗双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
	ZHINENG_ABC = PinInCpp.PinInCpp_ZHINENG_ABC,	--智能ABC双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
    GUOBIAO = PinInCpp.PinInCpp_GUOBIAO,           --国标双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
	MICROSOFT = PinInCpp.PinInCpp_MICROSOFT,		--微软双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
	PINYINPP = PinInCpp.PinInCpp_PINYINPP,		    --拼音加加双拼方案
    ---@type PinIn.Keyboard
    ---@diagnostic disable-next-line: assign-type-mismatch
	ZIGUANG = PinInCpp.PinInCpp_ZIGUANG,		    --紫光双拼方案
}

---@class PinIn.DeserError: integer // == int

PinInLua.DeserError = {
    ---@type PinIn.DeserError
    ---@diagnostic disable-next-line: assign-type-mismatch
    Normal = PinInCpp.PinInCpp_DeserNormal,
    ---@type PinIn.DeserError
    ---@diagnostic disable-next-line: assign-type-mismatch
    FileNotOpen = PinInCpp.PinInCpp_FileNotOpen,
    ---@type PinIn.DeserError
    ---@diagnostic disable-next-line: assign-type-mismatch
    BinaryVersionInvalidException = PinInCpp.PinInCpp_DeserBinaryVersionInvalidException,
    ---@type PinIn.DeserError
    ---@diagnostic disable-next-line: assign-type-mismatch
    OutOfRange = PinInCpp.PinInCpp_DeserOutOfRange,
    ---@type PinIn.DeserError
    ---@diagnostic disable-next-line: assign-type-mismatch
	BadAlloc = PinInCpp.PinInCpp_DeserBadAlloc
}

---@class PinIn.Config
---@field keyboard PinIn.Keyboard
---@field fZh2Z boolean;
---@field fSh2S boolean;
---@field fCh2C boolean;
---@field fAng2An boolean;
---@field fIng2In boolean;
---@field fEng2En boolean;
---@field fU2V boolean;
---@field fFirstChar boolean;
---@field pinin PinIn
local ConfigFuncs = {}

---@param keyboard PinIn.Keyboard
---@return PinIn.Config self
function ConfigFuncs:SetKeyboard(keyboard)
    self.keyboard = keyboard
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfZh2Z(enable)
    self.fZh2Z = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfSh2S(enable)
    self.fSh2S = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfCh2C(enable)
    self.fCh2C = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfAng2An(enable)
    self.fAng2An = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfIng2In(enable)
    self.fIng2In = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfEng2En(enable)
    self.fEng2En = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfU2V(enable)
    self.fU2V = enable
    return self
end
---@param enable boolean
---@return PinIn.Config self
function ConfigFuncs:SetfFirstChar(enable)
    self.fFirstChar = enable
    return self
end
---@return PinIn.Config self
function ConfigFuncs:Commit()
    self.pinin:ConfigCommit(self)
    return self
end

---如果PinIn为空则代表PinIn无效
---@return boolean
function PinInFuncs:Empty()
    local num = PinInCpp.PinInCpp_PinIn_Empty(self.cdata)
    return num ~= 0
end

---获取配置项，keyboard一般是NULLKeyboard
---@return PinIn.Config
function PinInFuncs:GetConfig()
    local rawCfg = PinInCpp.PinInCpp_PinIn_GetConfig(self.cdata)
    return setmetatable({
        keyboard = rawCfg.keyboard,
        fZh2Z = rawCfg.fZh2Z ~= 0,
        fSh2S = rawCfg.fSh2S ~= 0,
        fCh2C = rawCfg.fCh2C ~= 0,
        fAng2An = rawCfg.fAng2An ~= 0,
        fIng2In = rawCfg.fIng2In ~= 0,
        fEng2En = rawCfg.fEng2En ~= 0,
        fU2V = rawCfg.fU2V ~= 0,
        fFirstChar = rawCfg.fFirstChar ~= 0,
        pinin = self
    },{__index = ConfigFuncs})
end

---提交配置项
---@param cfg PinIn.Config
function PinInFuncs:ConfigCommit(cfg)
    local rawCfg = PinInCpp.PinInCpp_PinIn_GetConfig(self.cdata)
    rawCfg.keyboard = cfg.keyboard
    rawCfg.fZh2Z = cfg.fZh2Z and 1 or 0
    rawCfg.fSh2S = cfg.fSh2S and 1 or 0
    rawCfg.fCh2C = cfg.fCh2C and 1 or 0
    rawCfg.fAng2An = cfg.fAng2An and 1 or 0
    rawCfg.fIng2In = cfg.fIng2In and 1 or 0
    rawCfg.fEng2En = cfg.fEng2En and 1 or 0
    rawCfg.fU2V = cfg.fU2V and 1 or 0
    rawCfg.fFirstChar = cfg.fFirstChar and 1 or 0
    PinInCpp.PinInCpp_PinIn_ConfigCommit(self.cdata, rawCfg)
end

---序列化PinIn类到指定路径上
---@param path string
---@return boolean
function PinInFuncs:Serialize(path)
    return PinInCpp.PinInCpp_PinIn_Serialize(self.cdata, path) ~= 0
end

---手动预热字符串
---@param str string
function PinInFuncs:PreCacheString(str)
    PinInCpp.PinInCpp_PinIn_PreCacheString(self.cdata, str)
end

---手动预热空结果
function PinInFuncs:PreNullPinyinIdCache()
    PinInCpp.PinInCpp_PinIn_PreNullPinyinIdCache(self.cdata)
end

---返回是否启用缓存
---@return boolean
function PinInFuncs:IsCharCacheEnabled()
    return PinInCpp.PinInCpp_PinIn_IsCharCacheEnabled(self.cdata) ~= 0
end

---设置字符串缓存是否启用，一般来讲不建议关闭
---@param enable boolean
function PinInFuncs:SetCharCache(enable)
    PinInCpp.PinInCpp_PinIn_SetCharCache(self.cdata, enable and 1 or 0)
end

---构造一个PinIn对象
---@param path string
---@return PinIn?
function PinInLua.PinIn(path)
    return CreatePinIn(PinInCpp.PinInCpp_PinIn_New(path))
end

---@class TreeSearcher
---@field cdata ffi.cdata*
local TreeSearcherFuncs = {}

local function CreateTreeSearcher(tree)
    if tree == nil then
        return
    end
    tree = ffi.gc(tree, FreeTreeSearcher)
    return setmetatable({cdata = tree}, {__index = TreeSearcherFuncs})
end

---插入待搜索项，返回的是字符串id
---@param str string
---@return integer
function TreeSearcherFuncs:PutString(str)
    ---@diagnostic disable-next-line: return-type-mismatch 这个api返回的就是整数，无视警告即可
    return tonumber(PinInCpp.PinInCpp_TreeSearcher_PutString(self.cdata, str))
end


---获取PinIn上下文
---@return PinIn?
function TreeSearcherFuncs:GetPinIn()
    return CreatePinIn(PinInCpp.PinInCpp_TreeSearcher_GetPinIn(self.cdata))
end

---序列化搜索树
---@param path string
---@return boolean
function TreeSearcherFuncs:Serialize(path)
    return PinInCpp.PinInCpp_TreeSearcher_Serialize(self.cdata, path) ~= 0
end

---搜索并获取id列表
---@param str string
---@return integer[]
function TreeSearcherFuncs:ExecuteSearchGetIds(str)
    local resultData = PinInCpp.PinInCpp_TreeSearcher_ExecuteSearch(self.cdata, str)
    resultData = ffi.gc(resultData, FreeSearchResult)
    local result = {}
    local resultSize = tonumber(resultData.size)
    if resultSize == 0 then
        return result
    end
    for i = 0, resultSize - 1 do
        result[i + 1] = tonumber(resultData.ids[i])
    end
    return result
end

---根据指定id获取字符串，如果是从integer[]中获取字符串列表，不推荐用此方法，性能较差 应该用：TreeSearcherFuncs:GetStrListByIds
---@param id integer
function TreeSearcherFuncs:GetStrById(id)
    local cid = ffi.cast("size_t", id)
    local size = tonumber(PinInCpp.PinInCpp_TreeSearcher_GetStrSizeById(self.cdata, cid)) + 1
    local buf = ffi.new("char[?]", size)
    PinInCpp.PinInCpp_TreeSearcher_PutToCharBuf(self.cdata, cid, buf, size)
    return ffi.string(buf)
end

---将id列表转换为字符串列表
---@param ids integer[]
---@return string[]
function TreeSearcherFuncs:GetStrListByIds(ids)
    local result = {}
    local bufSize = -1
    local buf
    for i, id in ipairs(ids) do
        local cid = ffi.cast("size_t", id)
        local size = tonumber(PinInCpp.PinInCpp_TreeSearcher_GetStrSizeById(self.cdata, cid)) + 1
        if size > bufSize then --两倍大缓冲区策略
            bufSize = size * 2
            buf = ffi.new("char[?]", bufSize)
        end
        PinInCpp.PinInCpp_TreeSearcher_PutToCharBuf(self.cdata, id, buf, bufSize)
        result[i] = ffi.string(buf)
    end
    return result
end

---搜索并返回结果
---@param str string
---@return string[]
function TreeSearcherFuncs:ExecuteSearch(str)
    local resultData = PinInCpp.PinInCpp_TreeSearcher_ExecuteSearch(self.cdata, str)
    resultData = ffi.gc(resultData, FreeSearchResult)
    
    local bufSize = -1
    local buf

    local result = {}
    local resultSize = tonumber(resultData.size)
    if resultSize == 0 then
        return result
    end
    for i = 0, resultSize - 1 do
        local id = resultData.ids[i]
        local size = tonumber(PinInCpp.PinInCpp_TreeSearcher_GetStrSizeById(self.cdata, id)) + 1
        if size > bufSize then --两倍大缓冲区策略
            bufSize = size * 2
            buf = ffi.new("char[?]", bufSize)
        end
        PinInCpp.PinInCpp_TreeSearcher_PutToCharBuf(self.cdata, id, buf, bufSize)
        result[i + 1] = ffi.string(buf)
    end

    return result
end

---扩容内部字符串池，单位四字节
---@param _Newcapacity integer
function TreeSearcherFuncs:StrPoolReserve(_Newcapacity)
    PinInCpp.PinInCpp_TreeSearcher_StrPoolReserve(self.cdata, ffi.cast("size_t", _Newcapacity))
end

---手动刷新，config commit后会有一次自动刷新，调用这个可以提前完成
function TreeSearcherFuncs:Refresh()
    PinInCpp.PinInCpp_TreeSearcher_Refresh(self.cdata)
end

---已无效果
function TreeSearcherFuncs:ClearFreeList()
    PinInCpp.PinInCpp_TreeSearcher_ClearFreeList(self.cdata)
end

---收缩以适应内存，适合不再尝试增长数据的情况下使用
function TreeSearcherFuncs:ShrinkToFit()
    PinInCpp.PinInCpp_TreeSearcher_ShrinkToFit(self.cdata)
end

---构造一个TreeSearcher对象
---@param logic PinIn.Logic
---@param context string|PinIn 路径或一个PinIn对象
---@return TreeSearcher?
function PinInLua.TreeSearcher(logic, context)
    local tree
    if type(context) == "string" then
        tree = PinInCpp.PinInCpp_TreeSearcher_NewPath(logic, context)
    else
        tree = PinInCpp.PinInCpp_TreeSearcher_NewPinIn(logic, context.cdata)
    end
    return CreateTreeSearcher(tree)
end

---反序列化构造一个TreeSearcher对象
---@param path string
---@param pinin PinIn
---@return TreeSearcher?, PinIn.DeserError
function PinInLua.TreeSearcherDeserialize(path, pinin)
    local TreeGetter = ffi.new("PinInCpp_TreeSearcher[1]")
    local error = PinInCpp.PinInCpp_TreeSearcher_Deserialize(path, pinin.cdata, TreeGetter)
    if error ~= PinInCpp.PinInCpp_DeserNormal then
        return nil, error
    end
    return CreateTreeSearcher(TreeGetter[0]), error
end

---反序列化构造一个PinIn对象
---@param path string
---@param keyboard PinIn.Keyboard?
---@return PinIn?, PinIn.DeserError
function PinInLua.PinInDeserialize(path, keyboard)
    if keyboard == nil then
        keyboard = PinInLua.Keyboard.NULLKeyboard
    end
    local PininGetter = ffi.new("PinInCpp_PinIn[1]")
    local error = PinInCpp.PinInCpp_PinIn_Deserialize(path, keyboard, PininGetter)
    if error ~= PinInCpp.PinInCpp_DeserNormal then
        print(error)
        return nil, error
    end
    return CreatePinIn(PininGetter[0]), error
end

return PinInLua
