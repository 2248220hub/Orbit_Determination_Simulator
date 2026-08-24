@echo off
setlocal enabledelayedexpansion
REM ============================================================================
REM  OD Console V2  -  one-click publish to GitHub + GitHub Pages
REM
REM  Publishes this folder as its own repository:
REM      OD_Simulator_V2.html  ->  index.html   (what Pages serves)
REM      README.md             ->  repo home page
REM      MATH.md               ->  mathematical reference
REM      LICENSE, .gitignore, push.bat
REM
REM  Usage:   push.bat                       (interactive, asks for the details)
REM           push.bat <repo-url>            (non-interactive)
REM           push.bat <repo-url> "message"  (custom commit message)
REM ============================================================================
cd /d "%~dp0"
title OD Console V2 - GitHub Publisher

set "HTML=OD_Simulator_V2.html"
set "DEFUSER=2248220hub"
set "DEFREPO=Orbit_Determination_Simulator"

echo.
echo  ==========================================================
echo    OD CONSOLE V2  -  GitHub publisher
echo  ==========================================================
echo.

REM --- 1. preflight checks ---------------------------------------------------
where git >nul 2>nul
if errorlevel 1 (
  echo  [ERROR] Git is not installed or not on PATH.
  echo          Get it from https://git-scm.com/download/win  then re-run.
  goto :fail
)
if not exist "%HTML%" (
  echo  [ERROR] %HTML% not found in this folder:
  echo          %CD%
  echo          Run this .bat from the folder that contains the simulator.
  goto :fail
)
if not exist "README.md" echo  [WARN] README.md missing - the repo home page will be empty.
if not exist "MATH.md"   echo  [WARN] MATH.md missing - the deep-dive link will be broken.

REM --- 2. work out the repository URL ---------------------------------------
set "REPO=%~1"
if not "%REPO%"=="" goto :haveurl

echo  This publishes to a NEW repository. Create an EMPTY one first
echo  ^(no README, no .gitignore, no licence^) at:
echo.
echo      https://github.com/new
echo.
set "GHUSER=%DEFUSER%"
set /p GHUSER=  GitHub username [%DEFUSER%]:
if "!GHUSER!"=="" set "GHUSER=%DEFUSER%"
set "GHREPO=%DEFREPO%"
set /p GHREPO=  Repository name  [%DEFREPO%]:
if "!GHREPO!"=="" set "GHREPO=%DEFREPO%"
set "REPO=https://github.com/!GHUSER!/!GHREPO!.git"

REM --- optional: create the repo automatically if the GitHub CLI is present --
where gh >nul 2>nul
if not errorlevel 1 (
  echo.
  set "MAKE=n"
  set /p MAKE=  GitHub CLI found. Create !GHREPO! on GitHub now? [y/N]:
  if /i "!MAKE!"=="y" (
    echo  ... creating public repository !GHUSER!/!GHREPO!
    gh repo create "!GHUSER!/!GHREPO!" --public --description "Interactive orbit determination simulator - 60 range/range-rate observables, 7 estimators, batch and sequential" >nul 2>nul
    if errorlevel 1 echo  [WARN] gh could not create it ^(it may already exist^) - continuing anyway.
  )
)

:haveurl
if "%REPO%"=="" (
  echo  [ERROR] No repository URL given.
  goto :fail
)
echo %REPO%| findstr /b /i "http git@" >nul
if errorlevel 1 (
  echo  [ERROR] That does not look like a repository URL:
  echo            %REPO%
  echo          Expected  https://github.com/user/repo.git
  goto :fail
)

set "MSG=%~2"
if "%MSG%"=="" set "MSG=Publish OD Console V2 - range and range-rate orbit determination"

echo.
echo  ----------------------------------------------------------
echo    Folder : %CD%
echo    Remote : %REPO%
echo    Commit : %MSG%
echo  ----------------------------------------------------------
echo.
set "GO=y"
set /p GO=  Push to GitHub now? [Y/n]:
if /i "!GO!"=="n" ( echo  Cancelled - nothing was pushed. & goto :done )

REM --- 3. build the page GitHub Pages will serve -----------------------------
echo.
echo  [1/6] Copying %HTML%  -^>  index.html
copy /y "%HTML%" "index.html" >nul
if errorlevel 1 ( echo  [ERROR] Could not write index.html & goto :fail )

REM --- 4. keep stray local backups out of the repository ---------------------
echo  [2/6] Writing .gitignore
(
  echo # local working copies - never published
  echo *- Copy*.html
  echo *- Copy*.md
  echo *.bak
  echo *.tmp
  echo.
  echo # OS / editor noise
  echo Thumbs.db
  echo desktop.ini
  echo .DS_Store
  echo .vscode/
  echo .idea/
) > .gitignore

REM --- 5. init / stage / commit ---------------------------------------------
if not exist ".git" (
  echo  [3/6] Initialising a new git repository
  git init -q
  if errorlevel 1 ( echo  [ERROR] git init failed & goto :fail )
) else (
  echo  [3/6] Existing git repository found - reusing it
)

echo  [4/6] Staging and committing
git add .gitignore "%HTML%" index.html README.md MATH.md LICENSE push.bat >nul 2>nul
git commit -q -m "%MSG%" >nul 2>nul
if errorlevel 1 echo        ^(nothing new to commit - contents unchanged^)
git branch -M main >nul 2>nul

REM --- 6. remote + push ------------------------------------------------------
echo  [5/6] Pointing origin at %REPO%
git remote remove origin >nul 2>nul
git remote add origin "%REPO%"

echo  [6/6] Pushing to GitHub ^(you may be asked to sign in^)
echo.
git push -u origin main
if errorlevel 1 (
  echo.
  echo  ----------------------------------------------------------
  echo   [WARN] Push was rejected. The usual causes:
  echo.
  echo    * The repository does not exist yet
  echo      -^> create an EMPTY one at https://github.com/new
  echo.
  echo    * The repository already has commits
  echo      -^> git pull --rebase origin main    then re-run this file
  echo.
  echo    * Sign-in failed
  echo      -^> use a Personal Access Token as the password,
  echo         or install GitHub CLI and run:  gh auth login
  echo  ----------------------------------------------------------
  goto :fail
)

REM --- 7. try to switch Pages on automatically -------------------------------
for /f "tokens=4,5 delims=/." %%a in ("%REPO%") do ( set "U=%%a" & set "N=%%b" )
where gh >nul 2>nul
if not errorlevel 1 (
  echo.
  echo  ... asking GitHub to enable Pages on main / root
  gh api -X POST "repos/!U!/!N!/pages" -f "source[branch]=main" -f "source[path]=/" >nul 2>nul
  if errorlevel 1 (
    gh api -X PUT "repos/!U!/!N!/pages" -f "source[branch]=main" -f "source[path]=/" >nul 2>nul
  )
)

echo.
echo  ==========================================================
echo    PUSHED SUCCESSFULLY
echo  ==========================================================
echo.
echo    Repository :  https://github.com/!U!/!N!
echo    Live site  :  https://!U!.github.io/!N!/
echo.
echo    If the live link 404s, enable Pages once by hand:
echo      Settings  -^>  Pages  -^>  Source: "Deploy from a branch"
echo      Branch: main    Folder: / ^(root^)    -^>  Save
echo    It goes live about a minute later.
echo.
echo  ==========================================================
goto :done

:fail
echo.
echo  Publish aborted.
pause
endlocal
exit /b 1

:done
echo.
pause
endlocal
exit /b 0
