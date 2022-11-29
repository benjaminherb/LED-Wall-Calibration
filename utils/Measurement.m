classdef Measurement
    properties
        name;
        X;Y;Z;
        x;y;
        u;v;
        spd;
        ref_lum;
    end
    
    methods
        function obj = Measurement(s, ref_lum)
            % allow  for the .empty() function
            if nargin == 0
                return
            end
            
            obj.name = s.measurement;
            obj.X = s.XYZ.X;
            obj.Y = s.XYZ.Y;
            obj.Z = s.XYZ.Z;
            obj.x = s.Yxy.x;
            obj.y = s.Yxy.y;
            obj.u = s.Yuv.u;
            obj.v = s.Yuv.v;
            obj.spd = s.spectral;
            
            if ~exist('ref_lum', 'var')
                ref_lum = 100;
            end
            obj.ref_lum = ref_lum;
            
        end
        
        function r = get_XYZ(obj, mode)
            if ~exist('mode', 'var')
                mode = "absolute";
            end
            if (mode == "scaled")
                r = [obj.X / obj.ref_lum, obj.Y / obj.ref_lum, obj.Z / obj.ref_lum];
            elseif (mode == "absolute")
                r = [obj.X, obj.Y,  obj.Z];
            else
                disp("INVALID MODE! CHOOSE EITHER 'scaled' or 'absolute'");
            end
        end
        
        function r = get_Lab(obj, wp)
            if ~exist('wp', 'var')
                wp = "D65";
            end
            r = xyz2lab(obj.get_XYZ("scaled"), 'WhitePoint', wp);
        end
    end
end