--[[

    Author : Jonathan Els
    Version : 1.1

    Description:
    
        This script is used to meet a limited use case for forwarding to VM, to reach the VM box of the
        LAST Line Group member in call hunting scenarios, such as:

        Call: B(126) -> Fwd to Hunt Group ->  [C(163) -  D(129) – A(122)] -> Fwd to Voice Mail (A)

        The script looks at the last forwarding station, matches this against a hunt pilot dn pattern.
        If matched, it removes all diversion headers and configures a single diversion header, with a voice 
        mailbox specified as a script param.

        Supported matching multiple hunt pilots and for routing to the same final voice mailbox.

    Script Params:

        hunt-pilot-pattern      hunt pilot pattern matching a valid Lua regex pattern, not CUCM dial plan pattern.
                                e.g. "5.." and NOT "5XX"
        final-vm-user           final user's voicemail box (ie. DTMF ID) that the call should be routed to.

    Limitations:
    
        The script allows for multiple multiple hunt pilots to map to a SINGLE final user's voicemail box.  
        It does currently NOT support pilot/mailbox mappings.

--]] 


M = {}

function M.outbound_INVITE(msg)

    trace.enable()

    local huntPilotPattern = scriptParameters.getValue("hunt-pilot-pattern")
    local finalVmUser = scriptParameters.getValue("final-vm-user")

    if huntPilotPattern and finalVmUser then

        local callID = msg:getHeader("Call-ID")
        trace.format("M.outbound_INVITE: Call-ID is '%s'", callID)
        trace.format("Hunt Pilot Pattern is '%s'", huntPilotPattern)
        trace.format("Final VM User is '%s'", finalVmUser)

        local diversionTable = msg:getHeaderValues("Diversion")

        -- only applied for multiple forwarding and when final forwarding station matches hunt pilot pattern
        if #diversionTable > 1 and string.match(diversionTable[1], 'sip:' .. huntPilotPattern .. '@') then

            local lastForwardingStation = diversionTable[1]
            trace.format("Existing first Diversion header is '%s'", lastForwardingStation)
            local newForwardingStation = string.gsub(lastForwardingStation , "<sip:.*@" , "<sip:" .. finalVmUser .. "@")
            trace.format("New first Diversion header is '%s'", newForwardingStation)
            -- insert new header at start of list
            -- table.insert(diversionTable, 1, newForwardingStation)  -- table built-ins not supported by CUCM

            -- remove existing Diversion headers from SIP message
            for k,v in ipairs(msg:getHeaderValues("Diversion")) do
                msg:removeHeaderValue("Diversion", v)
            end

            msg:addHeader("Diversion", newForwardingStation) -- workaround for table.insert limitation
            -- write new header from modified Diversion table
            for k,v in ipairs(diversionTable) do
                msg:addHeader("Diversion", v)
            end
        end
    end

end

return M
