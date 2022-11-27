%% SETUP

clear

% USER CONFIG

conf.data_dir ="../measurements/primaries_comparison/";

% LOAD DATA

files = dir(conf.data_dir + "/*.json")';

primaries_pc = NaN(5,9);
primaries_wall = NaN(5, 9);

for i = 1:1:length(files)
    
    json_text = fileread(string(files(i).folder) + "/" + string(files(i).name));
    data = jsondecode(json_text);
    
    match = regexp(files(i).name, "\d{8}_\d{6}_(?<name>.*?)(?<number>\d*).json", "names");
    match.number = str2num(match.number);
    
    if (contains(match.name, "wall"))
        primaries_wall(match.number,:) = [ ...
            data(1).Yuv.Y, data(1).Yuv.u, data(1).Yuv.v, ...
            data(2).Yuv.Y, data(2).Yuv.u, data(2).Yuv.v, ...
            data(3).Yuv.Y, data(3).Yuv.u, data(3).Yuv.v, ...
            ];
    else
        primaries_pc(match.number,:) = [ ...
            data(1).Yuv.Y, data(1).Yuv.u, data(1).Yuv.v, ...
            data(2).Yuv.Y, data(2).Yuv.u, data(2).Yuv.v, ...
            data(3).Yuv.Y, data(3).Yuv.u, data(3).Yuv.v, ...
            ];
    end
    
end

clear("i", "files", "json_text", "match"); % clear temp variables

%% PLOT

figure("Name", "Primaries Wall - PC Output", "NumberTitle", "off", "Position", [0 0 1300 600] );
tiledlayout(1,2);

mean_pc = get_mean(primaries_pc);
mean_wall = get_mean(primaries_wall);

% UV PLOT
uv_plot = nexttile;

hold on
plotChromaticity("ColorSpace", "uv")

plot([mean_pc.u.red, mean_pc.u.green, mean_pc.u.blue, mean_pc.u.red], ...
    [mean_pc.v.red, mean_pc.v.green, mean_pc.v.blue, mean_pc.v.red], ...
    'white');

plot([mean_wall.u.red, mean_wall.u.green, mean_wall.u.blue, mean_wall.u.red], ...
    [mean_wall.v.red, mean_wall.v.green, mean_wall.v.blue, mean_wall.v.red], ...
    'black');

hold off

% BRIGHTNESS COMPARISON
bar_graph = nexttile;
categories = categorical({'RED','GREEN','BLUE'});
categories = reordercats(categories,{'RED','GREEN','BLUE'});

b = bar(categories, [mean_pc.Y.red, mean_wall.Y.red; mean_pc.Y.green, mean_wall.Y.green; mean_pc.Y.blue, mean_wall.Y.blue]);
ylabel("Luminance in cd/m²");
label_bar_graph(b)
legend('PC', 'WALL');


%% HELPER FUNCTIONS
function label_bar_graph(bar)
for b = bar
    xtips = b.XEndPoints;
    ytips = b.YEndPoints;
    labels = string(b.YData);
    text(xtips,ytips,labels, ...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom');
end
end

function r = get_mean(s)
% function to get readable mean values from the primary lists
r = struct( ...
    'Y', struct('red', mean(s(:,1)), 'green', mean(s(:,4)), 'blue', mean(s(:,7))),  ...
    'u', struct( 'red', mean(s(:,2)), 'green', mean(s(:,5)), 'blue', mean(s(:,8))), ...
    'v', struct( 'red', mean(s(:,3)), 'green', mean(s(:,6)), 'blue', mean(s(:,9))));
end