VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MSCOMCTL.OCX"
Object = "{9A143468-B450-48DD-930D-925078198E4D}#1.1#0"; "hexed.ocx"
Begin VB.Form frmMemSearchResults 
   Caption         =   "Memory Search Results"
   ClientHeight    =   8640
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   12885
   LinkTopic       =   "Form1"
   ScaleHeight     =   8640
   ScaleWidth      =   12885
   StartUpPosition =   2  'CenterScreen
   Begin rhexed.HexEd he 
      Height          =   8115
      Left            =   3150
      TabIndex        =   3
      Top             =   360
      Width           =   9600
      _ExtentX        =   16933
      _ExtentY        =   14314
   End
   Begin MSComctlLib.ListView lvAlloc 
      Height          =   3750
      Left            =   90
      TabIndex        =   1
      Top             =   315
      Width           =   2895
      _ExtentX        =   5106
      _ExtentY        =   6615
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   4
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Hits"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   1
         Text            =   "Base"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   2
         Text            =   "Size"
         Object.Width           =   2540
      EndProperty
      BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         SubItemIndex    =   3
         Text            =   "Protect"
         Object.Width           =   2540
      EndProperty
   End
   Begin MSComctlLib.ListView lvOffset 
      Height          =   4380
      Left            =   90
      TabIndex        =   2
      Top             =   4095
      Width           =   2895
      _ExtentX        =   5106
      _ExtentY        =   7726
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   -1  'True
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      NumItems        =   1
      BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
         Text            =   "Offset"
         Object.Width           =   2540
      EndProperty
   End
   Begin VB.Label Label1 
      Caption         =   "Allocation"
      Height          =   285
      Left            =   90
      TabIndex        =   0
      Top             =   90
      Width           =   1635
   End
End
Attribute VB_Name = "frmMemSearchResults"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim m_pid As Long
Dim selMem As CMemory
Dim pi As New CProcessInfo
Dim dumpFile As String

'lvAlloc: hits,base,size,protect

Sub LoadSearchResults(pid As Long, c As Collection)   'of CMemory with searchoffsetcsv field filled in
    Dim li As ListItem
    Dim m As CMemory
    
    m_pid = pid
    lvAlloc.ListItems.Clear
    dumpFile = fso.GetFreeFileName(Environ("temp"), ".bin")
    
    For Each m In c
        Set li = lvAlloc.ListItems.Add()
        Set li.Tag = m
        li.Text = CountOccurances(m.SearchOffsetCSV, ",") + 1
        li.SubItems(1) = m.BaseAsHexString
        li.SubItems(2) = Hex(m.size)
        li.SubItems(3) = m.ProtectionAsString
    Next
    
    Me.Visible = True
    
End Sub

Private Sub lvAlloc_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
    LV_ColumnSort lvAlloc, ColumnHeader
End Sub

Private Sub lvAlloc_ItemClick(ByVal Item As MSComctlLib.ListItem)
    
    On Error Resume Next
    
    Set selMem = Item.Tag
    lvOffset.ListItems.Clear
    
    If fso.FileExists(dumpFile) Then fso.DeleteFile dumpFile
    If pi.DumpMemory(m_pid, selMem.BaseAsHexString, Hex(selMem.size), dumpFile) Then
        he.LoadFile dumpFile
    Else
        he.LoadString "Failed to dump memory?"
    End If
    
    Dim tmp() As String, t
    tmp = Split(selMem.SearchOffsetCSV, ",")
    
    For Each t In tmp
        If Len(t) > 0 Then lvOffset.ListItems.Add , , Hex(t)
    Next
    
    lvOffset.ListItems(1).Selected = True
    lvOffset_ItemClick lvOffset.ListItems(1)
    
End Sub

Private Sub lvOffset_ItemClick(ByVal Item As MSComctlLib.ListItem)
    
    On Error Resume Next
    
    Dim o As Long
    o = CLng("&h" & Item.Text)
    he.scrollTo o
    
End Sub
