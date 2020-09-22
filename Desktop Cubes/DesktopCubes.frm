VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Raindrop Desktop"
   ClientHeight    =   1875
   ClientLeft      =   45
   ClientTop       =   210
   ClientWidth     =   3030
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   125
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   202
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin VB.Label Label1 
      Caption         =   "Use ESC to exit or close the window .  Dont use ""end"" in VB"
      Height          =   900
      Left            =   90
      TabIndex        =   0
      Top             =   135
      Width           =   2820
      WordWrap        =   -1  'True
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'**********************************
'Submitted by ChiriSoft
'chirisoft@flashmail.com
'**********************************
'the program basically uses a temporary buffer to copy a portion of
'screen(32x32'in this case) an then paste it back shifting it slightly from
'the original position in the process
'try experimenting with different values of dx and dy

Option Explicit
Private Declare Function GetWindowDC Lib "user32" (ByVal hwnd As Long) As Long
Private Declare Function GetDesktopWindow Lib "user32" () As Long
Private Declare Function CreateCompatibleBitmap Lib "gdi32" (ByVal hdc As Long, ByVal nWidth As Long, ByVal nHeight As Long) As Long
Private Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hdc As Long) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hdc As Long, ByVal hObject As Long) As Long
Private Declare Function BitBlt Lib "gdi32" (ByVal hDestDC As Long, ByVal x As Long, ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, ByVal dwRop As Long) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long
Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)
Private Const SRCCOPY = &HCC0020 ' (DWORD) dest = source

Dim x As Integer, y As Integer, dx As Integer, dy As Integer
Dim Buffer As Long, BitmapDC As Long, Desktop As Long, ScreenDC As Long, ScreenBuffer As Long
Dim Enable As Boolean

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
If KeyCode = vbKeyEscape Then
Enable = False
Unload Me
End If
End Sub

Private Sub Form_Load()

dx = 10
dy = 8

'To get the device context for the desktop(whole screen)
Desktop = GetWindowDC(GetDesktopWindow())

'to create a device context compatible with a known device context
'and assign it to a long variable
BitmapDC = CreateCompatibleDC(Desktop)
ScreenDC = CreateCompatibleDC(Desktop)

'to create bitmaps in memory for temporary storage compatible with a known bitmap
Buffer = CreateCompatibleBitmap(Desktop, 32, 32)
ScreenBuffer = CreateCompatibleBitmap(Desktop, Screen.Width / 15, Screen.Height / 15)

'assign device contexts to the bitmaps
SelectObject BitmapDC, Buffer
SelectObject ScreenDC, ScreenBuffer

'save the screen for later restoration
BitBlt ScreenDC, 0, 0, Screen.Width / 15, Screen.Height / 15, Desktop, 0, 0, SRCCOPY

Me.Show

Enable = True

Timer

End Sub


Private Sub Form_Unload(Cancel As Integer)
'restores the desktop to the saved picture when program ends
'try to comment out following line and see what happens
BitBlt Desktop, 0, 0, Screen.Width / 15, Screen.Height / 15, ScreenDC, 0, 0, SRCCOPY

'deletes the buffers and free memory
DeleteObject Buffer
DeleteObject ScreenBuffer
DeleteObject BitmapDC
DeleteObject ScreenDC
End Sub

Private Sub Timer()

Do While Enable = True

'copy 32x32 portion of screen into buffer at x,y
BitBlt BitmapDC, 0, 0, 32, 32, Desktop, x, y, SRCCOPY
'paste back changing values of x and y
BitBlt Desktop, x + dx, y - dy, 32, 32, BitmapDC, 0, 0, SRCCOPY

x = x + dx
y = y + dy


' To make sure that x and y dont go outside the visible screen
If (x + 34 >= Screen.Width / 15) Or x <= 1 Then
dx = -dx
End If
If (y + 35 >= Screen.Height / 15) Or y <= 1 Then
dy = -dy
End If
DoEvents

'pause for 1 millisecond
Sleep (1)

Loop

End Sub
