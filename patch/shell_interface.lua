-- shell_interface.lua (1.3 Zerted patch ) 
-- Decompiled by cbadal with help from SWBF2Helper
-- verified 
--
-- Copyright (c) 2005 Pandemic Studios, LLC. All rights reserved.
--

-- Master include for StarWars: Frontline ingame interface, lua
-- component. The game should be able to include this file and nothing
-- else.
gUsingControllerExe = true
if(ScriptCB_GetCurrentAspect == nil) then
    print("You are using a 'BattlefrontII.exe' that does not have native Controller support.")
    gUsingControllerExe = false
    -- These are important to define when using the mod_tools debugger with the .lvls
    -- from the Feb 9 Controller update

	ScriptCB_GetCurrentAspect = function ()
		return 0.5625
	end

	ScriptCB_GetTargetAspect = function()
		return 0.75
	end
	--ScriptCB_ReadRightstick()
	ScriptCB_ResetGamepadToDefault = function()
	end

	ScriptCB_IsJoyUsed = function ()
		return false
	end

	--[[ unused
	ScriptCB_IsKeyboardUsed = function()
		return 1
	end ]]

	-- used in \ifs_missionselect_pcmulti.script
	function ScriptCB_GetJoyButtonPressed()
		return false
	end
else
    print("You are using a Battlefront 2 exe that supports a Controller!")
end

printf = function(...)
    print(string.format(unpack(arg)))
end

if( tprint == nil ) then 
    function getn(v)
        local v_type = type(v);
        if v_type == "table" then
            return table.getn(v);
        elseif v_type == "string" then
            return string.len(v);
        else
            return;
        end
    end

    function string.starts(str, Start)
        return string.sub(str, 1, getn(Start)) == Start;
    end

    function tprint(t, indent)
        if not indent then indent = 1, print(tostring(t) .. " {") end
        if t then
            for key,value in pairs(t) do
                if not string.starts(tostring(key), "__") then
                    local formatting = string.rep("    ", indent) .. tostring(key) .. "= ";
                    if value and type(value) == "table" then
                        print(formatting .. --[[tostring(value) ..]] " {")
                        tprint(value, indent+1);
                    else
                        if(type(value) == "string") then 
                            --print(formatting .."'" .. tostring(value) .."'" ..",")
                            printf("%s'%s',",formatting, tostring(value))
                        else 
                            print(formatting .. tostring(value) ..",")
                        end 
                    end
                end
            end
            print(string.rep("    ", indent - 1) .. "},")
        end
    end
end

pushed_screens = {}

old_ReadDataFile = ReadDataFile
ReadDataFile = function ( ... )
	print("ReadDataFile: ".. arg[1])
	return old_ReadDataFile(unpack(arg))
end
old_ScriptCB_PushScreen = ScriptCB_PushScreen
ScriptCB_PushScreen = function(screenName)
    local movieName = _G[screenName].movieBackground
    local texName = _G[screenName].bg_texture
    printf("ScriptCB_PushScreen: '%s' movie: %s bg_tex: %s", screenName,  tostring(movieName), tostring(texName) )
    
    table.insert(pushed_screens, screenName)
    retVal =  old_ScriptCB_PushScreen(screenName)
    --CheckMovie(_G[screenName])
    return retVal
end

old_ScriptCB_PopScreen = ScriptCB_PopScreen
ScriptCB_PopScreen = function(...)
    local last_index = table.getn(pushed_screens)
    table.remove(pushed_screens, last_index)
    last_index = table.getn(pushed_screens)
    print("ScriptCB_PopScreen count=", last_index)
    tprint(pushed_screens)
    return old_ScriptCB_PopScreen(unpack(arg))
end

local oldScriptCB_StopMovie = ScriptCB_StopMovie
ScriptCB_StopMovie = function(...)
    print("  ScriptCB_IsMoviePlaying():", tostring(ScriptCB_IsMoviePlaying()))
    return oldScriptCB_StopMovie(unpack(arg))
end

local oldScriptCB_CloseMovie = ScriptCB_CloseMovie
ScriptCB_CloseMovie = function(...)
    print("ScriptCB_CloseMovie() called")
    print("  ScriptCB_IsMoviePlaying():", tostring(ScriptCB_IsMoviePlaying()))
    return oldScriptCB_CloseMovie(unpack(arg))
end

function  CheckMovie(this)
    if this.movieBackground ~= nil then 
        if not ScriptCB_IsMoviePlaying()  then
            print("CheckMovie: try to play movie", tostring(this.movieBackground))
            ScriptCB_StopMovie()
            ifelem_shellscreen_fnStartMovie(this.movieBackground,1, nil, true)
        else
            print("CheckMovie: movie is playing")
        end
    end
end
-- added by zerted
print("shell_interface: Entered")
 __v13patchSettings_noColors__ = "..\\..\\addon\\AAA-v1.3patch\\settings\\noColors.txt"
ReadDataFile("v1.3patch_strings.lvl")
-----------

-- Read in some globals for what platform, online service will be in use
gPlatformStr = ScriptCB_GetPlatform()
gOnlineServiceStr = ScriptCB_GetOnlineService()
gLangStr,gLangEnum = ScriptCB_GetLanguage()

---- added by zerted
print(
    "shell_interface: gPlatformStr, gOnlineServiceStr, gLangStr, gLangEnum: ",
    gPlatformStr or "[Nil]" , gOnlineServiceStr or "[Nil]", gLangStr or "[Nil]",
	gLangEnum or "[Nil]"
)
----------------------

-- set model memory
SetPS2ModelMemory(2000 * 1024)

-- Josh's utility stuff
ScriptCB_DoFile("globals")
-- Load player stats points
ScriptCB_DoFile("points")
-- shell movie stream to use
if(gPlatformStr == "PS2") then
    if (ScriptCB_IsPAL() == 1) then
    gMovieStream = "movies\\shellpal.mvs"
    else
    gMovieStream = "movies\\shell.mvs"
    end
elseif (gPlatformStr == "PC") then
   local shellMovie = {
      english    = "movies\\shell.mvs",
      spanish    = "movies\\shellsp.mvs",
      italian    = "movies\\shellit.mvs",
      french     = "movies\\shellfr.mvs",
      german     = "movies\\shellgr.mvs",
   }
   gMovieStream = shellMovie[gLangStr] or shellMovie["english"]
else
    gMovieStream = "movies\\shell.mvs"
end

--
--
-- Load interface utility functions, elements (ifelem_*)
ScriptCB_DoFile("interface_util")
-- give the console title color 
gTitleTextColor = { 246, 235, 20} -- of listbox titles, buttonlist titles yellow

ScriptCB_DoFile("ifelem_button")
ScriptCB_DoFile("ifelem_roundbutton")
ScriptCB_DoFile("ifelem_flatbutton")
ScriptCB_DoFile("ifelem_buttonwindow")
ScriptCB_DoFile("ifelem_segline")
ScriptCB_DoFile("ifelem_popup")
ScriptCB_DoFile("ifelem_listmanager")
ScriptCB_DoFile("ifelem_AnimationMgr")
ScriptCB_DoFile("ifelem_helptext")
ScriptCB_DoFile("ifelem_shellscreen")
ScriptCB_DoFile("ifelem_titlebar")
ScriptCB_DoFile("ifelem_borderrect")
ScriptCB_DoFile("ifelem_hslider")
ScriptCB_DoFile("ifelem_form")
ScriptCB_DoFile("ifs_movietrans_game")
-- And utility functions for just the shell.
ScriptCB_DoFile("ifelem_mappreview")
ScriptCB_DoFile("ifelem_titlebar_large")
ScriptCB_DoFile("ifelem_iconbutton")

if(gPlatformStr == "PC") then
    ScriptCB_DoFile("ifelem_tabmanager")
    ScriptCB_DoFile("ifutil_mouse")
    ScriptCB_DoFile("ifelem_editbox")
end

---------- added by zerted --------------
ScriptCB_DoFile("ifs_era_handler")

local r0 = 10 
local r1 = nil 
for i = 0, r0, 1 do 
	if ScriptCB_IsFileExist("custom_gc_" .. i .. ".lvl") == 0 then
		--print("shell_interface: No custom_gc_" .. i .. ".lvl")
	else
		print("shell_interface: Found custom_gc_" .. i .. ".lvl")
		ReadDataFile("custom_gc_" .. i .. ".lvl")
		ScriptCB_DoFile("custom_gc_" .. i)
	end
end


-------------------------------------

ScriptCB_DoFile("ifs_movietrans")
ScriptCB_DoFile("ifs_attract")
ScriptCB_DoFile("ifs_mp_lobby_quick")
-- Pull in list of missions.
ScriptCB_DoFile("missionlist")

if(gPlatformStr == "PC") then
    ScriptCB_DoFile("pctabs_options")
    ScriptCB_DoFile("ifs_pckeyboard")   

    --ScriptCB_DoFile("ifs_missionselect_pcMulti")  
    --ScriptCB_DoFile("ifs_missionselect_pcSingle") 
end
--
--

------------------------------------------------------------------

print("overriding AddIFScreen")
-- setup movie stuff by overriding AddIFScreen
local oldAddIFScreen = AddIFScreen
AddIFScreen= function(screen_table, screen_name)
    --[[print("AddIFScreen: ", screen_name)
    replace_table ={
        ifs_login= "shell_main", 
        ifs_start= "shell_main", 
        ifs_main= "shell_main", 
        ifs_mp= "shell_main", 
        ifs_sp_campaign= "shell_main",
        ifs_mpgs_login= "shell_main",
        ifs_opt_pccontrols="shell_main",
        ifs_saveop="shell_main",

        ifs_split_profile = "shell_sub_left",
        --ifs_saveop = "shell_sub_left",
        ifs_sp = "shell_sub_left",
        ifs_sp_briefing = "shell_sub_left",
        ifs_instant_options_overview = "shell_sub_left",

        ifs_opt_general = "shell_sub_left",
        ifs_opt_pcvideo = "shell_sub_left",
        ifs_opt_sound = "shell_sub_left",
        ifs_opt_mp = "shell_sub_left",
    }
    if( replace_table[screen_name] ~= nil) then
        screen_table.movieBackground = replace_table[screen_name]
        printf("AddIFScreen: setting '%s' movie to %s", screen_name, replace_table[screen_name])
    end]]
    if( screen_table.movieBackground ~= nil) then -- show the movies
        screen_table.bg_texture = nil
    end
    --print("AddIFScreen: ", screen_name, " movie: ", tostring(screen_table.movieBackground), 
    --                                    "bg_texture", tostring(screen_table.bg_texture))
    printf("AddIFScreen:\t%s  movie:\t%s bg_texture:\t%s",
            screen_name,tostring(screen_table.movieBackground), tostring(screen_table.bg_texture))
    return oldAddIFScreen(screen_table, screen_name)
end
--[[
old_ScriptCB_SetIFScreen = ScriptCB_SetIFScreen
ScriptCB_SetIFScreen = function(screen_name)
    local movieName = _G[screen_name].movieBackground
    local bgTexName = _G[screen_name].bg_texture
    printf("ScriptCB_SetIFScreen: '%s' movie: %s bg_tex: %s", screen_name,  tostring(movieName), tostring(bgTexName) )
    old_ScriptCB_SetIFScreen(screen_name)
    local screen_table = _G[screen_name]
    if screen_table ~= nil then 
        CheckMovie(screen_table)
    end
    
end
]]
------------------------------------------------------------------

function SetMovie(movieFile, movieName)
	print("SetMovie:", tostring(movieFile), tostring(movieName))

	local fullpath = movieFile .. ".mvs"
	if( gMovieStream ~= fullpath) then
		ScriptCB_CloseMovie()
		gMovieStream = fullpath
		ScriptCB_OpenMovie(gMovieStream, "")
	end
	if( gMovieName ~= movieName) then
		gMovieName = movieName
		ScriptCB_StopMovie()
		ifelem_shellscreen_fnStartMovie(movieName,1, nil, true)
	end
end
-- Load all the screens, which'll self-register themselves into C/C++

-- Utility stuff first.
ScriptCB_DoFile("popups_common")

if(gPlatformStr == "XBox") then
    ScriptCB_DoFile("popup_ab")
    ScriptCB_DoFile("ifs_dvd_or_game")
end
ScriptCB_DoFile("popup_ok")
ScriptCB_DoFile("popup_yesno")
ScriptCB_DoFile("popup_tutorial")
if(gPlatformStr ~= "PC") then
    ScriptCB_DoFile("popup_loadsave")
end
ScriptCB_DoFile("popup_loadsave2")
ScriptCB_DoFile("error_popup")
ScriptCB_DoFile("popup_yesno_large")
ScriptCB_DoFile("popup_ok_large")

ScriptCB_DoFile("popup_prompt")
if(gPlatformStr == "PC") then
	ScriptCB_DoFile("ifs_pcvkeyboard")
else 
	ScriptCB_DoFile("ifs_vkeyboard")
end 

ScriptCB_DoFile("ifs_boot")
ScriptCB_DoFile("ifs_legal")
ScriptCB_DoFile("ifs_start")
ScriptCB_DoFile("ifs_login")
ScriptCB_DoFile("ifs_main")
ScriptCB_DoFile("ifs_saveop")

-- MP (shared) files
ScriptCB_DoFile("ifs_mp")
ScriptCB_DoFile("ifs_mp_main")
ScriptCB_DoFile("ifs_mp_sessionlist")
ScriptCB_DoFile("ifs_mp_lobby")
ScriptCB_DoFile("ifs_mp_maptype")
if(gPlatformStr == "PS2") then
    ScriptCB_DoFile("ifs_mpps2_netconfig")
    ScriptCB_DoFile("ifs_mpps2_dnas")
    ScriptCB_DoFile("ifs_mpps2_eula")
    ScriptCB_DoFile("ifs_mpps2_patch")
    ScriptCB_DoFile("ifs_mpps2_optimatch")
end

if(gPlatformStr == "PC") then
	ScriptCB_DoFile("ifs_mp_gameopts")
	ScriptCB_DoFile("ifs_mp_heroopts")
	
	if( gOnlineServiceStr == "Galaxy") then 
		ScriptCB_DoFile("ifs_mpgs_galaxylogin")
	elseif (gOnlineServiceStr == "LAN") then 
		
	else
		ScriptCB_DoFile("ifs_mpgs_pclogin")
	end 
    
    ScriptCB_DoFile("ifs_missionselect_pcMulti")
else
    ScriptCB_DoFile("ifs_mpgs_login")   
end

ScriptCB_DoFile("ifs_mp_autonet")

ScriptCB_DoFile("popups_lobby")
ScriptCB_DoFile("popup_busy")

--ScriptCB_DoFile("ifs_split_main")
ScriptCB_DoFile("ifs_split_map")
ScriptCB_DoFile("ifs_split_profile")
if(gPlatformStr == "XBox") then
  ScriptCB_DoFile("ifs_split2_profile")
end

ScriptCB_DoFile("ifs_sp")
ScriptCB_DoFile("ifs_sp_campaign")
ScriptCB_DoFile("ifs_difficulty")
ScriptCB_DoFile("ifs_sp_era")
ScriptCB_DoFile("ifs_sp_briefing")
ScriptCB_DoFile("ifs_spacetraining")

ScriptCB_DoFile("ifs_trailer")

ScriptCB_DoFile("ifs_instant_top")
ScriptCB_DoFile("ifs_instant_side")
ScriptCB_DoFile("ifs_instant_options_tags")
ScriptCB_DoFile("ifs_instant_options")
ScriptCB_DoFile("ifs_instant_options_overview")

ScriptCB_DoFile("ifs_missionselect")

-- Freeform screens
ScriptCB_DoFile("ifs_freeform_init_common")
ScriptCB_DoFile("ifs_freeform_init_cw")
ScriptCB_DoFile("ifs_freeform_init_gcw")
ScriptCB_DoFile("ifs_freeform_init_custom")
ScriptCB_DoFile("ifs_freeform_start_cw")
ScriptCB_DoFile("ifs_freeform_start_rep")
ScriptCB_DoFile("ifs_freeform_start_cis")
ScriptCB_DoFile("ifs_freeform_start_gcw")
ScriptCB_DoFile("ifs_freeform_start_all")
ScriptCB_DoFile("ifs_freeform_start_imp")
ScriptCB_DoFile("ifs_freeform_start_custom")
ScriptCB_DoFile("ifs_freeform_main")
ScriptCB_DoFile("ifs_freeform_sides")
ScriptCB_DoFile("ifs_freeform_ai")
ScriptCB_DoFile("ifs_freeform_menu")
ScriptCB_DoFile("ifs_freeform_load")
ScriptCB_DoFile("ifs_freeform_cheat")
ScriptCB_DoFile("ifs_freeform_purchase")
ScriptCB_DoFile("ifs_freeform_purchase_unit")
ScriptCB_DoFile("ifs_freeform_purchase_tech")
ScriptCB_DoFile("ifs_freeform_fleet")
ScriptCB_DoFile("ifs_freeform_focus")
ScriptCB_DoFile("ifs_freeform_battle")
ScriptCB_DoFile("ifs_freeform_battle_mode")
ScriptCB_DoFile("ifs_freeform_battle_card")
ScriptCB_DoFile("ifs_freeform_result")
ScriptCB_DoFile("ifs_freeform_summary")
ScriptCB_DoFile("ifs_freeform_end")
ScriptCB_DoFile("ifs_freeform_rise_newload")
ScriptCB_DoFile("ifs_freeform_pickscenario")
ScriptCB_DoFile("ifs_freeform_customsetup")

-- Campaign screens
ScriptCB_DoFile("ifs_campaign_data")
ScriptCB_DoFile("ifs_campaign_main")
ScriptCB_DoFile("ifs_campaign_menu")
ScriptCB_DoFile("ifs_campaign_load")
ScriptCB_DoFile("ifs_campaign_turn_intro")
ScriptCB_DoFile("ifs_campaign_battle")
ScriptCB_DoFile("ifs_campaign_battle_card")
ScriptCB_DoFile("ifs_campaign_battle_intro")
ScriptCB_DoFile("ifs_campaign_summary")
ScriptCB_DoFile("ifs_campaign_end")

-- Options screens
ScriptCB_DoFile("ifs_opt_top")
ScriptCB_DoFile("ifs_opt_general")

if(gPlatformStr == "PC") then
	ScriptCB_DoFile("ifs_opt_pcsound")
else 
	ScriptCB_DoFile("ifs_opt_sound")
end 
ScriptCB_DoFile("ifs_opt_mp_listtags")
ScriptCB_DoFile("ifs_opt_mp")
if(gPlatformStr == "PC") then
    --ScriptCB_DoFile("ifs_opt_pckeyboard")
    ScriptCB_DoFile("ifs_opt_pccontrols")
    ScriptCB_DoFile("ifs_opt_pcvideo")
    ScriptCB_DoFile("controller_presets")
    ScriptCB_DoFile("ifs_opt_controller_common")
    ScriptCB_DoFile("ifs_opt_pccontroller")
else
    ScriptCB_DoFile("controller_presets")
    ScriptCB_DoFile("ifs_opt_controller_mode")
    ScriptCB_DoFile("ifs_opt_controller_common")
    ScriptCB_DoFile("ifs_opt_controller_vehunit")
end

-- unlockables
ScriptCB_DoFile("ifs_unlockables")
ScriptCB_DoFile("ifs_tutorials")
ScriptCB_DoFile("ifs_credits")

-- career stats page
ScriptCB_DoFile("ifs_careerstats")

-- Pull in XBox-only pages (with mpxl in the name)
if(gOnlineServiceStr == "XLive") then
    ScriptCB_DoFile("ifs_mpxl_login")
    ScriptCB_DoFile("ifs_mpxl_silentlogin")
    ScriptCB_DoFile("ifs_mpxl_optimatch")
    ScriptCB_DoFile("ifs_mpxl_friends")
    ScriptCB_DoFile("ifs_mpxl_feedback")
    ScriptCB_DoFile("ifs_mpxl_voicemail")
    ScriptCB_DoFile("ifs_mp_leaderboard")
    ScriptCB_DoFile("ifs_mp_leaderboarddetails")
else
    if( (gOnlineServiceStr == "GameSpy") or (gOnlineServiceStr == "Galaxy") ) then
        ScriptCB_DoFile("ifs_mp_leaderboard")
        ScriptCB_DoFile("ifs_mp_leaderboarddetails") 
    end
		ScriptCB_DoFile("ifs_mpgs_friends")
end

ScriptCB_DoFile("ifs_fonttest")


-- Set the first screen shown on entry
if(gXBox_DVDDemo) then
    -- DVD demo always goes to dvd-or-game screen.
    ifs_movietrans_PushScreen(ifs_dvdorgame)
elseif (ScriptCB_ShouldShowDemoPostscreen() and (not gE3Demo)) then
    -- Demo is over. Show the "please buy our game" screen
    ifs_movietrans_PushScreen(ifs_postdemo)

-- already in a campaign game?
elseif ScriptCB_IsCampaignStateSaved() then

	-- remove legal textures to make room for loading
	ifs_legal:ClearTextures()
	-- preload campaign
	ifs_campaign_main:OneTimeInit(false)
	-- go directly to campaign
	ifs_movietrans_PushScreen(ifs_campaign_main)
	
-- already in a galactic conquest game?
elseif ScriptCB_IsMetagameStateSaved() then

	-- remove legal textures to make room for loading
	ifs_legal:ClearTextures()
	-- preload galactic conquest
	ifs_freeform_main:OneTimeInit(false)
	-- go directly to galactic conquest
	ifs_movietrans_PushScreen(ifs_freeform_main)
	
else

	-- standard sequence
    ifs_movietrans_PushScreen(ifs_boot)
end


-- read sound data
ReadDataFile("sound\\shell.lvl")

-- open voice over stream
gVoiceOverStream = OpenAudioStream("sound\\shell.lvl", "shell_vo")
-- open music stream
gMusicStream     = OpenAudioStream("sound\\shell.lvl", "shell_music")
-- open movie stream

gMovieTutorialPostFix = ""
print( "shell_interface: Opening movie:",gMovieStream)
ScriptCB_OpenMovie(gMovieStream, "")
ifelem_shellscreen_fnStartMovie("shell_main",1, nil, true)

ScriptCB_SetMovieAudioBus("shellmovies")


function printGlobalVariablesWithString(str)
    local lowerStr = string.lower(str)
    local lowerName = ""
    for name, value in pairs(_G) do
      lowerName = string.lower(name)
      if string.find(lowerName, lowerStr) ~= nil then
        print("printGlobalVariablesWithString:",name)
      end
    end
end

--printGlobalVariablesWithString("movie")

--old_gIFShellScreenTemplate_fnEnter = gIFShellScreenTemplate_fnEnter
--gIFShellScreenTemplate_fnEnter = function(this, bFwd)
--    print("gIFShellScreenTemplate_fnEnter: ", tostring(this.ScreenName))
--    old_gIFShellScreenTemplate_fnEnter(this,bFwd)
--    CheckMovie(this)
--end

print("shell_interface: Leaving; ScriptCB_IsMoviePlaying():", tostring(ScriptCB_IsMoviePlaying()))