function line = socket_readline(obj)
    line = [];
    total_wait = 0;
    while total_wait < obj.timeout
        while obj.socket.BytesAvailable
            line = [line, char(obj.socket.read(1))];
            if length(line) >= 2 && strcmp(line((end-1):end), Redis.params.terminator)
                break
            end
        end
        if ~isempty(line)
            return
        end
        pause(obj.read_wait);
        total_wait = total_wait + obj.read_wait;
    end
    warning('redis timeout reached without any answer');
end