NOTES_DEBUG = true;--Set to nil to not get debug shit

--Contains all the frames ever created, this is not to orphan any frames by mistake...
local AllFrames = {};

--Contains frames that are created but currently not used (Frames can't be deleted so we pool them to save space);
local FramePool = {};

MapNotes = {};

NOTES_MAP_ICON_SCALE = 1.2;-- Zone
NOTES_WORLD_MAP_ICON_SCALE = 0.75;--Full world shown
NOTES_CONTINENT_ICON_SCALE = 1;--Continent Shown
NOTES_MINIMAP_ICON_SCALE = 1.0;

local Registered_Addons = {};


function MapNotes_SlashHandler(msgbase)

	if(msgbase=="test") then
		--function MapNotes:AddNoteToMap(continent, zoneid, posx, posy, id, icon, tooltip_function)
		--MapNotes:AddNoteToMap(2,12,0.5,0.5, 10,"complete",function() 	DEFAULT_CHAT_FRAME:AddMessage("test: "..tostring(this.data.customData)); end);
		MapNotes:RegisterAddon("TestAddon", MapNotes);
		MapNotes:DRAW_NOTES();
	elseif(msgbase == "draw") then
		MapNotes:DRAW_NOTES();
	elseif(msgbase == "frames") then
		for i = 1, table.getn(AllFrames) do
			MapNotes:debug_Print(AllFrames[i]:GetName());
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("No such command");
	end

end
--DEBUG CODE!
function MapNotes:GetNodes(continent, zone)
	Notes = {};

	--Sets values that i want to use for the notes THIS IS WIP MORE INFO MAY BE NEDED BOTH IN PARAMETERS AND NOTES!!!
	Note = {};
	Note.x = 0.5;
	Note.y = 0.5;
	Note.zoneid = 12;
	Note.continent = 2;
	Note.icon = "complete";
	Note.Tooltip = function() 	DEFAULT_CHAT_FRAME:AddMessage("test: "..tostring(this.data.customData)); end;
	Note.customData = 10;
	--Inserts it into the right zone and continent for later use.
	table.insert(Notes, Note);
	return Notes;
end

function MapNotes:RegisterAddon(name, Addon)
	DEFAULT_CHAT_FRAME:AddMessage("Registering addon");
	table.insert(Registered_Addons, Addon);
	for k, v in pairs(Registered_Addons) do
		for k1, v1 in pairs(v) do
			--DEFAULT_CHAT_FRAME:AddMessage(k1.." "..tostring(v1))
		end
	end
end


SlashCmdList["MAPNOTES"] = MapNotes_SlashHandler;
SLASH_MAPNOTES1 = "/mapnotes";

--Gets a blank frame either from Pool or creates a new one!
function MapNotes:GetBlankNoteFrame()
	if(table.getn(FramePool)==0) then
		MapNotes:CreateBlankFrameNote();
	end
	f = FramePool[1];
	table.remove(FramePool, 1);
	return f;
end


CREATED_NOTE_FRAMES = 1;
--Creates a blank frame for use within the map system
function MapNotes:CreateBlankFrameNote()
	local f = CreateFrame("Button","MapNotesFrame"..CREATED_NOTE_FRAMES,WorldMapFrame)
	f:SetFrameLevel(9);
	f:SetWidth(16*NOTES_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed 
	f:SetHeight(16*NOTES_MAP_ICON_SCALE) -- for your Texture
	local t = f:CreateTexture(nil,"BACKGROUND")
	t:SetTexture("Interface\\AddOns\\MapNotes\\Icons\\complete")
	t:SetAllPoints(f)
	f.texture = t
	CREATED_NOTE_FRAMES = CREATED_NOTE_FRAMES+1;
	table.insert(FramePool, f);
	table.insert(AllFrames, f);
end

TICK_DELAY = 0.01;--0.1 Atm not to get spam while debugging should probably be a lot faster...
LAST_TICK = GetTime();

UIOpen = false;

NATURAL_REFRESH = 60;
NATRUAL_REFRESH_SPACING = 2;

--Inital pool size (Not tested how much you can do before it lags like shit, from experiance 11 is good)
INIT_POOL_SIZE = 11;
function MapNotes:NOTES_LOADED()
	MapNotes:debug_Print("Loading MapNotes");
	if(table.getn(FramePool) < 10) then--For some reason loading gets done several times... added this in as safety
		for i = 1, INIT_POOL_SIZE do
			MapNotes:CreateBlankFrameNote();
		end
	end
	MapNotes:debug_Print("Done Loading MapNotes");
end

--Reason this exists is to be able to call both clearnotes and drawnotes without doing 2 function calls, and to be able to force a redraw
function MapNotes:RedrawNotes()
	local time = GetTime();
	MapNotes:CLEAR_ALL_NOTES();
	MapNotes:DRAW_NOTES();
	MapNotes:debug_Print("Notes redrawn time:", tostring((GetTime()- time)*1000).."ms");
	time = nil;
end

function MapNotes:Clear_Note(v)
	v:SetParent(nil);
	v:Hide();
	v:SetAlpha(1);
	v:SetFrameLevel(11);
	v:SetHighlightTexture(nil, "ADD");
	table.insert(FramePool, v);
end

UsedNoteFrames = {};
--Clears the notes, goes through the usednoteframes and clears them. Then sets the QuestieUsedNotesFrame to new table;
function MapNotes:CLEAR_ALL_NOTES()
	MapNotes:debug_Print("CLEAR_NOTES");
	Astrolabe:RemoveAllMinimapIcons();
	for k, v in pairs(UsedNoteFrames) do
		--MapNotes:debug_Print("Hash:"..v.questHash,"Type:"..v.type);
		MapNotes:Clear_Note(v);
	end
	UsedNoteFrames = {};
end


--[[MapNotes = {};
function MapNotes:AddNoteToMap(continent, zoneid, posx, posy, customData, icon, tooltip_function)
	--This is to set up the variables
	if(MapNotes[continent] == nil) then
		MapNotes[continent] = {};
	end
	if(MapNotes[continent][zoneid] == nil) then
		MapNotes[continent][zoneid] = {};
	end

	--Sets values that i want to use for the notes THIS IS WIP MORE INFO MAY BE NEDED BOTH IN PARAMETERS AND NOTES!!!
	Note = {};
	Note.x = posx;
	Note.y = posy;
	Note.zoneid = zoneid;
	Note.continent = continent;
	Note.icon = icon;
	Note.Tooltip = tooltip_function;
	Note.customData = customData;
	--Inserts it into the right zone and continent for later use.
	table.insert(MapNotes[continent][zoneid], Note);
end]]--

--2 / 12

--Checks first if there are any notes for the current zone, then draws the desired icon
function MapNotes:DRAW_NOTES()
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	for index, Addon in pairs(Registered_Addons) do
		for k, v in pairs(Addon:GetNodes(c, z)) do
			if true then
				Icon = MapNotes:GetBlankNoteFrame();
				--Here more info should be set but i CBA at the time of writing
				Icon.data = v;
				Icon:SetParent(WorldMapFrame);
				Icon:SetPoint("CENTER",0,0)
				Icon.type = "WorldMapNote";
				Icon:SetScript("OnEnter", v.Tooltip); --Script Toolip
				Icon:SetScript("OnLeave", function() if(WorldMapTooltip) then WorldMapTooltip:Hide() end if(GameTooltip) then GameTooltip:Hide() end end) --Script Exit Tooltip
				
				if(z == 0 and c == 0) then--Both continents
					Icon:SetWidth(16*NOTES_WORLD_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed 
					Icon:SetHeight(16*NOTES_WORLD_MAP_ICON_SCALE) -- for your Texture
				elseif(z == 0) then--Single continent
					Icon:SetWidth(16*NOTES_CONTINENT_ICON_SCALE)  -- Set These to whatever height/width is needed 
					Icon:SetHeight(16*NOTES_CONTINENT_ICON_SCALE) -- for your Texture
				else
					Icon:SetWidth(16*NOTES_MAP_ICON_SCALE)  -- Set These to whatever height/width is needed 
					Icon:SetHeight(16*NOTES_MAP_ICON_SCALE) -- for your Texture
				end

				--Set the texture to the right type
				Icon.texture:SetTexture(Icons[v.icon].path);
				Icon.texture:SetAllPoints(Icon)

				--Shows and then calls Astrolabe to place it on the map.
				Icon:Show();
				
				xx, yy = Astrolabe:PlaceIconOnWorldMap(WorldMapButton,Icon,v.continent ,v.zoneid ,v.x, v.y); --WorldMapFrame is global
				if(xx and yy and xx > 0 and xx < 1 and yy > 0 and yy < 1) then
					--Questie:debug_Print(Icon:GetFrameLevel());
					table.insert(UsedNoteFrames, Icon);			
				else
					--Questie:debug_Print("Outside map, reseting icon to pool");
					MapNotes:Clear_Note(Icon);
				end


				MMIcon = MapNotes:GetBlankNoteFrame();
				--Here more info should be set but i CBA at the time of writing
				MMIcon.data = v;
				MMIcon:SetParent(Minimap);
				MMIcon:SetFrameLevel(7);
				MMIcon:SetPoint("CENTER",0,0)
				MMIcon:SetWidth(16*NOTES_MINIMAP_ICON_SCALE)  -- Set These to whatever height/width is needed 
				MMIcon:SetHeight(16*NOTES_MINIMAP_ICON_SCALE) -- for your Texture
				MMIcon.type = "MiniMapNote";
				--Sets highlight texture (Nothing stops us from doing this on the worldmap aswell)
				MMIcon:SetHighlightTexture(Icons[v.icon].path, "ADD");
				--Set the texture to the right type
				MMIcon.texture:SetTexture(Icons[v.icon].path);
				MMIcon.texture:SetAllPoints(MMIcon)
				--Shows and then calls Astrolabe to place it on the map.
				--MMIcon:Show();
				--Questie:debug_Print(v.continent,v.zoneid,v.x,v.y);
				Astrolabe:PlaceIconOnMinimap(MMIcon, v.continent, v.zoneid, v.x, v.y);
				--Questie:debug_Print(MMIcon:GetFrameLevel());
				table.insert(UsedNoteFrames, MMIcon);
			end
		end
	end
end

--Debug print function
function MapNotes:debug_Print(...)
	local debugWin = 0;
	local name, shown;
	for i=1, NUM_CHAT_WINDOWS do
		name,_,_,_,_,_,shown = GetChatWindowInfo(i);
		if (string.lower(name) == "mndebug") then debugWin = i; break; end
	end
	if (debugWin == 0) then return end

	local out = "";
	for i = 1, arg.n, 1 do
		if (i > 1) then out = out .. ", "; end
		local t = type(arg[i]);
		if (t == "string") then
			out = out .. '"'..arg[i]..'"';
		elseif (t == "number") then
			out = out .. arg[i];
		else
			out = out .. dump(arg[i]);
		end
	end
	getglobal("ChatFrame"..debugWin):AddMessage(out, 1.0, 1.0, 0.3);
end











--Sets the icons
Icons = {
	["complete"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\complete"
	},
	["available"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\available"
	},
	["loot"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\loot"
	},
	["item"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\loot"
	},
	["event"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\event"
	},
	["object"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\object"
	},
	["slay"] = {
		text = "Complete",
		path = "Interface\\AddOns\\!Questie\\Icons\\slay"
	}
}



local lastC, lastZ = GetCurrentMapContinent(), GetCurrentMapZone();
function MapNotes:Update()
	local c, z = GetCurrentMapContinent(), GetCurrentMapZone();
	if(c ~= lastC or z ~= lastZ) then
		MapNotes:CLEAR_ALL_NOTES();
		MapNotes:DRAW_NOTES();
		lastC = c;
		lastZ = z;
	end
end

MapNotes:NOTES_LOADED();
WorldMapFrame:SetScript("OnUpdate", MapNotes.Update)