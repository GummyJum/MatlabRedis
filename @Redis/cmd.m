function response = cmd(obj, varargin)
    varargin = unpack_cells(varargin);
    varargin(cellfun(@isempty, varargin)) = [];
    response = [];
    
    if strcmpi(varargin{1}, 'multi')
        obj.multi_stack = uint8(obj.command_to_resp_str(varargin{:}));
        obj.multi_counter = 1;
        return
    end
    if ~isempty(obj.multi_stack)
        obj.multi_stack = [obj.multi_stack uint8(obj.command_to_resp_str(varargin{:}))];
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
    obj.socket.write(uint8(obj.command_to_resp_str(varargin{:})));
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