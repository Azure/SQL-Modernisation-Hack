
$folder= 'LABS'
$documents_path= (Join-Path $CurrentDir $folder)

$word_app = New-Object -ComObject Word.Application

Get-ChildItem -Path $documents_path -Filter *.docx -Recurse| ForEach-Object {

    $document = $word_app.Documents.Open($_.FullName)

    $pdf_filename = "$($_.DirectoryName)\$($_.BaseName).pdf"

    $document.SaveAs([ref] $pdf_filename, [ref] 17)
    Write-host "$pdf_filename converted from docx"
    $document.Close()
}

$word_app.Quit()