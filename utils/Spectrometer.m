classdef Spectrometer
    
    properties
        con
    end
    
    methods
        function obj = Spectrometer(port)
            try
                % may need privilidged execution
                obj.con = serialport(port, 115200);
                
                % increase timeout, to avoid stopping the readout before the measurement ends
                obj.con.Timeout = 30;
                
                disp("Connection successful");
                obj.enter_remote_mode()
                
            catch exception
                switch exception.identifier
                    case 'serialport:serialport:ConnectionFailed'
                        disp("CONNECTION FAILED");
                        disp(exception.message);
                        disp("You can check connected devices with 'serialportlist' or run with priviliges if permission was denied ");
                        return;
                    otherwise
                        disp("UNKNOWN EXCEPTION (" + exception.identifier + ")");
                        disp(exception.message);
                        return;
                end
            end
            
        end
        
        function output = command(obj, string)
            for  i = 1:strlength(string)
                write(obj.con, char(extract(string,i)), "uint8");
            end
            write(obj.con, char(13),"uint8"); % = [CR] ("newline") to end the command
            
            output = strings();
            output(end) = readline(obj.con);
            pause(0.5); % otherwise some long outputs are skipped
            while obj.con.NumBytesAvailable > 0
                output(end+1) = readline(obj.con);
            end
            flush(obj.con);
        end
        
        function enter_remote_mode(obj)
            obj.command("PHOTO");
            disp("Remote mode active");
        end
        
        function quit_remote_mode(obj)
            obj.command("Q");
        end
        
        function b = is_connected(obj)
            if isempty(obj.con)
                b = false;
            else
                b = true;
            end
        end
        
        function result = measure(obj, input, mode)
            % option to specify mode D
            if ~exist('mode', 'var')
                mode = "M";
            end
            
            % empty function call returns all values
            if ~exist('input', 'var')
                input = "all";
            end
            
            switch input
                case "Yxy"
                    fprintf("Measuring CIE1931 Yxy:");
                    out = obj.command(mode + "1");
                    out = strsplit(out, ',');
                    result = struct(...
                        'value', out(1),...
                        'unit', out(2), ...
                        'Y', str2double(out(3)), ...
                        'x', str2double(out(4)), ...
                        'y', str2double(out(5)));
                    fprintf("  Y: " + result.Y + "  x: " + result.x + "  y: " + result.y +"\n");
                    
                case "XYZ"
                    fprintf("Measuring CIE1931 XYZ:");
                    out = obj.command(mode + "2");
                    out = strsplit(out, ',');
                    result = struct(...
                        'value', out(1),...
                        'unit', out(2), ...
                        'X', str2double(out(3)), ...
                        'Y', str2double(out(4)), ...
                        'Z', str2double(out(5)));
                    fprintf("  X: " + result.X + "  Y: " + result.Y + "  Z: " + result.Z + "\n");
                     
                case "Yuv"
                    fprintf("Measuring CIE1976 u'v':");
                    out = obj.command(mode + "3");
                    out = strsplit(out, ',');
                    result = struct(...
                        'value', out(1),...
                        'unit', out(2), ...
                        'Y', str2double(out(3)), ...
                        'u', str2double(out(4)), ...
                        'v', str2double(out(5)));
                    fprintf("  Y: " + result.Y + "  u: " + result.u + "  v: " + result.v + "\n");
                    
                case "spectral"
                    fprintf("Measuring Spectral Distribution:");
                    out = obj.command(mode + "5");
                    first_out = strsplit(out(1), ',');
                    
                    spd = NaN(length(out)-1,2);
                    for i = 2:length(out)
                        s = strsplit(out(i), ',');
                        spd(i-1,1) = s(1);
                        spd(i-1,2) = s(2);
                    end
                    
                    result = struct(...
                        'value', first_out(1),...
                        'unit', first_out(2), ...
                        'peak_wavelength', str2double(first_out(3)), ...
                        'integrated_radiometric_value', str2double(first_out(4)), ...
                        'integrated_photon_radiometric_value', str2double(first_out(5)), ...
                        'spd', spd);
                    fprintf("  Peak WL: " + result.peak_wavelength + "  Int. Radiometr.: " ...
                    + result.integrated_radiometric_value + "  Int. Photon Radiometr.: " ...
                    + result.integrated_photon_radiometric_value + "\n");

                case "all"
                    disp("MEASURING ALL");
                    result = struct(...
                        'Yxy', obj.measure("Yxy"), ...
                        'XYZ', obj.measure("XYZ", "D"), ...
                        'Yuv', obj.measure("Yuv", "D"), ...
                        'spectral', obj.measure("spectral", "D"));
                    
                otherwise
                    disp("Unknown measurement mode! Possible options are:\n" + ...
                        "'XYZ', 'Yxy', 'Yuv', 'spectra', 'all'")
                    return
            end
        end
    end
end