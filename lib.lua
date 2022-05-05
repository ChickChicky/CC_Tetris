VERSION = 
'0.5.4'

typeof = type;

-- tables stuff
function table.find(t,match)
    local omatch = match;
    if typeof(match) ~= 'function' then
        match = function(v) return omatch == v end;
    end

    for k,v in pairs(t) do
        if match(v,k) then return v end;
    end
end
function table.indexof(t,match)
    local omatch = match;
    if typeof(match) ~= 'function' then
        match = function(v) return omatch == v end;
    end

    for k,v in pairs(t) do
        if match(v,k) then return k end;
    end
end
function table.filter(t,match)
    local omatch = match;
    if typeof(match) ~= 'function' then
        match = function(v) return omatch ~= v end;
    end
    local nt = {};
    for k,v in pairs(t) do
        if match(v,k) then nt[k] = v end;
    end
    return nt;
end
function table.ifilter(t,match)
    local omatch = match;
    if typeof(match) ~= 'function' then
        match = function(v) return omatch ~= v end;
    end
    local nt = {};
    for k,v in pairs(t) do
        if match(v,k) then table.insert(nt, v) end;
    end
    return nt;
end
function table.ishift(t)
    local m = t[1] or 1;
    for k,_ in pairs(t) do
        m = math.min(m,k);
    end
    local nt = {};
    for k,v in pairs(t) do
        nt[k-m+1] = v;
    end
    return nt;
end
-- deep-cloning function
function dclone(t)
    return textutils.unserialise(textutils.serialise(t));
end
function table.map(t,fn)
    local nt = {};
    for k,v in pairs(t) do
        nt[k] = fn(v,k,t);
    end
    return nt;
end
function table.imap(t,fn)
    local nt = {};
    for i,v in ipairs(t) do
        table.insert(nt, fn(v,i,t));
    end
    return nt;
end

-- random things
function parseVersion(v)
    if typeof(v) == 'string' then
        local major, minor, patch = v:match('(%w+)%.(%w+)%.(%w+)');
        return major * 1000000 + minor * 1000 + patch;
    else
        return v;
    end
end
function pak(t)
    if t == nil then t = 1 end;
    local cx,cy = term.getCursorPos();
    term.setTextColor(colors.gray);
    print('press any key to continue...');
    sleep(t);
    term.setCursorPos(1,cy);
    term.setTextColor(colors.lightGray);
    term.write('press any key to continue...');
    sleep(0.05);
    term.setCursorPos(1,cy);
    term.setTextColor(colors.white);
    term.write('press any key to continue...');
    os.pullEvent('key');
end

-- Score Server
function loadss(ss,dat)
    if ss then
        local conn = http.get(ss,{action="get"});
        local code, msg;
        if conn then code, msg = conn.getResponseCode() end;
        if conn ~= nil and code == 200 then
            for _,s in pairs(textutils.unserialiseJSON(conn.readAll())) do
                --print("loadss.scores.length="..tostring(#dat))
                s.org = 'ss';
                table.insert(dat,s);
            end
        else
            return msg;
        end
    end
end
function savess(ss,scoret)
    if ss then
        local conn = http.get(ss,{action="save",payload=textutils.serialiseJSON(scoret)});
        local code, msg;
        if conn then code, msg = conn.getResponseCode() end;
        if not( conn ~= nil and code == 200 ) then
            return msg;
        end
    end
end