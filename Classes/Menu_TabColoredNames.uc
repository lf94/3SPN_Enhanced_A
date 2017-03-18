/* UTComp - UT2004 Mutator
Copyright (C) 2004-2005 Aaron Everitt & Joël Moffatt

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA. */

class Menu_TabColoredNames extends UT2k3TabPanel;

var automated GUILabel l_ColorNameLetters[20];
var automated GUILabel l_LetterSelection;
var automated moCheckBox ch_ColorChat, ch_ColorScoreboard, ch_ColorHUD, ch_ColorQ3, ch_EnemyNames;
var automated GUIComboBox co_SavedNames;
var automated GUIButton bu_SaveName, bu_DeleteName, bu_ResetWhite, bu_Apply;
var automated GUISlider sl_RedColor, sl_BlueColor, sl_GreenColor;
var automated GUILabel l_RedLabel, l_BlueLabel, l_GreenLabel;
var automated GUISlider sl_LetterSelect;
var automated moComboBox co_DeathSelect;
var automated GUILabel l_SettingsLabel;

function bool AllowOpen(string MenuClass)
{
	if(PlayerOwner()==None || PlayerOwner().PlayerReplicationInfo==None)
		return false;
	return true;
}

event Opened(GUIComponent Sender)
{
	local bool OldDirty;

	OldDirty = class'Menu_Menu3SPN'.default.SettingsDirty;

	if(class'Misc_Player'.default.CurrentSelectedColoredName<class'Misc_Player'.default.ColoredName.Length)
	{
		co_SavedNames.SetIndex(class'Misc_Player'.default.CurrentSelectedColoredName);
		SpecialInitSliderAndLetters(class'Misc_Player'.default.CurrentSelectedColoredName);
	}
	else
	{
		InitSliderAndLetters();
	}

	super.Opened(Sender);

	class'Menu_Menu3SPN'.default.SettingsDirty = OldDirty;	
}

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
     local int i;
	 local bool OldDirty;

     Super.InitComponent(myController,MyOwner);	 
	 
	 OldDirty = class'Menu_Menu3SPN'.default.SettingsDirty;
	 
     for(i=0; i<class'Misc_Player'.default.ColoredName.Length; i++)
         co_SavedNames.AddItem(Misc_Player(PlayerOwner()).FindColoredName(i));
     co_SavedNames.ReadOnly(True);
	 
	 if(class'Misc_Player'.default.CurrentSelectedColoredName<class'Misc_Player'.default.ColoredName.Length)
	 {
		co_SavedNames.SetIndex(class'Misc_Player'.default.CurrentSelectedColoredName);
		SpecialInitSliderAndLetters(class'Misc_Player'.default.CurrentSelectedColoredName);
	}
	else
	{
		InitSliderAndLetters();
	}

	SetColorSliders(0);

	ch_ColorChat.Checked(class'Misc_Player'.default.bEnableColoredNamesInTalk);
	ch_ColorScoreboard.Checked(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnScoreboard);
	ch_ColorHUD.Checked(class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD);
	ch_ColorQ3.Checked(class'Misc_Player'.default.bAllowColoredMessages);
	ch_EnemyNames.Checked(class'Misc_Player'.default.bEnableColoredNamesOnEnemies);
	co_DeathSelect.AddItem("Disabled");
	co_DeathSelect.AddItem("Colored Names");
	co_DeathSelect.AddItem("Red/Blue Colored Names");
	co_DeathSelect.ReadOnly(True);

	if(class'Misc_DeathMessage'.default.bEnableTeamColoredDeaths)
		co_DeathSelect.SetIndex(2);
	else if(class'Misc_DeathMessage'.default.bDrawColoredNamesInDeathMessages)
		co_DeathSelect.SetIndex(1);
		
	 class'Menu_Menu3SPN'.default.SettingsDirty = OldDirty;
}

function InitSliderAndLetters()
{
     local int i;

	 if(PlayerOwner().PlayerReplicationInfo==None)
		return;
		
     for(i=0; i<Len(PlayerOwner().PlayerReplicationInfo.PlayerName); i++)
     {
          class'Misc_Player'.default.ColorName[i].A=255;     //make sure someone didnt change this
          l_ColorNameLetters[i].TextFont="UT2LargeFont";
          l_ColorNameLetters[i].WinTop=0.46;
          l_ColorNameLetters[i].WinWidth=0.029;
          l_ColorNameLetters[i].WinLeft=(0.50-(0.50*0.030*Len(PlayerOwner().PlayerReplicationInfo.PlayerName))+(0.030*i));
          l_ColorNameLetters[i].StyleName="TextLabel";
          l_ColorNameLetters[i].Caption=Right(Left(PlayerOwner().PlayerReplicationInfo.PlayerName, (i+1)), 1);
          l_ColorNameLetters[i].TextColor=class'Misc_Player'.default.ColorName[i];
          l_ColorNameLetters[i].TextAlign=TXTA_Center;
     }
     for(i=Len(PlayerOwner().PlayerReplicationInfo.PlayerName); i<20; i++)
          l_ColorNameLetters[i].Caption="";

      sl_LetterSelect.MinValue=1;
      sl_LetterSelect.WinLeft=(0.50-(0.50*0.030*Len(PlayerOwner().PlayerReplicationInfo.PlayerName)));
      sl_LetterSelect.MaxValue=Min((Len(PlayerOwner().PlayerReplicationInfo.PlayerName)), 20);
      sl_LetterSelect.WinWidth=(0.0297*Min((Len(PlayerOwner().PlayerReplicationInfo.PlayerName)), 20));
      sl_LetterSelect.BarStyle=None;
      sl_LetterSelect.FillImage=None;
}

function SpecialInitSliderAndLetters(int j)
{
     local int i;

     for(i=0; i<Len(class'Misc_Player'.default.ColoredName[j].SavedName); i++)
     {
          class'Misc_Player'.default.ColorName[i].A=255;     //make sure someone didnt change this
          l_ColorNameLetters[i].TextFont="UT2LargeFont";
          l_ColorNameLetters[i].WinTop=0.46;
          l_ColorNameLetters[i].WinWidth=0.029;
          l_ColorNameLetters[i].WinLeft=(0.50-(0.50*0.030*Len(class'Misc_Player'.default.ColoredName[j].SavedName))+(0.030*i));
          l_ColorNameLetters[i].StyleName="TextLabel";
          l_ColorNameLetters[i].Caption=Right(Left(class'Misc_Player'.default.ColoredName[j].SavedName, (i+1)), 1);
          l_ColorNameLetters[i].TextColor=class'Misc_Player'.default.ColoredName[j].SavedColor[i];
          l_ColorNameLetters[i].TextAlign=TXTA_Center;
     }
     for(i=Len(class'Misc_Player'.default.ColoredName[j].SavedName); i<20; i++)
          l_ColorNameLetters[i].Caption="";

      sl_LetterSelect.MinValue=1;
      sl_LetterSelect.WinLeft=(0.50-(0.50*0.030*Len(PlayerOwner().PlayerReplicationInfo.PlayerName)));
      sl_LetterSelect.MaxValue=Min((Len(PlayerOwner().PlayerReplicationInfo.PlayerName)), 20);
      sl_LetterSelect.WinWidth=(0.0297*Min((Len(PlayerOwner().PlayerReplicationInfo.PlayerName)), 20));
      sl_LetterSelect.BarStyle=None;
      sl_LetterSelect.FillImage=None;
}

function SetColorSliders(byte offset)
{
    sl_RedColor.SetValue(class'Misc_Player'.default.ColorName[offset].R);
    sl_GreenColor.SetValue(class'Misc_Player'.default.ColorName[offset].G);
    sl_BlueColor.SetValue(class'Misc_Player'.default.ColorName[offset].B);
}

function InternalOnChange( GUIComponent C )
{
    Switch(C)
    {
    case ch_ColorChat:
		class'Misc_Player'.default.bEnableColoredNamesInTalk=ch_ColorChat.IsChecked();  
		break;
		
    case ch_ColorScoreboard: 
		class'TAM_ScoreBoard'.default.bEnableColoredNamesOnScoreboard=ch_ColorScoreboard.IsChecked();
		break;
		
	case ch_ColorHUD:
		class'TAM_ScoreBoard'.default.bEnableColoredNamesOnHUD=ch_ColorHUD.IsChecked();
		break;
		
    case ch_ColorQ3: 
		class'Misc_Player'.default.bAllowColoredMessages=ch_ColorQ3.IsChecked(); 
		break;
		
    case ch_EnemyNames: 
		class'Misc_Player'.default.bEnableColoredNamesOnEnemies=ch_EnemyNames.IsChecked(); 
		break;
		
    case co_DeathSelect:  
		class'Misc_DeathMessage'.default.bEnableTeamColoredDeaths=(co_DeathSelect.GetIndex()==2);
		class'Misc_DeathMessage'.default.bDrawColoredNamesInDeathMessages=(co_DeathSelect.GetIndex()==1); 
		break;
		
   case sl_LetterSelect: 
		SetColorSliders(sl_LetterSelect.Value-1); 
		break;

    case sl_RedColor:   
		class'Misc_Player'.default.ColorName[sl_LetterSelect.Value-1].R=sl_RedColor.Value;
		Misc_Player(PlayerOwner()).SetColoredNameOldStyle();
		l_ColorNameLetters[sl_LetterSelect.Value-1].TextColor.R=sl_RedColor.Value;  
		break;
		
    case sl_BlueColor:  
		class'Misc_Player'.default.ColorName[sl_LetterSelect.Value-1].B=sl_BlueColor.Value;
		Misc_Player(PlayerOwner()).SetColoredNameOldStyle();
		l_ColorNameLetters[sl_LetterSelect.Value-1].TextColor.B=sl_BlueColor.Value;  
		break;
		
    case sl_GreenColor: 
		class'Misc_Player'.default.ColorName[sl_LetterSelect.Value-1].G=sl_GreenColor.Value;
		Misc_Player(PlayerOwner()).SetColoredNameOldStyle();
		l_ColorNameLetters[sl_LetterSelect.Value-1].TextColor.G=sl_GreenColor.Value;  
		break;

    case co_SavedNames:   
		//class'Misc_Player'.default.CurrentSelectedColoredName=.GetIndex();
		//Misc_Player(PlayerOwner()).SetInitialColoredName();
		//InitSliderAndLetters();
		break;
    }
	
    Misc_Player(PlayerOwner()).ReloadDefaults();
    class'Misc_Player'.Static.StaticSaveConfig();	
    class'TAM_ScoreBoard'.Static.StaticSaveConfig();
    class'Misc_DeathMessage'.Static.StaticSaveConfig();
	class'Menu_Menu3SPN'.default.SettingsDirty = true;
}

function bool InternalOnClick( GUIComponent Sender )
{
    local int i;

    switch (Sender)
    {
    case bu_SaveName:
		Misc_Player(PlayerOwner()).SaveNewColoredName();
		co_SavedNames.ReadOnly(False);
		co_SavedNames.AddItem(Misc_Player(PlayerOwner()).FindColoredName(class'Misc_Player'.default.ColoredName.Length-1));
		co_SavedNames.ReadOnly(True);
		break;

    case bu_DeleteName:  
		if(class'Misc_Player'.default.ColoredName.Length>co_SavedNames.GetIndex() && co_SavedNames.GetIndex()>=0)
			class'Misc_Player'.default.ColoredName.Remove(co_SavedNames.GetIndex(), 1);
		if(class'Misc_Player'.default.CurrentSelectedColoredName!=255)
		{
			if(class'Misc_Player'.default.CurrentSelectedColoredName>0)
			{
				if(class'Misc_Player'.default.CurrentSelectedColoredName>=co_SavedNames.GetIndex())
					--class'Misc_Player'.default.CurrentSelectedColoredName;
				else
					class'Misc_Player'.default.CurrentSelectedColoredName=255;
			}
			if(class'Misc_Player'.default.CurrentSelectedColoredName>=class'Misc_Player'.default.ColoredName.Length || class'Misc_Player'.default.CurrentSelectedColoredName<0)
				class'Misc_Player'.default.CurrentSelectedColoredName=255;
		}
		if(co_SavedNames.ItemCount()>0)
		{
			co_SavedNames.ReadOnly(False);
			co_SavedNames.RemoveItem(co_SavedNames.GetIndex());
			co_SavedNames.ReadOnly(True);
		}
		break;

	case bu_ResetWhite:   
		for(i=0; i<20; i++)
		{
			class'Misc_Player'.default.ColorName[i].R=255;
			class'Misc_Player'.default.ColorName[i].G=255;
			class'Misc_Player'.default.ColorName[i].B=255;
			l_ColorNameLetters[i].TextColor.R=255;
			l_ColorNameLetters[i].TextColor.G=255;
			l_ColorNameLetters[i].TextColor.B=255;
		}
		class'Misc_Player'.default.CurrentSelectedColoredName=255;
		break;
		
	case bu_Apply:
		if(co_SavedNames.GetIndex()<co_SavedNames.ItemCount() && co_SavedNames.GetIndex()>=0)
		{
			Misc_Player(PlayerOwner()).SetColoredNameOldStyleCustom(,co_SavedNames.GetIndex());
			class'Misc_Player'.default.CurrentSelectedColoredName=co_savedNames.GetIndex();
			SpecialInitSliderAndLetters(co_SavedNames.GetIndex());
			SetColorSliders(sl_LetterSelect.Value-1);
		}
		break;
	}
	
	Misc_Player(PlayerOwner()).ReloadDefaults();
	class'Misc_Player'.Static.StaticSaveConfig();
	class'Menu_Menu3SPN'.default.SettingsDirty = true;

	return true;
}

defaultproperties
{
	Begin Object Class=GUILabel Name=Label0
	End Object
	l_ColorNameLetters(0)=Label0

	Begin Object Class=GUILabel Name=Label1
	End Object
	l_ColorNameLetters(1)=Label1

	Begin Object Class=GUILabel Name=Label2
	End Object
	l_ColorNameLetters(2)=Label2

	Begin Object Class=GUILabel Name=Label3
	End Object
	l_ColorNameLetters(3)=Label3

	Begin Object Class=GUILabel Name=Label4
	End Object
	l_ColorNameLetters(4)=Label4

	Begin Object Class=GUILabel Name=Label5
	End Object
	l_ColorNameLetters(5)=Label5

	Begin Object Class=GUILabel Name=Label6
	End Object
	l_ColorNameLetters(6)=Label6

	Begin Object Class=GUILabel Name=Label7
	End Object
	l_ColorNameLetters(7)=Label7

	Begin Object Class=GUILabel Name=Label8
	End Object
	l_ColorNameLetters(8)=Label8

	Begin Object Class=GUILabel Name=Label9
	End Object
	l_ColorNameLetters(9)=Label9

	Begin Object Class=GUILabel Name=Label10
	End Object
	l_ColorNameLetters(10)=Label10

	Begin Object Class=GUILabel Name=Label11
	End Object
	l_ColorNameLetters(11)=Label11

	Begin Object Class=GUILabel Name=Label12
	End Object
	l_ColorNameLetters(12)=Label12

	Begin Object Class=GUILabel Name=Label13
	End Object
	l_ColorNameLetters(13)=Label13

	Begin Object Class=GUILabel Name=Label14
	End Object
	l_ColorNameLetters(14)=Label14

	Begin Object Class=GUILabel Name=Label15
	End Object
	l_ColorNameLetters(15)=Label15

	Begin Object Class=GUILabel Name=Label16
	End Object
	l_ColorNameLetters(16)=Label16

	Begin Object Class=GUILabel Name=Label17
	End Object
	l_ColorNameLetters(17)=Label17

	Begin Object Class=GUILabel Name=Label18
	End Object
	l_ColorNameLetters(18)=Label18

	Begin Object Class=GUILabel Name=Label19
	End Object
	l_ColorNameLetters(19)=Label19

	Begin Object Class=GUISlider Name=LetterSlider
		Value = 1
		bIntSlider = True
		WinTop = 0.51
		OnClick = LetterSlider.InternalOnClick
		OnMousePressed = LetterSlider.InternalOnMousePressed
		OnMouseRelease = LetterSlider.InternalOnMouseRelease
		OnChange = InternalOnChange
		OnKeyEvent = LetterSlider.InternalOnKeyEvent
		OnCapturedMouseMove = LetterSlider.InternalCapturedMouseMove
	End Object
    sl_LetterSelect=LetterSlider
	
	Begin Object Class=GUIComboBox Name=ComboSaved
		WinTop = 0.60
		WinLeft = 0.14
		WinWidth = 0.30
		WinHeight = 0.04
		OnChange = InternalOnChange
		OnKeyEvent = ComboSaved.InternalOnKeyEvent
	End Object
    co_SavedNames=ComboSaved
	
	Begin Object Class=GUIButton Name=ButtonSave
		Caption="Save"
		WinTop=0.65
		WinLeft=0.14
		WinWidth=0.13
		WinHeight=0.075
		OnClick=InternalOnClick
		OnKeyEvent=ButtonSave.InternalOnKeyEvent
	End Object	
    bu_SaveName=ButtonSave
	
	Begin Object Class=GUIButton Name=ButtonDelete
		Caption="Delete"
		WinTop=0.65
		WinLeft=0.30
		WinWidth=0.14
		WinHeight=0.075
		OnClick=InternalOnClick
		OnKeyEvent=ButtonDelete.InternalOnKeyEvent
	End Object
    bu_DeleteName=ButtonDelete
	
	Begin Object Class=GUIButton Name=ButtonWhite
		Caption="Reset Colors"
		WinTop=0.74
		WinLeft=0.50
		WinWidth=0.40
		WinHeight=0.10
		OnClick=InternalOnClick
		OnKeyEvent=ButtonWhite.InternalOnKeyEvent
	End Object
    bu_ResetWhite=ButtonWhite
	
	Begin Object Class=GUIButton Name=ButtonApply
		Caption="Use This Name"
		WinTop=0.74
		WinLeft=0.14
		WinWidth=0.30
		WinHeight=0.10
		OnClick=InternalOnClick
		OnKeyEvent=ButtonApply.InternalOnKeyEvent
	End Object
    bu_Apply=ButtonApply
	
	Begin Object Class=GUISlider Name=RedSlider
		MaxValue = 255
		bIntSlider = True
		WinTop = 0.60
		WinLeft = 0.60
		WinWidth = 0.30
		OnClick = RedSlider.InternalOnClick
		OnMousePressed = RedSlider.InternalOnMousePressed
		OnMouseRelease = RedSlider.InternalOnMouseRelease
		OnChange = InternalOnChange
		OnKeyEvent = RedSlider.InternalOnKeyEvent
		OnCapturedMouseMove = RedSlider.InternalCapturedMouseMove
	End Object
    sl_RedColor=RedSlider
	
	Begin Object Class=GUISlider Name=GreenSlider
		MaxValue = 255
		bIntSlider = True
		WinTop = 0.65
		WinLeft = 0.60
		WinWidth = 0.30
		OnClick = GreenSlider.InternalOnClick
		OnMousePressed = GreenSlider.InternalOnMousePressed
		OnMouseRelease = GreenSlider.InternalOnMouseRelease
		OnChange = InternalOnChange
		OnKeyEvent = GreenSlider.InternalOnKeyEvent
		OnCapturedMouseMove = GreenSlider.InternalCapturedMouseMove
	End Object
    sl_GreenColor=GreenSlider
	
	Begin Object Class=GUISlider Name=BlueSlider
		MaxValue = 255
		bIntSlider = True
		WinTop = 0.70
		WinLeft = 0.60
		WinWidth = 0.30
		OnClick = BlueSlider.InternalOnClick
		OnMousePressed = BlueSlider.InternalOnMousePressed
		OnMouseRelease = BlueSlider.InternalOnMouseRelease
		OnChange = InternalOnChange
		OnKeyEvent = BlueSlider.InternalOnKeyEvent
		OnCapturedMouseMove = BlueSlider.InternalCapturedMouseMove
	End Object
    sl_BlueColor=BlueSlider
	
	Begin Object Class=GUILabel Name=RedLabel
		Caption = "Red"
		TextColor = (R=255,G=0,B=0,A=255)
		WinTop = 0.59
		WinLeft = 0.50
	End Object
    l_RedLabel=RedLabel
	
	Begin Object Class=GUILabel Name=GreenLabel
		Caption = "Green"
		TextColor = (R=64,G=255,B=0,A=255)
		WinTop = 0.64
		WinLeft = 0.50
	End Object
    l_GreenLabel=GreenLabel

	Begin Object Class=GUILabel Name=BlueLabel
		Caption = "Blue"
		TextColor = (R=64,G=0,B=255,A=255)
		WinTop = 0.69
		WinLeft = 0.50
	End Object	
    l_BlueLabel=BlueLabel

	Begin Object Class=moCheckBox Name=ColorChatCheck
		Caption = "Show colored names in chat messages"
		OnCreateComponent = ColorChatCheck.InternalOnCreateComponent
		WinTop = 0.10
		WinLeft = 0.10
		WinWidth = 0.80
		OnChange = InternalOnChange
	End Object
	ch_ColorChat=ColorChatCheck
	
	Begin Object Class=moCheckBox Name=ColorScoreboardCheck
		Caption = "Show colored names on scoreboard"
		OnCreateComponent = ColorScoreboardCheck.InternalOnCreateComponent
		WinTop = 0.15
		WinLeft = 0.10
		WinWidth = 0.80
		OnChange = InternalOnChange
	End Object
    ch_ColorScoreboard=ColorScoreboardCheck

	Begin Object Class=moCheckBox Name=ColorHUDCheck
		Caption = "Show colored names on HUD"
		OnCreateComponent = ColorHUDCheck.InternalOnCreateComponent
		WinTop = 0.20
		WinLeft = 0.10
		WinWidth = 0.80
		OnChange = InternalOnChange
	End Object
    ch_ColorHUD=ColorHUDCheck
	
	Begin Object Class=moCheckBox Name=EnemyNamesCheck
		Caption = "Show colored enemy names on targeting"
		OnCreateComponent = EnemyNamesCheck.InternalOnCreateComponent
		WinTop = 0.25
		WinLeft = 0.10
		WinWidth = 0.80
		OnChange = InternalOnChange
	End Object
    ch_EnemyNames=EnemyNamesCheck

	Begin Object Class=moCheckBox Name=Colorq3Check
		Caption = "Show colored text in chat messages(Q3 Style)"
		OnCreateComponent = Colorq3Check.InternalOnCreateComponent
		WinTop = 0.30
		WinLeft = 0.10
		WinWidth = 0.80
		OnChange = InternalOnChange
	End Object
    ch_ColorQ3=Colorq3Check
	
	Begin Object Class=moComboBox Name=ColorDeathCombo
		Caption = "Death Message Color:"
		OnCreateComponent = ColorDeathCombo.InternalOnCreateComponent
		WinTop = 0.35
		WinLeft = 0.17
		WinWidth = 0.66
		OnChange = InternalOnChange
	End Object
    co_DeathSelect=ColorDeathCombo
	
	Begin Object Class=GUILabel Name=SettingsLabel
		Caption = "Only the active name can be saved on the server!"
		TextColor = (R=255,G=255,B=0,A=255)
		WinTop = 0.90
		WinLeft = 0.10
		WinWidth = 0.80
		TextAlign = TXTA_Center;
	End Object
    l_SettingsLabel=SettingsLabel
	
}
