---@meta effil

---@alias effil.metric "ms" | "s" | "m" | "h"
---@alias effil.status "running" | "paused" | "cancelled" | "completed" | "failed"

---@alias effil.type
---| "nil"
---| "number"
---| "string"
---| "boolean"
---| "table"
---| "function"
---| "thread"
---| "userdata"
---| "effil.thread"
---| "effil.table"
---| "effil.channel"

---@class effil.thread Thread handle provides API for interaction with thread.
local effil_thread = {}

---Returns thread status.
---@return effil.status status string values describes status of thread. Possible values are: "running", "paused", "cancelled", "completed" and "failed".
---@return string? err error message, if any. This value is specified only if thread status == "failed".
---@return string? stacktrace stacktrace of failed thread. This value is specified only if thread status == "failed".
function effil_thread:status()end

---Waits for thread completion and returns function result or nothing in case of error.<br>
---input: Operation timeout in terms of time metrics
---@param time number?
---@param metric effil.metric? metric = "s"
---@return any Results of captured function invocation or nothing in case of error.
function effil_thread:get(time, metric)end

---Waits for thread completion and returns thread status.<br>
---input: Operation timeout in terms of time metrics
---@param time number?
---@param metric effil.metric? metric = "s"
---@return effil.status status Returns status of thread. The output is the same as thread:status()
function effil_thread:wait(time, metric)end

---Pauses thread. Once this function was invoked 'pause' flag is set and thread can be paused sometime in the future (even after this function call done). To be sure that thread is paused invoke this function with infinite timeout.<br>
---input: Operation timeout in terms of time metrics
---@param time number?
---@param metric effil.metric? metric = "s"
---@return boolean flag Returns true if thread was stopped or false.
function effil_thread:cancel(time, metric)end

---Pauses thread. Once this function was invoked 'pause' flag is set and thread can be paused sometime in the future (even after this function call done). To be sure that thread is paused invoke this function with infinite timeout.
---@param time number?
---@param metric effil.metric? metric = "s"
---@return boolean flag Returns true if thread was paused or false. If the thread is completed function will return false
function effil_thread:pause(time, metric)end

---Resumes paused thread. Function resumes thread immediately if it was paused. This function does nothing for completed thread. Function has no input and output parameters.
---@param time number?
---@param metric effil.metric? metric = "s"
function effil_thread:resume(time, metric)end

---@class effil.runner.data
---@field path string Is a Lua package.path value for new state. Default value inherits package.path form parent state.
---@field cpath string Is a Lua package.cpath value for new state. Default value inherits package.cpath form parent state.
---@field step number Number of lua instructions lua between cancelation points (where thread can be stopped or paused). Default value is 200. If this values is 0 then thread uses only explicit cancelation points.
local effil_runner = {}

---@alias effil.v_get_thread fun(...):effil.thread

---@alias effil.runner effil.v_get_thread | effil.runner.data Allows to configure and run a new thread.

---@class effil.table<K, V>: { [K]: V }
local e_table = {}

---@class effil.channel effil.channel is a way to sequentially exchange data between effil threads. It allows to push message from one thread and pop it from another. Channel's message is a set of values of supported types. All operations with channels are thread safe. See examples of channel usage here
local effil_channel = {}

---Pushes message to channel.
---@param ... any
---@return boolean flag pushed is equal to true if value(-s) fits channel capacity, false otherwise.
function effil_channel:push(...)end

---Pop message from channel. Removes value(-s) from channel and returns them. If the channel is empty wait for any value appearance.
---@param time number?
---@param metric effil.metric? metric = "s"
---@return ... message variable amount of values which were pushed by a single channel:push() call.
function effil_channel:pop(time, metric)end

---Get actual amount of messages in channel.
---@return integer size amount of messages in channel.
function effil_channel:size()end


---@class effil.gc
local effil_gc = {}

---Force garbage collection, however it doesn't guarantee deletion of all effil objects.
function effil_gc.collect()end

---Show number of allocated shared tables and channels.
---@return integer count returns current number of allocated objects. Minimum value is 1, effil.G is always present.
function effil_gc.count()end

---Get/set GC memory step multiplier. Default is 2.0. GC triggers collecting when amount of allocated objects growth in step times.
---@param new_value number? is optional value of step to set. If it's nil then function will just return a current value.
---@return number old_value is current (if new_value == nil) or previous (if new_value ~= nil) value of step.
function effil_gc.step(new_value)end

---Pause GC. Garbage collecting will not be performed automatically. Function does not have any input or output
function effil_gc.pause()end

---Resume GC. Enable automatic garbage collecting.
function effil_gc.resume()end

---Get GC state.
---@return boolean enabled return true if automatic garbage collecting is enabled or false otherwise. By default returns true.
function effil_gc.enabled()end

---@class effil
---@field G effil.table Is a global predefined shared table. This table always present in any thread (any Lua state).
---@field gc effil.gc
local effil = {}

---Gives unique identifier.
---@return string id returns unique string id for current thread.
function effil.thread_id()end

---Explicit cancellation point. Function checks cancellation or pausing flags of current thread and if it's required it performs corresponding actions (cancel or pause thread).
function effil.yield()end

---Suspend current thread.
---@param time number?
---@param metric effil.metric? metric = "s"
function effil.sleep(time, metric)end

---Returns the number of concurrent threads supported by implementation. Basically forwards value from std::thread::hardware_concurrency.
---@return number output: number of concurrent hardware threads.
function effil.hardware_threads()end

---Creates thread runner. Runner spawns new thread for each invocation.
---@param func function Lua function
---@return effil.runner runner thread runner object to configure and run a new thread
function effil.thread(func)end

---Works exactly the same way as standard pcall except that it will not catch thread cancellation error caused by thread:cancel() call.
---@param func function function to call
---@param ... any arguments to pass to functions
---@return boolean status if no error occurred, false otherwise
---@return ... in case of error return one additional result with message of error, otherwise return function call results
function effil.pcall(func, ...)end

---Creates new empty shared table.
---@param tbl table? is optional parameter, it can be only regular Lua table which entries will be copied to shared table.
---@return effil.table table new instance of empty shared table. It can be empty or not, depending on tbl content.
function effil.table(tbl)end

---Sets a new metatable to shared table. Similar to standard setmetatable.
---@param tbl effil.table should be shared table for which you want to set metatable.
---@param mtbl effil.table|table should be regular table or shared table which will become a metatable. If it's a regular table effil will create a new shared table and copy all fields of mtbl. Set mtbl equal to nil to delete metatable from shared table.
---@return effil.table tbl just returns tbl with a new metatable value similar to standard Lua setmetatable method.
function effil.setmetatable(tbl, mtbl)end

---Returns current metatable. Similar to standard getmetatable
---@param tbl effil.table
---@return effil.table mtbl returns metatable of specified shared table. Returned table always has type effil.table. Default metatable is nil.
function effil.getmetatable(tbl)end

---Set table entry without invoking metamethod __newindex. Similar to standard rawset
---@param tbl effil.table is shared table.
---@param key any key of table to override. The key can be of any supported type.
---@param value any value to set. The value can be of any supported type.
---@return effil.table tbl returns the same shared table tbl
function effil.rawset(tbl, key, value)end

---Gets table value without invoking metamethod __index. Similar to standard rawget
---@param tbl effil.table is shared table.
---@param key any key of table to receive a specific value. The key can be of any supported type.
---@return any value returns required value stored under a specified key
function effil.rawget(tbl, key)end

---Truns effil.table into regular Lua table.
---@param obj effil.table
---@return table result
function effil.dump(obj)end

---Creates a new channel.
---@param capacity integer? optional capacity of channel. If capacity equals to 0 or to nil size of channel is unlimited. Default capacity is 0.
---@return effil.channel channel returns a new instance of channel.
function effil.channel(capacity)end

---Returns number of entries in Effil object.
---@param obj effil.table|effil.channel obj is shared table or channel.
---@return integer size number of entries in shared table or number of messages in channel
function effil.size(obj)end

---Threads, channels and tables are userdata. Thus, type() will return userdata for any type. If you want to detect type more precisely use effil.type. It behaves like regular type(), but it can detect effil specific userdata.
---@param obj any
---@return effil.type type string name of type. If obj is Effil object then function returns string like effil.table in other cases it returns result of lua_typename function.
function effil.type(obj)end

return effil
