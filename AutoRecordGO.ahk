;Created by valleyman86
;Updated by Doug Krahmer (Dange Zone compatibility)
; needs to be #Persistent, otherwise events will kick few times and script exits.
#Persistent
 
consoleLogPath := "D:\Games\SteamLibrary\steamapps\common\Counter-Strike Global Offensive\csgo\console.log"
;consoleLogPath := "D:\test.txt"

AutoTrim, On

;Delete this section to remove auto recording
;-start-
SetTimer MonitorConsoleLog, 500
TruncateFile(consoleLogPath)
_consoleLogFile := FileOpen(consoleLogPath, "r")

_consoleLogFile.Seek(0, 2)
_size0 := _consoleLogFile.Length
_mapName := ""
_isNewConnectionToDzMap := 0
_isRecording := 0
;-end-
 
;Delete this section to remove Ctrl+Shift+S hotkey recording
;-start-
#If WinActive("ahk_exe csgo.exe")
	^+s::
		RecordDemo()
	return
#if
;-end-
 
;Delete this section to enable caps lock in game. (Note: It still works as a key it just does not stay toggled on)
;-start-
#If WinActive("ahk_exe csgo.exe") or WinActive("ahk_exe dota.exe")
	~CapsLock Up::SetCapsLockState, off
#if
;-end-
 
RecordDemo()
{
	;MsgBox RecordDemo
	FormatTime, time, %A_Now%, MM-dd-yy_hh-mmtt
	SendInput ``
	Sleep, 250
	SendInput record Saved_Demos\%_mapName%_%time% {enter}
	Sleep, 100
	SendInput ``
}

TruncateFile(filePath)
{
	fileToClear := FileOpen(filePath, "w")
	fileToClear.Write("")
	fileToClear.Close()
}

MonitorConsoleLog:
	global _mapName
	global _isRecording
	global _isNewConnectionToDzMap	; special handling for dz_* maps
	
	size := _consoleLogFile.Length
 
	if (_size0 >= size) 
	{
		_size0 := size
		_consoleLogFile.Seek(0, 2)
		Return
	}
 
	while (logLine := _consoleLogFile.ReadLine())
	{
		if (RegExMatch(logLine, "i)^Map: (.*/)?(.*)", mapName)) 
		{
			_mapName := mapName2
		}
		else if (RegExMatch(logLine, "i).+ connected.")) 
		{
			if (_isRecording = 0)
			{
				if (RegExMatch(_mapName, "i)^dz_.+"))
				{
					_isNewConnectionToDzMap := 1
				}
				else
				{
					Sleep, 6000
					RecordDemo()
				}
			}
			;MsgBox %logLine%
		}
		else if (_isNewConnectionToDzMap = 1 and RegExMatch(logLine, "i)^ChangeGameUIState\: CSGO_GAME_UI_STATE_INGAME -\> CSGO_GAME_UI_STATE_INGAME")) 
		{
			_isNewConnectionToDzMap := 0
			Sleep, 1000
			;MsgBox %logLine%
			RecordDemo()
		}
		else if (RegExMatch(logLine, "i)Recording to")) 
		{
			_isRecording := 1
			SoundBeep
			;SoundPlay recording_started.mp3
		}
		else if (RegExMatch(logLine, "i)Completed demo")) 
		{
			_isRecording := 0
			SoundBeep
			;SoundPlay replay_saved.mp3
		}
	}
 
	_size0 := size
Return
