--[[
	
    Description:
	
        Normalize From header by replacing URI host portion with what is sent in metadata for "x-nearendaddr" tag.  
		This matches the phone's actual extension and facilitates Libra call recording that currently looks at URI host portion only.
		
	Notes:
	
		Addresses recording issues of mismatched host portion in forwarded, transferred and other mid-call re-INVITE type scenarios.
		Addresses recording issues with E.164 numbers being sent to libra for PSTN calls instead of internal extension.

    Exceptions:
	
		None
	
	Future development:
	
		None
	
--]] 
 
 M = {}
 trace.enable()
 
 function M.outbound_ANY(msg)
	
	 -- Get "From" header
    local from = msg:getHeader("From")
	
	 -- Fetch x-nearendaddr and modify uri host portion of From header
	local nearendaddr = string.match(from, "x-nearendaddr=(%d+);")
	local newFrom = string.gsub(from, "<sip:.*@", "<sip:" .. nearendaddr .. "@")
	
	 -- Update From Header with nearendaddr as URI host portion
	msg:modifyHeader("From", newFrom)

 end
 
 return M
