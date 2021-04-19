function response = cmd(obj, varargin)
    varargin = unpack_cells(varargin);
    varargin(cellfun(@isempty, varargin)) = [];
    response = [];
    
    if strcmpi(varargin{1}, 'multi')
        obj.multi_stack = uint8(command_to_resp_str(varargin{:}));
        obj.multi_counter = 1;
        return
    end
    if ~isempty(obj.multi_stack)
        obj.multi_stack = [obj.multi_stack uint8(command_to_resp_str(varargin{:}))];
        obj.multi_counter = obj.multi_counter + 1;
        if strcmpi(varargin{1}, 'exec')
            obj.socket.write(obj.multi_stack)
            for ind = 1:obj.multi_counter  
                response = obj.read_response;         
            end
            obj.multi_stack = [];
        end
        return
    end
    
    send_command(obj, varargin{:});
    response = obj.read_response;
end

function send_command(obj, varargin)
    obj.socket.write(uint8(command_to_resp_str(varargin{:})));
end

function resp_str = command_to_resp_str(varargin)
    resp_str = sprintf('*%d%s', numel(varargin), Redis.params.terminator);
    redis_strings = cellfun(@(x)  to_redis_string(x), varargin, 'UniformOutput', false);
    redis_strings(cellfun(@isempty, redis_strings)) = [];
    args = cellfun(@(x) {[sprintf('$%d%s', numel(x), Redis.params.terminator), x]}, redis_strings);
    resp_str = [resp_str, strjoin(args, Redis.params.terminator), Redis.params.terminator];
end

function redis_str = to_redis_string(redis_str)
    if isstring(redis_str)
        redis_str = char(redis_str);
    end
    if isnumeric(redis_str)
        redis_str = num2str(redis_str);
    end
end            

function unpacked_cells = unpack_cells(cells)
    unpacked_cells = [];
    for cell_idx = 1:numel(cells)
        if iscell(cells{cell_idx})
            unpacked_cells = [unpacked_cells, unpack_cells(cells{cell_idx})];
        else
            unpacked_cells = [unpacked_cells, cells(cell_idx)];
        end
    end
end