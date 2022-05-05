print('loading...');

require('lib'); -- contains useful things

local q = false;

args = {...};

if args[1] == 'update' then
    q = 2;
    -- old pastebin version
    --[[
    local res = http.get('https://pastebin.com/raw/g26ueH22');
    res.readLine(); -- just reads the first line; which doesn't matter
    local ver = tonumber(res.readLine(false));
    res.close();

    if ver > VERSION then
        print('Newer version found; do you wish to proceed hte installation ?');
        local r = read();
        if r == 'y' or r == 'Y' or r == 'Yes' or r == 'yes' then
            term.clear();
            term.setCursorPos(1,1);
            local res = http.get('https://pastebin.com/raw/g26ueH22');
            local updater = res.readAll();
            res.close();
            loadstring(updater)(true); -- runs the updater
        else
            print('Cancelling update');
        end
    else
        local c = term.getTextColor();
        term.setTextColor(colors.green);
        print('Up to date');
        term.setTextColor(c);
    end
    ]]
    local res = http.get('https://raw.githubusercontent.com/ChickChicky/CC_Tetris/main/update.lua');
    res.readLine(); -- just reads the first line which doesn't matter
    local ver = loadstring('return '..res.readLine(false))();
    res.close();

    if parseVersion(ver) > parseVersion(VERSION) then
        print('Newer version found ('..VERSION..' -> '..ver..'); do you wish to proceed with the installation ?\n');
        term.setTextColor(colors.cyan);
        local r = read();
        term.setTextColor(colors.white);
        if r == 'y' or r == 'Y' or r == 'Yes' or r == 'yes' then
            term.clear();
            term.setCursorPos(1,1);
            local res = http.get('https://raw.githubusercontent.com/ChickChicky/CC_Tetris/main/update.lua');
            local updater = res.readAll();
            res.close();
            loadstring(updater)(true); -- runs the updater
        else
            print('Cancelling update');
        end
    else
        local c = term.getTextColor();
        term.setTextColor(colors.green);
        print('Up to date ('..VERSION..')\n');
        term.setTextColor(c);
    end

    local cx,cy = term.getCursorPos();
    term.setTextColor(colors.gray);
    term.write('press any key to continue...');
    sleep(1);
    term.setCursorPos(1,cy);
    term.setTextColor(colors.lightGray);
    term.write('press any key to continue...');
    sleep(0.05);
    term.setCursorPos(1,cy);
    term.setTextColor(colors.white);
    term.write('press any key to continue...');
    os.pullEvent('key');
    print();
end

if not q then
    print('looking for updates...');
    local res = http.get('https://raw.githubusercontent.com/ChickChicky/CC_Tetris/main/update.lua');
    local code,msg;
    if res then code, msg = res.getResponseCode() end;
    if res ~= nil and code == 200 then
        res.readLine(); -- just reads the first line which doesn't matter
        local ver = loadstring('return '..res.readLine(false))();
        res.close();

        --print(VERSION,ver)
        --sleep(5);

        if parseVersion(ver) > parseVersion(VERSION) then
            term.setTextColor(colors.lime) print('newer version found ('..VERSION..' -> '..ver..'), exit and type "tetris update" to download it')
            
            local cx,cy = term.getCursorPos();
            term.setTextColor(colors.gray);
            print('press any key to continue...');
            sleep(1);
            term.setCursorPos(1,cy);
            term.setTextColor(colors.lightGray);
            term.write('press any key to continue...');
            sleep(0.05);
            term.setCursorPos(1,cy);
            term.setTextColor(colors.white);
            term.write('press any key to continue...');
            os.pullEvent('key');
        end
    else
        print('could not fetch updater');
    end
end

local pieces = {
    {
        variants = {
            { {0,0},{1,0},{2,0},{1,1} }, -- ?
            { {1,0},{0,1},{1,1},{1,2} }, -- ?
            { {1,0},{0,1},{1,1},{2,1} }, -- ?
            { {0,0},{0,1},{0,2},{1,1} }, -- ?
        },
        type = 'T'
    },
    {
        variants = {
            { {0,0},{0,1},{0,2},{0,3} }, -- I
            { {0,0},{1,0},{2,0},{3,0} }, -- -
        },
        type = 'I'
    },
    {
        variants = {
            { {0,0},{0,1},{0,2},{1,2} }, -- L
            { {0,0},{1,0},{2,0},{0,1} }, -- |?
            { {0,0},{1,0},{1,1},{1,2} }, -- ?|
            { {2,0},{0,1},{1,1},{2,1} }, -- _|
        },
        type = 'L'
    },
    {
        variants = {
            { {1,0},{1,1},{0,2},{1,2} }, -- J
            { {0,0},{0,1},{1,1},{2,1} }, -- |_
            { {0,0},{1,0},{0,1},{0,2} }, -- |?
            { {0,0},{1,0},{2,0},{2,1} }, -- ?|
        },
        type = 'J'
    },
    {
        variants = {
            { {0,0},{1,0},{1,1},{2,1} }, -- Z
            { {1,0},{0,1},{1,1},{0,2} }, -- N
        },
        type = 'Z'
    },
    {
        variants = {
            { {1,0},{2,0},{0,1},{1,1} }, -- S
            { {0,0},{0,1},{1,1},{1,2} }, -- ?
        },
        type = 'S'
    },
    {
        variants = {
            { {0,0},{1,0},{0,1},{1,1} } -- O
        },
        type = 'O'
    }
}
for _,p in pairs(pieces) do for _,v in pairs(p.variants) do v.type = p.type end end;

local sname = nil; -- session name

function random_piece(random_variant) 
    random_variant = random_variant or false;
    -- gets a random piece
    local piece = pieces[math.random(1,#pieces)];
    if random_variant then
        -- gets a random variant of the piece
        local variant = piece.variants[math.random(1,#piece.variants)];
        --variant.type = piece.type;
        return variant;
    else
        local p = textutils.unserialise(textutils.serialise(piece.variants[1] or {}));
        --p.type = piece.type;
        return p;
    end
end;

function display_piece(p,x,y,colormode)
    colormode = colormode or 0;

    local bg = term.getBackgroundColor();
    local color = colors.white;

    -- color of the tetromino
    if colormode == 0 then
        if p.type == 'T' then
            color = colors.purple;
        elseif p.type == 'I' then
            color = colors.cyan;
        elseif p.type == 'L' then
            color = colors.orange;
        elseif p.type == 'J' then
            color = colors.blue;
        elseif p.type == 'Z' then
            color = colors.red;
        elseif p.type == 'S' then
            color = colors.green;
        elseif p.type == 'O' then
            color = colors.yellow;
        elseif p.type == 'P' then
            color = colors.lightGray;
        end
    end

    -- renders all pixels of the tetromino
    for key,pp in pairs(p) do
        if typeof(key) == 'number' then
            if colormode ~= 0 then
                -- color of the tile
                if pp.type == 'T' then
                    color = colors.purple;
                elseif pp.type == 'I' then
                    color = colors.cyan;
                elseif pp.type == 'L' then
                    color = colors.orange;
                elseif pp.type == 'J' then
                    color = colors.blue;
                elseif pp.type == 'Z' then
                    color = colors.red;
                elseif pp.type == 'S' then
                    color = colors.green;
                elseif pp.type == 'O' then
                    color = colors.yellow;
                elseif p.type == 'P' then
                    color = colors.lightGray;
                end
            end
            term.setCursorPos(pp[1]+x,pp[2]+y);
            term.setBackgroundColor(color);
            term.write(' ');
        end
    end

    term.setBackgroundColor(bg);

end

function mod(a,b) 
    if a<0 then 
        return (a%b)+b 
    else 
        return a%b 
    end
end

-- graphical cleaning
if not q then
    term.clear();
    term.setCursorPos(1,1);
end

local handle, err = fs.open('.tetris','r');
local dat;
if (err) then
    dat = {};
else
    dat = textutils.unserialiseJSON(handle.readAll()) or {};
    handle.close();
end

local n;
if not q then print('Session name (leave blank for none):'); term.setTextColor(colors.magenta) n = read(nil,nil,nil,dat.name) end;
if n == '' then
    sname = nil;
else
    sname = n;
end

function display_frame(c,score,nextp)
    local frame_color = c or colors.gray;
    local cc = term.getBackgroundColor();
    term.setBackgroundColor(frame_color);
    for x=1,12 do
        term.setCursorPos(x,1);
        term.write(' ');
    end
    for y=1,22 do
        term.setCursorPos(12,y);
        term.write(' ');
    end
    for x=12,1,-1 do
        term.setCursorPos(x,22);
        term.write(' ');
    end
    for y=22,1,-1 do
        term.setCursorPos(1,y);
        term.write(' ');
    end
    term.setBackgroundColor(cc);
    if score ~= nil then
        local tc = term.getTextColor();
        term.setCursorPos(14,2);
        term.setTextColor(colors.white);
        term.write('Score:');
        term.setTextColor(colors.red);
        term.setCursorPos(14,3);
        term.write(tostring(score));
        term.setTextColor(tc);
    end
    if nextp ~= nil then
        local tc = term.getTextColor();
        term.setCursorPos(25,2);
        term.setTextColor(colors.white);
        term.write('Next: ');
        display_piece(nextp,25,4);
        term.setTextColor(tc);
    end
end

function is_outside(p,x,y)
    for _,tile in pairs(p) do
        if typeof(tile) == 'table' then 
            if 
                tile[2]+y >= 21 or
                tile[2]+y <= 0  or
                tile[1]+x >= 11 or
                tile[1]+x <= 0
            then
                return true;
            end
        end
    end
    return false;
end

function is_valid(p,P,x,y)
    if is_outside(p,x,y) then return false end;
    term.setTextColor(colors.brown);
    for _,Ptile in pairs(P) do
        term.setCursorPos(Ptile[1],Ptile[2]);
        --print('X');
        for _,ptile in pairs(p) do
            if typeof(ptile) == 'table' then
                term.setCursorPos(ptile[1]+x,ptile[2]+y);
                --print('O');
                if ptile[1]+x == Ptile[1] and ptile[2]+y == Ptile[2] then 
                    return false; 
                end
            end
        end
    end
    return true;
end

function is_empty(P,x,y)
    return is_valid({{0,0}},P,x,y);
end

-- it's more like a tutorial :/
function demo()
    local variant = 1;

    local x = 1;
    local y = 1;

    local handle, err = fs.open('.tetris','r');
    local dat;
    if (err) then
        dat = {};
    else
        dat = textutils.unserialiseJSON(handle.readAll()) or {};
        handle.close();
    end
    local ss = dat.ss;

    os.queueEvent('upd'); -- allows the first frame to be rendered
    while true do

        local evt = {os.pullEventRaw()};
        local evtName = evt[1];
        if q then break end;

        if evtName == "key" then
            local key = evt[2];
            if (key == keys.k or key == keys.down) then
                y = y+1;

            elseif (key == keys.j or key == keys.left) then
                if not is_outside(pieces[1].variants[variant],x-1,y) then
                    x = x-1;
                end

            elseif (key == keys.l or key == keys.right) then
                if not is_outside(pieces[1].variants[variant],x+1,y) then
                    x = x+1;
                end

            elseif (key == keys.o or key == keys.up or key == keys.i) then
                --variant = mod(variant+1,5);
                --if variant == 0 then variant = 1 end;
                local vv = 1;
                while true do
                    variant = mod(variant +1*vv,5);
                    if variant == 0 then variant = 1 end;
                    if not is_outside(pieces[1].variants[variant],x,y) then
                        break;
                    else
                        vv = vv+1;
                    end
                end
            
            elseif (key == keys.u) then
                --variant = mod(variant-1,5);
                --if variant == 0 then variant = 1 end;
                local vv = 1;
                while true do
                    variant = mod(variant -1*vv,5);
                    if variant == 0 then variant = 4 end;
                    if not is_outside(pieces[1].variants[variant],x,y) then
                        break;
                    else
                        vv = vv+1;
                    end
                end

            elseif (key == keys.backspace) then

                local options = {
                    'return to tutorial',
                    'scoreboard',
                    'change session name'
                }

                local quit = false;

                local opt = 0;

                while true do
                    function clr()
                        term.clear();
                        term.setCursorPos(1,1);
    
                        term.setTextColor(colors.white);
                        term.write('Menu    ');
    
                        term.write('Score: ');
                        term.setTextColor(colors.red);
                        term.write(tostring(score or '<no score>'));
                        if sname then
                            term.setTextColor(colors.white);
                            term.write('    Name: ');
                            term.setTextColor(colors.magenta);
                            term.write(sname);
                        end
                        if ss then
                            term.setCursorPos(9,2);
                            term.setTextColor(colors.white);
                            term.write('SS: ');
                            term.setTextColor(colors.magenta);
                            term.write(ss);
                        else
                            print(); -- just adds a newline
                        end
                        term.setTextColor(colors.white);
                        print('\n');
                    end
    
                    clr();
    
                    term.setTextColor(colors.gray);
                    print('(cycle with I / K)');
    
                    for i,option in pairs(options) do
                        if i == opt+1 then
                            term.setTextColor(colors.yellow);
                        else
                            term.setTextColor(colors.white);
                        end
                        print(option);
                    end
                    term.setTextColor(colors.white);

                    local evt = {os.pullEventRaw()};
                    local evtName = evt[1];
                    if evtName == "key" then
                        local key = evt[2];
                        if key == keys.backspace then
                            break;
                        elseif key == keys.down or key == keys.k then
                            opt = mod(opt+1,#options);
                        elseif key == keys.up or key == keys.i then
                            opt = mod(opt-1,#options);
                        elseif key == keys.enter then
                            local c = options[opt+1];
                            if c == 'return to tutorial' then
                                break;
                            elseif c == 'scoreboard' then
                                clr();
    
                                local handle, err = fs.open('.tetris','r');
                                local dat = {scores={}};
                                if handle then 
                                    -- print(handle.readAll());
                                    -- sleep(1);
                                    --local log = fs.open('tetris.log','a');
                                    --log.write("BEFORE:\n"..textutils.serialise(dat).."\n---------------\n");
                                    -- dat = textutils.unserialiseJSON(handle.readAll());
                                    --log.write("CONTENT:\n"..content.."\n---------------\n");
                                    --local tempdat = textutils.unserialiseJSON(content);
                                    --for k,v in pairs(tempdat) do dat[k] = v end;
                                    --log.write("AFTER:\n"..textutils.serialise(dat).."\n---------------\n");
                                    --log.write("SCORES ID:"..tostring(dat.scores).."\n---------------\n");
                                    --debug.
                                    --log.close();
                                    --print("local.scores.length="..tostring(#dat.scores));
                                    dat = textutils.unserialiseJSON(handle.readAll());
                                    --print(#dat.scores);
                                    loadss(ss,dat.scores);
                                    handle.close();
                                end;
                                if ( err and not(dat) ) then
                                    term.setTextColor(colors.lightGray);
                                    print('<no data>');
                                else
                                    dat = dat.scores;
                                    --table.insert(dat,{t='now',s=score});
                                    table.sort(dat, function(a,b) return a.s > b.s end);
                                    local bsl = 0;
                                    local lsn = 0;
                                    for _,s in pairs(dat) do
                                        bsl = math.max(bsl,#tostring(s.s));
                                        lsn = math.max(lsn,#(s.n or '')+2);
                                    end
                                    lsn = lsn +1;
                                    for _,s in pairs(dat) do
                                        --print('E');
                                        -- name of the scorer
                                        local n = '';
                                        if s.n then
                                            n = ' ('..s.n..') ';
                                        end
    
                                        -- origin of the score
                                        local o = '';
                                        if s.org == 'ss' then
                                            o = ' [server] ';
                                        end
    
                                        -- flag of the score
                                        local f = ' ';
                                        if s.org == 'ss' then
                                            f = 'S';
                                        elseif s.t == 'now' then
                                            f = 'C';
                                        end
    
                                        term.setTextColor(colors.gray) term.write(f..' ');
                                        term.setTextColor(colors.red) term.write(s.s) term.setTextColor(colors.gray);
    
                                        if s.t == 'now' then
                                            print(string.rep(' ',bsl-#tostring(s.s)+1)..n..'<current score>');
                                        else
                                            print(string.rep(' ',bsl-#tostring(s.s)+1)..os.date('!%d/%m/%G %H:%M',s.t/1000)..n..(' '):rep(math.max(1,lsn-(#n-2)))..o);
                                        end
                                    end
                                end
                                print(#dat);
                                term.setTextColor(colors.gray);
                                print();
                                print('press any key to return back to menu');
                                local evt = os.pullEventRaw('key');
                                dat = nil;
                            elseif c == 'change session name' then
                                clr();
                                print('New session name (leave blank to clear):'); term.setTextColor(colors.magenta); 
                                local n = read(nil,nil,nil,sname);
                                if n == '' then
                                    sname = nil;
                                else
                                    sname = n;
                                end
                            end
                        end
                    elseif evtName == "terminate" then
                        quit = true;
                        break;
                    end
                end
    
                if quit then q = true break end;

            elseif (key == keys.enter) then
                break;

            end
        end
        if evtName == "terminate" then
            --os.reboot(); -- exit doesn't work ¯\_(?)_/¯
            q = true;
            break;
        end

        if is_outside(pieces[1].variants[variant],x,y) then
            y = 1;
        end

        term.clear();
        term.setCursorPos(13,1); term.write('Press ') term.setTextColor(colors.blue) term.write('U') term.setTextColor(colors.white) print(' to rotate your shape counter-clockwise');
        term.setCursorPos(13,2); term.write('Press ') term.setTextColor(colors.blue) term.write('O') term.setTextColor(colors.gray) term.write('/') term.setTextColor(colors.blue) term.write('I') term.setTextColor(colors.gray) term.write('/') term.setTextColor(colors.cyan) term.write('Up') term.setTextColor(colors.white)  print(' to rotate your shape clockwise');
        term.setCursorPos(13,3); term.write('Press ') term.setTextColor(colors.blue) term.write('K') term.setTextColor(colors.gray) term.write('/') term.setTextColor(colors.cyan) term.write('Down') term.setTextColor(colors.white) print(' to softly drop your piece');
        term.setCursorPos(13,4); term.write('Press ') term.setTextColor(colors.blue) term.write('J') term.setTextColor(colors.gray) term.write('/') term.setTextColor(colors.cyan) term.write('Left') term.setTextColor(colors.white) print(' to move your piece to the left');
        term.setCursorPos(13,5); term.write('Press ') term.setTextColor(colors.blue) term.write('L') term.setTextColor(colors.gray) term.write('/') term.setTextColor(colors.cyan) term.write('Right') term.setTextColor(colors.white) print(' to move your piece to the right');
        term.setCursorPos(13,6); term.write('Press ') term.setTextColor(colors.blue) term.write('Space') term.setTextColor(colors.white) print(' to hardly drop your piece');
        term.setCursorPos(13,7); term.write('Press ') term.setTextColor(colors.blue) term.write('Backspace') term.setTextColor(colors.white) print(' to open the menu');
        term.setCursorPos(13,8); term.write('Press ') term.setTextColor(colors.blue) term.write('Enter') term.setTextColor(colors.white) print(' to start playing');
        term.setCursorPos(13,9); term.write('Hold ') term.setTextColor(colors.blue) term.write('Ctrl') term.setTextColor(colors.gray) term.write('+') term.setTextColor(colors.blue) term.write('T') term.setTextColor(colors.white) print(' to leave');

        -- term.setCursorPos(13,2); term.write('Press ') O to rotate your shape clockwise');
        -- term.setCursorPos(13,3); term.write('Press ') K to softly drop your piece');
        -- term.setCursorPos(13,4); term.write('Press ') J to move your piece to the left');
        -- term.setCursorPos(13,5); term.write('Press ') L to move your piece to the right');
        -- term.setCursorPos(13,7); term.write('Press ') Enter to start playing');
        -- term.setCursorPos(13,8); term.write('Press ') Ctrl+T to leave');
        term.setCursorPos(14,10); print('variant: '..tostring(variant));
        display_frame();
        display_piece(pieces[1].variants[variant],x+1,y+1);
    end

end

demo(); -- maybe do it only the first time ?

local piece = pieces[math.random(1,#pieces)];
local npiece = pieces[math.random(1,#pieces)];
local last = os.clock();

local variant = 1;
local x = 4;
local y = 1;

local placed = {};

local pp;

local score = 0;

local ph = piece.type;

local handle, err = fs.open('.tetris','r');
local dat;
if (err) then
    dat = {};
else
    dat = textutils.unserialiseJSON(handle.readAll()) or {};
    handle.close();
end
local g = dat.g;
local ss = dat.ss;
if g == nil then g = true end;

local cd = 1; -- cooldown for piece falldown

--local sname = nil; -- session name

os.queueEvent('upd'); -- allows the first frame to be rendered
while true do

    local id = os.startTimer(cd);
    local evt = {os.pullEventRaw()};
    os.cancelTimer(id);
    local evtName = evt[1];

    if q then break end;

    --[[
    if evtName == "key" then
        local key = evt[2];
        if (key == keys.down) then
            y = y+1;
        elseif (key == keys.left) then
            x = x-1;
        elseif (key == keys.right) then
            x = x+1;
        end
    end
    if evtName == "terminate" then
        os.reboot();
    end
    ]]

    if evtName == "key" then
        local key = evt[2];
        if (key == keys.k or key == keys.down) then
            if is_valid(piece.variants[variant],placed,x,y+1) then
                y = y+1;
                score = score +1*math.max(1,math.floor(#placed/20));
            else
                last = last -cd;
            end

        elseif (key == keys.j or key == keys.left) then
            -- makes sure the piece fits in and then moves it to the left
            if is_valid(piece.variants[variant],placed,x-1,y) then
                x = x-1;
            end

        elseif (key == keys.l or key == keys.right) then
            -- makes sure the piece fits in and then moves it to the right
            if is_valid(piece.variants[variant],placed,x+1,y) then
                x = x+1;
            end

        elseif (key == keys.o or key == keys.up or key == keys.i) then
            -- finds the first fitiing variant, cycling clockwise
            while true do
                variant = mod(variant +1,#piece.variants+1);
                if variant == 0 then variant = 1 end;
                if is_valid(piece.variants[variant],placed,x,y) then
                    break;
                end
            end

        elseif (key == keys.backspace) then

            local quit = false;
            local options = {
                'return to game',
                'scoreboard',
                'save and exit',
                'change session name',
                'set scores server',
                'clear',
                'toggle ghost'
            }
            local opt = 0;

            while true do
                function clr()
                    term.clear();
                    term.setCursorPos(1,1);

                    term.setTextColor(colors.white);
                    term.write('Menu    ');

                    term.write('Score: ');
                    term.setTextColor(colors.red);
                    term.write(tostring(score));
                    if sname then
                        term.setTextColor(colors.white);
                        term.write('    Name: ');
                        term.setTextColor(colors.magenta);
                        term.write(sname);
                    end
                    if ss then
                        term.setCursorPos(9,2);
                        term.setTextColor(colors.white);
                        term.write('SS: ');
                        term.setTextColor(colors.magenta);
                        term.write(ss);
                    else
                        print(); -- just adds a newline
                    end
                    term.setTextColor(colors.white);
                    print('\n');
                end

                clr();

                term.setTextColor(colors.gray);
                print('(cycle with I / K)');

                for i,option in pairs(options) do
                    if i == opt+1 then
                        term.setTextColor(colors.yellow);
                    else
                        term.setTextColor(colors.white);
                    end
                    print(option);
                end
                term.setTextColor(colors.white);

                local evt = {os.pullEventRaw()};
                local evtName = evt[1];
                if evtName == "key" then
                    local key = evt[2];
                    if key == keys.backspace then
                        break;
                    elseif key == keys.down or key == keys.k then
                        opt = mod(opt+1,#options);
                    elseif key == keys.up or key == keys.i then
                        opt = mod(opt-1,#options);
                    elseif key == keys.enter then
                        local c = options[opt+1];
                        if c == 'save and exit' then
                            quit = true;
                            break;
                        elseif c == 'return to game' then
                            break;
                        elseif c == 'scoreboard' then
                            clr();

                            local handle, err = fs.open('.tetris','r');
                            local dat = {scores={}};
                            if handle then 
                                -- print(handle.readAll());
                                -- sleep(1);
                                --local log = fs.open('tetris.log','a');
                                --log.write("BEFORE:\n"..textutils.serialise(dat).."\n---------------\n");
                                -- dat = textutils.unserialiseJSON(handle.readAll());
                                --log.write("CONTENT:\n"..content.."\n---------------\n");
                                --local tempdat = textutils.unserialiseJSON(content);
                                --for k,v in pairs(tempdat) do dat[k] = v end;
                                --log.write("AFTER:\n"..textutils.serialise(dat).."\n---------------\n");
                                --log.write("SCORES ID:"..tostring(dat.scores).."\n---------------\n");
                                --debug.
                                --log.close();
                                --print("local.scores.length="..tostring(#dat.scores));
                                dat = textutils.unserialiseJSON(handle.readAll());
                                --print(#dat.scores);
                                loadss(ss,dat.scores);
                                handle.close();
                            end;
                            if ( err and not(dat) ) then
                                term.setTextColor(colors.lightGray);
                                print('<no data>');
                            else
                                dat = dat.scores;
                                table.insert(dat,{t='now',s=score});
                                table.sort(dat, function(a,b) return a.s > b.s end);
                                local bsl = 0;
                                local lsn = 0;
                                for _,s in pairs(dat) do
                                    bsl = math.max(bsl,#tostring(s.s));
                                    lsn = math.max(lsn,#(s.n or '')+2);
                                end
                                lsn = lsn +1;
                                for _,s in pairs(dat) do
                                    --print('E');
                                    -- name of the scorer
                                    local n = '';
                                    if s.n then
                                        n = ' ('..s.n..') ';
                                    end

                                    -- origin of the score
                                    local o = '';
                                    if s.org == 'ss' then
                                        o = ' [server] ';
                                    end

                                    -- flag of the score
                                    local f = ' ';
                                    if s.org == 'ss' then
                                        f = 'S';
                                    elseif s.t == 'now' then
                                        f = 'C';
                                    end

                                    term.setTextColor(colors.cyan) term.write(f..' ');
                                    term.setTextColor(colors.red) term.write(s.s) term.setTextColor(colors.gray);

                                    if s.t == 'now' then
                                        print(string.rep(' ',bsl-#tostring(s.s)+1)..n..'<current score>');
                                    else
                                        print(string.rep(' ',bsl-#tostring(s.s)+1)..os.date('!%d/%m/%G %H:%M',s.t/1000)..n..(' '):rep(math.max(1,lsn-(#n-2)))..o);
                                    end
                                end
                            end
                            print(#dat);
                            term.setTextColor(colors.gray);
                            print();
                            print('press any key to return back to menu');
                            local evt = os.pullEventRaw('key');
                            dat = nil;
                        elseif c == 'change session name' then
                            clr();
                            print('New session name (leave blank to clear):'); term.setTextColor(colors.magenta); 
                            local n = read(nil,nil,nil,sname);
                            if n == '' then
                                sname = nil;
                            else
                                sname = n;
                            end
                        elseif c == 'clear' then
                            term.write('Do you want to clear the field ? ') 
                                term.setTextColor(colors.green) term.write('y');
                                term.setTextColor(colors.white) term.write('/');
                                term.setTextColor(colors.red) term.write('n');
                            term.setTextColor(colors.white);
                            print();
                            
                            local cc;
                            while true do
                                local evt = {os.pullEventRaw()};
                                local evtName = evt[1];
                                if evtName == "key" then
                                    local key = evt[2];
                                    if key == keys.y then
                                        cc = 'y';
                                        break;
                                    elseif key == keys.n then
                                        cc = 'n';
                                        break;
                                    end
                                elseif evtName == "terminate" then
                                    quit = true;
                                end
                            end
                            if quit then break end;
                            if cc == 'y' then
                                piece = pieces[math.random(1,#pieces)];
                                npiece = pieces[math.random(1,#pieces)];
                                ph = --[[p ..]]piece.type;
                                last = os.clock();
                                variant = 1;
                                x = 4;
                                y = 1;
                                placed = {};
                                score = 0;
                            end
                        elseif c == 'toggle ghost' then
                            local handle, err = fs.open('.tetris','r');
                            local dat;
                            if (err) then
                                dat = {};
                            else
                                dat = textutils.unserialiseJSON(handle.readAll()) or {};
                                handle.close();
                            end
                            dat.g = not g;
                            g = not g;
                            local handle = fs.open('.tetris','w');
                            handle.write(textutils.serialiseJSON(dat));
                            handle.flush();
                            handle.close();
                        elseif c == 'set scores server' then
                            local ssa;
                            while true do
                                clr();
                                print('new scores server (leave blank to clear):'); term.setTextColor(colors.magenta);
                                ssa = read(nil,nil,nil,ssa or ss);

                                if ssa == '' then ssa = nil break end;

                                local conn = http.get(ssa,{action="ping"});
                                if conn == nil then
                                    term.write('impossible to connect to the server, do you still want to proceed? \n'); term.setTextColor(colors.cyan);
                                    local r = read(nil,nil,nil,nil);
                                    if r == 'yes' or r == 'y' then
                                        break;
                                    end
                                else
                                    term.write('successfully set the scores server !');
                                    print();
                                    break;
                                end

                            end
                            pak();
                            ss = ssa;
                        end
                    end
                elseif evtName == "terminate" then
                    quit = true;
                    break;
                end
            end

            if quit then break end;

        elseif (key == keys.d) then

            print(textutils.serialise(placed));
            os.pullEvent('key');

        elseif (key == keys.space) then

            x = pp[1];
            y = pp[2];
            last = last - cd;
        
        elseif (key == keys.u) then
            -- finds the first fitiing variant, cycling counter-clockwise
            while true do
                variant = mod(variant -1,#piece.variants+1);
                if variant == 0 then variant = #piece.variants end;
                if is_valid(piece.variants[variant],placed,x,y) then
                    break;
                end
            end

        elseif (key == keys.enter) then
            break;

        end
    end
    if evtName == "terminate" then -- CTRL+T (CTRL+C adaptation for craftos)
        --os.reboot(); -- exit() doesn't work ¯\_(?)_/¯
        break;
    end

    -- instantly trigger the piece-placing code if the piece cannot be moved
    if not is_valid(piece.variants[variant],placed,x,y+1) and (not is_valid(piece.variants[variant],placed,x-1,y) or not is_valid(piece.variants[variant],placed,x+1,y)) then
        last = last -cd;
    end

    --print('AAA');

    --local lines = {};
    --for _,tile in pairs(placed) do
    --    local ll = table.find(lines,function(n) return n.l==tile[2] end);
    --    if not ll then 
    --        ll = {l=tile[2],tiles={}};
    --        table.insert(lines,ll);
    --    end
    --    table.insert(ll.tiles,tile);
    --end
    --os.pullEvent('key');
    --local fall = {};
    --for _,line in pairs(lines) do
    --    if #line.tiles == 9 then
    --        for _,tile in pairs(line.tiles) do
    --            if table.indexof(fall,tile[2]) ~= nil then table.insert(fall,tile[2]) end;
    --            table.remove(placed,table.indexof(tile));
    --        end
    --    end
    --end

    --print(textutils.serialise(lines));
    --if (math.max(table.unpack(lines) or 0)) >8 then sleep(1) end;
    --for i,tile in ipairs(placed) do
    --    if lines[tile[2]] >= 9 then
    --        print(tile[2]);
    --    end
    --end

    --if (#placed) >8 then sleep(1) end;
    --if (#placed) >1 then sleep(15) end;
    --local np = {};
    --placed = np;
    -- if #fall == 1 then
    --     score = score + 40
    -- elseif #fall == 2 then
    --     score = score + 100
    -- elseif #fall == 3 then
    --     score = score + 300
    -- elseif #fall == 4 then
    --     score = score + 1200
    -- else
    --     score = score + 250*#fall
    -- end
    --local np = {};
    --for _,tile in pairs(placed) do
    --    local t = textutils.unserialiseJSON(textutils.serialiseJSON(tile));
    --    if is_empty(placed,tile[1],tile[2]+1) then t[2] = t[2]+1 end;
    --    table.insert(np,t);
    --end
    --placed = np

    -- lowers the piece every second
    if os.clock()-last >cd then
        if not is_valid(piece.variants[variant],placed,x,y+1) then
            if not is_valid(piece.variants[variant],placed,x,y) then y = y -1 end;
            if y <= 1 then
                break; -- exit
            end
            for _,tile in pairs(dclone(piece.variants[variant])) do
                if typeof(tile) == 'table' then
                    --print('A');
                    table.insert(placed,{tile[1]+x,tile[2]+y,type=dclone(piece.variants[variant].type)});
                end
            end
            --sleep(1);
            piece = npiece;
            npiece = pieces[math.random(1,#pieces)];
            ph = ph ..piece.type;
            variant = 1;
            y = 1;
            x = 4;
            last = os.clock();
    
            -- creates a table with each line number and the amount of tiles in that line
            local lines = {};
            for _,tile in pairs(placed) do
                local c = lines[tile[2]] or 0;
                lines[tile[2]] = c+1;
            end
    
            lines = table.ishift(table.filter(lines));
    
            -- removes the full lines
            local ll = 0;
            local ln = 0;
            local np = textutils.unserialise(textutils.serialise(placed));
            for n,line in pairs(lines) do
                if line == 10 then
                    ll = n;
                    ln = ln +1;
                    --[[local np = {};
                    for _,tile in pairs(placed) do
                        if tile[2] ~= n then
                            table.insert(np,tile);
                        end
                    end
                    placed = np;
                    ]]
                    placed = table.ifilter(placed, function(t) return t[2] ~= n end);
                end
            end
    
            -- increases the score
            if ln == 1 then
                score = score + 40
            elseif ln == 2 then
                score = score + 100
            elseif ln == 3 then
                score = score + 300
            elseif ln == 4 then
                score = score + 1200
            else
                score = score + 250*ln
            end
    
            --placed = np;
    
            -- lowers pieces above the broken line(s)
            if ln ~= 0 then
                local np = dclone(placed);
                for n,tile in pairs(placed) do
                    if tile[2] < ll then
                        np[n] = {tile[1],tile[2] +ln,type=tile.type};
                    end
                end
                placed = np;
            end
        else
            y = y+1;
            last = os.clock();
        end
    end

    -- projection position
    pp = {x,y};
    while true do
        if not is_valid(piece.variants[variant],placed,pp[1],pp[2]+1) then break end;
        pp[2] = pp[2] +1;
    end
    local projected = dclone(piece.variants[variant]);
    projected.type = 'P';

    term.clear();
    display_frame(nil,score,npiece.variants[1]);
    if g then display_piece(projected,pp[1]+1,pp[2]+1,0) end;
    display_piece(piece.variants[variant],x+1,y+1);
    display_piece(placed,1,1,1);

    --print('AAA');
    --print('EEE');
    --print(textutils.serialiseJSON(lines),#lines);
    --is_valid(piece.variants[variant],placed,x+1,y+1);
end

if not q then
    local rhandle, err = fs.open('.tetris','r');
    local dat;
    if (err) then
        dat = {scores={}};
    else
        dat = textutils.unserialiseJSON(rhandle.readAll()) or {scores={}};
        rhandle.close();
    end
    if dat.scores == nil then
        dat.scores = {};
    end
    local whandle = fs.open('.tetris','w');
    if score > 0 then
        -- saves the score

        local scoret = {t=os.epoch('local'),s=score,n=sname,p=ph,u=ss};

        if ss then
            local err = savess(ss,scoret);
            if err then
                term.setTextColor(colors.red);
                print('Could not save online score: '..err);
                table.insert(dat.scores,scoret);
            end
        else
            table.insert(dat.scores,scoret);
        end
    end

    dat.name = sname;
    dat.g = g;
    dat.ss = ss;

    whandle.write(textutils.serialiseJSON(dat));
    whandle.close();

    term.clear();
    display_frame(nil,score);
    display_piece(piece.variants[variant],x+1,y+1);
    display_piece(placed,1,1,1);
    term.setCursorPos(14,5);
    term.setTextColor(colors.gray);
    print('press any key to continue...');
    sleep(1);
    term.setCursorPos(14,5);
    term.setTextColor(colors.white);
    print('press any key to continue...');
    os.pullEvent('key');
end

if q ~= 2 then
    term.clear();
    term.setCursorPos(1,1);
end

-- display all pieces in a 6x5 square
-- display_piece(pieces[1].variants[1],1,1);
-- display_piece(pieces[2].variants[2],2,1);
-- display_piece(pieces[3].variants[4],2,4);
-- display_piece(pieces[4].variants[1],5,1);
-- display_piece(pieces[5].variants[2],1,3);
-- display_piece(pieces[6].variants[1],3,2);
-- display_piece(pieces[7].variants[1],5,4);