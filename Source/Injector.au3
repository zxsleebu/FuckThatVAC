#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.14.5
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

Func CreateProcessEx(Const $sExecutablePath, Const $sDllPath, Const $sCommandLine = '', Const $vWorkingDir = Null)
    If Not FileExists($sDllPath) Then Return SetError(1, 0, False)
    Local $tagSTARTUPINFO = DllStructCreate( _
            'DWORD cb;' & _
            'ptr Reserved;' & _
            'ptr Desktop;' & _
            'ptr Title;' & _
            'DWORD X;' & _
            'DWORD Y;' & _
            'DWORD XSize;' & _
            'DWORD YSize;' & _
            'DWORD XCountChars;' & _
            'DWORD YCountChars;' & _
            'DWORD FillAttribute;' & _
            'DWORD Flags;' & _
            'WORD ShowWindow;' & _
            'WORD cbReserved2;' & _
            'ptr Reserved2;' & _
            'HANDLE StdInput;' & _
            'HANDLE StdOutput;' & _
            'HANDLE StdError')
    Local Const $tagPROCESS_INFORMATION = DllStructCreate( _
            'HANDLE hProcess;' & _
            'HANDLE hThread;' & _
            'DWORD ProcessId;' & _
            'DWORD ThreadId')
    DllStructSetData($tagSTARTUPINFO, 'cb', DllStructGetSize($tagSTARTUPINFO))
    Local Const $bCreateProcess = DllCall('kernel32.dll', 'BOOL', 'CreateProcess', _
            'str', $sExecutablePath, _
            'str', $sCommandLine, _
            'ptr', 0, _
            'ptr', 0, _
            'BOOL', False, _
            'DWORD', 0x00000004, _ ;CREATE_SUSPENDED
            'ptr', 0, _
            'str', $vWorkingDir, _
            'struct*', $tagSTARTUPINFO, _
            'struct*', $tagPROCESS_INFORMATION)
    If @error Or $bCreateProcess[0] = 0 Then Return SetError(2, 0, False)
    $tagSTARTUPINFO = 0
    Local Const $pRemoteAddress = DllCall('kernel32.dll', 'ptr', 'VirtualAllocEx', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
            'ptr', 0, _
            'int', 1, _
            'DWORD', 0x00001000, _ ;MEM_COMMIT
            'DWORD', 0x04) ;PAGE_READWRITE
    If @error Or $pRemoteAddress[0] = 0 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(3, 0, False)
    EndIf
    Local Const $tagBuffer = DllStructCreate('CHAR[' & StringLen($sDllPath) & ']')
    DllStructSetData($tagBuffer, 1, $sDllPath)
    Local Const $bWPM = DllCall('kernel32.dll', 'BOOL', 'WriteProcessMemory', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
            'ptr', $pRemoteAddress[0], _
            'struct*', $tagBuffer, _
            'int', StringLen($sDllPath), _
            'int*', 0)
    If @error Or $bWPM[0] = 0 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(4, 0, False)
    EndIf
    Local Const $hKernel32 = DllCall('kernel32.dll', 'HANDLE', 'GetModuleHandle', _
            'str', 'kernel32.dll')
    If @error Or $hKernel32[0] = 0 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(5, 0, False)
    EndIf
    Local Const $pLoadLibraryA = DllCall('kernel32.dll', 'DWORD', 'GetProcAddress', _
            'HANDLE', $hKernel32[0], _
            'str', 'LoadLibraryA')
    If @error Or $pLoadLibraryA[0] = 0 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(6, 0, False)
    EndIf
    Local Const $hRemoteThread = DllCall('kernel32.dll', 'HANDLE', 'CreateRemoteThread', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
            'ptr', 0, _
            'int', 0, _
            'DWORD', $pLoadLibraryA[0], _
            'ptr', $pRemoteAddress[0], _
            'DWORD', 0, _
            'DWORD*', 0)
    If @error Or $hRemoteThread[0] = 0 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(7, 0, False)
    EndIf
    Local Const $dwEvent = DllCall('kernel32.dll', 'DWORD', 'WaitForSingleObject', _
            'HANDLE', $hRemoteThread[0], _
            'DWORD', 0xFFFFFFFF) ;INFINITE
    If @error Or $dwEvent[0] <> 0x00000000 Then ;WAIT_OBJECT_0
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(8, 0, False)
    EndIf
    DllCall('kernel32.dll', 'BOOL', 'CloseHandle', _
            'HANDLE', $hRemoteThread[0])
    Local Const $bVirtualFreeEx = DllCall('kernel32.dll', 'BOOL', 'VirtualFreeEx', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
            'ptr', $pRemoteAddress[0], _
            'int', 0, _
            'DWORD', 0x8000) ;MEM_RELEASE
    If @error Or $bVirtualFreeEx[0] = 0 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(9, 0, False)
    EndIf
    Local Const $dwResumeThread = DllCall('kernel32.dll', 'DWORD', 'ResumeThread', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hThread'))
    If @error Or $dwResumeThread[0] = -1 Then
        DllCall('kernel32.dll', 'BOOL', 'TerminateProcess', _
                'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'), _
                'DWORD', 0)
        Return SetError(10, 0, False)
    EndIf
    DllCall('kernel32.dll', 'BOOL', 'CloseHandle', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hThread'))
    DllCall('kernel32.dll', 'BOOL', 'CloseHandle', _
            'HANDLE', DllStructGetData($tagPROCESS_INFORMATION, 'hProcess'))
    Return SetError(0, 0, DllStructGetData($tagPROCESS_INFORMATION, 'ProcessId'))
EndFunc   ;==>CreateProcessEx