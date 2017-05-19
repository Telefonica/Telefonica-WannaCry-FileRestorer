function restore{
    param(
       [parameter(Mandatory=$true)]  
       [string] $path 
    )
    
    
    echo $path
    Get-Childitem $path -include *.WNCRYT -recurse -force | 
    Foreach-Object {
        $name = $_.FullName
        echo "$name"
        
        $bytes = gc -en byte -TotalCount 600 $name | % { '{0:X2}' -f $_ } 
        $b = ""

        for($i=0; $i -le 100; $i++)
        {
            $b += $bytes[$i]
        }
        
        for($i=0; $i -lt $known.Length; $i++)
        {       
            $file_docx=$false   
            $file_xlsx=$false
            $file_pptx=$false  
        
            if ($b.contains($known[$i].header)){
                echo "Header Detection: "$known[$i].extension
                $newFile = $name + "." + $known[$i].extension 
                mv $name $newFile
                
                 
                 if ($known[$i].extension -eq "doc"){ 
                        $doc = $newFile + ".doc"

                        cp $newFile $doc

                        $xls = $newFile + ".xls"

                        cp $newfile $xls

                        $ppt = $newFile + ".ppt"

                        cp $newfile $ppt
                        break
                 } 
                 
                 if ($known[$i].extension -eq "Zip"){   

                        cat $newFile | findstr "word/_rels/document.xml.rels" | Out-Null
                        if ($?) {$file_docx=$true}
                        
                        cat $newFile | findstr "xl/worksheets" | Out-Null
                        if ($?) {$file_xlsx=$true}
                        
                        cat $newFile | findstr "ppt/_rels/presentation.xml.rels" | Out-Null
                        if ($?) {$file_pptx=$true}
                                                    
                        if ($file_docx){
                            $docx = $newFile + ".docx"
                            mv $newFile $docx
                        }
                        
                        if ($file_xlsx){
                            $xlsx = $newFile + ".xlsx"
                            mv $newFile $xlsx
                        }
                        
                        if ($file_pptx) {         
                            $pptx = $newFile + ".pptx"
                            mv $newFile $pptx      
                        }  
                        break
                 }
            } 
        }    
    }
}




$known = @'
"Extension","Header"
"7z","377ABCAF271C"
"djvu","41542654464F524Dnnnnnnnn444A56"
"doc","D0CF11E0A1B11AE1"
"dpx","53445058"
"jpg","4A464946"
"pdf","25504446"
"png","89504E470D0A1A0A"
"ps","25215053"
"psd","38425053"
"rar","526172211A0700"
"rar","526172211A070100"
"tif","49492A00"
"vsdx","504B0708"
"wav","52494646nnnnnnnn"
"wma","A6D900AA0062CE6C"
"zip","504B0304"
"epub","504B03040A000200"
"ppt","D0CF11E0A1B11AE1"
"rtf","7B5C72746631"
"xls","D0CF11E0A1B11AE1"
"bmp","424D"
"txt",""
'@ | ConvertFrom-Csv | sort {$_.header.length} -Descending

echo "Telefonica Wannacry File Restorer Alpha v.0.1"
echo "============================================="


for($i=0; $i -lt $known.Length; $i++)
{
    ($known[$i].header).replace(" ","") | Out-Null
}

$strComputer = "."
$colDisks = Get-WmiObject -Class Win32_LogicalDisk -ComputerName $strComputer 

foreach ($objDisk in $colDisks)
{
    if ($objDisk.DriveType -eq 3) 
    {
        $finalPath = $objDisk.deviceID 
        #
        if ($finalPath -eq "C:")
        {
            $path = $env:LOCALAPPDATA+"\temp"
        }
        else
        {
             $path = "$finalPath\$RECYCLE"
        }
        restore -path $path

    }
}

exit
