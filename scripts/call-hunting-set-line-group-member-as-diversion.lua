--[[

    Author : Jonathan Els
    Version : 1.0

    Description:
    
        This script is used to meet a limited use case for forwarding to VM, to reach the VM box of the LAST Line Group member
        in call hunting scenarios, such as:

        Call: B(126) -> Fwd to Hunt Group ->  [C(163) -  D(129) – A(122)] -> Fwd to Voice Mail (A)

        The script looks at the last forwarding station, matches this against a hunt pilot dn pattern.  if matched, it removes all
        diversion headers and configures a single diversion header, with a voice mailbox specified as a script param.

        Supported matching multiple hunt pilots and for routing to the same final voice mailbox.

    Script Params:

        hunt-pilot-pattern      hunt pilot pattern matching a valid Lua regex pattern, not CUCM dial plan pattern.
                                e.g. "5.." and NOT "5XX"
        final-vm-user           final user's voicemail box (ie. DTMF ID) that the call should be routed to.

    Limitations:
    
        The script allows for multiple multiple hunt pilots to map to a SINGLE final user's voicemail box.  It does currently not
        support multiple mappings.

        Script doesn't write Diversion table working into final outbound INVITE.  Only a single modified Diversion header is passed to Unity. 

        Usage with the Unity Advanced > Conversations "Use Last (Rather than First) Redirecting Number for Routing Incoming Call"
        enabled may require script modification and testing.

        May not observe expected Unity locale in a multi-locale deployment due to Hunt Pilot forwarding stations. 

--]] 


M = {}

function M.outbound_INVITE(msg)

    trace.enable()

    local huntPilotPattern = scriptParameters.getValue("hunt-pilot-pattern")
    local finalVmUser = scriptParameters.getValue("final-vm-user")

    if huntPilotPattern and finalVmUser then

        local callid = msg:getHeader("Call-ID")
        trace.format("M.outbound_INVITE: callid is '%s'", callid)
        trace.format("Hunt Pilot Pattern is '%s'", huntPilotPattern)
        trace.format("Final VM User is '%s'", finalVmUser)

        local DiversionTable = msg:getHeaderValues("Diversion")

        -- only applied for multiple forwarding and when final forwarding station matches hunt pilot pattern
        if #DiversionTable > 1 and string.match(DiversionTable[1], 'sip:' .. huntPilotPattern .. '@') then
            firstDiversion = DiversionTable[1]
            trace.format("First Diversion Header is '%s'", firstDiversion)
            newFirstDiversion = string.gsub(firstDiversion , "<sip:.*@" , "<sip:" .. finalVmUser .. "@")
            trace.format("Modified Diversion Header is '%s'", newFirstDiversion)
            msg:modifyHeader("Diversion", newFirstDiversion)
        end
    end

end

return M