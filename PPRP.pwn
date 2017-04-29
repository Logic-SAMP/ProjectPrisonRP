/******************************************************************************/
/**                 PP:RP - PROJECT PRISON ROLE PLAY - PP:RP                 **/
/******************************************************************************/
#include <a_samp>
#include <core>
#include <float>
#include <izcmd>
#include <streamer>
#include <sscanf2>
#include <YSI\y_ini>
#include <YSI\y_timers>

AntiDeAmx()
{
	new a[][] =
	{
		"Anti DeAmx protection",
		"PP:RP"
	};
	#pragma unused a
}

native WP_Hash(buffer[], len, const str[]);//Credits to Y_Less(Whirlpool)

#if defined MAX_PLAYERS
	#undef MAX_PLAYERS
	#define MAX_PLAYERS (30)
#endif

#define MAX_CELLS (101)

#define USER_FILE "PPRP/Users/%s.ini"
#define CELL_FILE "PPRP/Cells/%d.ini"

UserPath(playerid)
{
	new	str[36], name[MAX_PLAYER_NAME];
	
	GetPlayerName(playerid, name, sizeof(name));

	format(str, sizeof(str), USER_FILE, name);
	return str;
}

new Text:SSPXT[4];
new Text:Slogan, Text:PPTD, Text:RPTD, Text:WEB, Text:Time;
new BunnyHop[MAX_PLAYERS];
new Text:Blood, Text:Hurt, BloodTimer[MAX_PLAYERS], BloodStatus[MAX_PLAYERS];
new QuizAnswers[MAX_PLAYERS], QuizID[MAX_PLAYERS], QuizDid[MAX_PLAYERS];
new gPlayerUsingLoopingAnim[MAX_PLAYERS];
new Text:BoxCredits, PlayerText:Credits;
new fstr[200], fstr2[200], SelectingSkin[MAX_PLAYERS], hour, Text:Info, KeySpam[MAX_PLAYERS];
new IsLoggedIn[MAX_PLAYERS char], SkinSelection[MAX_PLAYERS] = 0;

#define GM_TEXT	"PP:RP v0.7"
#define SV_LINK	"www.pp-rp.com"
#define SV_HOST	"Project Prison : Role Play"
#define GM_SYMB	"[PP:RP]"
#define SV_RCON	"pprpdev07"
#define SV_LANG	"English"

#define COLOR_WHITE 0xFFFFFFAA
#define COLOR_PURPLE 0xC2A2DAAA
#define COLOR_GRAD1 0xAFAFAFAA
#define COLOR_GREY 0xAFAFACAA
#define COLOR_LIGHTBLUE 0x33CCFFAA
#define COLOR_LIGHTGREEN 0x9ACD32AA
#define COLOR_ORANGERED 0xFF957AAA
#define COLOR_MEDIC 0xB300FFAA
#define COLOR_COP 0x648BD8AA
#define COLOR_COOK 0xB3CC33AA

#define PRESSED(%0) (((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))
#define HOLDING(%0) ((newkeys & (%0)) == (%0))
#define RELEASED(%0) (((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))
#define KEY_AIM (128)

#define HIDE_SECONDS (1)
#define DEFAULT_STATUS (1)
#define KNIFE_DAMAGE (30.0)
#define FIST_DAMAGE (2.0)

#define SPRUNK_COST (5)
#define SNACK_COST  (10)
#define HOTDOG_COST (5)
#define BURGER_COST (10)
#define FRIES_COST  (15)
#define PIZZA_COST  (20)
#define CHICKEN_COST (25)

PlayerName(playerid)
{
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, sizeof(name));
	return name;
}

PlayerCName(playerid)
{
	new name[MAX_PLAYER_NAME];
	strmid(name, str_replace('_', ' ', PlayerName(playerid)), 0, MAX_PLAYER_NAME);
	return name;
}

str_replace(sSearch, sReplace, const sSubject[], &iCount = 0)
{
	new sReturn[128];
	format(sReturn, sizeof(sReturn), sSubject);
	for(new i = 0; i < sizeof(sReturn); i++)
	{
		if(sReturn[i] == sSearch)
		{
			sReturn[i] = sReplace;
		}
	}
	return sReturn;
}

new MaleSkins[][] =
{
	1, 2, 3, 4, 5, 6, 7, 14, 15, 17, 101, 136, 142, 20, 50,
	170, 184, 186, 185, 188, 234, 250, 37, 36, 59, 296,
	60, 72, 95, 98, 29, 217, 223, 240, 242, 299, 297, 22
};

new FemaleSkins[][] =
{
	9, 12, 13, 40, 41, 55, 56, 65, 69, 76, 90, 91, 93, 131, 141,
	148, 150, 157, 169, 172, 190, 191, 192, 193, 211, 219, 233
};

new GenderNames[3][] =
{
	{"__"},
	{"Male"},
	{"Female"}
};

new SubjectGenderPronouns[3][] =
{
	{"__"},
	{"He"},
	{"She"}
};

new ObjectGenderPronouns[3][] =
{
	{"__"},
	{"Him"},
	{"Her"}
};

new PossessiveGenderPronouns[3][] =
{
	{"__"},
	{"His"},
	{"Her"}
};

new ReflexiveGenderPronouns[3][] =
{
	{"__"},
	{"Himself"},
	{"Herself"}
};

enum
{
	DIALOG_REGISTER,
	DIALOG_LOGIN,
	DIALOG_ADMINS,
	DIALOG_FS,
	DIALOG_QUIZ1,
	DIALOG_QUIZ2,
	DIALOG_QUIZ3,
	DIALOG_QUIZ4,
	DIALOG_QUIZ5,
	DIALOG_CMDS,
	DIALOG_STATS,
	DIALOG_RULES,
	DIALOG_UCP,
	DIALOG_SEE,
	DIALOG_SCP,
	DIALOG_GMX,
	DIALOG_SDWN,
	DIALOG_CHANGEPS,
	DIALOG_CHANGEPS2,
	DIALOG_CHANGEPS3,
	DIALOG_GENDER,
	DIALOG_TUT1,
	DIALOG_TUT2,
	DIALOG_TUT3,
	DIALOG_TUT4,
	DIALOG_TUT5,
	DIALOG_TUT6,
	DIALOG_TUT7,
	DIALOG_CAFE
};

enum hinfo
{
	Float:ExtX,
	Float:ExtY,
	Float:ExtZ,
	Float:IntX,
	Float:IntY,
	Float:IntZ,
	World,
	Int,
	Owned,
	Text3D: TextLabel
}
new Cell[MAX_CELLS][hinfo];

enum pinfo
{
	Pass[129],
	Float:Health,
	XP,
	PCredits,
	FID,
	Admin,
	UnderCover,
	OnDuty,
	Skin,
	Gender,
	QuizDone,
	Float:X,
	Float:Y,
	Float:Z,
	Interior,
	VirWorld,
	FStyle,
	InCell,
	CellOwn
}
new Account[MAX_PLAYERS][pinfo];

main()
{
	print("\n----------------------------------");
	print(" Project Prison : Role Play | PP:RP");
	print("----------------------------------\n");
}

public OnGameModeInit()
{
	AntiDeAmx();
	print("Loading...");
	
	CreateActor(203, 210.0966, 1406.6808, 10.5859, 269.6556); /* = Karate*/
	CreateDynamic3DTextLabel("Press 'H' to learn new fighting styles", COLOR_WHITE, 210.0966, 1406.6808, 10.5859, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0); /* = KarateL*/

	CreateDynamic3DTextLabel("Press 'H' to use sprunk", COLOR_WHITE, 165.4438, 1397.1838, 10.5859, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0); /* = Food1L*/
	CreateDynamicObject(1775, 165.4438, 1397.1838, 10.5859, 0.0, 0.0, 90.0);
	
	CreateDynamic3DTextLabel("Press 'H' to use\nsnack machine", COLOR_WHITE, 240.830856, 1437.664184, 10.566799, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0); /* = Food2L*/
	CreateDynamicObject(1776, 240.830856, 1437.664184, 10.566799, 0.00000, 0.00000, 3.4596);

	CreateDynamic3DTextLabel("Block A\n/enter", COLOR_WHITE, 249.4464, 1436.9285,10.5950, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	CreateDynamic3DTextLabel("Exit Block A\n/exit", COLOR_WHITE, 195.0910, 1389.4769, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 1, 1);

	CreateDynamic3DTextLabel("Block B\n/enter", COLOR_WHITE, 201.7583,1436.9501,10.5950, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	CreateDynamic3DTextLabel("Exit Block B\n/exit", COLOR_WHITE, 195.0910, 1389.4769, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 4, 4);

	CreateDynamic3DTextLabel("Block C\n/enter", COLOR_WHITE, 154.1549,1436.4116,10.5950, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	CreateDynamic3DTextLabel("Exit Block C\n/exit", COLOR_WHITE, 195.0910, 1389.4769, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 5, 5);
	
	CreateDynamic3DTextLabel("Exit DoC HQ\n/exit", COLOR_WHITE, 769.8107,-1406.1138,3001.0859, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	CreateDynamic3DTextLabel("DoC HQ\n/enter", COLOR_WHITE, 174.4326,1365.5961,10.5859, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);

	CreateDynamic3DTextLabel("Library\n/enter", COLOR_WHITE, 154.8477,1404.2882,10.5950, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);
	CreateDynamic3DTextLabel("Exit Library\n/exit", COLOR_WHITE, -2225.0032, 429.1323, 35.3019, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);

	CreateDynamicPickup(1275, 0, 196.1133,1441.7916,551.2960); /* = Cloth*/
	CreateDynamic3DTextLabel("Press 'H' to change clothes", COLOR_WHITE, 196.1133,1441.7916,551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0); /* = ClothL*/

	CreateDynamic3DTextLabel("Press 'H' to continue", COLOR_WHITE, 2022.0273, 2235.2402, 2103.9536, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0); /* = BusL*/
	
	CreateDynamic3DTextLabel("Press 'H' to buy\nfood ((Cafeteria A))", COLOR_WHITE, 195.0459, 1401.4282, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 1, 1);
	CreateDynamic3DTextLabel("Press 'H' to buy\nfood ((Cafeteria B))", COLOR_WHITE, 195.0459, 1401.4282, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 4, 4);
	CreateDynamic3DTextLabel("Press 'H' to buy\nfood ((Cafeteria C))", COLOR_WHITE, 195.0459, 1401.4282, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, 5, 5);
	
	CreateDynamic3DTextLabel("Press 'H' to wash hands", COLOR_WHITE, 202.2894, 1440.4408, 551.2960, 10.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0);

	SetGameModeText(GM_TEXT);
	SendRconCommand("weburl "SV_LINK);
	SendRconCommand("hostname "SV_HOST"");
	SendRconCommand("rcon_password "SV_RCON"");
	SendRconCommand("language "SV_LANG"");
	
	repeat OnSecondSync();
	InitializeTime();

	CreateGlobalCredits();
	CreateSSPXT();
	CreateGlobalBlood();
	LoadInterior();
	LoadOutdoors();
	//CreateVehicle(497, 263.3317, 1382.3812, 24.6011, 2.4577);
	
	LoadCells();
	LoadTextdraws();
	return 1;
}

LoadCells()
{
	print("Loading Cells...");
	new cfile[40];
	for(new c = 1; c < MAX_CELLS; c++)
	{
		format(cfile, sizeof(cfile), CELL_FILE, c);
		INI_ParseFile(cfile, "LoadCell", .bExtra = true, .extra = c, .bPassTag = true);
		format(cfile, sizeof(cfile), "Cell %d", c);
		Cell[c][TextLabel] = CreateDynamic3DTextLabel(cfile, COLOR_WHITE, Cell[c][ExtX], Cell[c][ExtY], Cell[c][ExtZ] + 0.05, 5.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 0, Cell[c][World], Cell[c][Int]);
	}
	return 1;
}

UnloadCells()
{
	print("Unloading Cells...");
	for(new c = 1; c < MAX_CELLS; c++)
	{
		new str[20];
		format(str, sizeof(str), "PPRP/Cells/%d.ini", c);
		if(fexist(str))
		{
			SaveCells(c);
			DestroyDynamic3DTextLabel(Cell[c][TextLabel]);
		}
	}
	return 1;
}

RangeCell_Entrance(playerid)
{
	for(new c = 1; c < MAX_CELLS; c++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, Cell[c][ExtX], Cell[c][ExtY], Cell[c][ExtZ])) return 1;
	}
	return 0;
}

RangeCell_Exit(playerid)
{
	for(new c = 1; c < MAX_CELLS; c++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, Cell[c][IntX], Cell[c][IntY], Cell[c][IntZ])) return 1;
	}
	return 0;
}

EnterCell(playerid)
{
	for(new c = 1; c < MAX_CELLS; c++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, Cell[c][ExtX], Cell[c][ExtY], Cell[c][ExtZ]))
		{
			SetPlayerPos(playerid, Cell[c][IntX], Cell[c][IntY], Cell[c][IntZ]);
			Account[playerid][InCell] = 1;
		}
	}
	return 1;
}

ExitCell(playerid)
{
	for(new c = 1; c < MAX_CELLS; c++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 2.0, Cell[c][ExtX], Cell[c][ExtY], Cell[c][ExtZ]))
		{
			SetPlayerPos(playerid, Cell[c][ExtX], Cell[c][ExtY], Cell[c][ExtZ]);
			Account[playerid][InCell] = 0;
		}
	}
	return 1;
}

forward LoadCell(id, tag[], name[], value[]);
public LoadCell(id, tag[], name[], value[])
{
	INI_Float("ExteriorX", Cell[id][ExtX]);
	INI_Float("ExteriorY", Cell[id][ExtY]);
	INI_Float("ExteriorZ", Cell[id][ExtZ]);
	INI_Float("InteriorX", Cell[id][IntX]);
	INI_Float("InteriorY", Cell[id][IntY]);
	INI_Float("InteriorZ", Cell[id][IntZ]);
	INI_Int("World", Cell[id][World]);
	INI_Int("Interior", Cell[id][Int]);
	INI_Int("Owned", Cell[id][Owned]);
	return 1;
}

SaveCells(id)
{
	new file[40];
	format(file, sizeof(file), CELL_FILE, id);
	new INI:ufile = INI_Open(file);
	INI_WriteInt(ufile, "Owned", Cell[id][Owned]);
	INI_Close(ufile);
	return 1;
}

InitializeTime()
{
	print("Initializing Time");
	hour += 1;
	TimeTimer();
	repeat TimeTimer();
	WeatherTimer();
	repeat WeatherTimer();
}

timer WeatherTimer[1500000]()
{
	switch(random(11))
	{
		case 0: SetWeather(3);
		case 1: SetWeather(19);
		case 2: SetWeather(7);
		case 3: SetWeather(2);
		case 4: SetWeather(8);
		case 5: SetWeather(38);
		case 6: SetWeather(15);
		case 7: SetWeather(5);
		case 8: SetWeather(10);
		case 9: SetWeather(13);
		case 10: SetWeather(18);
	}
}

SetTimeDivision(xid)
{
	switch(xid)
	{
		case 0:
		{
			TextDrawSetString(Time, "~w~Time: 12 AM~n~Midnight");
			SetWorldTime(0);
		}
		case 1:
		{
			TextDrawSetString(Time, "~w~Time: 1 AM~n~Morning");
			SetWorldTime(1);
		}
		case 2:
		{
			TextDrawSetString(Time, "~w~Time: 2 AM~n~Morning");
			SetWorldTime(2);
		}
		case 3:
		{
			TextDrawSetString(Time, "~w~Time: 3 AM~n~Morning");
			SetWorldTime(3);
		}
		case 4:
		{
			TextDrawSetString(Time, "~w~Time: 4 AM~n~Morning");
			SetWorldTime(4);
		}
		case 5:
		{
			TextDrawSetString(Time, "~w~Time: 5 AM~n~Morning");
			SetWorldTime(5);
		}
		case 6:
		{
			TextDrawSetString(Time, "~w~Time: 6 AM~n~Morning");
			SetWorldTime(6);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 6 AM!...");
			SendClientMessageToAll(COLOR_LIGHTBLUE, "... Wake up and have the breakfast!");
		}
		case 7:
		{
			TextDrawSetString(Time, "~w~Time: 7 AM~n~Morning");
			SetWorldTime(7);
		}
		case 8:
		{
			TextDrawSetString(Time, "~w~Time: 8 AM~n~Morning");
			SetWorldTime(8);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 8 AM!.");
			SendClientMessageToAll(COLOR_LIGHTBLUE, "... Head to the Yard!");
		}
		case 9:
		{
			TextDrawSetString(Time, "~w~Time: 9 AM~n~Morning");
			SetWorldTime(9);
		}
		case 10:
		{
			TextDrawSetString(Time, "~w~Time: 10 AM~n~Morning");
			SetWorldTime(10);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 10 AM!.");
		}
		case 11:
		{
			TextDrawSetString(Time, "~w~Time: 11 AM~n~Morning");
			SetWorldTime(11);
		}
		case 12:
		{
			TextDrawSetString(Time, "~w~Time: 12 PM~n~Noon");
			SetWorldTime(12);
		}
		case 13:
		{
			TextDrawSetString(Time, "~w~Time: 1 PM~n~Afternoon");
			SetWorldTime(13);
		}
		case 14:
		{
			TextDrawSetString(Time, "~w~Time: 2 PM~n~Afternoon");
			SetWorldTime(14);
		}
		case 15:
		{
			TextDrawSetString(Time, "~w~Time: 3 PM~n~Afternoon");
			SetWorldTime(15);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 3 PM!.");
			SendClientMessageToAll(COLOR_LIGHTBLUE, "... Lunch time!");
		}
		case 16:
		{
			TextDrawSetString(Time, "~w~Time: 4 PM~n~Afternoon");
			SetWorldTime(16);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 4 PM!.");
			SendClientMessageToAll(COLOR_LIGHTBLUE, "... Head to your blocks");
		}
		case 17:
		{
			TextDrawSetString(Time, "~w~Time: 5 PM~n~Evening");
			SetWorldTime(17);
		}
		case 18:
		{
			TextDrawSetString(Time, "~w~Time: 6 PM~n~Evening");
			SetWorldTime(18);
		}
		case 19:
		{
			TextDrawSetString(Time, "~w~Time: 7 PM~n~Evening");
			SetWorldTime(19);
		}
		case 20:
		{
			TextDrawSetString(Time, "~w~Time: 8 PM~n~Evening");
			SetWorldTime(20);
		}
		case 21:
		{
			TextDrawSetString(Time, "~w~Time: 9 PM~n~Evening");
			SetWorldTime(21);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 9 PM!.");
			SendClientMessageToAll(COLOR_LIGHTBLUE, "... Dinner time!");
		}
		case 22:
		{
			TextDrawSetString(Time, "~w~Time: 10 PM~n~Evening");
			SetWorldTime(22);
			SendClientMessageToAll(COLOR_LIGHTBLUE, "Speaker: The time is now 10 PM!.");
			SendClientMessageToAll(COLOR_LIGHTBLUE, "... Head to your cells");
		}
		case 23:
		{
			TextDrawSetString(Time, "~w~Time: 11 PM~n~Evening");
			SetWorldTime(23);
		}
		case 24:
		{
			TextDrawSetString(Time, "~w~Time: 12 AM~n~Midnight");
			SetWorldTime(24);
			hour = 0;
		}
	}
}

timer TimeTimer[600000]()
{
	switch(hour)
	{
		case 1: SetTimeDivision(1);
		case 2: SetTimeDivision(2);
		case 3: SetTimeDivision(3);
		case 4: SetTimeDivision(4);
		case 5: SetTimeDivision(5);
		case 6: SetTimeDivision(6);
		case 7: SetTimeDivision(7);
		case 8: SetTimeDivision(8);
		case 9: SetTimeDivision(9);
		case 10: SetTimeDivision(10);
		case 11: SetTimeDivision(11);
		case 12: SetTimeDivision(12);
		case 13: SetTimeDivision(13);
		case 14: SetTimeDivision(14);
		case 15: SetTimeDivision(15);
		case 16: SetTimeDivision(16);
		case 17: SetTimeDivision(17);
		case 18: SetTimeDivision(18);
		case 19: SetTimeDivision(19);
		case 20: SetTimeDivision(20);
		case 21: SetTimeDivision(21);
		case 22: SetTimeDivision(22);
		case 23: SetTimeDivision(23);
		case 24: SetTimeDivision(24);
	}
	hour += 1;
	return 1;
}

public OnGameModeExit()
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			SaveUserStats(i);
			OnPlayerDisconnect(i, 1);
		}
	}
	DestroyGlobalBlood();
	DestroyMap();
	DestroyGlobalCredits();
	UnloadCells();
	return 1;
}

public OnPlayerConnect(playerid)
{
	QuizAnswers[playerid] = QuizID[playerid] = QuizDid[playerid] = SelectingSkin[playerid] = KeySpam[playerid] = 0;

	TogglePlayerSpectating(playerid, true);
	PlayerSpectatePlayer(playerid, playerid);
	
	LoadConnection(playerid);
	
	PreloadAnims(playerid);
	BloodStatus[playerid] = DEFAULT_STATUS;
	CreateLocalCredits(playerid);
	LoadRemove(playerid);
	SetPlayerColor(playerid, 0xFFFFFFFF);
	return 1;
}

LoadConnection(playerid)
{
	SetPlayerCameraPos(playerid, 329.0985, 1411.3584, 22.6507);
	SetPlayerCameraLookAt(playerid, 226.1878, 1410.5841, 11.0000, CAMERA_CUT);
	if(!IsPlayerNameValid(playerid))
	{
		SendClientMessage(playerid, COLOR_WHITE, "You're kicked because you don't have a roleplay name");
		defer KickEx(playerid);
	}
	ShowConnectionTD(playerid);
	defer Connection(playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	HideConnectionTD(playerid);
	SaveUserStats(playerid);
	HideBlood(playerid);
	HideCredits(playerid);
	HideTimeTD(playerid);
	DestroyLocalCredits(playerid);
	return 1;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerColorEx(playerid);
	TextDrawShowForPlayer(playerid, Info);
	PreloadAnims(playerid);
	if(QuizDid[playerid] >= 4)
	{
		SetPlayerPosEx(playerid, 2022.0273, 2235.2402, 2103.9536);
		SetPlayerFacingAngle(playerid, 180.0);
		SetPlayerSkin(playerid, Account[playerid][Skin]);
	}
	else
	{
		SetPlayerPosEx(playerid, Account[playerid][X], Account[playerid][Y], Account[playerid][Z]);
		SetPlayerSkin(playerid, Account[playerid][Skin]);
		SetPlayerInterior(playerid, Account[playerid][Interior]);
		SetPlayerVirtualWorld(playerid, Account[playerid][VirWorld]);
		SetPlayerFightingStyle(playerid, Account[playerid][FStyle]);
	}
	ShowCredits(playerid);
	ShowTimeTD(playerid);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	TextDrawHideForPlayer(playerid, Info);
	SaveUserStats(playerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if(SelectingSkin[playerid] == 1)
	{
		if(strfind(text, "next", true) != -1)
		{
			if(Account[playerid][Gender] == 1)
			{
				if(SkinSelection[playerid] < sizeof(MaleSkins) - 1)
				{
					SkinSelection[playerid] += 1;
					SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
				else
				{
					SkinSelection[playerid] = 0;
					SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
			}
			else if(Account[playerid][Gender] == 2)
			{
				if(SkinSelection[playerid] < sizeof(FemaleSkins) - 1)
				{
					SkinSelection[playerid] ++;
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				else
				{
					SkinSelection[playerid] = 0;
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
			}
			return 0;
		}
		if(strfind(text, "previous", true) != -1)
		{
			if(Account[playerid][Gender] == 1)
			{
				if(SkinSelection[playerid] <= sizeof(MaleSkins) - 1 && SkinSelection[playerid] > 0)
				{
					SkinSelection[playerid] --;
					SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
				else if(SkinSelection[playerid] == 0)
				{
					SkinSelection[playerid] = sizeof(MaleSkins) - 1;
					SetPlayerSkin(playerid, MaleSkins[SkinSelection[playerid]][0]);
				}
			}
			else if(Account[playerid][Gender] == 2)
			{
				if(SkinSelection[playerid] <= sizeof(FemaleSkins) - 1 && SkinSelection[playerid] > 0)
				{
					SkinSelection[playerid] --;
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
				else if(SkinSelection[playerid] == 0)
				{
					SkinSelection[playerid] = sizeof(FemaleSkins) - 1;
					SetPlayerSkin(playerid, FemaleSkins[SkinSelection[playerid]][0]);
				}
			}
			return 0;
		}
		if(strfind(text, "done", true) != -1)
		{
			new select = GetPlayerSkin(playerid);
			if(Account[playerid][Skin] != select)
			{
				new str[75];
				SelectingSkin[playerid] = 0;
				Account[playerid][PCredits] -= 100;
				SetPlayerSkinEx(playerid, select);
				TogglePlayerControllable(playerid, true);
				ApplyAnimation(playerid, "CLOTHES", "CLO_POSE_TORSO", 4.0, 0, 1, 1, 0, 0);
				SendClientMessage(playerid, COLOR_GRAD1, "You bought a new skin for 100 prison credits");
				format(str, sizeof(str), "* %s bought a new skin for %s.", PlayerCName(playerid), ReflexiveGenderPronouns[Account[playerid][Gender]]);
				SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
			}
			else
			{
				SendClientMessage(playerid, COLOR_GRAD1, "You already own this skin");
			}
			return 0;
		}
		if(strfind(text, "cancel", true) != -1)
		{
			SelectingSkin[playerid] = 0;
			SetPlayerSkinEx(playerid, Account[playerid][Skin]);
			TogglePlayerControllable(playerid, true);
			SendClientMessage(playerid, COLOR_GRAD1, "You cancelled selecting a skin");
			return 0;
		}
	}
	if(!IsPlayerInAnyVehicle(playerid) && !Account[playerid][OnDuty])
	{
		new str[144];
		new Length = strlen(text), TalkTime = Length*150;
		if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK && !IsPlayerMoving(playerid))
		{
			ApplyAnimation(playerid, "PED", "IDLE_CHAT", 4.1, 0, 0, 0, 0, TalkTime, 1);
		}
		format(str, sizeof(str), "* %s says: %s", PlayerCName(playerid), text);
		SendLocalMessage(16.0, playerid, str, COLOR_WHITE, COLOR_WHITE);
		return 0;
	}
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if(PRESSED(KEY_CTRL_BACK))
	{
		if(IsPlayerInRangeOfPoint(playerid, 1.0, 202.2894, 1440.4408, 551.2960))
		{
			if(KeySpam[playerid] > gettime()) return SendClientMessage(playerid, COLOR_GRAD1, "You must wait 10 seconds before using this function");
			KeySpam[playerid] = gettime() + 10;
			SetPlayerPos(playerid, 202.2894, 1440.4408, 551.2960);
			SetPlayerFacingAngle(playerid, 271.9962);
			new str[70];
			format(str, sizeof(str), "* %s washes %s hands to clean off the dirt", PlayerCName(playerid), PossessiveGenderPronouns[Account[playerid][Gender]]);
			SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
			ApplyAnimation(playerid, "BD_FIRE", "WASH_UP", 2.0, 0, 1, 1, 0, 0);
		}
		else if(IsPlayerInRangeOfPoint(playerid, 2.0, 195.0459, 1401.4282, 551.2960))
		{
			if(KeySpam[playerid] > gettime()) return SendClientMessage(playerid, COLOR_GRAD1, "You must wait 10 seconds before using this function");
			KeySpam[playerid] = gettime() + 10;
			if(GetPlayerInterior(playerid) == 1 && GetPlayerVirtualWorld(playerid) == 1)
			{
				ShowPlayerDialog(playerid, DIALOG_CAFE, DIALOG_STYLE_TABLIST_HEADERS, "Cafeteria Block A", "Food\tPrice\nHotdog\t5PC$\nBurger\t10 PC$\nFries\t15 PC$\nPizza\t20 PC$\nChicken\t25 PC$", "Okay", "Cancel");
			}
			else if(GetPlayerInterior(playerid) == 4 && GetPlayerVirtualWorld(playerid) == 4)
			{
				ShowPlayerDialog(playerid, DIALOG_CAFE, DIALOG_STYLE_TABLIST_HEADERS, "Cafeteria Block B", "Food\tPrice\nHotdog\t5PC$\nBurger\t10 PC$\nFries\t15 PC$\nPizza\t20 PC$\nChicken\t25 PC$", "Okay", "Cancel");
			}
			else if(GetPlayerInterior(playerid) == 5 && GetPlayerVirtualWorld(playerid) == 5)
			{
				ShowPlayerDialog(playerid, DIALOG_CAFE, DIALOG_STYLE_TABLIST_HEADERS, "Cafeteria Block C", "Food\tPrice\nHotdog\t5PC$\nBurger\t10 PC$\nFries\t15 PC$\nPizza\t20 PC$\nChicken\t25 PC$", "Okay", "Cancel");
			}
		}
		else if(IsPlayerInRangeOfPoint(playerid, 2.0, 2022.6918, 2235.4385, 2102.8000))
		{
			SetPlayerPos(playerid, 257.8678, 1424.7155, 10.5930);
			SetPlayerFacingAngle(playerid, 357.0);
			SendClientMessage(playerid, COLOR_GREY, "Welcome to the Prison.");
		}
		else if(IsPlayerInRangeOfPoint(playerid, 1.0, 165.4438, 1397.1838, 10.5859))
		{
			if(KeySpam[playerid] > gettime()) return SendClientMessage(playerid, COLOR_GRAD1, "You must wait 10 seconds before using this function");
			KeySpam[playerid] = gettime() + 10;
			if(Account[playerid][PCredits] >= SPRUNK_COST)
			{
				if(HP(playerid) < 95.0)
				{
					Account[playerid][PCredits] -= SPRUNK_COST;
					SetPlayerHealth(playerid, HP(playerid) + 5.0);
					SetPlayerArmedWeapon(playerid, 0);
					if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
					if(random(6) < 3)
					{
						ApplyAnimation(playerid, "VENDING", "VEND_DRINK2_P", 4.0, 0, 1, 1, 0, 0);
					}
					else
					{
						ApplyAnimation(playerid, "VENDING", "VEND_DRINK_P", 4.0, 0, 1, 1, 0, 0);
					}
					new str[70];
					format(str, sizeof(str), "* %s pickups the Sprunk from the vending machine and drinks it.", PlayerCName(playerid));
					SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
				}
				else SendClientMessage(playerid, COLOR_GREY, "Your health is in good state.");
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "You don't have 5 prison credits.");
			}
		}
		else if(IsPlayerInRangeOfPoint(playerid, 1.0, 240.830856, 1437.664184, 10.566799))
		{
			if(KeySpam[playerid] > gettime()) return SendClientMessage(playerid, COLOR_GRAD1, "You must wait 10 seconds before using this function");
			KeySpam[playerid] = gettime() + 10;
			if(Account[playerid][PCredits] >= SNACK_COST)
			{
				if(HP(playerid) < 90)
				{
					Account[playerid][PCredits] -= SNACK_COST;
					SetPlayerHealth(playerid, HP(playerid) + 10.0);
					SetPlayerArmedWeapon(playerid, 0);
					if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
					ApplyAnimation(playerid, "VENDING", "VEND_EAT1_P", 4.0, 0, 1, 1, 0, 0);
					new str[70];
					format(str, sizeof(str), "* %s pickups the snack from the vending machine and eats it.", PlayerCName(playerid));
					SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
				}
				else SendClientMessage(playerid, COLOR_GREY, "Your health is in good state.");
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "You don't have 10 prison credits.");
			}
		}
		else if(IsPlayerInRangeOfPoint(playerid, 1.0, 210.0966, 1406.6808, 10.5859))
		{
			if(KeySpam[playerid] > gettime()) return SendClientMessage(playerid, COLOR_GRAD1, "You must wait 10 seconds before using this function");
			KeySpam[playerid] = gettime() + 10;
			if(Account[playerid][PCredits] >= 50)
			{
				ShowPlayerDialog(playerid, DIALOG_FS, DIALOG_STYLE_LIST, "Training fighting styles", "Normal styles\nBoxing style\nKung Fu style\nKnee Head style\nGrab Kick style\nElbow style", "Select", "Cancel");
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "You don't have 50 prison credits.");
			}
		}
		else if(IsPlayerInRangeOfPoint(playerid, 2.0, 196.1133,1441.7916,551.2960))
		{
			if(Account[playerid][PCredits] >= 100)
			{
				if(SelectingSkin[playerid] == 1)
				{
					SelectingSkin[playerid] = 0;
					TogglePlayerControllable(playerid, true);
					SetPlayerSkinEx(playerid, Account[playerid][Skin]);
					SendClientMessage(playerid, COLOR_GRAD1, "You cancelled selecting a skin");
				}
				else
				{
					if(KeySpam[playerid] > gettime()) return SendClientMessage(playerid, COLOR_GRAD1, "You must wait 10 seconds before using this function");
					KeySpam[playerid] = gettime() + 10;
					SelectingSkin[playerid] = 1;
					TogglePlayerControllable(playerid, false);
					SendClientMessage(playerid, COLOR_GREY, "Type 'next', 'previous' to browse skin, 'done' to select a skin and 'cancel' to stop selecting.");
					SendClientMessage(playerid, COLOR_GREY, "You can also press key 'H' to stop selecting.");
					SetPlayerFacingAngle(playerid, 178.0);
				}
			}
			else
			{
				SendClientMessage(playerid, COLOR_GREY, "You don't have 100 prison credits.");
			}
		}
	}
	if(newkeys & KEY_JUMP && !(oldkeys & KEY_JUMP))
	{
		if(!IsPlayerInAnyVehicle(playerid))
		{
			//====================[ Tripping System ]======================
			if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_CUFFED)
			{
				if(BunnyHop[playerid] < 2)
				{
					BunnyHop[playerid] += 1;
					if(BunnyHop[playerid] == 2)
					{
						if(random(2) < 1) TripPlayer(playerid);
					}
					defer TimerTripPlayer(playerid);
				}
				else if(BunnyHop[playerid] > 2)
				{
					defer TimerTripPlayer(playerid);
					return 0;
				}
			}
			else
			{
				ApplyAnimation(playerid, "GYMNASIUM", "gym_jog_falloff", 4.1, 0, 1, 1, 0, 0);//Credits to MP2
				new str[64];
				format(str, sizeof(str), "* %s jumped while being cuffed and fell.", PlayerCName(playerid));
				SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
			}
		}
	}
	if(PRESSED(KEY_SPRINT))
	{
		if(gPlayerUsingLoopingAnim[playerid])
		{
			StopLoopingAnim(playerid);
		}
	}
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(Account[i][Admin] < 1)
			{
				BadRCONAttempt(i);
			}
			else
			{
				if(success)
				{
					printf("%s(%d) has logged in RCON", PlayerCName(i), i);
				}
			}
		}
	}
	return 1;
}

BadRCONAttempt(playerid)
{
	SendClientMessage(playerid, COLOR_WHITE, "You are banned for attempting to log in the RCON.");
	SetTimerEx("BRA", 1000, false, "i", playerid);
	return 1;
}

forward BRA(playerid);
public BRA(playerid)
{
	BanEx(playerid, "Bad RCON Attempt");
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_FS:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GREY, "You have cancelled.");
			if(response)
			{
				switch(listitem)
				{
					case 0:
					{
						if(GetPlayerFightingStyle(playerid) == FIGHT_STYLE_NORMAL)
						{
							SendClientMessage(playerid,COLOR_GREY,"You are using normal fighting style");
						}
						else
						{
							SetPlayerFightingStyle(playerid, FIGHT_STYLE_NORMAL);
							Account[playerid][PCredits] -= 50;
						}
					}
					case 1:
					{
						if(GetPlayerFightingStyle(playerid) == FIGHT_STYLE_BOXING)
						{
							SendClientMessage(playerid,COLOR_GREY,"You are using boxing fighting style");
						}
						else
						{
							SetPlayerFightingStyle(playerid, FIGHT_STYLE_BOXING);
							Account[playerid][PCredits] -= 50;
						}
					}
					case 2:
					{
						if(GetPlayerFightingStyle(playerid) == FIGHT_STYLE_KUNGFU)
						{
							SendClientMessage(playerid,COLOR_GREY,"You are using Kung Fu fighting style");
						}
						else
						{
							Account[playerid][PCredits] -= 50;
							SetPlayerFightingStyle(playerid, FIGHT_STYLE_KUNGFU);
						}
					}
					case 3:
					{
						if(GetPlayerFightingStyle(playerid) == FIGHT_STYLE_KNEEHEAD)
						{
							SendClientMessage(playerid,COLOR_GREY,"You are using Knee Head fighting style");
						}
						else
						{
							Account[playerid][PCredits] -= 50;
							SetPlayerFightingStyle(playerid, FIGHT_STYLE_KNEEHEAD);
						}
					}
					case 4:
					{
						if(GetPlayerFightingStyle(playerid) == FIGHT_STYLE_GRABKICK)
						{
							SendClientMessage(playerid,COLOR_GREY,"You are using the Grab Kick fighting style");
						}
						else
						{
							SetPlayerFightingStyle(playerid, FIGHT_STYLE_GRABKICK);
							Account[playerid][PCredits] -= 50;
						}
					}
					case 5:
					{
						if(GetPlayerFightingStyle(playerid) == FIGHT_STYLE_ELBOW)
						{
							SendClientMessage(playerid,COLOR_GREY,"You are using the Elbow fighting style");
						}
						else
						{
							SetPlayerFightingStyle(playerid, FIGHT_STYLE_ELBOW);
							Account[playerid][PCredits] -= 50;
						}
					}
				}
			}
			return 1;
		}
		case DIALOG_REGISTER:
		{
			new f[40], string[150];
			format(f, sizeof(f), USER_FILE, PlayerName(playerid));
			if(!strlen(inputtext)) return SendClientMessage(playerid, COLOR_GRAD1, "You MUST provide a password.") && format(string,sizeof(string),"Welcome to PP:RP %s!\n\nYour not registered yet, please enter a password below to register:", PlayerName(playerid)) && ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "{FFFFFF}Register", string, "Register", "Quit");
			if(strlen(inputtext) < 3 || strlen(inputtext) > 24) return SendClientMessage(playerid, COLOR_GRAD1, "> Your password can only contain 3-24 characters.") && format(string,sizeof(string),"{FFFFFF}Welcome to PP:RP %s!\n\nYour not registered yet, please enter a password below to register:", PlayerName(playerid)) && ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "{FFFFFF}Register", string, "Register", "Quit");
			if(!response) return SendClientMessage(playerid, COLOR_GRAD1, "You MUST register before you can spawn.") && SetTimerEx("KickTimer", 10, 0, "i", playerid);
			{
				IsLoggedIn{playerid} = 1;
				new buf[129];
				WP_Hash(buf, sizeof(buf), inputtext);
				Account[playerid][Pass] = buf;
				new INI:ufile = INI_Open(f);
				INI_WriteString(ufile, "Pass", buf);
				INI_Close(ufile);

				format(fstr, sizeof(fstr), "[PP:RP] Bot: Account registered! Welcome to Prison %s.", PlayerName(playerid));
				SendClientMessage(playerid, COLOR_WHITE, fstr);
				format(fstr2, sizeof(fstr2), "%s [%d] has registered.", PlayerName(playerid), playerid);
				SendClientMessageToAll(COLOR_LIGHTBLUE, fstr2);
				
				QuizAnswers[playerid] = QuizID[playerid] = QuizDid[playerid] = 0;
				ShowPlayerQuiz(playerid);
			}
			return 1;
		}
		case DIALOG_LOGIN:
		{
			new f[40], string[150];
			format(f, sizeof(f), USER_FILE, PlayerName(playerid));
			if(!strlen(inputtext)) return SendClientMessage(playerid, COLOR_GRAD1, "You MUST provide a password.") && SetTimerEx("KickTimer", 10, 0, "i", playerid);
			else if(!response) return SendClientMessage(playerid, COLOR_GRAD1, "You MUST login before you can spawn.") && SetTimerEx("KickTimer", 10, 0, "i", playerid);
			{
				new buf[129];
				WP_Hash(buf, sizeof (buf), inputtext);
				if(strcmp(buf, Account[playerid][Pass], false) != 0)
				{
					SendClientMessage(playerid, COLOR_GRAD1, "Incorrect password.");
					format(string, sizeof(string), "%s [%d] has been kicked from PP:RP - Reason: Incorrect password", PlayerName(playerid), playerid);
					SendClientMessage(playerid, COLOR_GRAD1, string);
					defer KickEx(playerid);
					return 1;
				}
				else
				{
					SetPlayerScore(playerid, Account[playerid][XP]);

					IsLoggedIn{playerid} = 1;
					if(Account[playerid][QuizDone] == 1)
					{
						TogglePlayerSpectating(playerid, false);
						SpawnPlayer(playerid);
					}
					else
					{
						ShowPlayerQuiz(playerid);
					}

					format(fstr, sizeof(fstr), "[PP:RP] Bot: Login successful! Welcome back %s.", PlayerName(playerid));
					SendClientMessage(playerid, COLOR_WHITE, fstr);
					format(fstr2, sizeof(fstr2), "%s [%d] has logged in.", PlayerName(playerid), playerid);
					SendClientMessageToAll(COLOR_LIGHTBLUE, fstr2);
				}
			}
			return 1;
		}
		case DIALOG_QUIZ1:
		{
			if(!response) defer KickEx(playerid);
			else
			{
				if(listitem == 0)
				{
					if(QuizID[playerid] == 1)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 1;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 1)
				{
					if(QuizID[playerid] == 2)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 1;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 2)
				{
					if(QuizID[playerid] == 3)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 1;
					ShowPlayerQuiz(playerid);
				}
			}
			return 1;
		}
		case DIALOG_QUIZ2:
		{
			if(!response) defer KickEx(playerid);
			else
			{
				if(listitem == 0)
				{
					if(QuizID[playerid] == 1)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 2;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 1)
				{
					if(QuizID[playerid] == 2)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 2;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 2)
				{
					if(QuizID[playerid] == 3)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 2;
					ShowPlayerQuiz(playerid);
				}
			}
			return 1;
		}
		case DIALOG_QUIZ3:
		{
			if(!response) defer KickEx(playerid);
			else
			{
				if(listitem == 0)
				{
					if(QuizID[playerid] == 2)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 3;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 1)
				{
					if(QuizID[playerid] == 3)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 3;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 2)
				{
					if(QuizID[playerid] == 1)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 3;
					ShowPlayerQuiz(playerid);
				}
				if(QuizAnswers[playerid] >= 3)
				{
					SendClientMessage(playerid, -1, "You have three or more than three incorrect answers");
					defer KickEx(playerid);
				}
			}
			return 1;
		}
		case DIALOG_QUIZ4:
		{
			if(!response) defer KickEx(playerid);
			else
			{
				if(listitem == 0)
				{
					if(QuizID[playerid] == 1)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 4;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 1)
				{
					if(QuizID[playerid] == 3)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 4;
					ShowPlayerQuiz(playerid);
				}
				if(listitem == 2)
				{
					if(QuizID[playerid] == 2)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
					QuizDid[playerid] = 4;
					ShowPlayerQuiz(playerid);
				}
				if(QuizAnswers[playerid] >= 3)
				{
					SendClientMessage(playerid, -1, "You have three or more than three incorrect answers");
					defer KickEx(playerid);
				}
			}
			return 1;
		}
		case DIALOG_QUIZ5:
		{
			if(!response) defer KickEx(playerid);
			else
			{
				if(listitem == 0)
				{
					if(QuizID[playerid] == 1)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
				}
				if(listitem == 1)
				{
					if(QuizID[playerid] == 3)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
				}
				if(listitem == 2)
				{
					if(QuizID[playerid] == 2)
					{
						SendClientMessage(playerid, -1,"Correct answer!");
					}
					else
					{
						SendClientMessage(playerid, -1,"Wrong answer!");
						QuizAnswers[playerid] += 1;
					}
				}
				if(QuizAnswers[playerid] >= 3)
				{
					SendClientMessage(playerid, -1, "You have three or more than three incorrect answers");
					defer KickEx(playerid);
				}
				else
				{
					SendClientMessage(playerid, -1, "Congratulations for completing the quiz");
					Account[playerid][QuizDone] = 1;
					ShowPlayerDialog(playerid, DIALOG_GENDER, DIALOG_STYLE_MSGBOX, "Select Gender", "Select your gender", "Male", "Female");
				}
			}
			return 1;
		}
		case DIALOG_UCP:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GREY, "You have cancelled.");
			else
			{
				switch(listitem)
				{
					case 0: ShowPasswordChange(playerid);
					case 1: ShowStats(playerid, playerid);
					case 2: SaveUserStats(playerid), GameTextForPlayer(playerid, "~r~Stats ~w~Saved", 3000, 3);
					case 3: ShowPlayerDialog(playerid, DIALOG_SEE, DIALOG_STYLE_INPUT, "Check others stats", "Insert the ID of a player of whom you want to check stats", "Okay", "Cancel");
				}
			}
			return 1;
		}
		case DIALOG_SEE:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GREY, "You have cancelled.");
			else
			{
				new CheckID;
				if(!sscanf(inputtext, "u", CheckID))
				{
					if(IsPlayerConnected(CheckID) || CheckID != INVALID_PLAYER_ID)
					{
						ShowStats(playerid, CheckID);
					}
					else
					{
						SendClientMessage(playerid, COLOR_GRAD1, "The player is not connected/player id is invalid");
					}
				}
			}
			return 1;
		}
		case DIALOG_SCP:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GREY, "You have cancelled.");
			else
			{
				switch(listitem)
				{
					case 0: ShowPlayerDialog(playerid, DIALOG_GMX, DIALOG_STYLE_MSGBOX, "Restart server?", "Are you sure you want to restart the server?", "Yes", "No");
					case 1: ShowPlayerDialog(playerid, DIALOG_SDWN, DIALOG_STYLE_MSGBOX, "Shut down server?", "Are you sure you want to shut down the server?", "Yes", "No");
					case 2:
					{
						GameTextForAll("~w~Everyones' stats saved!", 3000, 3);
						for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
						{
							if(IsPlayerConnected(i))
							{
								SaveUserStats(i);
							}
						}
					}
				}
			}
			return 1;
		}
		case DIALOG_GMX:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GREY, "You have cancelled.");
			else
			{
				GMX(15);
			}
			return 1;
		}
		case DIALOG_SDWN:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GREY, "You have cancelled.");
			else
			{
				Exit(15);
			}
			return 1;
		}
		case DIALOG_CHANGEPS:
		{
			if(response)
			{
				new hashpass[129];

				WP_Hash(hashpass, sizeof(hashpass), inputtext);

				if(!strcmp(hashpass, Account[playerid][Pass]))
				{
					ShowPlayerDialog(playerid, DIALOG_CHANGEPS2, DIALOG_STYLE_PASSWORD, "Changing Password - Step 2/3", "Input your desired new password, in order to comple the process.", "Okay", "Cancel");
				}
				else
				{
					SendClientMessage(playerid, COLOR_GRAD1, "You have entered an incorrect password.");
					ShowPlayerDialog(playerid, DIALOG_CHANGEPS, DIALOG_STYLE_INPUT, "Changing Password - Step 1/3", "Input your current password, in order to change your password.", "Next", "Cancel");
				}
			}
			return 1;
		}
		case DIALOG_CHANGEPS2:
		{
			if(response)
			{
				if(!strlen(inputtext)) return SendClientMessage(playerid, COLOR_GRAD1, "You must enter a password.");
				new string[128];

				format(string, sizeof(string), "Your password is: {00BA00}%s", inputtext);
				ShowPlayerDialog(playerid, DIALOG_CHANGEPS3, DIALOG_STYLE_MSGBOX, "Changing Password - Step 3/3", string, "Okay", "");

				new INI:file = INI_Open(UserPath(playerid));
				WP_Hash(Account[playerid][Pass], 129, inputtext);
				INI_WriteString(file, "Pass", Account[playerid][Pass]);
				INI_Close(file);
				return 1;
			}
			return 1;
		}
		case DIALOG_GENDER:
		{
			if(!response)
			{
				Account[playerid][Gender] = 2;
				SendClientMessage(playerid, COLOR_GREY, "You have selected your gender as Female");
				if(random(6) < 3)
				{
					Account[playerid][Skin] = 224;
				}
				else
				{
					Account[playerid][Skin] = 225;
				}
				ShowTutorial(playerid, 1);
			}
			else
			{
				Account[playerid][Gender] = 1;
				SendClientMessage(playerid, COLOR_GREY, "You have selected your gender as Male");
				if(random(6) < 3)
				{
					Account[playerid][Skin] = 50;
				}
				else
				{
					Account[playerid][Skin] = 8;
				}
				ShowTutorial(playerid, 1);
			}
			return 1;
		}
		case DIALOG_TUT1: ShowTutorial(playerid, 2);
		case DIALOG_TUT2: ShowTutorial(playerid, 3);
		case DIALOG_TUT3: ShowTutorial(playerid, 4);
		case DIALOG_TUT4: ShowTutorial(playerid, 5);
		case DIALOG_TUT5: ShowTutorial(playerid, 6);
		case DIALOG_TUT6: ShowTutorial(playerid, 7);
		case DIALOG_TUT7: TogglePlayerSpectating(playerid, false), SpawnPlayer(playerid);
		case DIALOG_CAFE:
		{
			if(!response) return SendClientMessage(playerid, COLOR_GRAD1, "You have cancelled");
			else
			{
				switch(listitem)
				{
					case 0:
					{
						if(Account[playerid][PCredits] >= HOTDOG_COST)
						{
							if(HP(playerid) < 95.0)
							{
								Account[playerid][PCredits] -= HOTDOG_COST;
								SetPlayerArmedWeapon(playerid, 0);
								SetPlayerHealth(playerid, HP(playerid) + 5.0);
								if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
								ApplyAnimation(playerid, "FOOD", "EAT_Chicken", 4.0, 0, 1, 1, 0, 0);
							}
							else SendClientMessage(playerid, COLOR_GRAD1, "Your health is in good state.");
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "You don't have 5 prison credits.");
						}
					}
					case 1:
					{
						if(Account[playerid][PCredits] >= BURGER_COST)
						{
							if(HP(playerid) < 90.0)
							{
								Account[playerid][PCredits] -= BURGER_COST;
								SetPlayerArmedWeapon(playerid, 0);
								SetPlayerHealth(playerid, HP(playerid) + 10.0);
								if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
								ApplyAnimation(playerid, "FOOD", "EAT_Burger", 4.0, 0, 1, 1, 0, 0);
							}
							else SendClientMessage(playerid, COLOR_GRAD1, "Your health is in good state.");
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "You don't have 10 prison credits.");
						}
					}
					case 2:
					{
						if(Account[playerid][PCredits] >= FRIES_COST)
						{
							if(HP(playerid) < 90.0)
							{
								Account[playerid][PCredits] -= FRIES_COST;
								SetPlayerArmedWeapon(playerid, 0);
								SetPlayerHealth(playerid, HP(playerid) + 10.0);
								if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
								ApplyAnimation(playerid, "FOOD", "EAT_Pizza", 4.0, 0, 1, 1, 0, 0);
							}
							else SendClientMessage(playerid, COLOR_GRAD1, "Your health is in good state.");
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "You don't have 15 prison credits.");
						}
					}
					case 3:
					{
						if(Account[playerid][PCredits] >= PIZZA_COST)
						{
							if(HP(playerid) < 85.0)
							{
								Account[playerid][PCredits] -= PIZZA_COST;
								SetPlayerArmedWeapon(playerid, 0);
								SetPlayerHealth(playerid, HP(playerid) + 15.0);
								if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
								ApplyAnimation(playerid, "FOOD", "EAT_Pizza", 4.0, 0, 1, 1, 0, 0);
							}
							else SendClientMessage(playerid, COLOR_GRAD1, "Your health is in good state.");
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "You don't have 20 prison credits.");
						}
					}
					case 4:
					{
						if(Account[playerid][PCredits] >= CHICKEN_COST)
						{
							if(HP(playerid) < 80.0)
							{
								Account[playerid][PCredits] -= CHICKEN_COST;
								SetPlayerArmedWeapon(playerid, 0);
								SetPlayerHealth(playerid, HP(playerid) + 20.0);
								if(HP(playerid) >= 100.0) SetPlayerHealth(playerid, 100);
								ApplyAnimation(playerid, "FOOD", "EAT_Chicken", 4.0, 0, 1, 1, 0, 0);
							}
							else SendClientMessage(playerid, COLOR_GRAD1, "Your health is in good state.");
						}
						else
						{
							SendClientMessage(playerid, COLOR_GREY, "You don't have 25 prison credits.");
						}
					}
				}
			}
			return 1;
		}
	}
	return 0;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid, bodypart)
{
	if(issuerid != INVALID_PLAYER_ID)
	{
		switch(weaponid)
		{
			case 0:
			{
				new Float:armour, Float:hp;
				GetPlayerArmour(playerid, armour);
				if(Float:armour > 0.0)
				{
					if(Float:armour > FIST_DAMAGE)
					{
						GetPlayerArmour(playerid, armour);
						SetPlayerArmour(playerid, armour - FIST_DAMAGE);
					}
					else
					{
						new Float:newer;
						newer = FIST_DAMAGE - armour;
						SetPlayerArmour(playerid, 0);
						GetPlayerHealth(playerid, hp);
						SetPlayerHealth(playerid, hp - newer);
					}
				}
				else
				{
					GetPlayerHealth(playerid, hp);
					SetPlayerHealth(playerid, hp - FIST_DAMAGE);
				}
			}
			case 4:
			{
				new Float:armour, Float:hp;
				GetPlayerArmour(playerid, armour);
				GetPlayerHealth(playerid, hp);
				if(bodypart != 9)
				{
					if(armour > 0.0)
					{
						if(Float:armour > KNIFE_DAMAGE)
						{
							GetPlayerArmour(playerid, armour);
							SetPlayerArmour(playerid, armour - KNIFE_DAMAGE);
						}
						else
						{
							new Float:newer;
							newer = KNIFE_DAMAGE - armour;
							SetPlayerArmour(playerid, 0);
							GetPlayerHealth(playerid, hp);
							SetPlayerHealth(playerid, hp - newer);
						}
					}
					else
					{
						GetPlayerHealth(playerid, hp);
						SetPlayerHealth(playerid, hp - KNIFE_DAMAGE);
					}
				}
			}
		}
	}
	ShowBlood(playerid);
	return 1;
}

ShowTutorial(playerid, t)
{
	switch(t)
	{
		case 1: ShowPlayerDialog(playerid, DIALOG_TUT1, DIALOG_STYLE_MSGBOX, "Tutorial #1", "Welcome to Project Prison Roleplay\nThis is a medium RP based server\nThe server is in early alpha build.", "Continue", "");
		case 2: ShowPlayerDialog(playerid, DIALOG_TUT2, DIALOG_STYLE_MSGBOX, "Tutorial #2", "You are advised to read the tutorial carefully to avoid asking questions later on and for confusion", "Continue", "");
		case 3: ShowPlayerDialog(playerid, DIALOG_TUT3, DIALOG_STYLE_MSGBOX, "Tutorial #3", "This is the Prison\nWe have a cell (housing) and faction system", "Continue", "");
		case 4: ShowPlayerDialog(playerid, DIALOG_TUT4, DIALOG_STYLE_MSGBOX, "Tutorial #4", "You need to earn prison credits to buy new skins, cells, food and for the medical treatment\nYou can earn them by completing jobs", "Okay", "");
		case 5: ShowPlayerDialog(playerid, DIALOG_TUT5, DIALOG_STYLE_MSGBOX, "Tutorial #5", "You can also become part of our official factions, but not everyone can become part of it!", "Okay", "");
		case 6: ShowPlayerDialog(playerid, DIALOG_TUT6, DIALOG_STYLE_MSGBOX, "Tutorial #6", "Every in-game hour is as long as 10 minutes in real life, so don't AFK for too long", "Continue", "");
		case 7: ShowPlayerDialog(playerid, DIALOG_TUT7, DIALOG_STYLE_MSGBOX, "Tutorial #7", "You've completed the tutorial, now don't forget to read the rules and checking the commands.\nFor more help contact an online admin or our forum.", "Okay", "");
	}
	return 1;
}

SendLocalMessage(Float:radii, playerid, msg[], col1, col2)
{
	if(IsPlayerConnected(playerid))
	{
		new Float:PosX, Float:PosY, Float:PosZ;
		GetPlayerPos(playerid, PosX, PosY, PosZ);
		for(new i = 0, l = GetPlayerPoolSize(); i <= l; i++)
		{
			if(IsPlayerConnected(i))
			{
				if(GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(i) && GetPlayerInterior(i) == GetPlayerInterior(playerid))
				{
					if(IsPlayerInRangeOfPoint(i, radii/2, PosX, PosY,PosZ))
					{
						SendClientMessage(i, col1, msg);
					}
					else if(IsPlayerInRangeOfPoint(i, radii, PosX, PosY, PosZ))
					{
						SendClientMessage(i, col2, msg);
					}
				}
			}
		}
	}
	//
}

Float:GetDistanceBetweenPlayers(p1, p2)
{
	new Float:x1, Float:y1, Float:z1, Float:x2, Float:y2, Float:z2;
	if(!IsPlayerConnected(p1) || !IsPlayerConnected(p2))
	{
		return -1.00;
	}
	GetPlayerPos(p1, x1, y1, z1);
	GetPlayerPos(p2, x2, y2, z2);
	return floatsqroot(floatpower(floatabs(floatsub(x2, x1)), 2) +floatpower(floatabs(floatsub(y2, y1)), 2) +floatpower(floatabs(floatsub(z2, z1)), 2));
}

GetClosestPlayer(p1)
{
	new Float:dis, Float:dis2, player2;
	player2 = -1;
	dis = 99999.99;
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPlayerState(i) != PLAYER_STATE_SPECTATING)
			{
				if(i != p1)
				{
					dis2 = GetDistanceBetweenPlayers(i, p1);
					if(dis2 < dis && dis2 != -1.00)
					{
						dis = dis2;
						player2 = i;
					}
				}
			}
		}
	}
	return player2;
}

CMD:enter(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid, 2.0, 249.4464,1436.9285,10.5950))
	{
		SetPlayerPosEx(playerid, 195.0910, 1389.4769, 551.2960);
		SetPlayerInterior(playerid, 1);
		SetPlayerVirtualWorld(playerid, 1);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 154.8477,1404.2882,10.5950))
	{
		SetPlayerPosEx(playerid, -2225.0032,429.1323,35.3019);
		SetPlayerInterior(playerid, 2);
		SetPlayerVirtualWorld(playerid, 2);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 174.4326,1365.5961,10.5859))
	{
		SetPlayerPosEx(playerid, 769.8107,-1406.1138,3001.0859);
		SetPlayerInterior(playerid, 3);
		SetPlayerVirtualWorld(playerid, 3);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 154.1549,1436.4116,10.5950))
	{
		SetPlayerPosEx(playerid, 195.0910, 1389.4769, 551.2960);
		SetPlayerInterior(playerid, 5);
		SetPlayerVirtualWorld(playerid, 5);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 201.7583,1436.9501,10.5950))
	{
		SetPlayerPosEx(playerid, 195.0910, 1389.4769, 551.2960);
		SetPlayerInterior(playerid, 4);
		SetPlayerVirtualWorld(playerid, 4);
	}
	else if(RangeCell_Entrance(playerid))
	{
		EnterCell(playerid);
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "You are not near any entrance");
	return 1;
}

CMD:exit(playerid)
{
	if(IsPlayerInRangeOfPoint(playerid, 2.0, 195.0910,1389.4769,551.2960) && GetPlayerInterior(playerid) == 1)
	{
		SetPlayerPosEx(playerid, 249.4464, 1436.9285, 10.5950);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, -2225.0032,429.1323,35.3019) && GetPlayerInterior(playerid) == 2)
	{
		SetPlayerPosEx(playerid,154.8477,1404.2882,10.5950);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 769.8107,-1406.1138,3001.0859) && GetPlayerInterior(playerid) == 3)
	{
		SetPlayerPosEx(playerid, 174.4326,1365.5961,10.5859);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 195.0910, 1389.4769, 551.2960) && GetPlayerInterior(playerid) == 5)
	{
		SetPlayerPosEx(playerid, 154.1549,1436.4116,10.5950);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
	else if(IsPlayerInRangeOfPoint(playerid, 2.0, 195.0910, 1389.4769, 551.2960) && GetPlayerInterior(playerid) == 4)
	{
		SetPlayerPosEx(playerid, 201.7583,1436.9501,10.5950);
		SetPlayerInterior(playerid, 0);
		SetPlayerVirtualWorld(playerid, 0);
	}
	else if(RangeCell_Exit(playerid))
	{
		ExitCell(playerid);
	}
	else SendClientMessage(playerid, COLOR_GRAD1, "You are not near any exit");
	return 1;
}

GivePlayerCredits(playerid, amount)
{
	Account[playerid][PCredits] += amount;
	return 1;
}

HP(playerid)
{
	new Float:pHealth; //Creates our float so we can store the health in it
	GetPlayerHealth(playerid, pHealth); //Get's their health storing it in our float
	return floatround(pHealth); //Rounds off the float to make it a regular number then returns that
}

timer OnSecondSync[1000]()
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(GetPlayerState(i) != PLAYER_STATE_SPECTATING && GetPlayerState(i) != PLAYER_STATE_SPAWNED && GetPlayerState(i) != PLAYER_STATE_WASTED)
			{
				new animname[32], animlib[32], str[20];
				format(str, sizeof(str), "~g~PC$%d", Account[i][PCredits]);
				PlayerTextDrawSetString(i, Credits, str);
				
				GetAnimationName(GetPlayerAnimationIndex(i), animlib, sizeof(animlib), animname, sizeof(animname));
				if (!strcmp(animname, "SWIM_CRAWL", true) && !IsPlayerInAnyVehicle(i))
				{
					new Float:vX, Float:vY, Float:vZ, Float:vS;
					GetPlayerVelocity(i, vX, vY, vZ);
					vS = floatsqroot((vX * vX) + (vY * vY) + (vZ + vZ) * 100);
					if(floatround(vS, floatround_round) >= 3)
					{
						format(fstr, sizeof(fstr), "[PP:RP] Bot has banned %s(%d) for \"Fly hacks", PlayerName(i), i);
						SendClientMessageToAll(COLOR_GREY, fstr);
					}
				}
			}
		}
	}
	return 1;
}

CMD:aduty(playerid)
{
	if(!Account[playerid][OnDuty])
	{
		Account[playerid][OnDuty] = 1;
		SetPlayerSkin(playerid, 294);
	}
	else
	{
		SetPlayerSkin(playerid, Account[playerid][Skin]);
		Account[playerid][OnDuty] = 0;
	}
	return 1;
}

CMD:admins(playerid)
{
	new count, string[500], AdmDuty[16];
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			switch(Account[i][OnDuty])
			{
				case 0: AdmDuty = "Playing";
				case 1: AdmDuty = "On Duty";
			}
			if(Account[i][Admin] > 0 && Account[i][UnderCover] != 1)
			{
				format(string, sizeof(string), "%s{7DD8CB}*%s - {FFFFFF}%s\n", string, PlayerName(i), AdmDuty);
				count+= 1;
			}
		}
	}
	if(!count) ShowPlayerDialog(playerid, DIALOG_ADMINS, DIALOG_STYLE_MSGBOX, "Admins", "No Admins Online", "Okay", "");
	else ShowPlayerDialog(playerid,  DIALOG_ADMINS, DIALOG_STYLE_MSGBOX, "Admins", string, "Okay", "");
	return 1;
}

CMD:undercover(playerid)
{
	if(!(Account[playerid][Admin] >= 3)) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	if(Account[playerid][UnderCover] == 0)
	{
		Account[playerid][UnderCover] = 1;
		SendClientMessage(playerid, COLOR_GREY, "You are now invisible in the admin list.");
	}
	else
	{
		Account[playerid][UnderCover] = 0;
		SendClientMessage(playerid, COLOR_GREY, "You are now visible in the admin list.");
	}
	return 1;
}

CMD:giveall(playerid, params[])
{
	if(!(Account[playerid][Admin] >= 5)) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	new type[8], amount;
	if(sscanf(params, "si", type, amount))
	{
		SendClientMessage(playerid, COLOR_GREY, "/giveall [type] [amount]");
		SendClientMessage(playerid, COLOR_GREY, "Types: 'credits' and 'xp'");
		SendClientMessage(playerid, COLOR_GREY, "Amount varies for each type.");
		return 1;
	}
	else
	{
		if(strfind(type, "credits", true) != -1)
		{
			if(1 < amount || amount > 5) return SendClientMessage(playerid, COLOR_GREY, "Amount value should not exceed 5.");
			for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
			{
				if(IsPlayerConnected(i))
				{
					GivePlayerCredits(i, amount);
					new str[75];
					format(str, sizeof(str), "%s %s has given everyone %d prison credits", GetAdminRank(playerid), PlayerName(playerid), amount);
					SendClientMessage(i, COLOR_LIGHTBLUE, str);
				}
			}
		}
		if(strfind(type, "xp", true) != -1)
		{
			if(1 < amount || amount > 5) return SendClientMessage(playerid, COLOR_GREY, "Amount value should not exceed 5.");
			for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
			{
				if(IsPlayerConnected(i))
				{
					GivePlayerScore(i, amount);
					new str[75];
					format(str, sizeof(str), "%s %s has given everyone %d XP", GetAdminRank(playerid), PlayerName(playerid), amount);
					SendClientMessage(i, COLOR_LIGHTBLUE, str);
				}
			}
		}
	}
	return 1;
}

GetAdminRank(pID)
{
	new admrank[35];
	switch(Account[pID][Admin])
	{
		case 0: admrank = "Player";
		case 1: admrank = "Junior Admin";
		case 2: admrank = "Senior Admin";
		case 3: admrank = "Lead Admin";
		case 4: admrank = "Division Leader";
		case 5: admrank = "Manager";
		case 6: admrank = "Developer";
		case 7: admrank = "CEO";
	}
	return admrank;
}

SaveUserStats(playerid)
{
	if(IsPlayerConnected(playerid) && IsLoggedIn{playerid} == 1)
	{
		new file[40], Float:PosX, Float:PosY, Float:PosZ, IntW, VirW;
		IntW = GetPlayerInterior(playerid);
		VirW = GetPlayerVirtualWorld(playerid);
		GetPlayerPos(playerid, PosX, PosY, PosZ);
		Account[playerid][X] = PosX;
		Account[playerid][Y] = PosY;
		Account[playerid][Z] = PosZ;
		format(file, sizeof(file), USER_FILE, PlayerName(playerid));
		new INI:ufile = INI_Open(file);
		INI_WriteString(ufile, "Pass", Account[playerid][Pass]);
		INI_WriteFloat(ufile, "Health", Account[playerid][Health]);
		INI_WriteInt(ufile, "XP", GetPlayerScore(playerid));
		INI_WriteInt(ufile, "Credits", Account[playerid][PCredits]);
		INI_WriteInt(ufile, "FID", Account[playerid][FID]);
		INI_WriteInt(ufile, "Admin", Account[playerid][Admin]);
		INI_WriteInt(ufile, "Skin", Account[playerid][Skin]);
		INI_WriteInt(ufile, "Gender", Account[playerid][Gender]);
		INI_WriteInt(ufile, "QuizDone", Account[playerid][QuizDone]);
		INI_WriteFloat(ufile, "X", Account[playerid][X]);
		INI_WriteFloat(ufile, "Y", Account[playerid][Y]);
		INI_WriteFloat(ufile, "Z", Account[playerid][Z]);
		INI_WriteInt(ufile, "Interior", IntW);
		INI_WriteInt(ufile, "VirWorld", VirW);
		INI_WriteInt(ufile, "FStyle", GetPlayerFightingStyle(playerid));
		INI_WriteInt(ufile, "CellOwn", Account[playerid][CellOwn]);
		INI_WriteInt(ufile, "InCell", Account[playerid][InCell]);
		INI_Close(ufile);
	}
	return 1;
}

forward LoadUser_data(playerid, name[], value[]);
public LoadUser_data(playerid, name[], value[])
{
	INI_String("Pass", Account[playerid][Pass], 129);
	INI_Float("Health", Account[playerid][Health]);
	INI_Int("XP", Account[playerid][XP]);
	INI_Int("Credits", Account[playerid][PCredits]);
	INI_Int("FID", Account[playerid][FID]);
	INI_Int("Admin", Account[playerid][Admin]);
	INI_Int("Skin", Account[playerid][Skin]);
	INI_Int("Gender", Account[playerid][Gender]);
	INI_Int("QuizDone", Account[playerid][QuizDone]);
	INI_Float("X", Account[playerid][X]);
	INI_Float("Y", Account[playerid][Y]);
	INI_Float("Z", Account[playerid][Z]);
	INI_Int("Interior", Account[playerid][Interior]);
	INI_Int("VirWorld", Account[playerid][VirWorld]);
	INI_Int("FStyle", Account[playerid][FStyle]);
	INI_Int("CellOwn", Account[playerid][CellOwn]);
	INI_Int("InCell", Account[playerid][InCell]);
	return 1;
}

timer KickEx[1000](pID)
{
	Kick(pID);
	return 1;
}

ShowPlayerQuiz(playerid)
{
	new randomizer, string[128];
	switch(QuizDid[playerid])
	{
		case 0:
		{
			randomizer = random(3); // to learn more about random function
									// visit ~ http://wiki.sa-mp.com/wiki/Random
			switch(randomizer)
			{
				case 0:
				{
					string = "Project Prison\nProject Pride\nProject Peel";
					QuizID[playerid] = 1;
				}
				case 1:
				{
					string = "Project Pride\nProject Prison\nProject Peel";
					QuizID[playerid] = 2;
				}
				case 2:
				{
					string = "Project Peel\nProject Pride\nProject Prison";
					QuizID[playerid] = 3;
				}
			}
			ShowPlayerDialog(playerid, DIALOG_QUIZ1, DIALOG_STYLE_LIST, "What is our project name? (1/5)", string, "Select", "Leave Game");
		}
		case 1:
		{
			randomizer = random(3);

			switch(randomizer)
			{
				case 0:
				{
					string = "Real Pussy\nRole Play\nRape Pace";
					QuizID[playerid] = 2;
				}
				case 1:
				{
					string = "Role Play\nRape Pace\nReal Pussy";
					QuizID[playerid] = 1;
				}
				case 2:
				{
					string = "Rape Pace\nReal Pussy\nRole Play";
					QuizID[playerid] = 3;
				}
			}
			ShowPlayerDialog(playerid, DIALOG_QUIZ2, DIALOG_STYLE_LIST, "What does RP stands for? (2/5)", string, "Select", "Leave Game");
		}
		case 2:
		{
			randomizer = random(3);

			switch(randomizer)
			{
				case 0:
				{
					string = "Information Center\nI'm Cool\nIn Character";
					QuizID[playerid] = 1;
				}
				case 1:
				{
					string = "In Character\nI'm Cool\nInformation Center";
					QuizID[playerid] = 2;
				}
				case 2:
				{
					string = "I'm Cool\nIn Character\nInformation Center";
					QuizID[playerid] = 3;
				}
			}
			ShowPlayerDialog(playerid, DIALOG_QUIZ3, DIALOG_STYLE_LIST, "What IC stands for? (3/5)", string, "Select", "Leave Game");
		}
		case 3:
		{
			randomizer = random(3);

			switch(randomizer)
			{
				case 0:
				{
					string = "Out of Character\nOut of Chat\nOut of Clan";
					QuizID[playerid] = 1;
				}
				case 1:
				{
					string = "Out of Chat\nOut of Clan\nOut of Character";
					QuizID[playerid] = 2;
				}
				case 2:
				{
					string = "Out of Clan\nOut of Character\nOut of Chat";
					QuizID[playerid] = 3;
				}
			}
			ShowPlayerDialog(playerid, DIALOG_QUIZ4, DIALOG_STYLE_LIST, "What OOC stands for? (4/5)", string, "Select", "Leave Game");
		}
		case 4:
		{
			randomizer = random(3);

			switch(randomizer)
			{
				case 0:
				{
					string = "/me laughs\n/me rofl\n/me wtf";
					QuizID[playerid] = 1;
				}
				case 1:
				{
					string = "/me rofl\n/me wtf\n/me laughs";
					QuizID[playerid] = 2;
				}
				case 2:
				{
					string = "/me rofl\n/me laughs\n/me wtf";
					QuizID[playerid] = 3;
				}
			}
			ShowPlayerDialog(playerid, DIALOG_QUIZ5, DIALOG_STYLE_LIST, "Which /me is used correctly? (5/5)", string, "Select", "Leave Game");
		}
	}
	return 1;
}

GivePlayerScore(playerid, amount)
{
	SetPlayerScore(playerid, GetPlayerScore(playerid) + amount);
	return 1;
}

CMD:a(playerid, params[])
{
	new string[256], text[100];
	if(Account[playerid][Admin] < 1) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	if(sscanf(params, "s[100]", text)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /a [text]");
	format(string, sizeof(string), "{7DD8CB}%s %s:{FFFFFF} %s", GetAdminRank(playerid), PlayerName(playerid), text);
	AdminMessage(string);
	return 1;
}

AdminMessage(strtxt[])
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			if(Account[i][Admin] >= 1)
			{
				SendClientMessage(i, -1, strtxt);
			}
		}
	}
	return 1;
}

ShowPlayerCMDS(playerid)
{
	new CMDz[100];
	strcat(CMDz, "{FFFFFF}/do\n/me\n/enter\n/exit\n/admins\n/ucp\n/blood\n/shout");

	ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, "PP:RP Help", CMDz, "Okay", "");
}

ShowPlayerACMDS(playerid)
{
	new acmdS[1000];
	strcat(acmdS, "\n{7DD8CB}Admin Level 1+ - Junior Administrator\n");
	strcat(acmdS, "{FFFFFF}/aduty - to go on admin duty\n");
	strcat(acmdS, "/slap - to slap a player with a custom height\n");
	strcat(acmdS, "/kick - to kick a specified player.\n");
	strcat(acmdS, "/a - to send a message to fellow admins.\n");
	strcat(acmdS, "\n{7DD8CB}Admin Level 2+ - Senior Administrator\n");
	strcat(acmdS, "{FFFFFF}/cc - to clear the chat.\n");
//	strcat(acmdS, "{FFFFFF}/jail - to jail a specified player.\n");
//	strcat(acmdS, "{FFFFFF}/unjail - to un-jail a specified player.\n");
//	strcat(acmdS, "{FFFFFF}/mute - to mute a specified player.\n");
//	strcat(acmdS, "{FFFFFF}/unmute - to un-mute a specificed player.\n");
	strcat(acmdS, "\n{7DD8CB}Admin Level 3+ - Lead Administrator\n");
	strcat(acmdS, "{FFFFFF}/sethp - to set someone's health\n");
	strcat(acmdS, "{FFFFFF}/undercover - to go undercover in admin list\n");
	strcat(acmdS, "\n{7DD8CB}Admin Level 4+ - Division Leader\n");
	strcat(acmdS, "\n{7DD8CB}Admin Level 5+ - Management Team\n");
	strcat(acmdS, "{FFFFFF}/giveall - give players, what ever you like.\n");
	strcat(acmdS, "\n{7DD8CB}Admin Level 6+ - Development Team\n");
	strcat(acmdS, "{FFFFFF}/setlevel - to set a specified player's admin level.\n");
	strcat(acmdS, "/scp - to open the server control panel\n");
	strcat(acmdS, "\n{7DD8CB}Admin Level 7+ - Owner\n");
//	strcat(acmdS, "{FFFFFF}/setvip - to set a specificed player's vip level.\n");
//	strcat(acmdS, "{FFFFFF}/setpass - to set a specified offline player's password.\n");

	ShowPlayerDialog(playerid, DIALOG_CMDS, DIALOG_STYLE_MSGBOX, "PP:RP Admin Commands", acmdS, "Okay", "");
	return 1;
}

ShowPlayerRules(playerid)
{
	new RulZ[550];
	strcat(RulZ, "{FFFFFF}You must follow all these rules to play at PP:RP, not following any of these rules may lead to warn, kick or ban.\n");
	strcat(RulZ, "{FFFFFF}1. You are not allowed to do MG (Meta-Gaming) or PG (Power-Gaming).\n");
	strcat(RulZ, "{FFFFFF}2. You are not allowed to hack, abuse or interrupt the RP situations.\n");
	strcat(RulZ, "{FFFFFF}3. You are not allowed to abuse bugs, this includes GTA SA and SA-MP bugs.\n");
	strcat(RulZ, "{FFFFFF}4. You are not allowed to use advertise any kinds of links or IPs\n");
	strcat(RulZ, "{FFFFFF}5. If you have found someone hacking or abusing, take some proofs and report him/ her on our forum.");
	
	ShowPlayerDialog(playerid, DIALOG_RULES, DIALOG_STYLE_MSGBOX, "PP:RP Rules", RulZ, "Okay", "");
	return 1;
}

ShowPasswordChange(playerid)
{
	ShowPlayerDialog(playerid, DIALOG_CHANGEPS, DIALOG_STYLE_INPUT, "Changing Password - Step 1/3", "Input your current password, in order to change your password.", "Next", "Cancel");
	return 1;
}

ShowStats(playerid, targetid)
{
	new stts[100];
	strcat(stts, "Name: %s\nXP: %d\nPrison Credits: %d\nFaction ID: %d\nAdmin: %d\n");
	strcat(stts, "Skin: %d\nGender: %s");
	
	format(stts, sizeof(stts), stts, PlayerName(targetid), GetPlayerScore(targetid), Account[targetid][PCredits],
	Account[targetid][FID], Account[targetid][Admin], Account[targetid][Skin], GenderNames[Account[playerid][Gender]]);
	
	ShowPlayerDialog(playerid, DIALOG_STATS, DIALOG_STYLE_MSGBOX, "PP:RP User Stats", stts, "Okay", "");
	return 1;
}

ShowPlayerUCP(playerid)
{
	new UCPB[80];
	
	strcat(UCPB, "{FFFFFF}Change password\nCheck your stats\nSave your stats\nCheck others stats");
	ShowPlayerDialog(playerid, DIALOG_UCP, DIALOG_STYLE_LIST, "PP:RP User Control Panel", UCPB, "Select", "Cancel");
	return 1;
}

CMD:ucp(playerid)
{
	ShowPlayerUCP(playerid);
	return 1;
}

ShowPlayerSCP(playerid)
{
	new SCPB[80];
	
	strcat(SCPB, "{FFFFFF}Restart\nShut Down\nSave everyone's stats");
	ShowPlayerDialog(playerid, DIALOG_SCP, DIALOG_STYLE_LIST, "PP:RP Server Control Panel", SCPB, "Select", "Cancel");
	return 1;
}

CMD:scp(playerid)
{
	if(Account[playerid][Admin] < 5) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	ShowPlayerSCP(playerid);
	return 1;
}

CMD:cmds(playerid)
	return cmd_help(playerid);

CMD:help(playerid)
{
	ShowPlayerCMDS(playerid);
	return 1;
}

CMD:rules(playerid)
{
	ShowPlayerRules(playerid);
	return 1;
}

CMD:acmds(playerid, params[])
{
	if(Account[playerid][Admin] < 1) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	ShowPlayerACMDS(playerid);
	return 1;
}

CMD:kick(playerid, params[])
{
	new userid, reason[48], string[256];
	if(Account[playerid][Admin] < 1) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	if(sscanf(params, "uS(No Reason)[48]", userid, reason)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /kick [userid] [reason]");
	if(!IsPlayerConnected(userid) || userid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GRAD1, "User is not connected or invalid.");
	if(Account[userid][Admin] > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAD1, "That admin is higher than you.");
	format(string, sizeof(string), "%s %s has kicked %s %s. Reason: %s.", GetAdminRank(playerid), PlayerName(playerid), GetAdminRank(userid), PlayerName(userid), reason);
	SendClientMessageToAll(-1, string);
	defer KickEx(userid);
	return 1;
}

CMD:setlevel(playerid, params[])
{
	new userid, alvl, alvlS[128];
	if(Account[playerid][Admin] < 5) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	if(sscanf(params, "ud", userid, alvl)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /setlevel [userid] [admin level]");
	if(!IsPlayerConnected(userid) || userid == INVALID_PLAYER_ID) return SendClientMessage(playerid, COLOR_GRAD1, "User is not connected or invalid.");
	if(alvl < 0 || alvl > 7) return SendClientMessage(playerid, COLOR_GRAD1, "Admin levels are between 0 and 7");
	if(Account[userid][Admin] > Account[playerid][Admin]) return SendClientMessage(playerid, COLOR_GRAD1, "That admin is senior than you.");
	if(Account[userid][Admin] < alvl)
	{
		Account[userid][Admin] = alvl;
		format(alvlS, sizeof(alvlS), "%s %s has set you %s (Level %d).", GetAdminRank(playerid), PlayerName(playerid), GetAdminRank(userid), alvl);
		SendClientMessage(userid, COLOR_LIGHTGREEN, alvlS);
		SendClientMessage(userid, -1, "Promoted");
	}
	else
	{
		if(alvl > 0)
		{
			Account[userid][Admin] = alvl;
			format(alvlS, sizeof(alvlS), "%s %s has set you %s (Level %d).", GetAdminRank(playerid), PlayerName(playerid), GetAdminRank(userid), alvl);
			SendClientMessage(userid, COLOR_LIGHTGREEN, alvlS);
			SendClientMessage(userid, -1, "Demoted");
		}
		else if(alvl == 0)
		{
			Account[userid][Admin] = alvl;
			format(alvlS, sizeof(alvlS), "%s %s has removed you from the admin team", GetAdminRank(playerid), PlayerName(playerid));
			SendClientMessage(userid, COLOR_LIGHTGREEN, alvlS);
			SendClientMessage(userid, -1, "Fired");
		}
	}
	return 1;
}

CMD:slap(playerid,params[])
{
	if(Account[playerid][Admin] < 1) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	new targetid,string[256],height;
	if(sscanf(params, "ud", targetid, height)) return SendClientMessage(playerid,COLOR_GREY,"USAGE: /slap [playerid] [height]");
	if(height < 0 || height > 10) return SendClientMessage(playerid, COLOR_GRAD1, "The height should be between 0-10.");
	if(!IsPlayerConnected(targetid)) return SendClientMessage(playerid,COLOR_GRAD1,"Player is not online.");
	new Float:posxx[3];
	GetPlayerPos(targetid, posxx[0], posxx[1], posxx[2]);
	SetPlayerPos(targetid, posxx[0], posxx[1], posxx[2]+height);
	format(string, sizeof(string), "%s %s has slapped %s %s",GetAdminRank(playerid),PlayerName(playerid), GetAdminRank(targetid), PlayerName(targetid));
	SendClientMessageToAll(COLOR_LIGHTBLUE,string);
	return 1;
}

CMD:cc(playerid)
{
	if(Account[playerid][Admin] < 2) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " ");
	SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " ");
	SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " ");
	SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " ");
	SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " "); SendClientMessageToAll(-1, " ");
	return 1;
}

CMD:sethp(playerid, params[])
{
	new health, target;
	if(Account[playerid][Admin] < 3) return SendClientMessage(playerid, COLOR_GRAD1, "You are not authorized to use this command.");
	if(sscanf(params, "ud", target, health)) return SendClientMessage(playerid, COLOR_GREY, "USAGE: /sethp [playerid] [health]");
	if(health < 0 || health > 100) return SendClientMessage(playerid, COLOR_GRAD1, "Health must be between 0 - 100");
	if(!IsPlayerConnected(target)) return SendClientMessage(playerid,COLOR_GRAD1,"Player is not online.");
	SetPlayerHealth(target, health);
	return 1;
}

timer Connection[7500](playerid)
{
	SetPlayerCameraPos(playerid, 329.0985, 1411.3584, 22.6507);
	SetPlayerCameraLookAt(playerid, 226.1878, 1410.5841, 11.0000, CAMERA_CUT);
	HideConnectionTD(playerid);
	new userfile[40];
	format(userfile, sizeof(userfile), USER_FILE, PlayerName(playerid));
	if(fexist(userfile))
	{
		INI_ParseFile(userfile, "LoadUser_%s", .bExtra = true, .extra = playerid);
		new check[150];
		new File:checkfile = fopen(userfile, io_read);
		while(fread(checkfile, check))
		{
			if(strcmp(check, "Banned = 1", false) == 0 || strcmp(check, "Banned=1", false) == 0)
			{
				format(fstr2, sizeof(fstr2), "%s [%d] has been kicked from PP:RP - Reason: Name banned", PlayerName(playerid), playerid);
				SendClientMessageToAll(COLOR_GRAD1, fstr2);
				defer KickEx(playerid);
				return 1;
			}
			else
			{
				format(fstr2,sizeof(fstr2),"{FFFFFF}Welcome back %s!\n\nPlease enter your password below to login:", PlayerName(playerid));
				ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "{FFFFFF}PP:RP Account Login", fstr2, "Login", "Quit");
			}
		}
	}
	else
	{
		Account[playerid][XP] = 0;
		Account[playerid][Health] = 100.0;
		Account[playerid][PCredits] = 100;
		Account[playerid][FID] = 0;
		Account[playerid][Admin] = 0;
		Account[playerid][UnderCover] = 0;
		Account[playerid][OnDuty] = 0;
		Account[playerid][Skin] = 50;
		Account[playerid][Gender] = 0;
		Account[playerid][QuizDone] = 0;
		Account[playerid][X] = 0.0;
		Account[playerid][Y] = 0.0;
		Account[playerid][Z] = 0.0;
		Account[playerid][Interior] = 0;
		Account[playerid][VirWorld] = 0;
		Account[playerid][FStyle] = 0;
		Account[playerid][CellOwn] = 0;
		Account[playerid][InCell]= 0;

		new INI:ufile = INI_Open(userfile);
		INI_WriteString(ufile, "Pass", Account[playerid][Pass]);
		INI_WriteFloat(ufile, "Health", Account[playerid][Health]);
		INI_WriteInt(ufile, "XP", Account[playerid][XP]);
		INI_WriteInt(ufile, "Credits", Account[playerid][PCredits]);
		INI_WriteInt(ufile, "FID", Account[playerid][FID]);
		INI_WriteInt(ufile, "Admin", Account[playerid][Admin]);
		INI_WriteInt(ufile, "Skin", Account[playerid][Skin]);
		INI_WriteInt(ufile, "Gender", Account[playerid][Gender]);
		INI_WriteInt(ufile, "QuizDone", Account[playerid][QuizDone]);
		INI_WriteFloat(ufile, "X", Account[playerid][X]);
		INI_WriteFloat(ufile, "Y", Account[playerid][Y]);
		INI_WriteFloat(ufile, "Z", Account[playerid][Z]);
		INI_WriteFloat(ufile, "Interior", Account[playerid][Interior]);
		INI_WriteFloat(ufile, "VirWorld", Account[playerid][VirWorld]);
		INI_WriteInt(ufile, "FStyle", Account[playerid][FStyle]);
		INI_WriteInt(ufile, "CellOwn", Account[playerid][CellOwn]);
		INI_WriteInt(ufile, "InCell", Account[playerid][InCell]);
		INI_Close(ufile);

		format(fstr,sizeof(fstr),"{FFFFFF}Welcome to Project Prison RP %s!\n\nYou're not registered yet, please enter a password below to register:", PlayerName(playerid));
		ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "{FFFFFF}PP:RP Account Register", fstr, "Register", "Quit");
	}
	return 1;
}

CMD:b(playerid, params[])
{
	new msg[128], str[144];
	if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GREY, "{00BFFF}Usage:{FFFFFF} /o(oc) [text]");
	format(str, sizeof(str), "* [Local] %s: %s", PlayerCName(playerid), msg);
	SendLocalMessage(16.0, playerid, str, COLOR_LIGHTBLUE, COLOR_LIGHTBLUE);
	return 1;
}

CMD:ooc(playerid, params[])
	return cmd_o(playerid, params);

CMD:o(playerid, params[])
{
	new msg[128], str[200];
	if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GREY, "{00BFFF}Usage:{FFFFFF} /o(oc) [text]");
	format(str, sizeof(str), "* [OOC] %s: %s", PlayerCName(playerid), msg);
	SendClientMessageToAll(COLOR_LIGHTBLUE, str);
	return 1;
}

CMD:s(playerid, params[])
	return cmd_shout(playerid, params);

CMD:shout(playerid, params[])
{
	if(GetPlayerSpecialAction(playerid) != SPECIAL_ACTION_DUCK && GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_NONE && !Account[playerid][OnDuty])
	{
		switch(random(3))
		{
			case 0: ApplyAnimation(playerid, "ON_LOOKERS", "SHOUT_OUT", 4.0, 0, 1, 1, 0, 0);
			case 1: ApplyAnimation(playerid, "ON_LOOKERS", "SHOUT_01", 4.0, 0, 1, 1, 0, 0);
			case 2: ApplyAnimation(playerid, "ON_LOOKERS", "SHOUT_02", 4.0, 0, 1, 1, 0, 0);
		}
	}
	new msg[128], str[200];
	if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GREY, "{00BFFF}Usage:{FFFFFF} /(s)hout [text]");
	format(str, sizeof(str), "* %s shouts: %s", PlayerCName(playerid), msg);
	SendLocalMessage(20.0, playerid, str, COLOR_LIGHTBLUE, COLOR_LIGHTBLUE);
	return 1;
}

CMD:me(playerid, params[])
{
//	if(Account[playerid][Muted] == 1) return SendClientMessage(playerid, COLOR_GREY, "You can't use this whilst muted.");
	new msg[128], str[200];
	if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GREY, "{00BFFF}Usage:{FFFFFF} /me [action]");
	{
		format(str, sizeof(str), "* %s %s", PlayerCName(playerid), msg);
		SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
	}
	return 1;
}

CMD:do(playerid, params[])
{
//	if(Account[playerid][Muted] == 1) return SendClientMessage(playerid, COLOR_GREY, "You can't use this whilst muted.");
	new msg[128], str[200];
	if(sscanf(params, "s[128]", msg)) return SendClientMessage(playerid, COLOR_GREY, "{00BFFF}Usage:{FFFFFF} /do [local chat]");
	{
		format(str, sizeof(str), "* %s (( %s ))", msg, PlayerCName(playerid));
		SendLocalMessage(16.0, playerid, str, COLOR_PURPLE, COLOR_PURPLE);
	}
	return 1;
}

SetPlayerSkinEx(playerid, skinz)
{
	Account[playerid][Skin] = skinz;
	SetPlayerSkin(playerid, skinz);
	return 1;
}

ApplyAnimationEx(playerid, animlib[], animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You can't use this whilst inside of a vehicle.");
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp, 1);
	return 1;
}

LoopingAnim(playerid, animlib[], animname[], Float:Speed, looping, lockx, locky, lockz, lp)
{
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You can't use this whilst inside of a vehicle.");
	ApplyAnimation(playerid, animlib, animname, Speed, looping, lockx, locky, lockz, lp, 1);
	gPlayerUsingLoopingAnim[playerid] = 1;
	return 1;
}
LoopingWalk(playerid, lib[], anim[], Float:one, two, three, four, five, six, seven = 0)
{
	ApplyAnimation(playerid, lib, anim, one, two, three, four, five, six, seven);
	return 1;
}

StopLoopingAnim(playerid)
{
	gPlayerUsingLoopingAnim[playerid] = 0;
	ApplyAnimationEx(playerid, "CARRY", "crry_prtial", 4.0, 0, 0, 0, 0, 0);
}
//==============================================================================
PreloadAnimLib(playerid, animlib[])
{
	ApplyAnimation(playerid, animlib, "null", 0.0, 0, 0, 0, 0, 0);
}

PreloadAnims(playerid)
{
	if(!IsPlayerNPC(playerid))
	{
		ApplyAnimation(playerid, "AIRPORT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "Attractors", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BAR", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BASEBALL", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BD_FIRE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BEACH", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "benchpress", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BF_injection", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BIKED", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BIKEH", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BIKELEAP", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BIKES", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BIKEV", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BIKE_DBZ", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BLOWJOBZ", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BMX", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BOMBER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BOX", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BSKTBALL", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BUDDY", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "BUS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CAMERA", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CAR", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CARRY", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CAR_CHAT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CASINO", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CHAINSAW", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CHOPPA", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CLOTHES", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "COACH", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "COLT45", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "COP_AMBIENT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "COP_DVBYZ", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CRACK", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "CRIB", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DAM_JUMP", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DANCING", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DEALER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DILDO", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DODGE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DOZER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "DRIVEBYS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FAT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FIGHT_B", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FIGHT_C", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FIGHT_D", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FIGHT_E", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FINALE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FINALE2", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FLAME", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "Flowers", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "FOOD", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "Freeweights", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GANGS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GHANDS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GHETTO_DB", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "goggles", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GRAFFITI", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GRAVEYARD", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GRENADE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "GYMNASIUM", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "HAIRCUTS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "HEIST9", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "INT_HOUSE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "INT_OFFICE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "INT_SHOP", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "JST_BUISNESS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "KART", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "KISSING", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "KNIFE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "LOWRIDER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "MD_CHASE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "MD_END", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "MEDIC", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "MISC", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "MTB", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "MUSCULAR", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "NEVADA", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "ON_LOOKERS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "OTB", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "PARACHUTE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "PARK", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "PAULNMAC", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "ped", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "PLAYER_DVBYS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "PLAYIDLES", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "POLICE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "POOL", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "POOR", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "PYTHON", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "QUAD", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "QUAD_DBZ", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "RAPPING", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "RIFLE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "RIOT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "ROB_BANK", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "RUSTLER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "RYDER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SCRATCHING", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SHAMAL", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SHOP", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SHOTGUN", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SILENCED", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SKATE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SMOKING", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SNIPER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SPRAYCAN", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "STRIP", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SUNBATHE", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SWAT", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SWEET", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SWIM", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "SWORD", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "TANK", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "TATTOOS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "TEC", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "TRAIN", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "TRUCK", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "UZI", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "VAN", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "VENDING", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "VORTEX", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "WAYFARER", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "WEAPONS", "null", 0.0, 0, 0, 0, 0, 0);
		ApplyAnimation(playerid, "WUZI", "null", 0.0, 0, 0, 0, 0, 0);
	}
	return 1;
}

CreateGlobalBlood()
{
	Blood = TextDrawCreate(-37.000000, 2.000000, "_");
	TextDrawBackgroundColor(Blood, 255);
	TextDrawFont(Blood, 1);
	TextDrawLetterSize(Blood, 0.500000, 55.000000);
	TextDrawColor(Blood, -1);
	TextDrawSetOutline(Blood, 0);
	TextDrawSetProportional(Blood, 1);
	TextDrawSetShadow(Blood, 1);
	TextDrawUseBox(Blood, 1);
	TextDrawBoxColor(Blood, -939524046);
	TextDrawTextSize(Blood, 640.000000, 1.000000);
	TextDrawSetSelectable(Blood, 0);

	Hurt = TextDrawCreate(257.000000, 136.000000, "~r~You are hurt");
	TextDrawBackgroundColor(Hurt, 255);
	TextDrawFont(Hurt, 1);
	TextDrawLetterSize(Hurt, 0.600000, 3.000000);
	TextDrawColor(Hurt, -1);
	TextDrawSetOutline(Hurt, 1);
	TextDrawSetProportional(Hurt, 1);
	TextDrawSetSelectable(Hurt, 0);
	return 1;
}

DestroyGlobalBlood()
{
	TextDrawDestroy(Hurt);
	TextDrawDestroy(Blood);
	return 1;
}

ShowBlood(playerid)
{
	if(BloodStatus[playerid])
	{
		KillTimer(BloodTimer[playerid]);
		TextDrawShowForPlayer(playerid, Blood);
		TextDrawShowForPlayer(playerid, Hurt);
		BloodTimer[playerid] = SetTimerEx("BloodTime", HIDE_SECONDS * 1000, false, "i", playerid);
	}
	return 1;
}

HideBlood(playerid)
{
	TextDrawHideForPlayer(playerid, Blood);
	TextDrawHideForPlayer(playerid, Hurt);
	return 1;
}

forward BloodTime(playerid);
public	BloodTime(playerid)
{
	KillTimer(BloodTimer[playerid]);
	HideBlood(playerid);
	return 1;
}

CMD:blood(playerid)
{
	if(BloodStatus[playerid])
	{
		BloodStatus[playerid] = 0;
		SendClientMessage(playerid, -1, "Blood effects are disabled.");
	}
	else
	{
		BloodStatus[playerid] = 1;
		SendClientMessage(playerid, -1, "Blood effects are enabled.");
	}
	return 1;
}

LoadRemove(playerid)
{
	RemoveBuildingForPlayer(playerid, 3682, 247.9297, 1461.8594, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3682, 192.2734, 1456.1250, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3682, 199.7578, 1397.8828, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 166.7891, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 221.5703, 1374.9688, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 212.0781, 1426.0313, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 218.2578, 1467.5391, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1435.1953, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1410.5391, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1385.8906, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3291, 246.5625, 1361.2422, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3290, 190.9141, 1371.7734, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 183.7422, 1444.8672, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 222.5078, 1444.6953, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 221.1797, 1390.2969, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3288, 223.1797, 1421.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3683, 133.7422, 1459.6406, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3289, 207.5391, 1371.2422, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 220.6484, 1355.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 221.7031, 1404.5078, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 210.4141, 1444.8438, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3424, 262.5078, 1465.2031, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 220.6484, 1355.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1356.9922, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 190.9141, 1371.7734, 9.5859, 0.25);
	//RemoveBuildingForPlayer(playerid, 16392, 150.0781, 1378.3438, 11.8438, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1392.1563, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 207.5391, 1371.2422, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1394.1328, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1392.1563, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 205.6484, 1394.1328, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 207.3594, 1390.5703, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1387.8516, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 199.7578, 1397.8828, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 221.5703, 1374.9688, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 221.1797, 1390.2969, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 203.9531, 1409.9141, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 199.3828, 1407.1172, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 204.6406, 1409.8516, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1404.2344, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 206.5078, 1400.6563, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 221.7031, 1404.5078, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 207.3594, 1409.0000, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3257, 223.1797, 1421.1875, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 212.0781, 1426.0313, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 166.7891, 1426.9141, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1426.9141, 17.0938, 0.25);
	//RemoveBuildingForPlayer(playerid, 16391, 239.2969, 1367.9922, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1361.2422, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1385.8906, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1410.5391, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 183.7422, 1444.8672, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 210.4141, 1444.8438, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3258, 222.5078, 1444.6953, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 16086, 232.2891, 1434.4844, 13.5000, 0.25);
	//RemoveBuildingForPlayer(playerid, 16393, 149.3750, 1452.9375, 11.8516, 0.25);
	//RemoveBuildingForPlayer(playerid, 16394, 238.2734, 1452.9375, 11.8359, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 192.2734, 1456.1250, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 183.0391, 1455.7500, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3636, 133.7422, 1459.6406, 17.0938, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 196.0234, 1462.0156, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 198.0000, 1462.0156, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 196.0234, 1462.0156, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 180.2422, 1460.3203, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 180.3047, 1461.0078, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3256, 218.2578, 1467.5391, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 199.5859, 1463.7266, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 181.1563, 1463.7266, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 185.9219, 1462.8750, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 202.3047, 1462.8750, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 189.5000, 1462.8750, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3255, 246.5625, 1435.1953, 9.6875, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1451.8281, 27.4922, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1458.1094, 23.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 255.5313, 1454.5469, 19.1484, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1456.1328, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 253.8203, 1458.1094, 10.1172, 0.25);
	RemoveBuildingForPlayer(playerid, 3259, 262.5078, 1465.2031, 9.5859, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1468.2109, 18.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 3673, 247.9297, 1461.8594, 33.4141, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 254.6797, 1464.6328, 22.4688, 0.25);
	RemoveBuildingForPlayer(playerid, 3674, 247.5547, 1471.0938, 35.8984, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 255.5313, 1472.9766, 19.7578, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 252.8125, 1473.8281, 11.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 3675, 252.1250, 1473.8906, 16.2969, 0.25);
	RemoveBuildingForPlayer(playerid, 16089, 342.1250, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16090, 315.7734, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16091, 289.7422, 1431.0938, 5.2734, 0.25);
	RemoveBuildingForPlayer(playerid, 16087, 358.6797, 1430.4531, 11.6172, 0.25);
	return 1;
}

LoadInterior()
{
	LoadBlockA();
	LoadLibrary();
	LoadBus();
	LoadHQs();
	return 1;
}

LoadOutdoors()
{
	//Light
	CreateDynamicObject(1278, 229.90096, 1368.96594, 23.32740,   0.00000, 0.00000, 220.00000);
	CreateDynamicObject(1278, 200.74687, 1368.64319, 23.32740,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1278, 165.18126, 1376.34033, 23.32740,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(1278, 177.82100, 1440.04126, 23.32740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1278, 224.96089, 1439.91064, 23.32740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1278, 274.66998, 1421.92847, 23.32740,   0.00000, 0.00000, 300.00000);
	CreateDynamicObject(1278, 122.27402, 1401.62268, 23.32740,   0.00000, 0.00000, 120.00000);
	CreateDynamicObject(1278, 121.71516, 1440.38428, 23.32740,   0.00000, 0.00000, 40.00000);

	//Helipad
	CreateDynamicObject(3934, 263.38199, 1382.63379, 23.58800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3109, 250.77750, 1383.13220, 24.77640,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19124, 274.09549, 1371.32324, 24.19493,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19124, 253.04935, 1371.26794, 24.19493,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19124, 252.99965, 1392.70959, 24.19493,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19124, 274.11551, 1392.69324, 24.19493,   0.00000, 0.00000, 0.00000);

	CreateDynamicObject(3636, 401.63470, 1430.83179, 13.91010,   -2.44900, 0.79400, 0.00000);
	CreateDynamicObject(2774, 288.42181, 1420.14966, 8.99200,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19313, 280.73251, 1420.65112, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 273.66440, 1427.60815, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 273.66440, 1441.59253, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 232.71010, 1439.51099, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 218.71750, 1439.51099, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 184.82860, 1439.51099, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 170.84010, 1439.51099, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 136.91161, 1439.51099, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 127.59380, 1439.50647, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 120.60090, 1432.50391, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1418.53784, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1404.55750, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1390.57666, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1376.60352, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1362.59875, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2774, 288.42181, 1400.35864, 8.99200,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(2774, 273.68338, 1413.10034, 8.40500,   44.32500, 90.00000, 90.00000);
	CreateDynamicObject(19313, 273.66440, 1413.58960, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 273.66241, 1399.62964, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3998, 250.5902, 1383.93469, 15.86240,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 231.12820, 1348.60974, 11.45120,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 231.12820, 1373.50317, 11.45119,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 266.45618, 1392.07166, 12.91330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 264.77591, 1392.09949, 12.91330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 120.61320, 1362.59875, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1376.60352, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1390.57666, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1404.55750, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.61320, 1418.53784, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 120.60090, 1432.50391, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 127.59380, 1439.50647, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 136.91161, 1439.51099, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 170.84010, 1439.51099, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 184.82860, 1439.51099, 0.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 184.82860, 1439.51099, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 218.71750, 1439.51099, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 232.71010, 1439.51099, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 273.66440, 1441.59253, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 273.66440, 1427.60815, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 273.66440, 1413.58960, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 273.66241, 1399.62964, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 280.73251, 1420.65112, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 127.63920, 1402.47144, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 141.68280, 1402.47485, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 127.63920, 1402.47144, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 141.68280, 1402.47485, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 152.80748, 1402.46436, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 152.80750, 1402.46436, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 224.08275, 1341.65161, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 210.08070, 1341.64966, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 196.03830, 1341.64966, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 189.04291, 1348.67053, 8.86000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 181.95216, 1369.68909, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 167.93201, 1369.68713, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 167.93201, 1369.68713, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 181.95219, 1369.68909, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 189.04289, 1348.67053, 15.43390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 196.03830, 1341.64966, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 210.08070, 1341.64966, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 224.08270, 1341.65161, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 266.65228, 1448.68750, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 266.65231, 1448.68750, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 253.24706, 1448.69482, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 253.24710, 1448.69482, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 166.33110, 1369.70410, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 166.33110, 1369.70410, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 231.15221, 1378.30518, 11.45120,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 231.12820, 1348.60974, 18.01870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 231.18027, 1362.62976, 18.01870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 231.12820, 1376.63184, 18.01870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 231.15221, 1378.30518, 18.01870,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 249.09987, 1395.66016, 10.81643,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 144.01550, 1433.23865, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 144.01550, 1423.60559, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 144.01550, 1413.97095, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 144.01550, 1407.29395, 7.84530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(946, 133.94099, 1405.53662, 11.74820,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(946, 133.94099, 1436.98035, 11.75420,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(946, 192.15331, 1394.54370, 11.75420,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(946, 192.15327, 1415.97351, 11.75420,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(16101, 124.67510, 1430.52795, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 121.50750, 1430.53333, 2.04530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.69012, 1411.44495, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 121.52267, 1411.42480, 2.01386,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.80370, 1422.46643, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.80370, 1425.06714, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.80370, 1417.00623, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.80370, 1419.72461, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.80369, 1414.12524, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 124.80370, 1427.62610, 2.66450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1368, 121.81980, 1429.13477, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1426.59399, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1424.05383, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1421.51306, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1418.97241, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1416.43298, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1413.89294, 10.24290,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1368, 121.81980, 1412.79272, 10.24090,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3819, 148.02538, 1430.57410, 10.56690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3819, 148.02541, 1412.24792, 10.56690,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 133.75110, 1421.10522, 7.84730,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 256.09412, 1416.68701, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 256.09021, 1402.67493, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 259.53851, 1416.68701, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 259.53851, 1402.67493, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 259.53851, 1388.71472, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 259.53134, 1385.30688, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19304, 257.82379, 1423.68518, 12.65040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19303, 258.70190, 1423.68518, 10.82450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19302, 256.96381, 1423.68518, 10.82450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19304, 257.82181, 1423.68604, 13.45540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19087, 243.86713, 1409.75989, 11.82390,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(16101, 241.42200, 1409.74902, 1.03310,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 243.83760, 1409.74902, 1.55447,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19087, 241.42929, 1412.25928, 11.51171,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(16101, 241.41301, 1412.28894, 0.71990,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 238.44328, 1409.49829, 4.53515,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 233.55949, 1409.49829, 4.53520,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(19087, 238.47841, 1409.50061, 15.41054,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19087, 236.02180, 1409.49976, 15.41050,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19087, 235.13200, 1409.49976, 15.41050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19088, 235.13200, 1409.49976, 12.56050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19087, 235.13300, 1409.49988, 14.97250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19087, 236.88100, 1409.49976, 15.41050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19087, 236.88200, 1409.49988, 14.97250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19088, 236.88100, 1409.49976, 12.56050,   0.00000, 0.00000, 100.00000);
	CreateDynamicObject(2629, 232.45370, 1396.74707, 9.56030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2629, 235.83270, 1396.74707, 9.56030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2628, 239.51656, 1396.91650, 9.56030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2628, 242.37840, 1396.91650, 9.56030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2628, 246.40311, 1396.91650, 9.56030,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19087, 243.85231, 1409.78259, 12.43094,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(16101, 243.83659, 1407.32373, 1.55450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14791, 221.89018, 1409.56616, 10.71730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3819, 222.00067, 1416.85522, 10.56690,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3819, 222.00070, 1401.17529, 10.56690,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14401, 158.21140, 1389.36743, 9.85860,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14401, 158.21140, 1382.26062, 9.85860,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(14401, 199.27879, 1451.74060, 9.85860,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19313, 196.08022, 1369.65076, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 210.08054, 1369.65601, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 224.14120, 1369.71680, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 196.08020, 1369.65076, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 210.08051, 1369.65601, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 224.14120, 1369.71680, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 259.54727, 1430.67126, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 259.54489, 1444.65137, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 259.52869, 1444.99170, 10.81640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3279, 225.11710, 1453.37585, 9.57495,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, 177.97411, 1453.37585, 9.57490,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, 131.18930, 1453.37585, 9.57490,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3279, 196.86661, 1362.67029, 9.57490,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3819, 192.97433, 1384.39124, 10.56690,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3279, 277.74667, 1462.05188, 9.57495,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3881, 290.71954, 1403.95178, 7.91466,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3881, 290.71951, 1403.95178, 11.62820,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(966, 287.82001, 1406.73767, 9.38020,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(995, 288.36459, 1414.8303, 10.02890,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(19357, 230.36552, 1344.86133, 7.83630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 227.24139, 1344.86133, 7.83630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 224.30040, 1344.86133, 7.83630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 221.12010, 1344.86133, 7.83630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 217.97820, 1344.86133, 7.83630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 214.87869, 1344.86133, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 211.89880, 1344.86133, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 208.79820, 1344.86133, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 205.73801, 1344.86133, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 202.65770, 1344.86133, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 199.62410, 1344.86133, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19445, 205.85971, 1365.02515, 7.84330,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(19445, 210.96640, 1365.02515, 7.84330,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(19445, 216.35660, 1365.02515, 7.84330,   0.00000, 0.00000, 40.00000);
	CreateDynamicObject(19445, 194.27516, 1355.55566, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 194.25998, 1351.51111, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19313, 182.06242, 1355.64258, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 168.05917, 1355.65137, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 166.29829, 1355.63013, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 182.06239, 1355.64258, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 168.05920, 1355.65137, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 166.29829, 1355.63013, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16101, 209.59576, 1416.09485, 2.11692,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.47256, 1416.10486, 2.63112,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.48151, 1396.98914, 2.63112,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 209.60202, 1396.99182, 2.02408,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.36301, 1400.21082, 2.63110,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.36301, 1403.31189, 2.63110,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.36301, 1406.55176, 2.63110,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.36298, 1409.67273, 2.63112,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(16101, 206.36301, 1412.97266, 2.63110,   0.00000, 0.00000, -0.12000);
	CreateDynamicObject(1368, 209.32401, 1414.75415, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32401, 1412.21338, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32401, 1409.67358, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32401, 1407.13293, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32401, 1404.59229, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32401, 1402.05164, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32401, 1399.51184, 10.22490,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1368, 209.32600, 1398.23071, 10.22290,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1344, 144.56853, 1379.93787, 10.38110,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1344, 144.56850, 1382.72021, 10.38110,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1344, 144.57619, 1385.46326, 10.38110,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1448, 143.55380, 1376.95752, 9.65270,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1448, 143.55380, 1376.95752, 9.79170,   0.00000, 0.00000, 342.68130);
	CreateDynamicObject(1448, 143.55380, 1376.95752, 9.93170,   0.00000, 0.00000, 14.36257);
	CreateDynamicObject(1438, 143.05623, 1386.77234, 9.58368,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 152.35753, 1402.46692, 8.86000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19313, 152.35750, 1402.46692, 15.43390,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19357, 249.71919, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 246.57690, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 243.57091, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 240.60989, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 237.58971, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 255.62720, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 258.84741, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 261.94739, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 265.06699, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 268.22720, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19357, 271.58710, 1368.81921, 7.83630,   0.00000, 0.00000, -0.24000);
	CreateDynamicObject(19445, 231.60339, 1348.26526, 8.14430,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19381, 236.77890, 1348.25146, 9.81440,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19445, 236.50990, 1352.99475, 8.14430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 246.13570, 1352.99475, 8.14430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19381, 247.27850, 1348.25146, 9.81440,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19445, 236.33180, 1343.50916, 8.14330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 245.96671, 1343.50916, 8.14330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19381, 257.77829, 1348.25146, 9.81440,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, 268.27979, 1348.25146, 9.81440,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19445, 255.60130, 1343.50916, 8.14330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 265.23401, 1343.50916, 8.14330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 268.72629, 1343.51025, 8.14430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 273.45529, 1348.26318, 8.14330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 255.76910, 1352.99475, 8.14430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 265.40240, 1352.99475, 8.14430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 268.60251, 1352.99585, 8.14530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 174.64439, 1397.55090, 7.84830,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 174.64540, 1391.74231, 7.84730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 179.55141, 1387.01550, 7.84730,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 189.18491, 1387.01550, 7.84730,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 198.81950, 1387.01550, 7.84730,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 203.72580, 1391.74316, 7.84730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 203.72580, 1401.37756, 7.84730,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 203.72580, 1411.01184, 7.84930,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 203.72580, 1414.61157, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 200.05220, 1414.51978, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 200.05220, 1404.88550, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 200.05220, 1395.25098, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 195.14500, 1390.67908, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 185.51089, 1390.67908, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 183.03030, 1390.67810, 7.84230,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 178.32050, 1395.58594, 7.84230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 178.32150, 1397.62573, 7.84130,   0.00000, 0.00000, 0.00000);

	CreateDynamicObject(617, 240.74400, 1347.65723, 9.58400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(615, 267.28683, 1347.63049, 9.58400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(8623, 237.49951, 1348.04504, 10.50238,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8623, 248.02049, 1348.10803, 10.50238,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8623, 258.78787, 1347.87732, 10.50238,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8623, 267.66467, 1348.14111, 10.50238,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8990, 265.79184, 1347.00977, 10.40348,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8990, 253.82431, 1346.98291, 10.40348,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8990, 239.91698, 1346.90771, 10.40348,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8990, 239.52455, 1348.38513, 10.40348,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8990, 252.48409, 1348.48730, 10.40348,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(8990, 265.10614, 1348.68286, 10.40348,   0.00000, 0.00000, 0.72000);


	//Cell blocks & Public building
	new cblock = CreateObject(5738, 250.59111, 1457.35632, 13.04880,   0.00000, 0.00000, 90.65300);
	SetObjectMaterial(cblock, 4, 4079, "civic04_lan", "twintWin1_LAn"); //Windows
	SetObjectMaterial(cblock, 3, 4079, "civic04_lan", "twintWall2_LAn"); //Roof corner
	cblock = CreateObject(5738, 202.69530, 1457.38159, 13.04880,   0.00000, 0.00000, 90.65300);
	SetObjectMaterial(cblock, 4, 4079, "civic04_lan", "twintWin1_LAn" ); //Windows
	SetObjectMaterial(cblock, 3, 4079, "civic04_lan", "twintWall2_LAn"); //Roof corner
	cblock = CreateObject(5738, 154.79713, 1457.36853, 13.04880,   0.00000, 0.00000, 90.65300);
	SetObjectMaterial(cblock, 4, 4079, "civic04_lan", "twintWin1_LAn" ); //Windows
	SetObjectMaterial(cblock, 3, 4079, "civic04_lan", "twintWall2_LAn"); //Roof corner

	cblock = CreateObject(5738, 153.92700, 1364.09631, 13.04880,   0.00000, 0.00000, 0.65300);
	SetObjectMaterial(cblock, 4, 3998, "civic04_lan", "twintWin2_LAn" ); //Windows
	SetObjectMaterial(cblock, 3, 3998, "civic04_lan", "twintconc_LAn"); //Roof corner
	cblock = CreateObject(5738, 156.25397, 1383.78210, 5.84841,   0.00000, 0.00000, 90.65300);
	SetObjectMaterial(cblock, 4, 4079, "civic04_lan", "twintWin1_LAn" ); //Windows
	SetObjectMaterial(cblock, 3, 4079, "civic04_lan", "twintWall2_LAn"); //Roof corner

	new grass = CreateObject(8661, 239.54919, 1429.49438, 9.58680,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(8661, 199.54930, 1429.49438, 9.58680,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(8661, 163.92641, 1429.49438, 9.58880,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(8661, 163.92641, 1412.45239, 9.59080,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(8661, 246.07111, 1419.51489, -10.39270,   -0.09000, 90.00000, 270.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(19381, 225.75252, 1378.60693, 9.81440,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(19381, 225.75369, 1388.24182, 9.81440,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(19381, 215.25240, 1388.24182, 9.81440,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");
	grass = CreateObject(19381, 215.25240, 1378.60693, 9.81440,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(grass, 0, 17877, "landhub", "dirtKB_64HV");

	//Roads
	new road = CreateObject(19447, 153.82552, 1433.24878, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 153.82550, 1423.61450, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 153.82550, 1413.98083, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 153.82550, 1404.34619, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 201.88910, 1433.24878, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 249.70700, 1433.24475, 9.50310,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 160.39301, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 170.02370, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 179.65800, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 189.29311, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 198.92720, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 208.56310, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 218.19791, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 227.83200, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 237.46550, 1426.67969, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 246.64120, 1426.67773, 9.50710,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 257.82697, 1396.96594, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 257.82700, 1406.60217, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 257.82700, 1416.23669, 9.50910,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 251.65305, 1422.43433, 9.40710,   0.00000, 90.00000, 51.63934);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 254.75819, 1426.67773, 9.50510,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 257.82700, 1422.33044, 9.50710,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 206.90739, 1436.32495, 9.50710,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 160.39191, 1404.88257, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 249.70700, 1424.24158, 9.50510,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 201.88910, 1424.30957, 9.50710,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 148.91389, 1421.23462, 9.50710,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 201.88910, 1414.67603, 9.50710,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 201.88910, 1405.04333, 9.50710,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 201.88910, 1395.40613, 9.50710,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 198.82060, 1388.83875, 9.50710,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 189.18770, 1388.83875, 9.50710,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 179.55310, 1388.83875, 9.50710,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 176.48511, 1395.40625, 9.50710,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 170.02319, 1404.88257, 9.50910,   0.00000, 90.00000, 90.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");
	road = CreateObject(19447, 176.48309, 1401.81384, 9.50810,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(road, 0, 4079, "civic04_lan", "plaintarmac1");

	CreateDynamicObject(19445, 170.10970, 1402.45764, 7.84630,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 179.25240, 1402.45764, 7.84530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 183.98109, 1407.36255, 7.84530,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 183.97910, 1414.69836, 7.84330,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 188.88429, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 198.51880, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 208.15269, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 217.78529, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 227.41811, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 237.05209, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 246.68600, 1419.42615, 7.84330,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 251.54640, 1419.42712, 7.84130,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2913, 235.35320, 1396.20483, 10.53980,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(2913, 231.97060, 1396.22119, 10.53980,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(2915, 234.32182, 1400.07874, 9.70230,   0.00000, 0.00000, 5.00000);
	CreateDynamicObject(2916, 237.37637, 1399.65674, 9.70230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2915, 236.32271, 1400.50977, 9.70230,   0.00000, 0.00000, 10.00000);
	CreateDynamicObject(19445, 259.48611, 1433.24548, 7.84330,   0.00000, 0.00000, 0.00000);



	//Pit
	new pit = CreateObject(19447, 121.50720, 1416.17822, 11.00700,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 121.50717, 1425.81262, 11.00700,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 123.18810, 1425.81262, 13.31820,   0.00000, -100.00000, 0.00000); //Roof
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "plaintarmac1");
	pit = CreateObject(19447, 123.18810, 1416.17822, 13.31820,   0.00000, -100.00000, 0.00000); //Roof
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "plaintarmac1");
	pit = CreateObject(19447, 257.81140, 1418.93103, 14.04940,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 257.81140, 1409.29639, 14.04940,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 257.81140, 1399.66150, 14.04940,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 257.81140, 1390.02795, 14.04940,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 254.31754, 1390.86194, 14.04940,   0.00000, 90.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 209.63820, 1411.35950, 11.00700,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 209.63820, 1401.72534, 11.00700,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19447, 208.03281, 1401.72534, 13.27660,   0.00000, 100.00000, 0.00000); //Roof
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "plaintarmac1");
	pit = CreateObject(19447, 208.03191, 1411.35950, 13.27660,   0.00000, 100.00000, 0.00000); //Roof
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "plaintarmac1");
	pit = CreateObject(19355, 123.20170, 1411.45129, 11.00700,   0.00000, 0.00000, 90.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19355, 123.20320, 1430.54175, 11.00700,   0.00000, 0.00000, 90.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19355, 207.94400, 1416.08618, 11.00700,   0.00000, 0.00000, 90.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");
	pit = CreateObject(19355, 207.94400, 1396.99658, 11.00700,   0.00000, 0.00000, 90.00000);
	SetObjectMaterial(pit, 0, 4079, "civic04_lan", "twintWall2_LAn");

	//Sign
	new sign = CreateObject(19447, 288.09763, 1415.01477, 19.62394,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(sign, 0, 2774, "airp_prop", "cj_white_wall2");
	sign = CreateObject(19447, 288.09830, 1405.38281, 19.62390,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(sign, 0, 2774, "airp_prop", "cj_white_wall2");
	sign = CreateObject(19447, 287.9496, 1415.01477, 19.62394,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(sign, 0, 2774, "airp_prop", "cj_white_wall2");
	sign = CreateObject(19447, 287.9496, 1405.38281, 19.62390,   0.00000, 0.00000, 0.00000);
	SetObjectMaterial(sign, 0, 2774, "airp_prop", "cj_white_wall2");

	//Gates
	CreateDynamicObject(988, 231.21869, 1358.35840, 10.61700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(988, 231.21870, 1363.84888, 10.61700,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(968, 287.81442, 1406.71497, 10.02230,   0.00000, 0.00000, 90.00000); //Barrier

	//Doors
	CreateDynamicObject(3109, 154.61871, 1438.06323, 10.77020,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3109, 202.56454, 1438.04517, 10.77020,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3109, 250.45157, 1438.03906, 10.77020,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3109, 153.9786, 1403.04712, 10.77020,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3109, 173.22977, 1366.2065, 10.77020,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(3109, 139.8456, 1374.94885, 10.77020,   0.00000, 0.00000, 270.00000);

	//Grass area
	CreateDynamicObject(19445, 216.55380, 1373.85425, 8.14430,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 214.81371, 1373.85315, 8.14530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 210.06380, 1378.58154, 8.14630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 210.06380, 1388.20105, 8.14630,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19445, 214.79179, 1393.00476, 8.14530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 224.42570, 1393.00476, 8.14530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19445, 234.05949, 1393.00476, 8.14530,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3694, 226.09680, 1382.20959, 10.23200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(617, 211.71286, 1383.07922, 9.58400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(337, 221.29813, 1387.08557, 10.63570,   180.00000, -20.00000, 180.00000);
	CreateDynamicObject(337, 218.26199, 1386.34912, 9.98550,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(617, 226.17700, 1383.07922, 9.58400,   0.00000, 0.00000, 60.00000);
	CreateDynamicObject(19445, 226.18690, 1373.85425, 8.14430,   0.00000, 0.00000, 90.00000);

	new SAHFP = CreateObject(10184, 288.0661, 1410.3990, 19.4953, 0.0000, 0.0000, 179.9874);
	SetObjectMaterialText(SAHFP, "PROJECT PRISON ROLE PLAY", 0, 120, "Times New Roman", 31, 1, -8092540, 0, 1);
	return 1;
}

DestroyMap()
{
	for(new i = 0; i < MAX_OBJECTS; i +=1)
	{
		if(IsValidObject(i))
		{
			DestroyObject(i);
		}
	}
	return 1;
}

LoadLibrary()
{
	CreateDynamicObject(16500, -2235.39355, 413.58496, 36.15100,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(16500, -2233.82788, 427.91101, 33.55300,   0.00000, 0.00000, 139.99454);
	CreateDynamicObject(16500, -2235.39404, 418.57700, 33.54700,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(16500, -2235.40625, 423.56641, 36.16300,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(16500, -2235.39404, 418.57599, 38.74700,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(16500, -2235.39404, 413.58499, 38.75100,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(16500, -2235.40601, 423.56601, 38.73800,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(16500, -2233.82690, 427.91000, 38.72800,   0.00000, 0.00000, 139.99329);
	CreateDynamicObject(16500, -2229.79907, 429.78799, 38.71600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(1843, -2235.21289, 412.79800, 32.71600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1843, -2235.21509, 415.77499, 32.71600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1843, -2235.21606, 418.77499, 32.71600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1843, -2235.21411, 421.75000, 32.71600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1843, -2235.21411, 424.72601, 32.71600,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1843, -2234.37305, 427.02200, 32.71600,   0.00000, 0.00000, 50.00000);
	CreateDynamicObject(1843, -2233.00488, 428.64999, 32.71600,   0.00000, 0.00000, 49.99878);
	CreateDynamicObject(1843, -2230.95288, 429.61301, 32.71600,   0.00000, 0.00000, 359.99878);
	CreateDynamicObject(1843, -2228.80298, 429.61600, 32.71600,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(1501, -2226.31909, 429.81299, 34.28000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(16500, -2229.79883, 429.78809, 36.16600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2219.82202, 429.78900, 36.16600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2214.84595, 429.79001, 36.16600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2209.84692, 429.78900, 36.16600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(1843, -2220.82300, 429.61099, 32.71600,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(1843, -2219.83911, 429.61200, 32.71600,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(1843, -2216.86304, 429.61200, 32.71600,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(1843, -2213.88599, 429.61099, 32.71600,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(1843, -2210.90405, 429.60999, 32.71600,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(16500, -2224.80688, 429.78799, 38.71600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2219.82104, 429.78799, 38.71600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2214.84595, 429.78900, 38.71600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2209.84692, 429.78799, 38.71600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(1501, -2223.28906, 429.83200, 34.28000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1843, -2225.82007, 429.61600, 32.29100,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(1843, -2222.82397, 429.61301, 32.29100,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(16500, -2228.77808, 429.76700, 36.16600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(16500, -2220.82397, 429.78699, 36.16600,   0.00000, 0.00000, 89.98901);
	CreateDynamicObject(19358, -2226.33594, 428.14700, 35.34700,   89.49994, 0.00000, 1.75000);
	CreateDynamicObject(19358, -2224.80811, 428.14899, 36.84700,   0.24936, 90.00653, 270.25244);
	CreateDynamicObject(19358, -2223.15991, 428.15900, 35.34700,   89.49463, 0.00000, 1.74683);
	CreateDynamicObject(19378, -2227.65088, 424.39801, 34.21600,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19378, -2218.02490, 424.40201, 34.21600,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19378, -2208.40210, 424.40302, 34.21600,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19378, -2230.86108, 413.91501, 34.21600,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19378, -2221.23608, 413.92001, 34.21600,   0.00000, 90.00000, 269.99994);
	CreateDynamicObject(19378, -2211.60205, 413.92499, 34.21600,   0.00000, 90.00000, 270.00000);
	CreateDynamicObject(19361, -2221.58691, 426.39700, 36.02700,   0.00000, 0.00000, 270.50000);
	CreateDynamicObject(19361, -2218.82495, 427.43301, 36.02700,   0.00000, 0.00000, 310.49988);
	CreateDynamicObject(19453, -2212.83301, 428.15399, 36.02700,   0.00000, 0.00000, 266.00000);
	CreateDynamicObject(19453, -2209.55688, 413.50000, 36.02700,   0.00000, 0.00000, 179.99548);
	CreateDynamicObject(19453, -2209.55566, 423.11523, 36.02700,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(19453, -2230.25391, 411.33401, 36.02700,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(19453, -2220.62891, 411.33600, 36.02700,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(19453, -2211.00000, 411.33801, 36.02700,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(19361, -2227.80005, 426.33701, 36.02700,   0.00000, 0.00000, 270.49988);
	CreateDynamicObject(19361, -2230.38306, 427.52100, 36.02700,   0.00000, 0.00000, 220.49988);
	CreateDynamicObject(19434, -2231.73511, 429.12601, 36.02700,   0.00000, 0.00000, 39.50000);
	CreateDynamicObject(19361, -2233.12207, 428.36801, 33.80200,   0.25021, 180.00000, 139.99554);
	CreateDynamicObject(19434, -2234.61792, 426.59100, 33.80200,   0.00000, 180.00000, 139.49588);
	CreateDynamicObject(19361, -2235.12988, 424.32001, 36.00200,   0.00000, 0.00000, 180.49561);
	CreateDynamicObject(19434, -2235.12988, 421.93500, 36.00200,   0.00000, 0.00000, 359.49585);
	CreateDynamicObject(19361, -2235.14795, 419.52701, 33.80200,   0.00000, 180.00000, 0.49445);
	CreateDynamicObject(19361, -2235.09692, 417.65100, 33.80200,   0.00000, 179.99451, 0.49438);
	CreateDynamicObject(19434, -2235.14111, 421.87799, 36.00200,   0.00000, 0.00000, 359.49463);
	CreateDynamicObject(19453, -2235.08203, 411.24500, 36.02700,   0.00000, 0.00000, 359.99451);
	CreateDynamicObject(19361, -2233.12207, 428.36700, 38.45200,   0.24719, 179.99451, 139.99329);
	CreateDynamicObject(19434, -2234.61694, 426.59100, 38.45200,   0.00000, 179.99451, 139.49341);
	CreateDynamicObject(19361, -2235.12305, 419.52701, 38.47700,   0.00000, 179.99451, 0.49438);
	CreateDynamicObject(19361, -2235.09692, 417.64999, 38.47700,   0.00000, 179.99451, 0.49438);
	CreateDynamicObject(19366, -2233.56592, 420.89801, 34.20400,   0.00000, 270.00000, 269.99994);
	CreateDynamicObject(19366, -2233.57104, 424.36899, 34.20400,   0.00000, 270.00000, 269.99451);
	CreateDynamicObject(19366, -2232.88794, 426.57599, 34.17900,   0.00000, 270.00000, 229.99451);
	CreateDynamicObject(19366, -2232.44409, 427.11700, 34.15400,   0.00000, 270.00000, 229.99329);
	CreateDynamicObject(1649, -2235.46191, 416.38199, 35.10500,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1649, -2235.45410, 420.78299, 35.10500,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1649, -2235.22998, 420.78201, 35.10500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1649, -2235.22949, 420.78125, 35.10500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1649, -2235.23804, 416.37799, 35.10500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1649, -2235.26294, 416.37799, 35.10500,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1649, -2234.38110, 427.36700, 35.10500,   0.00000, 269.74976, 230.00000);
	CreateDynamicObject(1649, -2233.37305, 428.58701, 35.10500,   0.00000, 269.74731, 229.99878);
	CreateDynamicObject(1649, -2233.21899, 428.42300, 35.10500,   0.00000, 269.74731, 49.99878);
	CreateDynamicObject(1649, -2234.21802, 427.20999, 35.10500,   0.00000, 269.74731, 49.99878);
	CreateDynamicObject(19361, -2235.12305, 419.52399, 32.70200,   0.00000, 179.99451, 0.49438);
	CreateDynamicObject(19361, -2235.07202, 417.64899, 32.72700,   0.00000, 179.99451, 0.49438);
	CreateDynamicObject(19434, -2234.61694, 426.59100, 32.70200,   0.00000, 179.99451, 139.49341);
	CreateDynamicObject(19361, -2233.12207, 428.36700, 32.70200,   0.24719, 179.99451, 139.99329);
	CreateDynamicObject(19361, -2224.70801, 426.38599, 38.60200,   359.99719, 179.99451, 90.49326);
	CreateDynamicObject(19358, -2226.32690, 427.97400, 32.82200,   0.49988, 180.00000, 181.74683);
	CreateDynamicObject(19358, -2223.16699, 428.01801, 32.82200,   359.99988, 179.99451, 181.74130);
	CreateDynamicObject(19377, -2227.27490, 424.50201, 37.85900,   0.00000, 90.00000, 89.99994);
	CreateDynamicObject(19377, -2230.51489, 420.74301, 37.88400,   0.00000, 90.00000, 89.99451);
	CreateDynamicObject(19377, -2230.51807, 410.31400, 37.88400,   0.00000, 90.00000, 89.99451);
	CreateDynamicObject(19377, -2217.64795, 424.51901, 37.88400,   0.00000, 90.00000, 89.99451);
	CreateDynamicObject(19377, -2208.05493, 424.52301, 37.88400,   0.00000, 90.00000, 89.99451);
	CreateDynamicObject(19377, -2220.93091, 414.10501, 37.88400,   0.00000, 90.00000, 89.99451);
	CreateDynamicObject(19377, -2211.72607, 413.94800, 37.88400,   0.00000, 90.00000, 89.99451);
	CreateDynamicObject(19362, -2232.82300, 426.19601, 37.89100,   0.00000, 90.25021, 50.00000);
	CreateDynamicObject(19362, -2231.91602, 427.32700, 37.86600,   0.00000, 90.24719, 49.99878);
	CreateDynamicObject(14455, -2214.66797, 411.42401, 35.97400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -2220.39502, 411.42200, 35.97400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -2226.11108, 411.42001, 35.97400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -2231.84204, 411.42001, 35.97400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14455, -2209.64307, 412.25000, 35.97400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14455, -2209.64307, 417.96399, 35.97400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2289, -2227.86890, 426.22501, 36.65400,   0.00000, 0.00000, 0.50000);
	CreateDynamicObject(2287, -2221.52490, 425.83600, 36.24100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2284, -2218.18896, 427.05600, 36.25700,   0.00000, 0.00000, 40.50000);
	CreateDynamicObject(2283, -2213.48193, 428.08801, 36.64800,   0.00000, 0.00000, 356.00000);
	CreateDynamicObject(2282, -2231.05908, 427.44699, 36.14900,   0.00000, 0.00000, 310.75000);
	CreateDynamicObject(2281, -2234.53711, 423.44699, 36.28100,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2280, -2234.47290, 413.63199, 36.29300,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2272, -2210.21606, 425.42999, 36.05700,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1893, -2230.66089, 414.67099, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2230.56396, 419.54700, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2230.75000, 424.48499, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2225.61890, 422.20599, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2225.85107, 416.61099, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2221.85010, 416.53299, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2221.61792, 422.20099, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2216.01196, 419.34799, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2215.74194, 424.43301, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1893, -2215.66797, 414.53400, 38.25800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1702, -2213.41309, 416.97501, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2230.80591, 415.31201, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2230.80688, 416.69601, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2230.80493, 418.07901, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2230.80591, 419.46301, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2229.85303, 414.77600, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2229.85596, 416.15900, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2229.85693, 417.53799, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2229.85693, 418.92300, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2227.16406, 415.35199, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2227.16602, 416.73499, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2227.16406, 418.12100, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2223.16797, 415.36200, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2226.20508, 414.81400, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2226.20190, 416.19699, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2226.20190, 417.58200, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2222.20898, 414.82401, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2227.15723, 419.50195, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2223.16895, 416.74600, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2223.16992, 418.13199, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2223.17310, 419.51501, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2175, -2226.19727, 418.96680, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2222.20898, 416.20999, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2222.20605, 417.59500, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2175, -2222.20703, 418.97800, 34.30200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2196, -2223.42993, 418.73700, 35.07900,   0.00000, 0.00000, 130.00000);
	CreateDynamicObject(2196, -2223.42310, 417.33600, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2223.44409, 415.95999, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2223.40991, 414.58499, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2227.40405, 414.54401, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2227.39111, 415.91901, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2227.37793, 417.31900, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2227.39111, 418.69400, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2231.05688, 418.65799, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2231.03394, 417.25699, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2231.03711, 415.88199, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2231.04199, 414.48199, 35.07900,   0.00000, 0.00000, 129.99573);
	CreateDynamicObject(2196, -2229.63892, 415.59601, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2229.65088, 416.97198, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2229.63892, 418.34698, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2229.62500, 419.74701, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2225.97998, 419.79099, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2225.96411, 418.39001, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2225.97510, 417.01501, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2225.98511, 415.64001, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2221.96997, 415.63901, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2221.99390, 417.03900, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2221.99292, 418.41299, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(2196, -2221.99194, 419.78699, 35.07900,   0.00000, 0.00000, 309.99573);
	CreateDynamicObject(1721, -2223.72290, 419.26501, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2223.73291, 417.94901, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2223.62012, 416.54300, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2224.03491, 414.97000, 34.30200,   0.00000, 0.00000, 310.00000);
	CreateDynamicObject(1721, -2225.73706, 415.07101, 34.30200,   0.00000, 0.00000, 89.99573);
	CreateDynamicObject(1721, -2225.80200, 416.39700, 34.30200,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1721, -2225.57910, 417.40302, 34.30200,   0.00000, 0.00000, 39.99451);
	CreateDynamicObject(1721, -2225.45093, 419.64200, 34.30200,   0.00000, 0.00000, 149.99451);
	CreateDynamicObject(1721, -2227.54395, 419.28101, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2227.56299, 417.87299, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2227.89209, 416.23999, 34.30200,   0.00000, 0.00000, 330.00000);
	CreateDynamicObject(1721, -2231.22998, 415.08401, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2229.07690, 415.41000, 34.30200,   0.00000, 0.00000, 149.99451);
	CreateDynamicObject(1721, -2229.30298, 416.40601, 34.30200,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1721, -2229.10107, 417.24799, 34.30200,   0.00000, 0.00000, 49.99451);
	CreateDynamicObject(1721, -2229.37012, 419.17999, 34.30200,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1721, -2227.60156, 415.17773, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2231.21704, 416.41901, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2231.26392, 417.89899, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, -2231.53711, 418.76001, 34.30200,   0.00000, 0.00000, 330.00000);
	CreateDynamicObject(1721, -2221.25610, 419.02802, 34.30200,   0.00000, 0.00000, 46.00000);
	CreateDynamicObject(1721, -2221.54102, 417.76801, 34.30200,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1721, -2221.68091, 416.43799, 34.30200,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1721, -2221.67896, 415.00500, 34.30200,   0.00000, 0.00000, 89.99451);
	CreateDynamicObject(1702, -2214.04102, 413.96399, 34.30200,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1433, -2215.08911, 415.89001, 34.48200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2164, -2210.95605, 427.88300, 34.30200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1998, -2210.23291, 424.56799, 34.30200,   0.00000, 0.00000, 178.00000);
	CreateDynamicObject(1998, -2212.22192, 423.63800, 34.30200,   0.00000, 0.00000, 87.99500);
	CreateDynamicObject(1721, -2212.49194, 424.87500, 34.30200,   0.00000, 0.00000, 145.99976);
	CreateDynamicObject(1721, -2211.38892, 424.78900, 34.30200,   0.00000, 0.00000, 217.99731);
	CreateDynamicObject(2854, -2230.90503, 419.27899, 35.13200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2854, -2227.20508, 416.56201, 35.13200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2853, -2227.07690, 419.34100, 35.08000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2853, -2223.08008, 416.58701, 35.08000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2852, -2215.12598, 415.89401, 34.99000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2855, -2222.91211, 419.68399, 35.09500,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2836, -2225.34497, 428.56400, 34.30200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2824, -2230.82593, 417.92200, 35.09000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2824, -2227.17700, 417.91800, 35.09000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2824, -2223.18701, 415.16000, 35.09000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2186, -2212.80396, 427.59698, 34.30200,   0.00000, 0.00000, 356.00000);
	CreateDynamicObject(2002, -2214.26709, 423.59100, 34.30200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2864, -2214.15308, 424.48999, 34.99000,   0.00000, 0.00000, 44.00000);
	CreateDynamicObject(1433, -2214.30908, 424.46100, 34.48200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(914, -2233.60498, 411.46899, 36.91900,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(910, -2210.28296, 433.05701, 35.44100,   0.00000, 0.00000, 260.00000);
	CreateDynamicObject(1428, -2224.82397, 411.90500, 35.87000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1428, -2217.42090, 412.00400, 35.87000,   0.00000, 0.00000, 179.99451);
	CreateDynamicObject(1428, -2210.20996, 416.65302, 35.87000,   0.00000, 0.00000, 269.99451);
	CreateDynamicObject(19439, -2231.00195, 430.04800, 40.11600,   0.00000, 89.74976, 0.00000);
	CreateDynamicObject(19439, -2233.25806, 428.99100, 40.11600,   0.00000, 89.74731, 50.00000);
	CreateDynamicObject(19439, -2227.54712, 430.04599, 40.11600,   0.00000, 89.74731, 0.00000);
	CreateDynamicObject(19439, -2224.06909, 430.04800, 40.11600,   0.00000, 89.74731, 0.00000);
	CreateDynamicObject(19439, -2220.59399, 430.05301, 40.11600,   0.00000, 89.74731, 0.00000);
	CreateDynamicObject(19439, -2217.17212, 430.05200, 40.11600,   0.00000, 89.74731, 0.00000);
	CreateDynamicObject(19439, -2213.70288, 430.05499, 40.11600,   0.00000, 89.74731, 0.00000);
	CreateDynamicObject(19439, -2210.23608, 430.06000, 40.11600,   0.00000, 89.74731, 0.00000);
	CreateDynamicObject(19439, -2234.73193, 427.23801, 40.11600,   0.00000, 89.74731, 49.99878);
	CreateDynamicObject(19439, -2235.65991, 424.67599, 40.11600,   0.00000, 89.74731, 89.99878);
	CreateDynamicObject(19439, -2235.65601, 421.17599, 40.11600,   0.00000, 89.74731, 89.99451);
	CreateDynamicObject(19439, -2235.65210, 417.67099, 40.11600,   0.00000, 89.74731, 89.99451);
	CreateDynamicObject(19439, -2235.64893, 414.16699, 40.11600,   0.00000, 89.74731, 89.99451);
	CreateDynamicObject(19439, -2235.64795, 412.85101, 40.11600,   0.00000, 89.74731, 89.99451);
	CreateDynamicObject(19439, -2230.98608, 430.75699, 40.96600,   270.00000, 180.00000, 90.00000);
	CreateDynamicObject(19439, -2227.50806, 430.75500, 40.96600,   270.00000, 179.99451, 90.00000);
	CreateDynamicObject(19439, -2224.00903, 430.75500, 40.96600,   270.00000, 179.99451, 90.00000);
	CreateDynamicObject(19439, -2220.51001, 430.75201, 40.96600,   270.00000, 179.99451, 90.00000);
	CreateDynamicObject(19439, -2217.01001, 430.75101, 40.96600,   270.00000, 179.99451, 90.00000);
	CreateDynamicObject(19439, -2213.51294, 430.75000, 40.96600,   270.00000, 179.99451, 90.00000);
	CreateDynamicObject(19439, -2210.01294, 430.74899, 40.96600,   270.00000, 179.99451, 90.00000);
	CreateDynamicObject(19439, -2233.79492, 429.45099, 40.96600,   270.00000, 179.99451, 140.00000);
	CreateDynamicObject(19439, -2235.27197, 427.69501, 40.96600,   270.00000, 179.99451, 139.99878);
	CreateDynamicObject(19439, -2236.37109, 424.65100, 40.96600,   270.00000, 179.99451, 179.99878);
	CreateDynamicObject(19439, -2236.37109, 421.17401, 40.96600,   270.00000, 179.99451, 179.99451);
	CreateDynamicObject(19439, -2236.37598, 417.69601, 40.96600,   270.00000, 179.99451, 179.99451);
	CreateDynamicObject(19439, -2236.37598, 414.21799, 40.96600,   270.00000, 179.99451, 179.99451);
	CreateDynamicObject(19439, -2236.36108, 412.84399, 40.96600,   270.00000, 179.99451, 179.99451);
	CreateDynamicObject(19439, -2234.56299, 411.18500, 40.96600,   270.00000, 179.99451, 269.74451);
	CreateDynamicObject(19381, -2214.11694, 425.89200, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2214.11401, 416.26300, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2224.61108, 425.88400, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2227.41406, 425.87201, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2231.11890, 421.58801, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2231.07104, 411.96301, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2223.33911, 412.59201, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19381, -2223.33911, 419.84201, 41.64100,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19373, -2232.62109, 428.48599, 41.63300,   0.00000, 90.00000, 49.99994);
	CreateDynamicObject(19373, -2234.09692, 426.68900, 41.63300,   0.00000, 90.00000, 49.99878);
	return 1;
}

LoadBus()
{
	CreateDynamicObject(2631, 2022.00000, 2236.69995, 2102.89990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, 2022.00000, 2240.60010, 2102.89990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, 2022.00000, 2244.50000, 2102.89990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2631, 2022.00000, 2248.39990, 2102.89990,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(16501, 2022.09998, 2238.30005, 2102.80005,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(16501, 2022.09998, 2245.30005, 2102.80005,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(16000, 2024.19995, 2240.10010, 2101.19995,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(16000, 2019.80005, 2240.60010, 2101.19995,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(16000, 2022.19995, 2248.69995, 2101.19995,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(16501, 2021.80005, 2246.50000, 2107.30005,   0.00000, 270.00000, 90.00000);
	CreateDynamicObject(16501, 2022.00000, 2240.80005, 2107.30005,   0.00000, 270.00000, 0.00000);
	CreateDynamicObject(16501, 2022.00000, 2233.69995, 2107.30005,   0.00000, 270.00000, 0.00000);
	CreateDynamicObject(18098, 2024.30005, 2239.60010, 2104.80005,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18098, 2024.30005, 2239.69995, 2104.69995,   0.00000, 0.00000, 450.00000);
	CreateDynamicObject(18098, 2020.09998, 2239.60010, 2104.80005,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(18098, 2020.00000, 2239.60010, 2104.69995,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2236.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2238.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2240.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2242.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2244.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2246.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2023.59998, 2248.10010, 2106.69995,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(2180, 2020.30005, 2235.10010, 2106.69995,   0.00000, 180.00000, 270.00000);
	CreateDynamicObject(2180, 2020.30005, 2237.10010, 2106.69995,   0.00000, 180.00000, 270.00000);
	CreateDynamicObject(2180, 2020.30005, 2239.10010, 2106.69995,   0.00000, 180.00000, 270.00000);
	CreateDynamicObject(2180, 2020.30005, 2241.10010, 2106.69995,   0.00000, 180.00000, 270.00000);
	CreateDynamicObject(2180, 2020.30005, 2243.10010, 2106.69995,   0.00000, 180.00000, 270.00000);
	CreateDynamicObject(2180, 2020.30005, 2245.10010, 2106.69995,   0.00000, 180.00000, 270.00000);
	CreateDynamicObject(2674, 2023.40002, 2238.30005, 2102.89990,   0.00000, 0.00000, 600.00000);
	CreateDynamicObject(2674, 2020.40002, 2242.30005, 2102.89990,   0.00000, 0.00000, 600.00000);
	CreateDynamicObject(2674, 2023.40002, 2246.30005, 2102.89990,   0.00000, 0.00000, 600.00000);
	CreateDynamicObject(14405, 2022.00000, 2242.10010, 2103.50000,   0.00000, 0.00000, 540.00000);
	CreateDynamicObject(14405, 2022.00000, 2243.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2022.00000, 2245.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2022.00000, 2246.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2022.00000, 2248.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2022.00000, 2249.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2022.00000, 2251.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2242.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2243.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2245.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2246.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2248.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2249.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2251.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2242.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2243.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2245.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2246.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2248.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2249.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2019.40002, 2251.10010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2022.00000, 2253.60010, 2104.00000,   -6.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2021.09998, 2253.60010, 2104.00000,   -6.00000, 0.00000, 180.00000);
	CreateDynamicObject(14405, 2024.59998, 2253.60010, 2103.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2674, 2020.40002, 2235.69995, 2102.89990,   0.00000, 0.00000, 52.00000);
	CreateDynamicObject(2673, 2020.40002, 2246.69995, 2102.89990,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2700, 2023.50000, 2235.10010, 2105.50000,   180.00000, -4.00000, 90.00000);
	CreateDynamicObject(2700, 2020.40002, 2235.10010, 2105.50000,   180.00000, 0.00000, 90.00000);
	CreateDynamicObject(2700, 2023.50000, 2242.10010, 2105.50000,   180.00000, -4.00000, 90.00000);
	CreateDynamicObject(2700, 2020.40002, 2242.10010, 2105.50000,   180.00000, 0.00000, 90.00000);
	CreateDynamicObject(1799, 2023.09998, 2234.19995, 2105.69995,   270.00000, 0.00000, 360.00000);
	CreateDynamicObject(1799, 2019.80005, 2234.19995, 2105.69995,   270.00000, 0.00000, 0.00000);
	CreateDynamicObject(1538, 2022.69995, 2234.69995, 2102.80005,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1799, 2022.09998, 2234.19995, 2106.10010,   720.00000, 90.00000, 450.00000);
	CreateDynamicObject(1799, 2021.80005, 2234.19995, 2105.10010,   0.00000, 270.00000, 270.00000);
	CreateDynamicObject(1799, 2022.09998, 2234.19995, 2107.30005,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1799, 2021.59998, 2234.19995, 2106.30005,   0.00000, 270.00000, 270.00000);
	CreateDynamicObject(1799, 2022.30005, 2234.19995, 2104.30005,   90.00000, 0.00000, 180.00000);
	return 1;
}

LoadBlockA()
{
	CreateDynamicObject(19364, 182.64000, 1416.43005, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1419.63000, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1419.64001, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1410.01001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1413.21997, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1410.02002, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 1406.81006, 552.03998, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 198.27000, 1419.63000, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.27000, 1410.01001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1422.83997, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 182.47000, 1420.15002, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1420.16003, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1424.33997, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.42999, 1424.33997, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1418.26001, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1416.19995, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1416.19995, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1414.27002, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1412.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1412.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1410.28003, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1408.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 141.00000, 552.31000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 208.75999, 1410.01001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 208.75999, 1419.63000, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19365, 204.56000, 1408.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1408.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 207.17999, 1406.81006, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1410.02002, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1413.21997, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1416.43005, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1419.64001, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1422.83997, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 204.56000, 1412.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1416.19995, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1420.16003, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1408.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1412.38000, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1416.19995, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1420.16003, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1424.33997, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1424.33997, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 188.85001, 1424.34998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 192.06000, 1424.32996, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 193.59419, 1425.84241, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 198.46001, 1424.32996, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 201.66000, 1424.32996, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 207.17999, 1406.81006, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1410.02002, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1413.21997, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1416.43005, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1419.64001, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.14999, 1422.83997, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1400.39001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.28000, 1400.39001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 208.80000, 1400.39001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 208.78000, 1390.76001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.25999, 1390.76001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1390.76001, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1403.59998, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1400.39001, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1397.18994, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1393.97998, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1390.78003, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1387.57996, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1403.59998, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 187.00000, 1409.54004, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1402.31995, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 207.20000, 1400.39001, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1397.18994, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1393.97998, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1390.78003, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1387.57996, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19365, 204.56000, 1404.40002, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1404.40002, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 186.94000, 1406.31995, 556.21002,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(19365, 185.64000, 1404.40002, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1404.40002, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1400.42004, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1400.42004, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1400.42004, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1400.42004, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1398.33997, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1396.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1396.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1394.35999, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.56000, 1392.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1392.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1390.38000, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1388.51001, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1388.51001, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1396.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1392.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1388.51001, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1396.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1392.47998, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1388.51001, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 188.86000, 1388.48999, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 192.05000, 1388.48999, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 198.46001, 1388.48999, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 201.66000, 1388.48999, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 207.17999, 1403.59998, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.20000, 1400.39001, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1397.18994, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1393.97998, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1390.78003, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 207.17999, 1387.57996, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 201.66000, 1424.32996, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 198.46001, 1424.32996, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 195.25999, 1424.32996, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 192.06000, 1424.32996, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 188.85001, 1424.32996, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1424.33997, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1424.33997, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1424.33997, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.42999, 1424.33997, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 182.64000, 1422.83997, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1419.64001, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1416.43005, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1413.21997, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1410.02002, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1403.59998, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1406.81006, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1400.39001, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1397.18994, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1393.97998, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1390.78003, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19364, 182.64000, 1387.57996, 555.53998,   0.00000, 180.00000, 0.00000);
	CreateDynamicObject(19365, 185.66000, 1388.51001, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1388.51001, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 188.86000, 1388.48999, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 192.05000, 1388.48999, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 195.25000, 1388.48999, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 198.46001, 1388.48999, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19364, 201.66000, 1388.48999, 555.53998,   0.00000, 180.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1388.51001, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1388.51001, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1422.23999, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 184.52000, 1422.76001, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(12839, 190.32001, 1415.68005, 551.46997,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19377, 184.52000, 1413.14001, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(970, 189.78000, 1415.87000, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 184.52000, 1413.14001, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1422.76001, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1413.16003, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1422.76001, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14437, 203.25999, 1422.23999, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1420.16003, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.47000, 1420.15002, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1418.26001, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1414.27002, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1416.19995, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1416.19995, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1412.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1412.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1408.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1408.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 184.52000, 1393.88000, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1403.52002, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14437, 203.25999, 1402.31995, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1398.31995, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1394.35999, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(14437, 203.25999, 1390.38000, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1404.40002, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1404.40002, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.66000, 1400.42004, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1400.42004, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1396.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1396.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 185.64000, 1392.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 182.45000, 1392.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 184.52000, 1403.52002, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1393.87000, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1384.26001, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1403.52002, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1393.88000, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1384.26001, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14437, 203.25999, 1406.31995, 552.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 182.64000, 1406.80005, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1422.73999, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1403.52002, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1393.90002, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 184.52000, 1384.26001, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1384.28003, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1422.77002, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1413.14001, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1403.52002, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1393.90002, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1384.28003, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1422.76001, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1413.14001, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1403.52002, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1393.90002, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53999, 1384.28003, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14437, 203.25999, 1410.28003, 556.21002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 195.02000, 1424.88000, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(970, 189.78000, 1411.70996, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 189.78000, 1407.55005, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 189.78000, 1403.38000, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 189.78000, 1399.21997, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 189.78000, 1395.05005, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 191.91000, 1420.08997, 554.73999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 196.07001, 1420.08997, 554.73999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 198.17000, 1420.08997, 554.73999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(13011, 199.75000, 1414.76001, 550.84998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 200.35001, 1415.79004, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 200.35001, 1411.63000, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 200.35001, 1407.46997, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 200.35001, 1403.31006, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 200.35001, 1399.15002, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 200.35001, 1394.98999, 554.73999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 195.02000, 1388.15002, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(970, 198.25999, 1392.92004, 554.73999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 194.08000, 1392.92004, 554.73999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(970, 191.84000, 1392.92004, 554.73999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 187.00000, 1413.54004, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1417.53003, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1421.52002, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1405.58997, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 195.02000, 1388.15002, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.02000, 1388.15002, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1495, 187.00000, 1401.58997, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1397.60999, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1393.63000, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1389.66003, 550.19000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 195.02000, 1424.88000, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.02000, 1424.88000, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1495, 203.14999, 1391.15002, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1395.14001, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1399.12000, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1403.09998, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1407.08997, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1411.04004, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1415.05005, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1419.05005, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1423.01001, 550.19000,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 187.00000, 1389.66003, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1393.63000, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1397.60999, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1401.58997, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1405.58997, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1409.54004, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1413.54004, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1417.53003, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 187.00000, 1421.52002, 554.20001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1495, 203.14999, 1423.01001, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1419.05005, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1415.05005, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1411.06006, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1407.08997, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1403.09998, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1399.12000, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1395.14001, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1495, 203.14999, 1391.15002, 554.20001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1771, 184.06000, 1391.71997, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1616, 202.59000, 1388.83997, 556.96002,   0.00000, 0.00000, -20.00000);
	CreateDynamicObject(1616, 202.85001, 1424.09998, 553.01001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1389.38000, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.06000, 1391.71997, 551.92999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1393.30005, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1397.71997, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1401.78003, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1405.65002, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1409.77002, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1413.69995, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1417.62000, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1421.38000, 550.83002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00000, 1395.68994, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00000, 1395.68994, 551.96002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1399.64001, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1399.64001, 551.95001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1403.64001, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1403.64001, 551.92999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00999, 1407.62000, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00999, 1407.62000, 551.95001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.07001, 1411.63000, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.07001, 1411.63000, 551.95001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1415.43994, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1415.43994, 551.90997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1419.39001, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1419.39001, 551.94000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1423.56995, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1423.56995, 551.95001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1389.38000, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1393.30005, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1397.71997, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1401.78003, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1405.65002, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1409.77002, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1413.69995, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1417.62000, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 183.09000, 1421.38000, 554.71997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.06000, 1391.71997, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00000, 1395.68994, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1399.64001, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1403.64001, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00999, 1407.62000, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.07001, 1411.63000, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1415.43994, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1419.39001, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1423.56995, 554.77002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.06000, 1391.71997, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00000, 1395.68994, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1399.64001, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1403.64001, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.00999, 1407.62000, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.07001, 1411.63000, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1415.43994, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.02000, 1419.39001, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 184.03000, 1423.56995, 555.79999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 206.70000, 1389.13000, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1393.08997, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1397.16003, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1401.27002, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1405.31006, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1409.39001, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1413.48999, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1417.28003, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1421.22998, 550.82001,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1771, 205.78000, 1391.71997, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1391.71997, 551.94000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1395.69995, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1395.69995, 551.94000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1399.63000, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1399.63000, 551.92999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1403.60999, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1403.60999, 551.92999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1407.59998, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1407.59998, 551.91998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1411.59998, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1411.59998, 551.92999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1415.40002, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1415.40002, 551.92999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.75999, 1419.42004, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.75999, 1419.40002, 551.95001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1423.56006, 550.89001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1423.56006, 551.94000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 206.70000, 1389.13000, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(19365, 204.56000, 1392.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1392.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1396.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1400.42004, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1404.40002, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1408.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1412.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1416.19995, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1420.16003, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 204.56000, 1424.33997, 555.53998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1396.47998, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1400.42004, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1404.40002, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1408.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 205.53999, 1413.14001, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19365, 207.75999, 1412.38000, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1416.19995, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19365, 207.75999, 1420.16003, 555.96997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2602, 206.70000, 1393.08997, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1397.16003, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1401.27002, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1405.31006, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1409.39001, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1413.48999, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1417.28003, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2602, 206.70000, 1421.22998, 554.71997,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(1771, 205.78000, 1423.56006, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.75999, 1419.42004, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1415.40002, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1411.59998, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1407.59998, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1403.60999, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1399.63000, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1395.69995, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1391.71997, 554.82001,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1423.56006, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.75999, 1419.42004, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1415.40002, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1411.59998, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1407.59998, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1403.60999, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1399.63000, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1395.69995, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1771, 205.78000, 1391.71997, 555.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 208.78000, 1390.76001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.25999, 1390.76001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1390.76001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1400.39001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.28000, 1400.39001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 208.80000, 1400.39001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 208.75999, 1410.01001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 208.75999, 1419.63000, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.27000, 1410.01001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.27000, 1419.63000, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1419.63000, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 187.78000, 1410.01001, 557.38000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19393, 195.25000, 1388.48999, 552.03003,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1569, 194.48000, 1388.51001, 550.28003,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19379, 277.84000, 1722.18994, 536.77002,   0.00000, -90.00000, 0.00000);
	CreateDynamicObject(19379, 277.84000, 1731.82996, 536.77002,   0.00000, -90.00000, 0.00000);
	CreateDynamicObject(19379, 288.35001, 1731.81006, 536.77002,   0.00000, -90.00000, 0.00000);
	CreateDynamicObject(19379, 288.35001, 1722.18994, 536.77002,   0.00000, -90.00000, 0.00000);
	CreateDynamicObject(19363, 293.51001, 1735.02002, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 293.51001, 1731.81995, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 293.51001, 1728.62000, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 293.51001, 1725.42004, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 293.51001, 1722.21997, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 293.51001, 1719.02002, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1719.53003, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1720.88000, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1722.22998, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1723.58997, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1724.93994, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1729.01001, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1730.35999, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1731.71997, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.92999, 1733.06995, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 288.91000, 1734.43005, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1734.43005, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1733.06995, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1731.71997, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1730.35999, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1729.01001, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1724.93994, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1723.58997, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1722.22998, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1720.88000, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 280.79001, 1719.53003, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1719.53003, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1720.88000, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1722.22998, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1723.58997, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1724.93994, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1729.01001, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1730.35999, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1731.71997, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1733.06995, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1968, 284.87000, 1734.43005, 537.37000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1845, 277.04001, 1718.85999, 536.84998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1845, 277.04001, 1721.85999, 536.84998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1845, 277.04001, 1724.85999, 536.84998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1845, 277.04001, 1727.85999, 536.84998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1845, 277.04001, 1730.87000, 536.84998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1845, 277.04001, 1733.87000, 536.84998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 291.82001, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 288.62000, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 285.42999, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 282.23001, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 279.01999, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 275.81000, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 272.60999, 1736.53003, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2857, 280.82001, 1734.71997, 537.63000,   0.00000, 0.00000, 45.00000);
	CreateDynamicObject(2218, 280.78000, 1729.59998, 537.67999,   -26.26000, 24.34000, 0.16000);
	CreateDynamicObject(2212, 285.04001, 1729.68994, 537.69000,   -26.26000, 24.34000, 0.16000);
	CreateDynamicObject(2213, 285.12000, 1724.56006, 537.69000,   -26.52000, 24.38000, 0.16000);
	CreateDynamicObject(19363, 272.66000, 1734.83997, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 272.66000, 1728.43994, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 272.66000, 1725.23999, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 272.66000, 1722.03003, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 272.66000, 1718.81995, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19363, 274.35999, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 277.56000, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 280.76001, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 283.97000, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19392, 287.17001, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 290.35999, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19363, 293.57001, 1717.48999, 538.59998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19392, 272.66000, 1731.64001, 538.59998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1569, 286.39999, 1717.47998, 536.85999,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1557, 272.64001, 1730.90002, 536.85999,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 277.85999, 1722.38000, 540.40002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 277.85999, 1732.00000, 540.40002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 288.37000, 1732.00000, 540.40002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 288.37000, 1722.38000, 540.40002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1432, 192.67546, 1406.75720, 550.29602,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1432, 196.67551, 1406.75720, 550.29602,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1432, 192.67551, 1399.75720, 550.29602,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1432, 196.67551, 1399.75720, 550.29602,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3430, 194.91161, 1403.46863, 551.90100,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 196.92419, 1425.84241, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 196.92419, 1428.97437, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 193.59419, 1428.97437, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 198.09393, 1428.97144, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 198.09390, 1438.49939, 550.21002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19364, 193.59419, 1432.17236, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 198.59000, 1430.49121, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 201.59000, 1430.49121, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 203.09860, 1432.12378, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 203.09860, 1435.12378, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 203.09860, 1438.12378, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 203.09860, 1441.12378, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 203.09860, 1444.12378, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 201.56912, 1442.97278, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 198.56911, 1442.97278, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 195.56911, 1442.97278, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 192.56911, 1442.97278, 552.03998,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19364, 193.59419, 1435.00000, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 193.59419, 1438.00000, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 193.59419, 1441.00000, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19364, 193.59419, 1444.00000, 552.03998,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2524, 202.53661, 1440.00000, 550.23187,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2524, 202.53661, 1441.00000, 550.23187,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2524, 202.53661, 1442.00000, 550.23187,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(14782, 200.70560, 1442.54089, 551.09650,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1557, 198.22881, 1430.51843, 550.23431,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 195.02000, 1434.50000, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.02000, 1443.50000, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.02000, 1434.50000, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.01431, 1443.52771, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.01430, 1443.52771, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 195.02000, 1434.50000, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.50700, 1434.50000, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53191, 1425.57617, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.53191, 1425.57617, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.50700, 1434.50000, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.50700, 1434.50000, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.50700, 1425.57617, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.38290, 1443.56897, 553.78003,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.38290, 1443.56897, 553.96002,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 205.38290, 1443.56897, 554.12000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(14401, 202.49690, 1433.45166, 550.39697,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2400, 194.38080, 1442.94409, 550.56097,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2689, 196.63499, 1442.57996, 551.89447,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2689, 195.48000, 1442.57996, 551.89447,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2704, 196.64375, 1442.51025, 551.10022,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2704, 195.45580, 1442.51025, 551.10022,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2063, 202.74451, 1437.59338, 551.14948,   0.00000, 0.00000, 90.00000);
	return 1;
}

LoadHQs()
{
	LoadDoCHQ();
	LoadInfirmary();
	return 1;
}

LoadDoCHQ()
{
	CreateDynamicObject(19439, 766.61749, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.59399, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.61261, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1402.68042, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1401.36035, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43390, -1399.92065, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1398.52039, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1397.24036, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1395.76038, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1395.76038, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1397.21741, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1398.67444, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1400.13147, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00244, -1401.66248, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1403.18652, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.75012, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.72308, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.20453, -1425.68628, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 770.27271, -1396.56213, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 749.40009, -1419.51465, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 749.40009, -1422.65747, 3001.74536,   0.00000, 0.00000, -0.06000);
	CreateDynamicObject(19358, 749.40009, -1424.85449, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1395.76038, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1397.02734, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1398.47534, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54822, -1399.90198, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1401.37134, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1402.81934, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.26300, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.20453, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.81653, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 768.63470, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 765.57867, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 762.48871, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 759.39868, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19404, 762.47791, -1401.47217, 3001.74194,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19325, 762.46808, -1403.84045, 3001.56421,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19439, 755.46228, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.81653, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.96777, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.28552, -1402.26514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.31317, -1400.71887, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.28552, -1399.16113, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.29950, -1397.60913, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.26550, -1396.05737, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.28552, -1395.75916, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 759.63092, -1397.54016, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 758.08929, -1401.88403, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 758.08929, -1399.40381, 3001.74658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 758.08929, -1403.63306, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 762.47791, -1396.42078, 3001.74658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 756.26270, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 753.22467, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 754.95349, -1395.75916, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.95349, -1397.22925, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.95349, -1398.69922, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.97180, -1400.19055, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.97339, -1401.64075, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.97552, -1403.09082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.46228, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.42853, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.96338, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 753.51312, -1406.28125, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 753.51312, -1403.08130, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 753.51312, -1399.88135, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 753.51361, -1396.41479, 3001.74658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 753.51312, -1399.28125, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19439, 751.65491, -1397.31604, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.65552, -1398.66919, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.67615, -1400.20190, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.65552, -1401.57922, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.63623, -1403.11230, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.96301, -1422.51868, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.94342, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.44690, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 750.10529, -1394.86865, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 751.65149, -1395.75916, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.17944, -1395.76062, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.15948, -1397.31116, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.15948, -1398.86316, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.15948, -1400.41516, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.15948, -1401.96716, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.17950, -1403.51917, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.46692, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.46692, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.07813, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.06000);
	CreateDynamicObject(19358, 747.85010, -1402.59338, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 747.84961, -1399.04480, 3001.74658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 747.85211, -1396.55640, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 747.02173, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 747.85010, -1405.78845, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 747.85010, -1407.26099, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1395.76062, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1397.29358, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1398.82666, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1400.35974, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1401.89270, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1403.42566, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.07813, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.07813, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.84302, -1424.09448, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1395.76062, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1397.29358, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1398.82666, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1400.35974, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1401.89270, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1403.42566, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.84302, -1422.49866, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1406.49170, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.84302, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 743.95569, -1394.86694, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 741.68372, -1394.86890, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 739.98767, -1396.38696, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1399.48706, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1402.58716, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1405.68726, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1406.30725, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 741.65930, -1408.93518, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07172, -1408.93518, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07172, -1400.22485, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 741.62457, -1400.22485, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07233, -1396.67285, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 743.58972, -1395.02502, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 741.64032, -1396.69287, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2603, 740.60541, -1406.59485, 3000.53369,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2602, 742.73877, -1400.74500, 3000.61230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2603, 740.60541, -1402.59985, 3000.53369,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2603, 740.60541, -1398.98083, 3000.53369,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2602, 742.73877, -1397.15100, 3000.61230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 762.47791, -1398.96790, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2602, 742.73877, -1404.69702, 3000.61230,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27271, -1402.92908, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27271, -1399.75513, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27118, -1418.49084, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27118, -1421.69031, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27118, -1424.88379, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27118, -1409.08435, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27118, -1412.16919, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 770.27118, -1415.28821, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1409.51575, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 749.40009, -1413.18140, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1404.95874, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1406.92969, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.87445, -1404.95959, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.15948, -1406.92725, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.15948, -1406.62317, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.17950, -1405.07117, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.89441, -1406.49170, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82843, -1406.92969, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.65552, -1406.92725, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.67548, -1404.68213, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.67548, -1406.25598, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.99341, -1406.05115, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.01343, -1406.92041, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.99341, -1404.58105, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.28552, -1405.36914, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.28552, -1406.92114, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58551, -1405.71582, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1406.92114, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58350, -1404.26721, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.28552, -1403.81714, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1404.69055, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1406.19458, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.00250, -1406.92163, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1404.04041, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1405.44043, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43347, -1406.92041, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.58679, -1425.68640, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.82361, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.80438, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.65790, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.74438, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.85083, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.32648, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.81732, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.08038, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.12231, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.60950, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.57422, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 752.29657, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.79761, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.06598, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.09698, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.59259, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.45697, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 759.29688, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.80200, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.81989, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.87482, -1417.69995, 3000.00000,   0.00000, 90.00000, -0.06000);
	CreateDynamicObject(19439, 765.35852, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.30682, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 766.22479, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.60071, -1417.69995, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.62811, -1419.29773, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.59308, -1420.89514, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.90131, -1416.21082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.88483, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.60120, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.56091, -1411.67944, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.56091, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.65381, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.49933, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.60468, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.05969, -1411.67944, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.83008, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.93793, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.41510, -1416.19092, 3000.00000,   0.00000, 90.00000, 0.06000);
	CreateDynamicObject(19439, 748.90552, -1416.21082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.16992, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.19470, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 748.56409, -1411.70398, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.82611, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84747, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.33368, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.31738, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 752.03882, -1411.70398, 3000.04004,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.68433, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 752.39948, -1416.22119, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.67181, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.89380, -1416.21082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.16553, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.17810, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 755.53259, -1411.70398, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.79980, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.82977, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.32428, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.18768, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 759.02643, -1411.70398, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.69598, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.56403, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 759.40674, -1416.21094, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.90833, -1416.21082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.92853, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.98572, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.52393, -1411.70398, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54053, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.59418, -1408.52002, 3000.00000,   0.00000, 90.00000, -0.06000);
	CreateDynamicObject(19439, 766.33588, -1416.21082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.41980, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.46552, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.04120, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.07037, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.55261, -1408.52002, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.52411, -1410.09998, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.57489, -1411.70398, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 765.93268, -1411.70398, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.57928, -1413.00146, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.55988, -1414.60071, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.57013, -1416.21082, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 763.78448, -1425.68628, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 741.68268, -1404.29712, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07233, -1404.09692, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 758.08759, -1396.42078, 3001.74658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 762.47791, -1407.26099, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 760.84003, -1397.54016, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 747.85010, -1406.12854, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 758.08759, -1407.26099, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 753.51312, -1407.26099, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 758.08759, -1405.80164, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19404, 762.47791, -1404.68005, 3001.74194,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 756.06427, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 749.37018, -1408.95032, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 751.98572, -1400.32104, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 770.27271, -1406.00000, 3001.74658,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1999, 760.78870, -1398.33301, 3000.08643,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2197, 758.53119, -1398.99792, 3000.08740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2197, 759.22272, -1398.99792, 3000.08740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19173, 758.17493, -1403.50000, 3002.10864,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2356, 761.44708, -1398.98096, 3000.08667,   0.00000, 0.00000, 10.00000);
	CreateDynamicObject(2010, 758.63422, -1401.11902, 3000.08716,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19175, 766.30939, -1408.87244, 3002.23438,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2011, 769.59741, -1408.27661, 3000.08618,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 763.17212, -1408.27661, 3000.08618,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1808, 769.93683, -1395.28894, 3000.08691,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1721, 770.03882, -1402.42578, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, 770.03882, -1396.85864, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, 770.03882, -1397.75647, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, 770.03882, -1398.68042, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, 770.03882, -1399.61450, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, 770.03882, -1400.56494, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1721, 770.03882, -1401.49963, 3000.08691,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19175, 766.37158, -1394.95874, 3002.23438,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 763.33411, -1395.37158, 3000.08618,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19171, 755.78229, -1394.94690, 3002.17993,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 757.52747, -1406.99988, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 754.20990, -1406.98291, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 757.51678, -1401.60034, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 754.20990, -1401.60034, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 757.51678, -1404.31641, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 754.20990, -1404.31641, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 768.73822, -1408.95142, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 767.16412, -1408.95142, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 763.98230, -1408.95032, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 760.91571, -1408.95032, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 759.59998, -1408.95032, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 743.85101, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 746.83752, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 749.96741, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 755.96661, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 741.50470, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 743.40887, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 741.52679, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 746.17578, -1408.93518, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 743.39136, -1408.93567, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 753.07813, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 765.52771, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2604, 760.36407, -1408.44128, 3000.86621,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(14883, 743.58972, -1396.45740, 3002.09619,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14883, 743.58972, -1404.01001, 3002.09619,   0.00000, 0.00000, -0.06000);
	CreateDynamicObject(19358, 741.70062, -1407.77795, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07172, -1403.94482, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07172, -1404.21545, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1408.46387, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 741.65930, -1403.78540, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.07172, -1403.78064, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1408.63245, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1407.77795, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1407.93835, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1408.11279, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1408.28589, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 742.10858, -1408.81030, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2011, 769.59528, -1411.04163, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 769.59534, -1409.52917, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 740.54260, -1411.12549, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 740.54260, -1409.49890, 3000.08691,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1424.88379, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1422.32288, 3001.74536,   0.00000, 0.00000, -0.06000);
	CreateDynamicObject(19358, 739.98767, -1419.11719, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1415.92944, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 739.98767, -1412.72498, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 759.16541, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 762.34167, -1411.65039, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 768.73199, -1411.63330, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 752.89789, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 759.23950, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 762.42560, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 765.60492, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 768.74921, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 746.56000, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 749.71338, -1426.40625, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 740.65192, -1415.55884, 3000.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19439, 756.98956, -1422.46216, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 756.12946, -1413.59460, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 758.65668, -1413.19617, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 758.65369, -1416.33411, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 758.65369, -1419.54785, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 758.65369, -1422.74805, 3001.74536,   0.00000, 0.00000, -0.06000);
	CreateDynamicObject(19358, 758.65369, -1424.88379, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 749.38800, -1416.35645, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19439, 751.64929, -1421.33093, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(2604, 747.31494, -1425.79285, 3000.87476,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2604, 740.74451, -1413.70654, 3000.87476,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1808, 740.46967, -1425.97314, 3000.08545,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2165, 756.11438, -1417.84045, 3000.08472,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2008, 746.28912, -1422.62524, 3000.08521,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2278, 740.56073, -1414.05908, 3002.21997,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(16780, 766.46887, -1403.49915, 3003.43994,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2162, 740.17200, -1421.51746, 3000.08472,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2191, 748.70270, -1412.49792, 3000.08496,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2613, 743.74030, -1414.15894, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2607, 752.56976, -1417.79126, 3000.28540,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, 746.28912, -1420.50452, 3000.08521,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, 746.28912, -1418.15222, 3000.08521,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, 742.50562, -1418.15222, 3000.08521,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, 742.50562, -1420.50452, 3000.08521,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2008, 742.50562, -1422.62195, 3000.08521,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2165, 745.16235, -1415.12610, 3000.08472,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2356, 744.53180, -1414.46667, 3000.08716,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2356, 746.96136, -1421.00439, 3000.08716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 743.07739, -1420.86426, 3000.08716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 747.00092, -1423.05115, 3000.08716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 743.35657, -1423.20044, 3000.08716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 743.26257, -1418.45947, 3000.08716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2356, 746.90582, -1418.73230, 3000.08716,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 748.96191, -1415.21655, 3000.08447,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 748.96191, -1417.93457, 3000.08447,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 753.35870, -1420.51526, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 752.19720, -1420.51526, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 756.01508, -1420.51526, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 754.65570, -1420.51526, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 756.01508, -1421.77405, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 754.65570, -1421.77405, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 753.35870, -1421.77405, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 752.19720, -1421.77405, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 756.01508, -1422.97595, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 756.01508, -1424.38049, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 754.65570, -1424.38049, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 753.35870, -1424.38049, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 752.19720, -1424.38049, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 752.19720, -1422.97595, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 753.35870, -1422.97595, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1721, 754.65570, -1422.97595, 3000.08472,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2162, 749.57593, -1422.92407, 3000.08472,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2162, 749.57593, -1421.08289, 3000.08472,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2356, 752.62225, -1416.97571, 3000.08716,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2356, 755.50812, -1417.18481, 3000.08716,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(19171, 756.31909, -1411.71326, 3002.23999,   90.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, 751.99463, -1412.03662, 3000.08569,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2010, 754.22369, -1412.01660, 3000.08569,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(14791, 764.03137, -1422.46533, 3001.62012,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2627, 760.15448, -1412.72278, 3000.08154,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2632, 760.58612, -1414.87915, 3000.10010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2632, 760.58612, -1413.00012, 3000.10010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2627, 760.15448, -1413.90393, 3000.08154,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2627, 760.15448, -1415.00476, 3000.08154,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2631, 768.86200, -1413.00012, 3000.08765,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2631, 768.86841, -1414.87915, 3000.08765,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2628, 768.78131, -1417.53833, 3000.08423,   0.00000, 0.00000, -90.00000);
	CreateDynamicObject(2629, 768.90448, -1413.09595, 3000.08374,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2630, 760.62207, -1417.51184, 3000.10449,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2629, 768.90448, -1414.72437, 3000.08374,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2631, 768.86841, -1417.52954, 3000.08765,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2632, 760.58612, -1417.52954, 3000.10010,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1808, 769.54248, -1425.74866, 3000.08545,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(2163, 770.24329, -1421.34924, 3001.78882,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2063, 752.02551, -1408.43335, 3000.90601,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2063, 749.36090, -1408.51343, 3000.90601,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(18637, 753.24554, -1407.93274, 3000.64648,   70.00000, 0.00000, 220.00000);
	CreateDynamicObject(18637, 753.34778, -1407.91345, 3000.64648,   70.00000, 0.00000, 220.00000);
	CreateDynamicObject(18637, 752.72888, -1407.80286, 3000.08691,   0.00000, 0.00000, 150.00000);
	CreateDynamicObject(334, 748.62842, -1403.50098, 3000.06934,   90.00000, 0.00000, 45.00000);
	CreateDynamicObject(335, 751.86969, -1408.54102, 3000.32568,   90.00000, 0.00000, 40.00000);
	CreateDynamicObject(342, 749.85828, -1408.51746, 3000.81982,   90.00000, 0.00000, 120.00000);
	CreateDynamicObject(343, 751.52289, -1408.47046, 3000.81982,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(359, 748.07312, -1404.77954, 3000.78711,   180.00000, -250.00000, 0.00000);
	CreateDynamicObject(365, 748.85181, -1408.68604, 3000.99976,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(368, 752.35162, -1408.63171, 3000.83984,   90.00000, 90.00000, 0.00000);
	CreateDynamicObject(373, 753.16760, -1403.51208, 3000.38647,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(373, 753.14734, -1402.72302, 3000.38647,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(373, 753.22607, -1405.08411, 3000.38647,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(373, 753.20544, -1404.31165, 3000.38647,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(334, 748.90991, -1403.90906, 3000.12939,   270.00000, 0.00000, 90.00000);
	CreateDynamicObject(334, 748.34009, -1404.03943, 3000.06934,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(334, 748.55920, -1403.69250, 3000.06934,   180.00000, 0.00000, 90.00000);
	CreateDynamicObject(335, 751.54999, -1408.71777, 3000.32568,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(342, 749.60071, -1408.54895, 3000.81982,   90.00000, 0.00000, 270.00000);
	CreateDynamicObject(342, 750.02649, -1408.54236, 3000.81982,   90.00000, 0.00000, 180.00000);
	CreateDynamicObject(342, 750.16711, -1408.53101, 3000.81982,   90.00000, 0.00000, 90.00000);
	CreateDynamicObject(359, 748.02551, -1404.07947, 3000.78711,   180.02000, -260.00000, 0.00000);
	CreateDynamicObject(343, 751.91132, -1408.53064, 3000.81982,   90.00000, 0.00000, 150.00000);
	CreateDynamicObject(343, 751.28229, -1408.47522, 3000.81982,   90.00000, 0.00000, 250.00000);
	CreateDynamicObject(365, 748.69232, -1408.58496, 3000.97974,   0.00000, -20.00000, 0.00000);
	CreateDynamicObject(365, 748.77332, -1408.44531, 3000.99976,   0.00000, -5.00000, 0.00000);
	CreateDynamicObject(368, 752.61047, -1408.61938, 3000.77979,   180.00000, 90.00000, 0.00000);
	CreateDynamicObject(2846, 750.41333, -1404.99963, 3000.08740,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 752.00677, -1408.95032, 3001.74536,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 749.49200, -1400.32104, 3001.74658,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2163, 747.93597, -1405.98914, 3001.91772,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 768.47693, -1418.56653, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1416.91150, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1413.69434, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1415.30774, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1407.21143, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1408.82227, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1410.44531, 3003.41992,   0.00000, 90.00000, -0.06000);
	CreateDynamicObject(19439, 768.47693, -1412.05798, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.43689, -1395.47107, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1395.99573, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1397.53662, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1420.15442, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1421.78442, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1424.68884, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1425.70129, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1405.57837, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1399.13025, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1400.72144, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1402.32776, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.52820, -1403.45093, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1425.71057, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1424.52405, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1421.89539, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1420.26587, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1418.66650, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1417.03772, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1415.44934, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1413.81421, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1412.18848, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1410.57190, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1408.94727, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1407.34082, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1405.71350, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1404.08569, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1402.47144, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1400.87024, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1399.27930, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1397.62122, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1396.13733, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.95892, -1395.48193, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1425.68408, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.51569, -1425.63367, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1424.31873, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.54358, -1424.20654, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.57184, -1422.62524, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1422.73743, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.60034, -1421.00964, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1421.12341, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1419.53235, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.62939, -1419.41724, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1417.91772, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.65814, -1417.80103, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1416.32581, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.68719, -1416.20911, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1414.72534, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.71704, -1414.60681, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1413.11206, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.74701, -1412.99243, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1411.50720, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.77710, -1411.38574, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1409.90442, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.80762, -1409.78186, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1408.31177, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.83838, -1408.18872, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1406.69812, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.87006, -1406.57263, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1405.09106, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.90082, -1404.96509, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1403.50427, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.93304, -1403.37671, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1401.90881, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.96527, -1401.77991, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1400.31946, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 744.99750, -1400.19006, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1398.69775, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.03052, -1398.56726, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.72418, -1397.23547, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.06299, -1397.10315, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 741.66821, -1395.64404, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 745.04071, -1395.51062, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1423.90271, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1425.66943, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1424.10583, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1424.45850, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1422.51599, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1421.87732, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1425.67224, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1420.89612, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1420.25000, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1419.30481, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1418.64124, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1417.68433, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1417.01233, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1415.40857, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1414.48315, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1413.79663, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1416.08972, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1412.86401, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1411.25623, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1410.54846, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1412.16809, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1409.64758, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1408.93298, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1407.32178, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1408.04883, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1406.43250, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1405.69275, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1404.07288, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1404.81934, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1403.22644, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1401.62512, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1400.03040, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1398.40259, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.58942, -1398.31641, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1399.26428, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1400.86206, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1402.46851, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1396.93420, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1396.13782, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 747.84509, -1395.53674, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1395.47546, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1424.12061, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1425.66968, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1425.66785, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1425.68115, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65936, -1424.04248, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1424.50830, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1422.40649, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1422.42737, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1422.31787, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1423.99121, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1420.78821, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1420.80750, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1420.69763, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1419.18726, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1419.21423, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1419.09668, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1417.56494, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1417.59375, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1417.46912, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1415.96960, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1415.99194, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1415.87378, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1414.36438, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1414.38550, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1414.26672, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1412.74414, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1412.76624, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.15125, -1412.63867, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1411.13135, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1411.15845, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1411.03357, 3003.41992,   0.00000, 90.00000, -0.06000);
	CreateDynamicObject(19439, 751.23798, -1409.52478, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1409.54272, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1409.41992, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1407.92310, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1407.94385, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1407.81812, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1406.30115, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1406.32568, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1406.19434, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1404.69067, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1404.70728, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1404.58374, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1403.09619, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1401.49353, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1399.89758, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1399.91638, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1401.51111, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1403.11438, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1402.97498, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1401.37244, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1399.78345, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1398.26868, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1396.79919, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 751.23798, -1395.52075, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1398.28857, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1395.51355, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.65869, -1396.81299, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1398.15454, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1396.67798, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.13123, -1395.51758, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1423.45447, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.97870, -1423.51624, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1422.99890, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.54718, -1397.61157, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.09894, -1398.61768, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.68774, -1398.76855, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 764.71442, -1398.21948, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 762.04547, -1406.15454, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.16467, -1406.53345, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.62518, -1406.72656, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 754.68286, -1404.96704, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 761.55664, -1412.50818, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 758.34583, -1413.15344, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.49200, -1412.59802, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 768.47693, -1403.95837, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(3089, 770.21271, -1405.23718, 3001.37988,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1495, 762.47791, -1394.94543, 3000.02368,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1502, 753.51361, -1395.63306, 3000.00000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1495, 745.40192, -1408.93518, 3000.02002,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1495, 747.84961, -1398.27429, 3000.02002,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(19439, 749.13391, -1399.08679, 3003.41992,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19358, 747.85010, -1402.17334, 3001.74536,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1502, 750.25189, -1400.32104, 3000.00000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1495, 751.56061, -1411.63330, 3000.02002,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1502, 766.27100, -1411.63330, 3000.00000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19439, 768.38983, -1409.68396, 3003.41992,   0.00000, 90.00000, -0.06000);
	CreateDynamicObject(1491, 749.38800, -1417.10339, 3000.02002,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19439, 756.06677, -1415.79529, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 752.59857, -1415.60620, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 750.30981, -1415.10095, 3000.00000,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19439, 749.81744, -1399.71057, 3000.00000,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19439, 749.87695, -1407.33813, 3000.00000,   0.00000, 90.00000, 90.00000);
	return 1;
}

LoadInfirmary()
{
	CreateDynamicObject(19379, 1167.73950, -1297.10168, 13.33970,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19379, 1158.10486, -1297.08179, 13.33970,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19404, 1161.18738, -1292.06238, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19450, 1167.59949, -1292.07043, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1158.01245, -1292.06238, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1154.87854, -1292.06238, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, 1174.43445, -1297.08179, 13.33920,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19450, 1174.24573, -1292.06238, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, 1158.10486, -1307.58105, 13.33970,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19450, 1174.24573, -1297.17627, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19404, 1179.03198, -1293.66663, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 1179.03198, -1296.84521, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19404, 1179.03198, -1300.05176, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19431, 1179.03198, -1302.45190, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1174.16431, -1302.05933, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19450, 1167.31860, -1302.05933, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19450, 1153.54407, -1296.82104, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1153.54407, -1306.43359, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1158.32813, -1312.66370, 15.08640,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 1169.47827, -1300.40271, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 1169.47827, -1297.21277, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 1169.47827, -1293.72864, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 1169.47803, -1296.65320, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1153.52417, -1316.03308, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1162.58655, -1306.92920, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1162.58655, -1316.49097, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1154.37671, -1302.40210, 13.68520,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1304.07031, 12.02340,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1303.54834, 12.37140,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1303.02625, 12.71940,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1302.50415, 13.06740,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1301.98218, 13.41540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1301.46021, 13.76340,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1300.93823, 14.11140,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1300.41626, 14.45940,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1299.89429, 14.80740,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1154.38049, -1299.37231, 15.15540,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19450, 1153.54407, -1296.82104, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1153.54407, -1306.43359, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1153.52417, -1316.03308, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1158.28809, -1320.82874, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19450, 1162.58655, -1306.92920, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1162.58655, -1316.49097, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19450, 1167.31860, -1302.06128, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19450, 1174.16431, -1302.05933, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19404, 1179.03198, -1300.05176, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19431, 1179.03198, -1302.45190, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19404, 1179.03198, -1293.66663, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19404, 1161.18738, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1154.87854, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19379, 1167.73950, -1297.10168, 16.81840,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19379, 1174.43445, -1297.08179, 16.82600,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1301.88013, 14.03320,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1301.35815, 14.38120,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1300.83618, 14.72920,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1300.31421, 15.07720,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1299.79224, 15.42520,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1299.27014, 15.77320,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1298.74805, 16.12120,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1298.22595, 16.46920,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1297.70398, 16.81720,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37988, -1296.04028, 15.15520,   180.00000, 0.00000, 90.00000);
	CreateDynamicObject(19370, 1155.91638, -1297.57983, 15.15520,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.90845, -1297.85181, 15.15520,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.92444, -1298.37378, 14.80620,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.91638, -1298.89380, 14.45420,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.90845, -1299.41174, 14.10820,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.93237, -1299.93567, 13.76020,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.92444, -1300.45959, 13.41620,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.92981, -1300.97986, 13.06420,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.93774, -1301.49988, 12.71520,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.92969, -1302.02393, 12.37120,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19370, 1155.90820, -1302.54871, 12.02320,   180.00000, 0.00000, 0.00000);
	CreateDynamicObject(19379, 1158.10486, -1309.17114, 16.82640,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19379, 1160.79565, -1297.10168, 16.82640,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1294.21375, 16.81720,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19370, 1154.37671, -1293.73767, 16.80920,   180.00000, 90.00000, 90.00000);
	CreateDynamicObject(19379, 1160.79565, -1307.59387, 16.81840,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19404, 1179.03198, -1296.86084, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19377, 1167.73950, -1296.94165, 16.81040,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1173.81311, -1296.94104, 16.80240,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1161.22424, -1296.94165, 16.80840,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1161.22424, -1306.57410, 16.81040,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1157.27283, -1308.72925, 16.80740,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19362, 1154.37671, -1293.73767, 16.80520,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19362, 1154.37671, -1294.23169, 16.79720,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(1533, 1162.45898, -1309.19360, 13.35200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1533, 1162.45898, -1307.70959, 13.35200,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(3657, 1163.96899, -1297.08337, 13.90240,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3657, 1162.37598, -1297.08337, 13.90240,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3657, 1165.44397, -1297.08337, 13.90240,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3657, 1160.95996, -1297.08337, 13.90240,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2596, 1169.09680, -1296.96350, 15.96280,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1523, 1169.49731, -1301.16138, 13.42160,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 1173.81311, -1297.25696, 16.80040,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1167.73950, -1297.20569, 16.80240,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(1523, 1169.47595, -1292.93298, 13.42160,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2185, 1156.59839, -1312.54639, 13.42390,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2185, 1156.58716, -1310.69226, 13.42190,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2185, 1156.91064, -1308.38184, 13.42190,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(11711, 1162.54236, -1309.19238, 16.10790,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2007, 1154.14001, -1312.03357, 13.43400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2007, 1154.14746, -1311.02148, 13.43400,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2011, 1154.03760, -1310.10669, 13.42575,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1715, 1155.06555, -1311.50281, 13.42620,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1715, 1155.22119, -1309.77979, 13.42620,   0.00000, 0.00000, 110.00000);
	CreateDynamicObject(2614, 1153.67200, -1311.38416, 15.72270,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1997, 1161.32507, -1311.67407, 13.42410,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1997, 1158.91479, -1311.66785, 13.42410,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(19325, 1160.27991, -1292.05139, 15.14180,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19325, 1160.27991, -1292.05139, 18.10280,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19325, 1179.04272, -1294.42566, 18.10280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19379, 1158.10486, -1319.66418, 16.82640,   0.00000, 90.00000, 90.00000);
	CreateDynamicObject(19450, 1157.88452, -1315.59595, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 1156.35999, -1310.73743, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 1159.50037, -1310.73743, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19431, 1154.25659, -1310.73743, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19431, 1161.79102, -1310.73743, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19404, 1158.02307, -1292.06445, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19377, 1157.27283, -1308.72925, 20.06240,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1157.58276, -1318.36121, 20.06240,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1157.27283, -1299.08521, 20.06240,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1157.27283, -1296.85925, 20.07040,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1167.76685, -1296.85925, 20.06240,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1173.80676, -1296.85925, 20.06040,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1167.76685, -1297.34631, 20.06640,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(19377, 1173.80676, -1297.34631, 20.05640,   0.00000, 90.00000, 0.00000);
	CreateDynamicObject(970, 1156.01160, -1301.82471, 17.43200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(970, 1153.92676, -1303.93945, 17.43200,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1715, 1154.89807, -1304.90344, 16.91280,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1715, 1154.90930, -1306.65833, 16.91280,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2773, 1160.58667, -1303.32031, 13.92790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2773, 1160.58777, -1305.23352, 13.92590,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(932, 1161.79285, -1306.05249, 13.42620,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(932, 1161.81006, -1305.17773, 13.42620,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(932, 1161.80383, -1304.28735, 13.42620,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(932, 1161.77185, -1303.34998, 13.42620,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(932, 1161.72717, -1302.49194, 13.42620,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1808, 1163.63477, -1301.79077, 13.42560,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19866, 1169.42151, -1297.05981, 13.39050,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19866, 1169.42224, -1297.06116, 14.13450,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19866, 1169.43433, -1297.06323, 14.87250,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1164.36804, -1301.69482, 13.42666,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1886, 1154.35596, -1312.09827, 16.71360,   20.00000, 0.00000, 120.00000);
	CreateDynamicObject(1886, 1154.46606, -1292.94788, 16.71360,   20.00000, 0.00000, 45.00000);
	CreateDynamicObject(1886, 1168.30664, -1292.80164, 16.71360,   20.00000, 0.00000, 310.00000);
	CreateDynamicObject(2606, 1153.67847, -1305.69946, 19.80290,   15.00000, 0.00000, 90.00000);
	CreateDynamicObject(2167, 1153.65295, -1307.35278, 16.84200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2167, 1153.65295, -1306.41675, 16.84200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2167, 1153.65295, -1305.48071, 16.84200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2167, 1153.65295, -1304.54468, 16.84200,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(1997, 1156.73450, -1300.89294, 16.91270,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1997, 1161.87915, -1299.53394, 16.91270,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1808, 1158.21191, -1310.37158, 16.91260,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2011, 1157.57178, -1310.26160, 16.91279,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1502, 1155.57275, -1310.75244, 16.88210,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1502, 1160.25183, -1310.72241, 16.89510,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19388, 1177.35059, -1298.47961, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1174.25806, -1300.09692, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19431, 1174.99719, -1298.48584, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1174.26111, -1300.61951, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 1177.51880, -1295.28638, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19431, 1175.14990, -1295.28638, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1174.44897, -1293.68384, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 1172.61475, -1298.47961, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19388, 1172.79944, -1295.28638, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19431, 1170.20984, -1298.47961, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19431, 1170.41113, -1295.28638, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1169.66382, -1293.68384, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 1168.00635, -1295.28638, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1169.44775, -1300.12085, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 1169.49109, -1300.67285, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19388, 1167.83032, -1298.47961, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1164.61243, -1298.47961, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1162.58655, -1300.50867, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 1164.10242, -1298.49463, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1162.60144, -1300.01367, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19358, 1164.79968, -1295.28638, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1163.27075, -1293.76721, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19325, 1179.06250, -1301.93445, 18.10280,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19404, 1167.86194, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1164.67529, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1164.06335, -1292.06445, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19404, 1171.04895, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1174.26245, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1177.46216, -1292.06238, 18.51040,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2008, 1156.16443, -1304.38818, 16.91270,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2008, 1156.16235, -1306.34045, 16.91070,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(19303, 1172.48914, -1298.44910, 18.00520,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1997, 1161.82910, -1301.86926, 16.91270,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1997, 1161.83765, -1304.19714, 16.91270,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(19450, 1157.88452, -1325.24512, 18.51040,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3396, 1155.48938, -1320.13049, 16.91110,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2994, 1154.54980, -1311.36267, 17.40820,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2171, 1157.31482, -1311.81641, 16.91400,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2184, 1161.31738, -1317.06726, 16.91190,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2164, 1159.31165, -1320.72754, 16.91180,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2164, 1161.04358, -1320.72754, 16.91180,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1808, 1162.11011, -1320.19910, 16.91200,   0.00000, 0.00000, 225.00000);
	CreateDynamicObject(2190, 1159.28564, -1316.86414, 17.68570,   0.00000, 0.00000, 20.00000);
	CreateDynamicObject(1714, 1160.26135, -1319.17004, 16.91390,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1964, 1160.18469, -1317.33740, 17.79240,   0.00000, 0.00000, 160.00000);
	CreateDynamicObject(2011, 1158.40869, -1311.37817, 16.91273,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2606, 1160.04236, -1320.77136, 19.58120,   20.00000, 0.00000, 180.00000);
	CreateDynamicObject(2610, 1162.26892, -1311.15491, 17.70750,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2610, 1162.26892, -1311.60669, 17.70750,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2610, 1162.26892, -1312.08374, 17.70750,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2610, 1162.26892, -1312.56067, 17.70750,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2596, 1160.90710, -1311.14624, 19.53400,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1361, 1162.53345, -1293.03723, 17.63980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1361, 1154.32800, -1292.81885, 17.63980,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1162.04260, -1310.08704, 16.91279,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1154.01477, -1310.13098, 16.91279,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2171, 1174.01733, -1301.35840, 13.49800,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2186, 1162.09009, -1313.31445, 16.91300,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2146, 1176.78821, -1298.00586, 13.91710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(19358, 1174.55371, -1297.12122, 15.08640,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2994, 1178.48816, -1300.29358, 13.92790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2146, 1171.20215, -1297.91064, 13.91710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2994, 1174.00037, -1297.94653, 13.92790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2171, 1175.42871, -1301.33154, 13.49800,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2146, 1171.15833, -1296.42383, 13.91710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2994, 1173.99341, -1296.21643, 13.92790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2171, 1174.83630, -1292.79529, 13.49800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2171, 1173.43848, -1292.82788, 13.49800,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2994, 1178.27856, -1296.21716, 13.92790,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2146, 1176.13293, -1296.52417, 13.91710,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2603, 1163.89429, -1294.03625, 17.29070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2596, 1169.26270, -1292.73926, 19.46280,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2011, 1169.04053, -1294.74829, 16.90460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1173.86206, -1294.78735, 16.90460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2596, 1174.04065, -1292.93958, 19.46280,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2603, 1170.45374, -1293.69812, 17.29070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2596, 1178.64856, -1292.60828, 19.46280,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2011, 1178.64917, -1294.88831, 16.90460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2603, 1175.14917, -1293.61499, 17.29070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2603, 1174.98584, -1300.76196, 17.29070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1178.43213, -1298.99780, 16.90460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2596, 1178.65076, -1298.90186, 19.46280,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2603, 1170.16028, -1300.58948, 17.29070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1173.72058, -1301.58264, 16.90460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19305, 1173.70740, -1298.54749, 18.36970,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(19305, 1171.41870, -1298.40332, 18.36970,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2603, 1163.31384, -1300.75098, 17.29070,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2011, 1168.81921, -1301.44739, 16.90460,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2596, 1169.03857, -1299.17480, 19.46280,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(1523, 1167.04102, -1298.56299, 16.90550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1167.21204, -1295.32910, 16.90550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1172.01550, -1295.32495, 16.90550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1176.71826, -1295.32117, 16.90550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1523, 1176.55249, -1298.50220, 16.90550,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1997, 1155.82068, -1316.13416, 16.91270,   0.00000, 0.00000, 180.00000);
	return 1;
}

LoadEatplace()
{
	CreateDynamicObject(14639, 2640.50000, 1838.40002, -1.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(4058, 2654.00000, 1824.20020, -33.00000,   0.00000, 0.00000, 358.99500);
	CreateDynamicObject(2120, 2655.19995, 1828.09998, -1.80000,   0.00000, 0.00000, 274.00000);
	CreateDynamicObject(2120, 2655.10010, 1830.09998, -1.80000,   0.00000, 0.00000, 96.24900);
	CreateDynamicObject(2120, 2654.50000, 1831.90002, -1.80000,   0.00000, 0.00000, 299.74600);
	CreateDynamicObject(2120, 2653.39990, 1833.50000, -1.80000,   0.00000, 0.00000, 127.49500);
	CreateDynamicObject(2120, 2651.89990, 1834.80005, -1.80000,   0.00000, 0.00000, 321.49100);
	CreateDynamicObject(2120, 2650.39990, 1835.90002, -1.80000,   0.00000, 0.00000, 144.23700);
	CreateDynamicObject(2120, 2648.30005, 1836.90002, -1.80000,   0.00000, 0.00000, 349.23401);
	CreateDynamicObject(2120, 2646.19995, 1837.19995, -1.80000,   0.00000, 0.00000, 178.23399);
	CreateDynamicObject(2120, 2647.00000, 1829.50000, -1.80000,   0.00000, 0.00000, 92.23100);
	CreateDynamicObject(2120, 2647.89990, 1828.59998, -1.80000,   0.00000, 0.00000, 2.23000);
	CreateDynamicObject(2120, 2647.00000, 1827.69995, -1.80000,   0.00000, 0.00000, 270.22501);
	CreateDynamicObject(2120, 2646.10010, 1828.59998, -1.80000,   0.00000, 0.00000, 181.47000);
	CreateDynamicObject(2120, 2646.89990, 1831.59998, -1.80000,   0.00000, 0.00000, 270.23001);
	CreateDynamicObject(2120, 2647.80005, 1832.50000, -1.80000,   0.00000, 0.00000, 0.97500);
	CreateDynamicObject(2120, 2646.89990, 1833.40002, -1.80000,   0.00000, 0.00000, 90.97200);
	CreateDynamicObject(2120, 2646.00000, 1832.59998, -1.80000,   0.00000, 0.00000, 180.22501);
	CreateDynamicObject(2120, 2650.50000, 1829.69995, -1.80000,   0.00000, 0.00000, 272.22501);
	CreateDynamicObject(2120, 2651.39990, 1830.59998, -1.80000,   0.00000, 0.00000, 2.21900);
	CreateDynamicObject(2120, 2650.39990, 1831.50000, -1.80000,   0.00000, 0.00000, 92.21400);
	CreateDynamicObject(2120, 2649.60010, 1830.59998, -1.80000,   0.00000, 0.00000, 182.21400);
	CreateDynamicObject(1433, 2647.00000, 1828.59998, -2.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, 2646.89990, 1832.50000, -2.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, 2650.39990, 1830.59998, -2.20000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1433, 2655.10010, 1829.09998, -2.20000,   0.00000, 0.00000, 5.75000);
	CreateDynamicObject(1433, 2653.89990, 1832.69995, -2.20000,   0.00000, 0.00000, 33.74600);
	CreateDynamicObject(1433, 2651.19995, 1835.40002, -2.20000,   0.00000, 0.00000, 53.74500);
	CreateDynamicObject(1433, 2647.30005, 1837.09998, -2.20000,   0.00000, 0.00000, 85.74000);
	CreateDynamicObject(14399, 2654.10059, 1825.50000, -2.60000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(3534, 2644.50000, 1826.40039, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(640, 2634.50000, 1830.69995, -1.10000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(640, 2634.50000, 1832.70020, -1.10000,   0.00000, 0.00000, 179.99500);
	CreateDynamicObject(640, 2641.30005, 1838.30005, -1.10000,   0.00000, 0.00000, 89.99500);
	CreateDynamicObject(640, 2640.60010, 1838.30005, -1.10000,   0.00000, 0.00000, 89.98900);
	CreateDynamicObject(948, 2633.19995, 1823.59998, -2.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, 2633.19995, 1819.19995, -2.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, 2638.30005, 1815.69995, -2.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(948, 2643.80005, 1815.69995, -2.50000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1337, 2557.69995, 1768.00000, 15.60000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2644.39990, 1828.59998, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2644.30005, 1830.90002, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2644.19995, 1833.19995, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2644.10010, 1835.59998, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2646.69995, 1826.30005, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2648.89990, 1826.19995, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2651.19995, 1826.30005, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(3534, 2653.60010, 1826.40002, 2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 2633.19995, 1823.09998, -2.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 2633.19995, 1819.69995, -2.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 2638.69995, 1815.69995, -2.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1215, 2643.30005, 1815.69995, -2.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2639, 2636.10010, 1828.30005, -2.00000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2637, 2636.10010, 1829.50000, -2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2638, 2636.10010, 1831.19995, -1.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2637, 2636.10010, 1832.90002, -2.10000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2639, 2636.10059, 1834.09961, -2.00000,   0.00000, 0.00000, 179.99500);
	CreateDynamicObject(2639, 2643.60010, 1836.80005, -2.00000,   0.00000, 0.00000, 90.00000);
	CreateDynamicObject(2637, 2642.30005, 1836.80005, -2.10000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2638, 2640.69995, 1836.80005, -1.90000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2639, 2638.00000, 1836.80005, -2.00000,   0.00000, 0.00000, 269.99500);
	CreateDynamicObject(2637, 2639.10010, 1836.80005, -2.10000,   0.00000, 0.00000, 270.00000);
	CreateDynamicObject(2755, 2642.39990, 1826.40002, -0.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 2644.39990, 1826.40002, -1.80000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 2644.39990, 1828.90002, -1.80000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 2644.39990, 1837.00000, -1.80000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(2755, 2636.50000, 1826.50000, -0.90000,   0.00000, 0.00000, 0.00000);
	CreateDynamicObject(1360, 2633.69995, 1826.50000, -1.80000,   0.00000, 0.00000, 272.00000);
	CreateDynamicObject(1360, 2644.39990, 1823.80005, -1.80000,   0.00000, 0.00000, 179.75000);
	CreateDynamicObject(1360, 2644.39990, 1817.09998, -1.80000,   0.00000, 0.00000, 179.74699);
	CreateDynamicObject(2395, 2653.90039, 1815.90039, -1.10000,   0.00000, 0.00000, 179.24200);
	CreateDynamicObject(2395, 2654.50000, 1815.90002, -1.10000,   0.00000, 0.00000, 179.24699);
	CreateDynamicObject(2267, 2647.89990, 1816.00000, 0.90000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2289, 2649.39990, 1815.90002, -0.30000,   0.00000, 0.00000, 179.25000);
	CreateDynamicObject(2284, 2650.69995, 1816.40002, 0.50000,   0.00000, 0.00000, 180.50000);
	CreateDynamicObject(2282, 2652.30005, 1816.40002, -0.60000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2281, 2654.19995, 1816.40002, 0.30000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(2265, 2652.50000, 1816.40002, 0.50000,   0.00000, 0.00000, 180.00000);
	CreateDynamicObject(1360, 2635.50000, 1837.30005, -1.80000,   0.00000, 0.00000, 314.00000);
	CreateDynamicObject(1360, 2647.10010, 1838.40002, -1.80000,   0.00000, 0.00000, 264.00000);
	CreateDynamicObject(1360, 2649.10010, 1838.00000, -1.80000,   0.00000, 0.00000, 251.74600);
	CreateDynamicObject(1360, 2651.30005, 1837.00000, -1.80000,   0.00000, 0.00000, 241.74100);
	CreateDynamicObject(1360, 2653.00000, 1835.80005, -1.80000,   0.00000, 0.00000, 230.23801);
	CreateDynamicObject(1360, 2654.39990, 1834.40002, -1.80000,   0.00000, 0.00000, 220.98500);
	CreateDynamicObject(1360, 2655.60059, 1832.59961, -1.80000,   0.00000, 0.00000, 208.98199);
	CreateDynamicObject(1360, 2656.30005, 1830.69995, -1.80000,   0.00000, 0.00000, 195.98199);
	CreateDynamicObject(1360, 2656.60010, 1829.30005, -1.80000,   0.00000, 0.00000, 189.98000);
	CreateDynamicObject(1360, 2656.69995, 1828.40002, -1.80000,   0.00000, 0.00000, 185.97600);
	CreateDynamicObject(2395, 2650.19995, 1815.90002, -1.10000,   0.00000, 0.00000, 179.24200);
	CreateDynamicObject(4848, 2649.39990, 1812.40002, -3.50000,   89.00000, 0.00000, 0.00000);
	CreateDynamicObject(4848, 2660.50000, 1831.30005, -3.50000,   88.99500, 0.00000, 90.00000);
	CreateDynamicObject(4848, 2659.39990, 1832.50000, -3.50000,   88.99500, 0.00000, 116.00000);
	CreateDynamicObject(4848, 2657.60010, 1836.69995, -3.50000,   88.99500, 0.00000, 147.99899);
	CreateDynamicObject(4848, 2647.30005, 1841.40002, -3.50000,   88.99500, 0.00000, 175.99699);
	CreateDynamicObject(4848, 2636.69995, 1844.30005, -3.50000,   88.99500, 0.00000, 225.99500);
	CreateDynamicObject(4848, 2629.39990, 1834.69995, -3.50000,   88.99500, 0.00000, 269.99399);
	CreateDynamicObject(4848, 2630.50000, 1825.19995, -3.50000,   88.99500, 0.00000, 269.98901);
	return 1;
}

CreateGlobalCredits()
{
	BoxCredits = TextDrawCreate(497.000000, 80.000000, "_");
	TextDrawBackgroundColor(BoxCredits, 255);
	TextDrawFont(BoxCredits, 1);
	TextDrawLetterSize(BoxCredits, 0.500000, 2.100000);
	TextDrawColor(BoxCredits, -1);
	TextDrawSetOutline(BoxCredits, 0);
	TextDrawSetProportional(BoxCredits, 1);
	TextDrawSetShadow(BoxCredits, 1);
	TextDrawUseBox(BoxCredits, 1);
	TextDrawBoxColor(BoxCredits, 255);
	TextDrawTextSize(BoxCredits, 612.000000, 1.000000);
	TextDrawSetSelectable(BoxCredits, 0);
	return 1;
}

CreateLocalCredits(playerid)
{
	Credits = CreatePlayerTextDraw(playerid, 555.000000, 80.000000, "~g~PC$LOADING");
	PlayerTextDrawAlignment(playerid, Credits, 2);
	PlayerTextDrawBackgroundColor(playerid, Credits, 255);
	PlayerTextDrawFont(playerid, Credits, 3);
	PlayerTextDrawLetterSize(playerid, Credits, 0.480000, 1.900000);
	PlayerTextDrawColor(playerid, Credits, -1);
	PlayerTextDrawSetOutline(playerid, Credits, 1);
	PlayerTextDrawSetProportional(playerid, Credits, 1);
	PlayerTextDrawSetSelectable(playerid, Credits, 0);
	return 1;
}

ShowCredits(playerid)
{
	PlayerTextDrawShow(playerid, Credits);
	TextDrawShowForPlayer(playerid, BoxCredits);
	return 1;
}

HideCredits(playerid)
{
	PlayerTextDrawHide(playerid, Credits);
	TextDrawHideForPlayer(playerid, BoxCredits);
	return 1;
}

DestroyGlobalCredits()
{
	TextDrawDestroy(BoxCredits);
	return 1;
}

DestroyLocalCredits(playerid)
{
	PlayerTextDrawDestroy(playerid, Credits);
	return 1;
}

CreateSSPXT()
{
	SSPXT[0] = TextDrawCreate(185.000000, 181.000000, "Box");
	TextDrawBackgroundColor(SSPXT[0], 0);
	TextDrawFont(SSPXT[0], 1);
	TextDrawLetterSize(SSPXT[0], 1.590000, 7.700005);
	TextDrawColor(SSPXT[0], 0);
	TextDrawSetOutline(SSPXT[0], 0);
	TextDrawSetProportional(SSPXT[0], 1);
	TextDrawSetShadow(SSPXT[0], 1);
	TextDrawUseBox(SSPXT[0], 1);
	TextDrawBoxColor(SSPXT[0], 100);
	TextDrawTextSize(SSPXT[0], 448.000000, 30.000000);

	SSPXT[1] = TextDrawCreate(315.000000, 180.000000, "Project Prison");
	TextDrawAlignment(SSPXT[1], 2);
	TextDrawBackgroundColor(SSPXT[1], 255);
	TextDrawFont(SSPXT[1], 3);
	TextDrawLetterSize(SSPXT[1], 0.70, 4);
	TextDrawColor(SSPXT[1], 0xFFFFFF40);
	TextDrawSetOutline(SSPXT[1], 1);
	TextDrawSetProportional(SSPXT[1], 1);

	SSPXT[2] = TextDrawCreate(315.000000, 215.000000, "Role Play");
	TextDrawAlignment(SSPXT[2], 2);
	TextDrawBackgroundColor(SSPXT[2], 255);
	TextDrawFont(SSPXT[2], 2);
	TextDrawLetterSize(SSPXT[2], 0.45, 3);
	TextDrawColor(SSPXT[2], 0xFFFFFF40);
	TextDrawSetOutline(SSPXT[2], 1);
	TextDrawSetProportional(SSPXT[2], 1);

	SSPXT[3] = TextDrawCreate(405.000000, 239.000000, "Loading objects...\nPlease wait...");
	TextDrawAlignment(SSPXT[3], 2);
	TextDrawBackgroundColor(SSPXT[3], 255);
	TextDrawFont(SSPXT[3], 2);
	TextDrawLetterSize(SSPXT[3], 0.189999, 1.200000);
	TextDrawColor(SSPXT[3], 0xFFFF00FF);
	TextDrawSetOutline(SSPXT[3], 1);
	TextDrawSetProportional(SSPXT[3], 1);
	return 1;
}

SetPlayerPosEx(playerid, Float:x, Float:y, Float:z)
{
	TogglePlayerControllable(playerid, false);
	TextDrawShowForPlayer(playerid, SSPXT[0]);
	TextDrawShowForPlayer(playerid, SSPXT[1]);
	TextDrawShowForPlayer(playerid, SSPXT[2]);
	TextDrawShowForPlayer(playerid, SSPXT[3]);
	SetPlayerPos(playerid, Float:x, Float:y, Float:z);
	switch(GetPlayerPing(playerid))
	{
		case 0 .. 150:
		{
			SetTimerEx("SSPX", 2000, false, "i", playerid);
		}
		case 151 .. 350:
		{
			SetTimerEx("SSPX", 4000, false, "i", playerid);
		}
		case 351 .. 550:
		{
			SetTimerEx("SSPX", 6000, false, "i", playerid);
		}
		case 551 .. 750:
		{
			SetTimerEx("SSPX", 10000, false, "i", playerid);
		}
		case 751 .. 1000:
		{
			SetTimerEx("SSPX", 12000, false, "i", playerid);
		}
		case 1001 .. 1500:
		{
			SetTimerEx("SSPX", 20000, false, "i", playerid);
		}
	}
}

forward SSPX(playerid);
public  SSPX(playerid)
{
	TogglePlayerControllable(playerid, true);
	TextDrawHideForPlayer(playerid, SSPXT[0]);
	TextDrawHideForPlayer(playerid, SSPXT[1]);
	TextDrawHideForPlayer(playerid, SSPXT[2]);
	TextDrawHideForPlayer(playerid, SSPXT[3]);
}

LoadInfoTD()
{
	Info = TextDrawCreate(0.000000, 426.000000, "~>~ Project Prison Role Play ~<~~>~ Version: Alpha 0.6 ~<~~>~ Website: www.PP-RP.com ~<~");
	TextDrawBackgroundColor(Info, 255);
	TextDrawFont(Info, 2);
	TextDrawLetterSize(Info, 0.339999, 1.999999/*2.000000*/);
	TextDrawColor(Info, -1);
	TextDrawSetOutline(Info, 1);
	TextDrawSetProportional(Info, 1);
	TextDrawSetSelectable(Info, 0);
}

LoadConnectionTD()
{
	Slogan = TextDrawCreate(285.000000, 254.000000, "The home of real prison rp");
	TextDrawBackgroundColor(Slogan, 255);
	TextDrawFont(Slogan, 1);
	TextDrawLetterSize(Slogan, 0.200000, 1.000000);
	TextDrawColor(Slogan, -1);
	TextDrawSetOutline(Slogan, 1);
	TextDrawSetProportional(Slogan, 1);
	TextDrawSetSelectable(Slogan, 0);

	PPTD = TextDrawCreate(242.000000, 207.000000, "~b~PROJECT PRISON");
	TextDrawBackgroundColor(PPTD, 255);
	TextDrawFont(PPTD, 3);
	TextDrawLetterSize(PPTD, 0.679999, 3.000000);
	TextDrawColor(PPTD, -1);
	TextDrawSetOutline(PPTD, 1);
	TextDrawSetProportional(PPTD, 1);
	TextDrawSetSelectable(PPTD, 0);

	RPTD = TextDrawCreate(335.000000, 220.000000, "~y~Roleplay");
	TextDrawBackgroundColor(RPTD, 255);
	TextDrawFont(RPTD, 2);
	TextDrawLetterSize(RPTD, 0.500000, 3.000000);
	TextDrawColor(RPTD, -1);
	TextDrawSetOutline(RPTD, 1);
	TextDrawSetProportional(RPTD, 1);
	TextDrawSetSelectable(RPTD, 0);

	WEB = TextDrawCreate(303.000000, 172.000000, "www.pp-rp.com");
	TextDrawBackgroundColor(WEB, 255);
	TextDrawFont(WEB, 1);
	TextDrawLetterSize(WEB, 0.200000, 1.000000);
	TextDrawColor(WEB, -1);
	TextDrawSetOutline(WEB, 1);
	TextDrawSetProportional(WEB, 1);
	TextDrawSetSelectable(WEB, 0);
}

ShowConnectionTD(playerid)
{
	TextDrawShowForPlayer(playerid, Slogan);
	TextDrawShowForPlayer(playerid, PPTD);
	TextDrawShowForPlayer(playerid, RPTD);
	TextDrawShowForPlayer(playerid, WEB);
}

HideConnectionTD(playerid)
{
	TextDrawHideForPlayer(playerid, Slogan);
	TextDrawHideForPlayer(playerid, PPTD);
	TextDrawHideForPlayer(playerid, RPTD);
	TextDrawHideForPlayer(playerid, WEB);
}

LoadTextdraws()
{
	LoadConnectionTD();
	LoadTimeTD();
	LoadInfoTD();
}

LoadTimeTD()
{
	Time = TextDrawCreate(553.000000, 103.000000, "~w~Time: 12 AM~n~Midnight");
	TextDrawAlignment(Time, 2);
	TextDrawBackgroundColor(Time, 255);
	TextDrawFont(Time, 2);
	TextDrawLetterSize(Time, 0.430000, 1.899999);
	TextDrawColor(Time, -1);
	TextDrawSetOutline(Time, 1);
	TextDrawSetProportional(Time, 1);
	TextDrawSetSelectable(Time, 0);
	return 1;
}

HideTimeTD(playerid)
{
	TextDrawHideForPlayer(playerid, Time);
}

ShowTimeTD(playerid)
{
	TextDrawShowForPlayer(playerid, Time);
}

timer TimerTripPlayer[2000](playerid)
{
	BunnyHop[playerid] = 0;
	return 1;
}

TripPlayer(playerid)
{
	new Float:hp, Float:arm;
	GetPlayerHealth(playerid, hp);
	GetPlayerArmour(playerid, arm);
	PlayerPlaySound(playerid, 1130, 0.0, 0.0, 0.0);
	new rand = random(2);
	if(rand == 0)
	{
		LoopingAnim(playerid, "GYMNASIUM", "gym_jog_falloff", 4.0, 0, 1, 1, 0, 0);
		if(arm > 1)
		{
			SetPlayerArmour(playerid, arm - 1);
		}
		else
		{
			SetPlayerHealth(playerid, hp -1);
		}
	}
	else
	{
		LoopingAnim(playerid, "PED", "FLOOR_hit_f", 4.0, 0, 1, 1, 0, 0);
		if(arm > 3)
		{
			SetPlayerArmour(playerid, arm - 3);
		}
		else
		{
			SetPlayerHealth(playerid, hp -3);
		}
	}
	new str[64];
	format(str, sizeof(str), "* %s tripped and fell down.", PlayerCName(playerid));
	SendLocalMessage(16.0, playerid, str, COLOR_PURPLE,COLOR_PURPLE);
	defer TimerTripPlayer(playerid);
	return 1;
}

Exit(seconds)
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			SaveUserStats(i);
		}
	}
	new gmsg[50];
	seconds *= 1000;
	SetTimer("ExitX", seconds, false);
	format(gmsg, sizeof(gmsg), "Server shutting down in %d seconds...", seconds/1000);
	SendClientMessageToAll(-1, gmsg);
}

forward ExitX();
public ExitX()
{
	SendClientMessageToAll(-1, "Server is shutting down...");
	GameTextForAll("~w~Server is ~n~~p~shutting down...", 2000, 3);
	SendRconCommand("exit");
	return 1;
}

GMX(seconds)
{
	for(new i = 0, j = GetPlayerPoolSize(); i <= j; i++)
	{
		if(IsPlayerConnected(i))
		{
			SaveUserStats(i);
		}
	}
	new gmsg[50];
	seconds *= 1000;
	SetTimer("GMXX", seconds, false);
	format(gmsg, sizeof(gmsg), "Server restarting in %d seconds...", seconds/1000);
	SendClientMessageToAll(-1, gmsg);
}

forward GMXX();
public GMXX()
{
	SendClientMessageToAll(-1, "Server is restarting...");
	GameTextForAll("~w~Server is ~n~~p~Restarting...", 2000, 3);
	SendRconCommand("gmx");
	return 1;
}

SetPlayerLookAt(playerid, Float:x, Float:y)
{
	new Float:Px, Float:Py, Float: Pa;
	GetPlayerPos(playerid, Px, Py, Pa);
	Pa = floatabs(atan((y-Py)/(x-Px)));
	if (x <= Px && y >= Py) Pa = floatsub(180, Pa);
	else if (x < Px && y < Py) Pa = floatadd(Pa, 180);
	else if (x >= Px && y <= Py) Pa = floatsub(360.0, Pa);
	Pa = floatsub(Pa, 90.0);
	if (Pa >= 360.0) Pa = floatsub(Pa, 360.0);
	SetPlayerFacingAngle(playerid, Pa);
}

GetXYInFrontOfPlayer(playerid, &Float:x, &Float:y, Float:distance) // Created by Y_Less
{
	new Float:a;
	GetPlayerPos(playerid, x, y, a);
	GetPlayerFacingAngle(playerid, a);
	if (GetPlayerVehicleID(playerid)) {
		GetVehicleZAngle(GetPlayerVehicleID(playerid), a);
	}
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

stock GetXYInFrontOfActor(actorid, &Float:x, &Float:y, Float:distance)
{
	// Created by Y_Less, just modified by SilentSoul

	new Float:a;
	GetActorPos(actorid, x, y, a);
	GetActorFacingAngle(actorid, a);
	x += (distance * floatsin(-a, degrees));
	y += (distance * floatcos(-a, degrees));
}

FindFreeObjectSlot( playerid )
{
	new
		objid;
	for( new i = 0; i < MAX_PLAYER_ATTACHED_OBJECTS; i++ )
	{
		if( IsPlayerAttachedObjectSlotUsed( playerid, i ) ) continue;
		objid = i;
	}
	return objid;
}

IsPlayerMoving(playerid)
{
	if(GetPlayerAnimationIndex(playerid))
	{
		new animname[32], animlib[32];
		GetAnimationName(GetPlayerAnimationIndex(playerid), animlib, sizeof(animlib), animname, sizeof(animname));
		if(!strcmp(animname, "WEAPON_CROUCH", true) || !strcmp(animname, "GUNCROUCHFWD", true))
		{
			return false;
		}
		else
		{
			new Float:Velocity[3];
			GetPlayerVelocity(playerid, Velocity[0], Velocity[1], Velocity[2]);
			if(Velocity[0] == 0.0 && Velocity[1] == 0.0 && Velocity[2] == 0.0) return false;
		}
	}
	return true;
}

SetPlayerColorEx(playerid)
{
	switch(Account[playerid][FID])
	{
		case 0: SetPlayerColor(playerid, COLOR_ORANGERED);
		case 1: SetPlayerColor(playerid, COLOR_MEDIC);
		case 2: SetPlayerColor(playerid, COLOR_COP);
		case 3: SetPlayerColor(playerid, COLOR_COOK);
	}
}

IsPlayerNameValid(playerid)
{
	if(strfind(PlayerName(playerid), "[", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "[", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "(", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), ")", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "1", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "2", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "3", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "4", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "5", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "6", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "7", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "8", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "9", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "0", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "$", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "=", true) != -1) return 0;
	else if(strfind(PlayerName(playerid), "_", true) != -1) return 1;
	return 1;
}