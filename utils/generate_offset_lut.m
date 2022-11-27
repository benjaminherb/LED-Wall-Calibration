function generate_offset_lut (measured_curve, reference_curve, output_dir, gamma, filename)

if not(isfolder(output_dir))
    mkdir(output_dir)
end
gamma_string = string(gamma*10);
output_filename = output_dir +  datestr(datetime,'yyyymmdd_HHMMss_') + filename  + '_gamma_' + gamma_string + '.gamdat'; 

offset_curve = reference_curve + (reference_curve - measured_curve);
offset_curve = offset_curve .* 2^16;
offset_curve = uint16(offset_curve);

output_file = fopen(output_filename, 'w');
fprintf(output_file, gamma_string + '*0#255#0#65535#');

first_number = 1; % Avoid the comma at the eof
for i = 1:1:length(offset_curve)
    if(first_number)
        fprintf(output_file, string(offset_curve(i)));
        first_number = 0;
    else
        fprintf(output_file, "," + string(offset_curve(i)));
    end
end
