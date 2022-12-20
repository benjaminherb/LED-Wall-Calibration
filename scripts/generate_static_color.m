conf.width = 1920;
conf.height = 1080;
conf.output_dir = "../output/";

%%
timestamp = datestr(datetime,'yyyymmdd_HHMMss');
if not(isfolder(conf.output_dir))
    mkdir(conf.output_dir)
end
mkdir(conf.output_dir + "/STATIC_COLOR", timestamp)
conf.output_dir = conf.output_dir + "/STATIC_COLOR/" + timestamp;
%%

for i = 0:1:255
image = repmat(i / 255, conf.height, conf.width);
for j = 0:1:4
    current_index = 5*i + j;
    disp(current_index);
    imwrite(image, conf.output_dir + "/" + num2str(current_index,'%04.f') + ".tiff");
end
end