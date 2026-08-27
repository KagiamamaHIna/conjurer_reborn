---@module 'MemoryPattern'
local mp = dofile_once("mods/conjurer_reborn/files/unsafe/MemoryPattern.lua")
local ffi = require("ffi")
ffi.cdef[[
struct DebugSettings_vtable{
    void (__thiscall *destroy)(struct DebugSettings*, char dealloc);//+0
    void* field1_4;
    void* field2_8;
    void* field3_12;
    void* field4_16;
    void* field5_20;
    void* field6_24;
    void* field7_28;
    void* field8_32;
    void* field9_36;
    void* field10_40;
    void* field11_44;
    void* field12_48;
    void* field13_52;
    void* field14_56;
    void* field15_60;
    void* field16_64;
};

struct DebugSettings {
    struct DebugSettings_vtable* vtable;//+0
    bool mDrawPathFindingGrid;//+4
    bool mDrawPathFindingPaths;//+5
    bool mDrawPathFindingCompJumpTrajectories;//+6
    char padding1;//+7
    float DEBUG_RAGDOLL_EXTRA_FORCE;//+8
    bool mRenderPathFinding;//+12
    bool mPauseSimulation;//+13
    bool mPauseSomeSimulation;//+14 有用
    bool mCameraFreeIsSmoothed;//+15
    bool mCameraIsLockedInGameplay;//+16
    bool camera_light;//+17
    bool mAllowCameraMoveWhenLocked;//+18
    bool mCameraDisableCameraShake;//+19
    float mCameraTargetOffsetY;//+20
    float mCameraTargetOffsetX;//+24
    bool mPostFxDisabled;//+28 有用
    bool mGuiDisabled;//+29
    bool mGuiHalfSize;//+30
    bool mFogOfWarOpenEverywhere;//+31
    bool mTrailerMode;//+32
    bool mDayTimeRotationPaused;//+33
    bool mPlayerNeverDies;//34
    bool mFreezeAI;//+35
    bool mGameAudioVisualization;//+36
    bool mGameMusicDebug;//+37
    bool mGameMusicDebugFades;//+38
    bool mAudioPerformanceDebug;//+39
    float B2_Friction;//+40
    float mRecordingCameraStartX;//+44
    float mRecordingCameraStartY;//+48
    bool GLOBAL_WE_ARE_DOING_RESET;//+52
    bool mSettingWasChanged;//+53
};

typedef struct DebugSettings* GetDebugSetting();
]]
local ptr = mp.FindPatternInModule(nil, "E8 ? ? ? ? 83 ? 01 0F ? ? ? ? ? E8 ? ? ? ? 80")
if ptr == 0 then
    print_error("GetDebugSetting ptr in nullptr")
    return
end

return ffi.cast("GetDebugSetting*", mp.ResolveRelativeAddress(ptr + 14, 1, 5))()
