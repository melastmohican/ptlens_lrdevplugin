--[[----------------------------------------------------------------------------

PTLens.lua
PTLens utility.

--------------------------------------------------------------------------------

Copyright (c) 2009 Mariusz S. Jurgielewicz 

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

------------------------------------------------------------------------------]]

local LrDialogs = import("LrDialogs")
local LrFileUtils = import("LrFileUtils")
local LrTasks = import "LrTasks"
local prefs = import("LrPrefs").prefsForPlugin()
local LrLogger = import("LrLogger")
local myLogger = LrLogger("PTLensLogger")
myLogger:enable("logfile")

--============================================================================--

PTLens = {}

-------------------------------------------------------------------------------
function PTLens.outputToLog(message)
  myLogger:trace(message)
end

-------------------------------------------------------------------------------
function PTLens.browseForPath()
	local selectedPathArray = {}
	local info = "If you have installed PTLens on your computer, click on 'Browse' to select it.\nIf you have not yet installed PTLens, please download it from www.hdrsoft.com."
	local result = LrDialogs.confirm("Could not find PTLens application", info, "Browse", "Cancel")
	if result == "cancel" then
	  return 
	end
	if MAC_ENV then
	  selectedPathArray = LrDialogs.runOpenPanel({title = "Browse to PTLens", prompt = "Select", canChooseFiles = true, canChooseDirectories = false, canCreateDirectories = false, allowsMultipleSelection = false})
	else
	  selectedPathArray = LrDialogs.runOpenPanel({title = "Browse to PTLens", prompt = "Select", canChooseFiles = true, canChooseDirectories = false, canCreateDirectories = false, allowsMultipleSelection = false, fileTypes = "exe"})
	end
	if selectedPathArray == nil then
	  return nil
	end
	return selectedPathArray[1]
end

-------------------------------------------------------------------------------
function PTLens.processPhoto(path)
	PTLens.outputToLog("PTLens.processPhoto --> photo: " .. path)
	local pathExist = false
	local appPath = prefs.ptlensPath
	if not LrFileUtils.exists(appPath) then
		PTLens.outputToLog("PTLens.processPhoto --> appPath does not exist")
		appPath = PTLens.browseForPath()
		PTLens.outputToLog("PTLens.processPhoto --> appPath: " .. appPath)
		prefs.ptlensPath = appPath
	end		
	local command
	local quotedCommand		
	if WIN_ENV == true then
			command = '"' .. appPath .. '" -q "' .. path .. '"'
			quotedCommand = '"' .. command .. '"'
	else
			command = '"' .. appPath .. '" -q "' .. path .. '"'
			quotedCommand = command   
	end		
	return LrTasks.execute(quotedCommand)
end

