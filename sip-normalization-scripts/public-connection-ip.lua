--[[

    Author : Jonathan Els
    Version : 0.1
    
    Description:
    
        Overwrite private IP addresses in SDP for NAT'd call flows to specified public IP.  Overcomes entry-level 
        FW limitations.
        
    Notes:
    
        NOT EXTENSIVELY TESTED.  Use at own risk.

    Future development:
    
        None

--]]

M = {}

-- enable tracing for writing to SDL
trace.enable()

local function modify_c_line_ip(msg)

    -- get public ip from script param and fetch sdp
    local public_ip = scriptParameters.getValue("public_ip")
    local sdp = msg:getSdp() 

    if public_ip and sdp
    then
        trace.format("Public IP script param set to %s", public_ip)
        trace.format("SDP found... proceeding with script")
        -- get connection line from sdp by matching only on start-of-line
        local c_line = sdp:getLine("c=", nil)
        
        if c_line
        then
            trace.format("Connection line (c) is: %s", c_line)
            -- match existing ip address in c line.
            -- Simple numeric string match for IP - not robust
            local private_ip = c_line:match("%d+%.%d+%.%d+%.%d+")
            trace.format("Matched existing Private IP is: %s", private_ip)
            -- substitue ip addresses in connection line
            new_c_line = c_line:gsub(private_ip, public_ip)
            trace.format("c line updated to: %s", new_c_line)
            -- update sdp with new connection line
            sdp = sdp:modifyLine("c=", nil, new_c_line)
            -- set sdp to updated sdp
            msg:setSdp(sdp)
        end
    end
end

-- apply modification to affected
-- call flow scenarios

-- INVITE and 200 OK should be affected, and needs to support EO and DO call flows
M.inbound_INVITE = modify_c_line_ip -- EO inbound request (INVITE) from phone
M.inbound_ANY_INVITE = modify_c_line_ip -- EO/DO inbound request and reponse (200 OK and ACK) from phone

-- we should also cater for early media
M.inbound_18X = modify_c_line_ip -- support early media in inbound 180 and 183 messages

return M
