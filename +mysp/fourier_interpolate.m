function s_ip = fourier_interpolate( s, ip_fct, varargin )

    assert(mod(ip_fct,1)==0,'Input parameter "ip_fct" must be integer valued.')

    p = inputParser();
    validDomain = @(x) strcmp(x,'t') || strcmp(x,'f');
    addParameter(p,'domain','t',validDomain);
    p.parse(varargin{:});

    if strcmp(p.Results.domain,'t')
        s_f = fft(s);
        s_f_zp = [s_f(1:floor(size(s,1)/2)+1,:);...
            zeros(size(s,1)*(ip_fct-1),size(s,2));...
            s_f(floor(size(s,1)/2)+2:end,:)];
        s_ip = ip_fct*ifft(s_f_zp);
    else
        s_t = ifft(s);
        s_t_zp = [s_t; zeros(size(s_t,1)*(ip_fct-1),size(s_t,2))];
        s_ip = fft(s_t_zp)/ip_fct;
    end

end