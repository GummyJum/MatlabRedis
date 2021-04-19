function hashStr = sha1(str)
    % Main class of interest:    System.Security.Cryptography.HashAlgorithm
    % Create any specified cryptographic hasher.
    % Supported string args include 'MD5', 'SHA1', 'SHA256', 'SHA384', 'SHA512'.
    hasher = System.Security.Cryptography.HashAlgorithm.Create('SHA1');

    % Convert the char string to uint8 type & run it through the hasher
    hash_byte = hasher.ComputeHash( uint8(str) );

    % Convert the System.Byte class to MATLAB 1xN uint8 number array by typecasting.
    hash_uint8 = uint8( hash_byte );

    % Convert uint8 to a Nx2 char array of HEX values
    hash_hex = dec2hex(hash_uint8);

    % FINALLY, convert the Nx2 hex char array to a 1x2N format
    % Example Result:    '12582D...'
    hashStr = str([]);
    nBytes = length(hash_hex);
    for k=1:nBytes
        hashStr(end+1:end+2) = hash_hex(k,:);
    end
    hashStr = lower(hashStr);
end