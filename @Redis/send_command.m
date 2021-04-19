function send_command(obj, varargin)
%     persistent multi_cache
%     
%     if strcmpi(varargin{1}, 'multi')
%         multi_cache = command_to_resp_str(varargin{:});
%     end
%     
%     if ~isempty(multi_cache)
%         multi_cache = [multi_cache command_to_resp_str(varargin{:})];
%         if strcmpi(varargin{1}, 'exec')
%             obj.socket.write(uint8(multi_cache));
%             multi_cache = [];
%         end
%         return
%     end
    
    obj.socket.write(uint8(command_to_resp_str(varargin{:})));
end