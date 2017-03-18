class Menu_Menu3SPN extends UT2k3GUIPage;

var GUITabControl TabC;
var Menu_TabColoredNames NamesTab;
var Menu_TabBrightskins BSTab;
var Menu_TabMisc MiscTab;
var Menu_TabInfo InfoTab;
var Menu_TabRanks StatsTab;
var UT2k3TabPanel AdminTab;
var Menu_TabTournamentAdmin TournamentAdminTab;

var bool DefaultToInfoTab;
var bool SettingsDirty;
var bool bAdmin;

function bool AllowOpen(string MenuClass)
{
	return false;
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);

    bAdmin = PlayerOwner().PlayerReplicationInfo!=None && (PlayerOwner().PlayerReplicationInfo.bAdmin || PlayerOwner().Level.NetMode == NM_Standalone);
	
	GUITitleBar(Controls[1]).Caption = "3SPN"@class'Misc_BaseGRI'.default.Version@"Configuration";	
		
    TabC = GUITabControl(Controls[2]);
	InfoTab = Menu_TabInfo(TabC.AddTab("Info", "3SPNv32232.Menu_TabInfo",, "General Information", DefaultToInfoTab));
	StatsTab = Menu_TabRanks(TabC.AddTab("Ranks", "3SPNv32232.Menu_TabRanks",, "Ranks", false));
    MiscTab = Menu_TabMisc(TabC.AddTab("Miscellaneous", "3SPNv32232.Menu_TabMisc",, "Miscellaneous player options", !DefaultToInfoTab));
    BSTab = Menu_TabBrightskins(TabC.AddTab("Brightskins & Models", "3SPNv32232.Menu_TabBrightskins",, "Brightskins configuration", false));
	NamesTab = Menu_TabColoredNames(TabC.AddTab("Colored Names", "3SPNv32232.Menu_TabColoredNames",, "Colored Names", false));

	if(InfoTab == None)
		log("Count not open tab Menu_TabInfo", '3SPN');
	if(StatsTab == None)
		log("Count not open tab Menu_TabRanks", '3SPN');
    if(MiscTab == None)
        log("Could not open tab Menu_TabMisc", '3SPN');
    if(BSTab == None)
        log("Could not open tab Menu_TabBrightskins", '3SPN');
	if(NamesTab == None)
		log("Could not open tab Menu_ColoredNames", '3SPN');
	
	if(bAdmin)
	{
		TournamentAdminTab = Menu_TabTournamentAdmin(TabC.AddTab("Tournament Admin", "3SPNv32232.Menu_TabTournamentAdmin",, "Tournament", false));
 
		if(PlayerOwner().Level.GRI!=None)
		{
			if(PlayerOwner().Level.GRI.bTeamGame)
				AdminTab = Menu_TabTAMAdmin(TabC.AddTab("Admin", "3SPNv32232.Menu_TabTAMAdmin",, "Admin/Server configuration", false));
			else
				AdminTab = Menu_TabAMAdmin(TabC.AddTab("Admin", "3SPNv32232.Menu_TabAMAdmin",, "Admin/Server configuration", false));
		}
		
		if(AdminTab == None)
			log("Could not open tab Menu_TabAdmin", '3SPN');
		if(TournamentAdminTab == None)
			log("Could not open the Menu_TabTournamentAdmin", '3SPN');		
	}
}

function InternalOnClose(optional bool bCanceled)
{
    local Misc_Player MP;

    if(BSTab.RedSpinnyDude != None)
    {
        BSTab.RedSpinnyDude.Destroy();
        BSTab.RedSpinnyDude = None;
    }

    if(BSTab.BlueSpinnyDude != None)
    {
        BSTab.BlueSpinnyDude.Destroy();
        BSTab.BlueSpinnyDude = None;
    }

    if(BSTab.YellowSpinnyDude != None)
    {
        BSTab.YellowSpinnyDude.Destroy();
        BSTab.YellowSpinnyDude = None;
    }
	
	if(class'Misc_Player'.default.AutoSyncSettings && default.SettingsDirty)
	{
		MP = Misc_Player(PlayerOwner());
		if(MP != None)
			MP.SaveSettings();
		default.SettingsDirty = false;
	}
}

defaultproperties
{
     bRenderWorld=True
     bRequire640x480=False
     bAllowedAsLast=True
     OnClose=Menu_Menu3SPN.InternalOnClose
     Begin Object Class=GUIImage Name=MenuBack
         Image=Texture'2K4Menus.NewControls.Display98'
         ImageColor=(B=100,G=128,R=200)
         ImageStyle=ISTY_Stretched
         ImageRenderStyle=MSTY_Normal
         WinTop=0.100000
         WinLeft=0.100000
         WinWidth=0.800000
         WinHeight=0.800000
         RenderWeight=0.000003
     End Object
     Controls(0)=GUIImage'3SPNv32232.Menu_Menu3SPN.MenuBack'

     Begin Object Class=GUITitleBar Name=MenuTitle
         Effect=FinalBlend'InterfaceContent.Menu.CO_Final'
         Caption="AM/TAM Configuration"
         StyleName="Header"
         WinHeight=0.075000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(1)=GUITitleBar'3SPNv32232.Menu_Menu3SPN.MenuTitle'

     Begin Object Class=GUITabControl Name=Tabs
         bDockPanels=True
         TabHeight=0.037500
         WinTop=0.060000
         WinLeft=0.015000
         WinWidth=0.970000
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=True
         OnActivate=Tabs.InternalOnActivate
     End Object
     Controls(2)=GUITabControl'3SPNv32232.Menu_Menu3SPN.Tabs'
 
     WinTop=0.089000
     WinLeft=0.100000
     WinWidth=0.800000
     WinHeight=0.775000
	 
	 DefaultToInfoTab=False
}
