--[[

    Author : Jonathan Els
    Version : 1.0
    
    Description:
    
    Script for separate handling of MWI to accommodate proxied partitions for centralized voicemail designs with SME
    e.g. with Proxied Manager/Secretary configurations.

    Script strips initial chars to add a prefix for custom routing - via script params configured on CUCM
    
    Future development:
    
        - Add checks specifically limit to MWI scenarios only.  Possibly match on Content (message-waiting etc.)
          or source address.

--]]


M={}

trace.disable()

function M.inbound_NOTIFY(msg)

    
    local prefix = scriptParameters.getValue("prefix")
    -- prefix = "**"
    
    -- Modify RURI header
    local m,r,v = msg:getRequestLine()
    trace.format("Original Request URI - %s", r)
    -- Strip "0" and add custom prefix
    r=string.gsub (r,"sip%:0(%d+)@", "sip:" .. prefix .. "%1@")
    msg:setRequestUri (r )
    trace.format("Modified Request URI - %s", r)
    
    -- Modify To header
    local t = msg:getHeader("To")
    trace.format("Original To Header - %s", t)
    -- Strip "0" and replace with custom prefix
    t=string.gsub (t,"sip%:0(%d+)@", "sip:" .. prefix .. "%1@")
    msg:modifyHeader ("To", t)
    trace.format("Modified To Header - %s", t)

end

return M
