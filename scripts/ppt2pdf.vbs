Sub ConvertToPDF(ppt, inputpath, outputpath)
   Dim presentation
   Dim printoptions

   ppt.Presentations.Open inputpath

   set presentation = ppt.ActivePresentation
   set printoptions = presentation.PrintOptions

   printoptions.Ranges.Add 1,presentation.Slides.Count
   printoptions.RangeType = 1 ' Show all.

   const ppFixedFormatTypePDF = 2
   const ppFixedFormatIntentScreen = 1
   const msoFalse = 0
   const msoTrue = -1
   const ppPrintHandoutHorizontalFirst = 2
   const ppPrintOutputSlides = 1
   const ppPrintAll = 1

   presentation.ExportAsFixedFormat outputpath, ppFixedFormatTypePDF, ppFixedFormatIntentScreen, msoTrue, ppPrintHandoutHorizontalFirst, ppPrintOutputSlides, msoFalse, printoptions.Ranges(1), ppPrintAll, inputFile, False, False, False, False, False

   presentation.Close
End Sub

Function GetOutputPath(inputPath, extension)
   Dim file
   Dim basename
   Dim foldername
   
   basename = FSO.GetBaseName( inputPath )
   set file = FSO.GetFile( inputPath )
   foldername = file.ParentFolder
   GetOutputPath = foldername & "\" & basename & extension
End Function

On Error Resume Next
Const ppExportFormatPDF = 17
Set ppt = WScript.CreateObject("PowerPoint.Application")
Set fso = WScript.CreateObject("Scripting.Filesystemobject")
Set fds=fso.GetFolder(".")
Set ffs=fds.Files
For Each ff In ffs
    If (LCase(Right(ff.Name,4))=".ppt" Or LCase(Right(ff.Name,4))="pptx" ) And Left(ff.Name,1)<>"~" Then
        outputpath = GetOutputPath( ff.Path, ".pdf" )
        ConvertToPDF ppt, ff.path, outputpath
        If Err.Number Then
            MsgBox Err.Description
        End If
    End If
    Next

ppt.Quit
Set ppt =Nothing
MsgBox "all ppt converted to pdf !!"
