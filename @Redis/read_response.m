function response = read_response(obj)
    % we have 5 possible responses first char +-:$*
    socket_line = obj.socket_readline;
    if isempty(socket_line)
        response = '';
        return
    end
    raw = strip(socket_line);

    if isempty(raw)
        error('ConnectionError(SERVER_CLOSED_CONNECTION_ERROR)');
    end

    prefix = raw(1);
    response = raw(2:end);

    if all(prefix ~= '+-:$*')
        error('InvalidResponse("Protocol Error: %s")', raw);
    end

    if prefix == '-'
        return
    elseif prefix == '+'
        % PASS
    elseif prefix == ':'
        % response = int64(str2double(response));
    elseif prefix == '$'
        len = int32(str2double(response));
        if len == -1
            response = [];
            return
        end
        response = strip(char(obj.socket.read(len+2)));
    elseif prefix == '*'
        len = int32(str2double(response));
        if len == -1
            response = [];
            return
        end
        response = cell(1, len);
        for ind = 1:len
            response{ind} = obj.read_response;
        end
    end
end