class Misc_ServerLink extends BufferedTCPLink;
		
var string 	ServerAddress;
var int 	ServerPort;

var string 	AccountName;
var string 	AccountPassword;

var IpAddr	ServerIpAddr;

var array<string> SendBuffer;
var bool SendBufferActive;

delegate OnReceivedStats(int PlayerIndex, float Rank, float AvgPPR);
delegate OnReceivedListName(string ListName);
delegate OnReceivedListIdx(int PlayerIndex, string PlayerName, string PlayerStat);

function AddToBuffer(string data)
{
	local int i;
	i = SendBuffer.Length;
	SendBuffer.Length = i+1;
	SendBuffer[i] = data;
}

function FlushBuffer()
{
	local int i;
	
	if(SendBufferActive==false)
		return;

	for(i=0; i<SendBuffer.Length; ++i)
		SendBufferedData(SendBuffer[i]);
	SendBuffer.Length = 0;
}

function RegisterGame(string GameTime, string MapName, string TeamScores)
{
	AddToBuffer("REGISTER_GAME "$GameTime$" "$MapName$" "$TeamScores$LF);
}

function RegisterStats(string GameTime, string PlayerName, string PlayerHash, int TeamIdx, int Rounds, float Score, int Kills, int Deaths, int Thaws, int Git)
{
	AddToBuffer("REGISTER_STATS "$GameTime$" "$PlayerName$" "$PlayerHash$" "$TeamIdx$" "$Rounds$" "$Score$" "$Kills$" "$Deaths$" "$Thaws$" "$Git$LF);
}

function RequestStats(int PlayerIndex, string PlayerHash)
{
	AddToBuffer("GET_STATS "$PlayerIndex$" "$PlayerHash$LF);
}

function RequestStatsList()
{
	AddToBuffer("GET_STATS_LIST"$LF);
}

function PostBeginPlay()
{
	Super.PostBeginPlay();
	SendBufferActive = false;
	Disable('Tick');
}

function DestroyLink()
{
	if(IsConnected())
	{
		FlushBuffer();
		SendBufferedData("LOGOUT"$LF);
		DoBufferQueueIO();
		Close();
	}
	else
	{
		Destroy();
	}
}

function Connect(string ServerAddressIn, int ServerPortIn, string AccountNameIn, string AccountPasswordIn)
{
	ServerAddress = ServerAddressIn;
	ServerPort = ServerPortIn;
	AccountName = AccountNameIn;
	AccountPassword = AccountPasswordIn;
	
	log("ServerLink: Connect: "$ServerAddress$":"$ServerPort$" as "$AccountNameIn);
	
	ResetBuffer();
	ServerIpAddr.Port = ServerPort;
	Resolve( ServerAddress );
}

function Resolved( IpAddr Addr )
{
	ServerIpAddr.Addr = Addr.Addr;

	if( ServerIpAddr.Addr == 0 )
	{
		Log("ServerLink: Unable to resolve server address.");
		return;
	}

	Log( "ServerLink: Server resolved "$ServerAddress$":"$ServerIpAddr.Port);

	if( BindPort() == 0 )
	{
		Log("ServerLink: Unable to bind the local port.");
		return;
	}

	Open( ServerIpAddr );
}

function ResolveFailed()
{
	Log("ServerLink: Unable to resolve server address.");
	DestroyLink();
}

event Opened()
{
	Log("ServerLink: Connection open.");
	SendBufferedData("LOGIN "$AccountName$" "$AccountPassword$LF);
	SendBufferActive = true;
	Enable('Tick');
}

event Closed()
{
	Log("ServerLink: Closing link.");
	SendBufferActive = false;
	DestroyLink();
}

function Tick(float DeltaTime)
{
	local string Line;
	local array<string> Params;

	FlushBuffer();
	DoBufferQueueIO();
	if(ReadBufferedLine(Line))
	{
		Log("ServerLink: Received: "$Line);
		Split(Line, " ", Params);
		HandleMessage(Params);
	}
	
    Super.Tick(DeltaTime);
}

function HandleMessage(array<string> Params)
{
	local int PlayerIndex;
	local float Rank, AvgPPR;
	local string ListName, PlayerName, PlayerStat;

	if(Params.Length == 0)
	{
		Log("ServerLink: No parameters for incoming message");
		return;
	}
	
	if(Params[0] == "STATS_UPDATE")
	{
		if(Params.Length < 4)
		{
			Log("ServerLink: Incorrect number of arguments for STATS_UPDATE");
			return;
		}

		PlayerIndex = int(Params[1]);
		Rank = float(Params[2]);
		AvgPPR = float(Params[3]);
		
		OnReceivedStats(PlayerIndex, Rank, AvgPPR);
	}
	else if(Params[0] == "SL_NAME")
	{
		if(Params.Length < 2)
		{
			Log("ServerLink: Incorrect number of arguments for SL_NAME");
			return;
		}
		
		ListName = Repl(Params[1],"_"," ");
		
		OnReceivedListName(ListName);
	}
	else if(Params[0] == "SL_IDX")
	{
		if(Params.Length < 4)
		{
			Log("ServerLink: Incorrect number of arguments for SL_IDX");
			return;
		}
		
		PlayerIndex = int(Params[1]);
		PlayerName = Params[2];
		PlayerStat = Params[3];
		
		OnReceivedListIdx(PlayerIndex, PlayerName, PlayerStat);
	}
}

defaultproperties
{
}