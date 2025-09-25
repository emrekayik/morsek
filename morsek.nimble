# Package

version       = "0.1.0"
author        = "emrekayik"
description   = "Morse Network Protocol - High-performance Morse code encoding and network transmission"
license       = "MIT"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["morsek"]
binDir        = "bin"
skipDirs      = @["tests", "docs", ".github", "htmldocs", "build", "bin"]

# Dependencies
requires "nim >= 2.2.4"

# Tasks
task docs, "Generate documentation":
  exec "nim doc --project --index:on --git.url:https://github.com/emrekayik/morsek --git.commit:main src/morsek.nim"

task clean, "Clean build artifacts":
  when defined(windows):
    exec "if exist nimcache rmdir /s /q nimcache"
    exec "if exist htmldocs rmdir /s /q htmldocs"
    exec "if exist bin rmdir /s /q bin"
    exec "if exist build rmdir /s /q build"
    exec "if exist morsek.exe del morsek.exe"
  else:
    exec "rm -rf nimcache htmldocs bin build morsek morsek.exe"

task build_release, "Build optimized release":
  exec "nimble build -d:release"
