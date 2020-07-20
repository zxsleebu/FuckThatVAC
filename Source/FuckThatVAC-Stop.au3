#cs ----------------------------------------------------------------------------

   Name:			FuckThatVAC (AutoIt VAC-Bypass-Loader)
   AutoIt Version:	3.3.14.5
   Author:        	@zxsleebu
   Github:			https://github.com/zxsleebu


   Script Function:
	  Template AutoIt script.

#ce ----------------------------------------------------------------------------
#RequireAdmin

; Waiting for it...
Sleep(3000)

; Renew connection
RunWait('ipconfig /renew', @TempDir, @SW_HIDE)