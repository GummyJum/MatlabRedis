function res = socket_read(obj, mode)
% we have two read modes:
% - line: read to terminator
% - bytes: read n bytes
    if strcmpi(mode, 'line')
        [res, remain] = strtok(obj.read_buffer, obj.terminator);
        if numel(remain) >= numel(obj.terminator) && strncmp(remain, obj.terminator, numel(obj.terminator))
            obj.read_buffer = remain(1+numel(obj.terminator):end);
            return
        end
    elseif mode <= numel(obj.read_buffer)
        res = obj.read_buffer(1:mode);
        obj.read_buffer = obj.read_buffer(mode+1:end);
        return
    end
    
    check = read_to_buffer(obj);
    if ~check
        warning('redis timeout reached without any answer');
    else
        res = socket_read(obj, mode);
    end
end

function check = read_to_buffer(obj)
    check = false;
    total_wait = 0;
    while total_wait < obj.timeout
        while obj.socket.BytesAvailable
            obj.read_buffer = [obj.read_buffer, char(obj.socket.read)];
            check = true;
        end
        if check
            return
        end
        pause(obj.read_wait);
        total_wait = total_wait + obj.read_wait;
    end
end