--[[
    
    Author : Jonathan Els
    Version : 1.0

    Description:
    
        Workaround for defect in Libra Recorder CTI Matching ignoring recording headers 
        (.e.g. x-nearendaddr and x-farendaddr), which contain the exact DNs required for matching purposes.  
        From/RURI may (correctly) contain mis-matches in the event of calling party normalization as part of standard 
        E.164 dial plans.

        Normalize From header by replacing URI host portion with what is sent in metadata for "x-nearendaddr" tag.  
        Matches the phone's actual extension and facilitates Libra call recording that currently looks at URI host portion only.
        
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
