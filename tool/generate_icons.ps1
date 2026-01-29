Add-Type -AssemblyName System.Drawing

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
if (-not (Test-Path "$projectRoot\pubspec.yaml")) {
    $projectRoot = Split-Path -Parent $PSScriptRoot
    if (-not (Test-Path "$projectRoot\pubspec.yaml")) {
        $projectRoot = $PSScriptRoot
    }
}

$sourceImage = Join-Path $projectRoot "assets\images\logo.png"
if (-not (Test-Path $sourceImage)) {
    $sourceImage = Join-Path $projectRoot "baktoob icon2@300x.png"
}

Write-Host "Source image: $sourceImage"
Write-Host "Project root: $projectRoot"

if (-not (Test-Path $sourceImage)) {
    Write-Host "ERROR: Source image not found!" -ForegroundColor Red
    exit 1
}

function Resize-Image {
    param(
        [string]$SourcePath,
        [string]$OutputPath,
        [int]$Width,
        [int]$Height
    )

    $src = [System.Drawing.Image]::FromFile($SourcePath)
    $dst = New-Object System.Drawing.Bitmap($Width, $Height)
    $graphics = [System.Drawing.Graphics]::FromImage($dst)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.DrawImage($src, 0, 0, $Width, $Height)

    $outputDir = Split-Path -Parent $OutputPath
    if (-not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    $dst.Save($OutputPath, [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $dst.Dispose()
    $src.Dispose()

    Write-Host "  Generated: $OutputPath ($Width x $Height)"
}

# ========== ANDROID ICONS ==========
Write-Host "`n=== Android Icons ===" -ForegroundColor Cyan

$androidRes = Join-Path $projectRoot "android\app\src\main\res"

$androidIcons = @(
    @{ Dir = "mipmap-mdpi";    Size = 48  },
    @{ Dir = "mipmap-hdpi";    Size = 72  },
    @{ Dir = "mipmap-xhdpi";   Size = 96  },
    @{ Dir = "mipmap-xxhdpi";  Size = 144 },
    @{ Dir = "mipmap-xxxhdpi"; Size = 192 }
)

foreach ($icon in $androidIcons) {
    $outputPath = Join-Path $androidRes "$($icon.Dir)\ic_launcher.png"
    Resize-Image -SourcePath $sourceImage -OutputPath $outputPath -Width $icon.Size -Height $icon.Size
}

# ========== iOS ICONS ==========
Write-Host "`n=== iOS Icons ===" -ForegroundColor Cyan

$iosIconDir = Join-Path $projectRoot "ios\Runner\Assets.xcassets\AppIcon.appiconset"

$iosIcons = @(
    @{ Name = "Icon-App-20x20@1x.png";       Size = 20   },
    @{ Name = "Icon-App-20x20@2x.png";       Size = 40   },
    @{ Name = "Icon-App-20x20@3x.png";       Size = 60   },
    @{ Name = "Icon-App-29x29@1x.png";       Size = 29   },
    @{ Name = "Icon-App-29x29@2x.png";       Size = 58   },
    @{ Name = "Icon-App-29x29@3x.png";       Size = 87   },
    @{ Name = "Icon-App-40x40@1x.png";       Size = 40   },
    @{ Name = "Icon-App-40x40@2x.png";       Size = 80   },
    @{ Name = "Icon-App-40x40@3x.png";       Size = 120  },
    @{ Name = "Icon-App-60x60@2x.png";       Size = 120  },
    @{ Name = "Icon-App-60x60@3x.png";       Size = 180  },
    @{ Name = "Icon-App-76x76@1x.png";       Size = 76   },
    @{ Name = "Icon-App-76x76@2x.png";       Size = 152  },
    @{ Name = "Icon-App-83.5x83.5@2x.png";   Size = 167  },
    @{ Name = "Icon-App-1024x1024@1x.png";   Size = 1024 }
)

foreach ($icon in $iosIcons) {
    $outputPath = Join-Path $iosIconDir $icon.Name
    Resize-Image -SourcePath $sourceImage -OutputPath $outputPath -Width $icon.Size -Height $icon.Size
}

# ========== WEB ICONS ==========
Write-Host "`n=== Web Icons ===" -ForegroundColor Cyan

$webIconDir = Join-Path $projectRoot "web\icons"

$webIcons = @(
    @{ Name = "Icon-192.png";          Size = 192 },
    @{ Name = "Icon-512.png";          Size = 512 },
    @{ Name = "Icon-maskable-192.png"; Size = 192 },
    @{ Name = "Icon-maskable-512.png"; Size = 512 }
)

foreach ($icon in $webIcons) {
    $outputPath = Join-Path $webIconDir $icon.Name
    Resize-Image -SourcePath $sourceImage -OutputPath $outputPath -Width $icon.Size -Height $icon.Size
}

# Web favicon
$faviconPath = Join-Path $projectRoot "web\favicon.png"
Resize-Image -SourcePath $sourceImage -OutputPath $faviconPath -Width 32 -Height 32

Write-Host "`n=== Done! All icons generated. ===" -ForegroundColor Green
