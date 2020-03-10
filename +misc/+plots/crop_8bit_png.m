function filename = crop_8bit_png(filename,OVERWRITE)
%filename = misc.plots.crop_8bit_png(filename,[OVERWRITE=false])

    if nargin < 2
        OVERWRITE = [];
    end
    if isempty(OVERWRITE)
        OVERWRITE = false;
    end

    data = imread(filename,'png');

    assert(isa(data,'uint8'),'only 8 bit png');

    tocrop = 255;

    data = 255-double(data);

    Hdata = squeeze(sum(data,3));

    idx1 = find(sum(Hdata,2));
    idx2 = find(sum(Hdata,1));

    data = 255-data(idx1(1):idx1(end),idx2(1):idx2(end),:);
    data = uint8(data);

    if OVERWRITE
        imwrite(data,filename,'png');
    else
        [filepath,name,ext] = fileparts(filename);
        filename = fullfile(filepath,[name,'_cropped',ext]);
        assert(~exist(filename,'file'),'File already exists: ''%s''.',filename);
        imwrite(data,filename,'png');
    end

end
