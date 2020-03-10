function Ytd_deemb = deembed_VSA_data(data,filename_calfile)
%Ytd_deemb = misc.deembed_VSA_data(data,filename_calfile)
%
% data             ... VSA data 
% filename_calfile ... Char vector or cell array of char vectors. S2P files. (S21 is used.)

    if nargin == 1
        filename_calfile = {};
    end
    
    if ~iscellstr(filename_calfile)
        assert(ischar(filename_calfile) & isvector(filename_calfile),'filename_calfile must be char vector or cell array of char vectors.');
        filename_calfile = {filename_calfile};
    end
    
    Ytd_deemb = data.Y;
    
    if ~isempty(filename_calfile)
        
        N = numel(data.Y);
        fs = 1/data.XDelta;
        [ ~ , ff , ~ ] = misc.init_tt_ff(N,fs);
        ff_data = ff + data.InputCenter;

        Yfd_deemb = fftshift(fft(double(Ytd_deemb)));

        for ii = 1:numel(filename_calfile)

            sobj = sparameters(filename_calfile{ii});

            ff_cal = sobj.Frequencies;
            S21 = squeeze(sobj.Parameters(2,1,:));

            S21_mag = abs(S21);
            S21_ang = unwrap(angle(S21));
            S21_data = interp1(ff_cal,S21_mag,ff_data).*exp(1i*interp1(ff_cal,S21_ang,ff_data));

            assert(~any(isnan(S21_data)),'Frequency range of cal file is not large enough for given data.%sCal file: ''%s''',newline,filename_calfile{ii})

            Yfd_deemb = Yfd_deemb ./ S21_data;

        end
        
        Ytd_deemb = single(ifft(ifftshift(Yfd_deemb)));

    end
    
end