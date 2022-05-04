VERSION = 
'0.5.0'
 
local args = {...};

-- old pastebin version
--[[
local files = {
    hPuYQY5V = 'lib.lua',
    tM7zrqc1 = 'tetris.lua',
}

if args[1] == true then -- updater

    print('Tetris updater\n');
    term.setCursorBlink(true);

    for link,name in pairs(files) do
        local res = http.get('https://pastebin.com/raw/'..link);
        local code, msg = res.getResponseCode();
        if code == 200 then
            local handle = fs.open(name,'w');
            handle.write(res.readAll());
            handle.close();
            print('Downloaded '..name);
        else
            print('Failed to download '..name..': '..msg);
        end
        res.close();
    end

    print('\nUpdate complete');

else -- installer

    print('Tetris installer\n');
    term.setCursorBlink(true);
    
    if fs.exists('lib.lua') then
        print('deleting lib.lua');
        fs.copy('lib.lua','lib.lua.bak_'..tostring(os.epoch()));
        fs.delete('lib.lua');
    end
    shell.run('pastebin get hPuYQY5V lib.lua');
    
    if fs.exists('tetris.lua') then
        print('deleting tetris.lua');
        fs.copy('tetris.lua','tetris.lua.bak_'..tostring(os.epoch()));
        fs.delete('tetris.lua');
    end
    shell.run('pastebin get tM7zrqc1 tetris.lua');
    
    print('\nInstallation complete');
    print('Type tetris to start playing');

end
]]

local files = {
    'lib.lua',
    'tetris.lua',
}

if args[1] == true then -- updater
    print('Tetris updater\n');
    term.setCursorBlink(true);

    for _,name in pairs(files) do
        local res = http.get('https://raw.githubusercontent.com/ChickChicky/CC_Tetris/main/'..name);
        local code, msg = res.getResponseCode();
        if code == 200 then
            local handle = fs.open(name,'w');
            handle.write(res.readAll());
            handle.close();
            term.setTextColor(colors.green) print('Downloaded '..name);
        else
            term.setTextColor(colors.red) print('Failed to download '..name..': '..msg);
        end
        res.close();
    end

    term.setTextColor(colors.white);

    print('\nUpdate complete');
else -- installer

    print('Tetris installer\n');
    term.setCursorBlink(true);
    
    for _,name in pairs(files) do
        local res = http.get('https://raw.githubusercontent.com/ChickChicky/CC_Tetris/main/'..name);
        local code, msg = res.getResponseCode();
        if code == 200 then
            local handle = fs.open(name,'w');
            handle.write(res.readAll());
            handle.close();
            print('Downloaded '..name);
        else
            print('Failed to download '..name..': '..msg);
        end
        res.close();
    end
    
    print('\nInstallation complete');
    print('Type tetris to start playing');

end

print()