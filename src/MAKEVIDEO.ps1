$startDir = pwd
$tempDir = "temp"
$ffmpegPath = "$startDir\bin\ffmpeg.exe"
$timeDir = (Get-Date).ToString('yyyyMMdd_hhmmss')
$workingDir = "$startDir\$tempDir\$timeDir"
$outputPath = "$workingDir\slideshow.mp4"
$categoryDirs = Get-ChildItem ".\source" -directory | Sort-Object -Property "Name"
$imgCount = 0;

if (Test-Path -Path $tempDir) {
    Write-Output "/$tempDir/ already exists";
} else {
    $eatIt = New-Item -Path . -Name $tempDir -ItemType "directory"
    Write-Output "/$tempDir/ was created";
}

$eatIt = New-Item -Path ".\$tempDir" -Name $timeDir -ItemType "directory";
$imgDir = (New-Item -Path $workingDir -Name "images" -ItemType "directory").FullName

foreach ($categoryDir in $categoryDirs) {
    $categoryPhotos = Get-ChildItem $categoryDir.FullName | Sort-Object -Property "Name"

    foreach ($categoryPhoto in $categoryPhotos) {
        $imgNum = '{0:d4}' -f $imgCount
        $newFilename = "src$imgNum.jpg"
        
        Copy-Item -Path $categoryPhoto.FullName -Destination "$imgDir\$newFilename"

        $imgCount = $imgCount + 1;
    }
}

cd $imgDir

iex "& `"$ffmpegPath`" -f image2 -framerate 1/4 -pattern_type sequence -i src%04d.jpg -vf `"scale=720:480:force_original_aspect_ratio=decrease,pad=720:480:(ow-iw)/2:(oh-ih)/2`" -s:v 720x480 -c:v libx264 `"$outputPath`""

cd $startDir