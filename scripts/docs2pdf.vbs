' 将此文件放置在一个文件夹中，双击即可将当前文件夹中的所有.doc .docx转换为pdf
' 应该不适用于 wps

On Error Resume Next
Const wdExportFormatPDF = 17
Set oWord = WScript.CreateObject("Word.Application")
Set fso = WScript.CreateObject("Scripting.Filesystemobject")
Set fds=fso.GetFolder(".")
Set ffs=fds.Files
For Each ff In ffs
    If (LCase(Right(ff.Name,4))=".doc" Or LCase(Right(ff.Name,4))="docx" ) And Left(ff.Name,1)<>"~" Then
        Set oDoc=oWord.Documents.Open(ff.Path)
        odoc.ExportAsFixedFormat Left(ff.Path,InStrRev(ff.Path,"."))&"pdf",wdExportFormatPDF
        If Err.Number Then
            MsgBox Err.Description
        End If
    End If
Next
odoc.Close
oword.Quit
Set oDoc=Nothing
Set oWord =Nothing
MsgBox "finished!!"
