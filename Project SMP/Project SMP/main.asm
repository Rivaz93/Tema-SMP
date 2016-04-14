.386 ; 32 bits
.model flat,stdcall 
option casemap:none ;case sensitive
	include d:\masm32\include\windows.inc 
	include d:\masm32\include\user32.inc 
	include d:\masm32\include\kernel32.inc 
	include d:\masm32\include\gdi32.inc 
	includelib d:\masm32\lib\user32.lib 
	includelib d:\masm32\lib\kernel32.lib 
	includelib d:\masm32\lib\gdi32.lib
	include d:\masm32\include\winmm.inc
	includelib d:\masm32\lib\winmm.lib
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
IDB_MAIN   equ 1
IDB_MARIO equ 2
IDB_MASHROOM equ 3

.data 
	ClassName db "SimpleWin32ASMBitmapClass",0 
	AppName  db "Mini Mario assembly",0
	sound BYTE "tetris.wav", MAX_PATH dup(0)
	moveToX dd 0, 0
	moveToY dd 300, 0
	hwnd dd 0
	wparam dd 1366,0
	lparam dd 768,0
	score dd 0, 0
	MsgBoxCaption db "Exit",0
	MsgBoxText db "You will exit",0
	MsgBoxCaptionWin db "Win",0
	MsgBoxTextWin db "You win!",0

.data? 
	hInstance HINSTANCE ? 
	CommandLine LPSTR ? 
	hBitmap dd ?
	hBitmap2 dd ?
	hBitmap3 dd ?

.code 
start: 
	 invoke GetModuleHandle, NULL 
	 mov    hInstance,eax 
	 invoke GetCommandLine 
	 invoke PlaySound,offset sound,NULL,SND_ASYNC
	 mov    CommandLine,eax 
	 invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
	 invoke ExitProcess,eax

	WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
	 LOCAL wc:WNDCLASSEX 
	 LOCAL msg:MSG 
	 mov   wc.cbSize,SIZEOF WNDCLASSEX 
	 mov   wc.style, CS_HREDRAW or CS_VREDRAW 
	 mov   wc.lpfnWndProc, OFFSET WndProc 
	 mov   wc.cbClsExtra,NULL 
	 mov   wc.cbWndExtra,NULL 
	 push  hInstance 
	 pop   wc.hInstance 
	 mov   wc.hbrBackground,COLOR_WINDOW+1 
	 mov   wc.lpszMenuName,NULL 
	 mov   wc.lpszClassName,OFFSET ClassName 
	 invoke LoadIcon,NULL,IDI_APPLICATION 
	 mov   wc.hIcon,eax 
	 mov   wc.hIconSm,eax 
	 invoke LoadCursor,NULL,IDC_ARROW 
	 mov   wc.hCursor,eax 
	 invoke RegisterClassEx, addr wc 
	 INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
			   WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
			   CW_USEDEFAULT,wparam,lparam,NULL,NULL,\ 
			   hInst,NULL 
	 mov   hwnd,eax 
	 invoke ShowWindow, hwnd,SW_SHOWNORMAL 
	 invoke UpdateWindow, hwnd 
	 .while TRUE 
	  invoke GetMessage, ADDR msg,NULL,0,0 
	  .break .if (!eax) 
	  invoke TranslateMessage, ADDR msg 
	  invoke DispatchMessage, ADDR msg 
	 .endw 
	 mov     eax,msg.wParam 
	 ret 
	WinMain endp

	WndProc proc hWnd:HWND, uMsg:UINT, wParam, lParam
	   LOCAL ps:PAINTSTRUCT 
	   LOCAL hdc:HDC 
	   LOCAL hMemDC:HDC 
	   LOCAL rect:RECT 
	   .if uMsg==WM_CREATE 

		  ; create background
		  invoke LoadBitmap,hInstance,IDB_MAIN 
		  mov hBitmap,eax 

		  ; create mario
		  invoke LoadBitmap,hInstance,IDB_MARIO
		  mov hBitmap2,eax 

		  ; create mashroom
		  invoke LoadBitmap,hInstance,IDB_MASHROOM
		  mov hBitmap3,eax 
	   .elseif uMsg==WM_PAINT 
		  invoke BeginPaint,hWnd,addr ps 
		  mov    hdc,eax 
		  ; paint background
		  invoke CreateCompatibleDC,hdc 
		  mov    hMemDC,eax 
		  invoke SelectObject,hMemDC,hBitmap 
		  invoke GetClientRect,hWnd,addr rect 
		  invoke BitBlt,hdc,0,0,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
		  invoke DeleteDC,hMemDC 

		  ; paint mashroom
		  invoke CreateCompatibleDC,hdc 
		  mov    hMemDC,eax 
		  invoke SelectObject,hMemDC,hBitmap3
		  invoke GetClientRect,hWnd,addr rect 
		  invoke BitBlt,hdc,300,300,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
		  invoke DeleteDC,hMemDC

		  ; paint mario
		  invoke CreateCompatibleDC,hdc 
		  mov    hMemDC,eax 
		  invoke SelectObject,hMemDC,hBitmap2 
		  invoke GetClientRect,hWnd,addr rect 
		  invoke BitBlt,hdc,moveToX,moveToY,rect.right,rect.bottom,hMemDC,0,0,SRCCOPY 
		  invoke DeleteDC,hMemDC 

		  invoke EndPaint,hWnd,addr ps 

		.elseif uMsg==WM_KEYDOWN
			.IF moveToX==200
				.IF moveToY<=300
				invoke MessageBox, NULL, addr MsgBoxTextWin, addr MsgBoxCaptionWin, MB_OK
				invoke ExitProcess, NULL ; exit to operating system
				.ENDIF
			.ENDIF

			.IF wParam == VK_UP		;## UP
			SUB moveToY, 10
			invoke InvalidateRect,hwnd,NULL,TRUE
			invoke UpdateWindow,hwnd

			.ELSEIF wParam == VK_DOWN   	;## Down
			ADD moveToY, 10
			invoke InvalidateRect,hwnd,NULL,TRUE
			invoke UpdateWindow,hwnd

			.ELSEIF wParam == VK_RIGHT   	;## Right
			ADD moveToX, 10
			invoke InvalidateRect,hwnd,NULL,TRUE
			invoke UpdateWindow,hwnd

			.ELSEIF wParam == VK_LEFT       ;## Left
			SUB moveToX, 10
			invoke InvalidateRect,hwnd,NULL,TRUE
			invoke UpdateWindow,hwnd
			.ELSEIF wParam == VK_E
			invoke MessageBox, NULL, addr MsgBoxText, addr MsgBoxCaption, MB_OK
			invoke ExitProcess, NULL ; exit to operating system
			.ENDIF 
	 .elseif uMsg==WM_DESTROY 
	  invoke DeleteObject,hBitmap 
	  invoke PostQuitMessage,NULL 
	 .ELSE 
	  invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
	  ret 
	 .ENDIF 
	 xor eax,eax 
	 ret 
	WndProc endp 
end start