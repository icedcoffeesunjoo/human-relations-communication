# 웹 강의록 빌드: src\*.md → docs\*.html (pandoc 필요)
# 실행: 이 폴더에서 pwsh -File build.ps1
$ErrorActionPreference = "Stop"
$script:cssv = (Get-Date -Format "yyyyMMddHHmmss")
$root = $PSScriptRoot
$src = Join-Path $root "src"
$out = Join-Path $root "docs"
[IO.Directory]::CreateDirectory((Join-Path $out "assets")) | Out-Null
[IO.File]::WriteAllText((Join-Path $out ".nojekyll"), "")
Get-ChildItem -LiteralPath (Join-Path $root "assets") -File |
  ForEach-Object { Copy-Item -LiteralPath $_.FullName -Destination (Join-Path $out "assets\$($_.Name)") -Force }

# 주차 목록 (강의계획서 순서). file이 src에 있으면 링크, 없으면 '준비 중'.
$weeks = @(
  @{ n = "2주";  g = 1; file = "week02"; t = "심리학적 유형과 자기이해"; s = "Jung의 심리학적 유형, Big Five, 자기이해" },
  @{ n = "3주";  g = 1; file = "week03"; t = "정서지능과 감정이해"; s = "감정인식과 정서조절" },
  @{ n = "4주";  g = 1; file = "week04"; t = "자의식적 감정의 이해"; s = "수치심, 죄책감, 자부심, 당혹감과 대인관계" },
  @{ n = "5주";  g = 2; file = "week05"; t = "마음이론과 관점수용"; s = "마음이론, 관점수용, 사회인지" },
  @{ n = "6주";  g = 2; file = "week06"; t = "정신화"; s = "정신화의 개념과 기능, 정신화 실패와 오해" },
  @{ n = "7주";  g = 2; file = "week07"; t = "사회인지와 귀인편향"; s = "귀인이론, 기본적 귀인 오류, 자기중심 편향, 확증편향" },
  @{ n = "9주";  g = 3; file = "week09"; t = "의사소통의 이해와 스타일"; s = "의사소통 과정, 언어·비언어 의사소통, 의사소통 유형" },
  @{ n = "10주"; g = 3; file = "week10"; t = "효과적인 의사소통 기술"; s = "적극적 경청, 질문하기, 피드백, 자기표현" },
  @{ n = "11·12주"; g = 3; file = "nvc"; t = "비폭력대화 특강"; s = "관찰-감정-욕구-부탁, 공감적 경청, 역할연습"; nolink = $true },
  @{ n = "13주"; g = 4; file = "week13"; t = "대인관계의 형성과 발달"; s = "애착이론, 사회침투이론, 신뢰와 친밀감" },
  @{ n = "14주"; g = 4; file = "week14"; t = "건강한 인간관계"; s = "심리적 경계, 자기존중과 상호존중, 건강한 관계 유지" }
)
$built = @($weeks | Where-Object { -not $_.nolink -and (Test-Path -LiteralPath (Join-Path $src "$($_.file).md")) })

function Invoke-Pandoc([string]$in, [string]$outFile, [string[]]$extra) {
  $pargs = @($in, "-f", "markdown", "-t", "html5", "--template", (Join-Path $root "template.html"),
             "--section-divs", "--lua-filter", (Join-Path $root "details.lua"), "-V", "cssv=$script:cssv", "-o", $outFile) + $extra
  & pandoc @pargs
  if ($LASTEXITCODE -ne 0) { throw "pandoc 실패: $in" }
}

# 주차별 페이지
for ($i = 0; $i -lt $built.Count; $i++) {
  $w = $built[$i]
  $extra = @("--toc", "--toc-depth=2")
  if ($i -gt 0) {
    $p = $built[$i - 1]
    $extra += @("-V", "prev=$($p.n) $($p.t)", "-V", "prev-href=$($p.file).html")
  } else {
    $extra += @("-V", "prev=표지", "-V", "prev-href=index.html")
  }
  if ($i -lt $built.Count - 1) {
    $q = $built[$i + 1]
    $extra += @("-V", "next=$($q.n) $($q.t)", "-V", "next-href=$($q.file).html")
  }
  Invoke-Pandoc (Join-Path $src "$($w.file).md") (Join-Path $out "$($w.file).html") $extra
  Write-Host "만듦: $($w.file).html"
}

# 표지: 단계별 주차 카드
$groups = @(
  @{ g = 1; t = "나를 이해하기"; s = "성격과 유형, 감정, 자의식적 감정" },
  @{ g = 2; t = "타인의 마음 읽기"; s = "마음이론, 정신화, 사회인지와 귀인" },
  @{ g = 3; t = "말하고 듣기"; s = "의사소통 스타일, 경청과 자기표현, 비폭력대화" },
  @{ g = 4; t = "관계 만들고 지키기"; s = "애착과 친밀감, 경계와 존중" }
)
$cards = foreach ($grp in $groups) {
  "<div class=""wgroup g$($grp.g)""><h3><i>$($grp.g)</i>$($grp.t)</h3><p>$($grp.s)</p><div class=""weeks"">"
  foreach ($w in ($weeks | Where-Object { $_.g -eq $grp.g })) {
    if (-not $w.nolink -and (Test-Path -LiteralPath (Join-Path $src "$($w.file).md"))) {
      "<a class=""card"" href=""$($w.file).html""><span class=""n"">$($w.n)</span><b>$($w.t)</b><span class=""s"">$($w.s)</span></a>"
    } elseif ($w.nolink) {
      "<div class=""card soon""><span class=""n"">$($w.n)</span><b>$($w.t)</b><span class=""s"">$($w.s)</span></div>"
    } else {
      "<div class=""card soon""><span class=""n"">$($w.n)</span><b>$($w.t)</b><span class=""s"">준비 중</span></div>"
    }
  }
  "</div></div>"
}$extra = @("-V", "weeks-html=$($cards -join "`n")")
if ($built.Count -gt 0) {
  $extra += @("-V", "next=$($built[0].n) $($built[0].t)", "-V", "next-href=$($built[0].file).html")
}
Invoke-Pandoc (Join-Path $src "index.md") (Join-Path $out "index.html") $extra
Write-Host "만듦: index.html"
