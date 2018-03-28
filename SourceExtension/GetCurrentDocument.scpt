on appIsRunning(appName)
tell application "System Events" to (name of processes) contains appName
end appIsRunning
if appIsRunning("Xcode") then
tell application "Xcode"
if count of documents > 0 then
get path of first document
-- get active workspace document
end if
end tell
end if
