function data_out = load_excel_data(filename,sheet)

data_in = xlsread(filename,sheet);

spot_IDs = data_in(:,1);
frame_nums = data_in(:,2);
X = data_in(:,3);
Y = data_in(:,4);
extra_column = zeros(size(spot_IDs));

ID_nums = unique(spot_IDs);

data_out = horzcat(extra_column,spot_IDs,frame_nums,X,Y);
logentry(['Loaded *' filename '* which contains ' num2str(length(ID_nums)) ' initial trackers.']);
end
