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
            output(end+1) = readline(obj.con);
            while obj.con.NumBytesAvailable > 0
                output(end+1) = readline(obj.con);
            end
        end
        
        function enter_remote_mode(obj)
            obj.command("PHOTO");
            disp("Remote mode active");
        end
        
        function quit_remote_mode(obj)
            obj.command("Q");
        end
        
    end
end