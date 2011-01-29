--[[----------------------------------------------------------------------------

PTLensExportServiceProvider.lua
Export service provider for PTLens.

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

local prefs = import("LrPrefs").prefsForPlugin()
local LrLogger = import("LrLogger")
local myLogger = LrLogger("PTLensLogger")
myLogger:enable("logfile")

--============================================================================--
local PTLensExportServiceProvider = {}

-------------------------------------------------------------------------------
PTLensExportServiceProvider.exportPresetFields = {
	{ key = 'creatorName',	 default = 'Lightroom'},
	{ key = 'metachoice', 	 default = 'Title' 	},
	{ key = 'metavalue', 	 default = '' 		},
}

-------------------------------------------------------------------------------
function PTLensExportServiceProvider.outputToLog(message)
  myLogger:trace(message)
end

-------------------------------------------------------------------------------
function PTLensExportServiceProvider.processRenderedPhotos( functionContext, exportContext )
	PTLensExportServiceProvider.outputToLog("PTLensExportServiceProvider.processRenderedPhotos")
	local progressScope = exportContext:configureProgress({title = LOC("$$$/PTLens/Upload/Progress/One=Exporting to PTLens")})
	for i, rendition in exportContext:renditions({ stopIfCanceled = true }) do	
		-- Wait for the upstream task to finish its work on this photo.		
		local success, pathOrMessage = rendition:waitForRender()	
		-- Check for cancellation again after photo has been rendered.		
		if progressScope:isCanceled() then break end
		if success then		
			local path = rendition.destinationPath
			require("PTLens")
			if PTLens.processPhoto(path) ~= 0 then
				rendition:renditionIsDone( false, "Failed to contact PTLens Application")
			end
		end	
	end
end

-------------------------------------------------------------------------------
return PTLensExportServiceProvider
