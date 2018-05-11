%this = percent_bar(varargin)
%
% Parameters to be set:
%         'char_bar'
%         'char_side'
%         'char_empty'
%         'char_blink'
%         'bar_length'
%         'blink_interval'
%         'selftime_show'
%         'datestr_format'
%         'self_time_warn_percent'
%
%         'CMDLINE_ONLY'
%
%
% UPDATES:
% - waitbar can be closed without killing parent
% - waitbar window is opened at initialization

classdef percent_bar < handle
    
    properties (SetAccess = private)
        
        bar_length;
        bar_character;
        side_character;
        empty_character;
        blink_character;
        blink_interval;
        
        
        CMDLINE_ONLY;
        SHOW_SELFTIME;
        
        datestr_format;
        self_time_warn_percent;
        
        t_tot = [];
        t_self = [];
        
        time_start = [];
        time_end = [];
        
        NAME = 'Percent Bar';
        
    end
    
    properties (Access = private)
        
        bar_length_min = 4;
        bar_characters_not_allowed = ['%' , '\'];
        
        N_msg_characters;
        msg_old;
        percent_done_old;
        tic_start;
        
        blink_ON;
        blink_start;
        
        
        WB = [];
        
        MODE = [];
        
    end
    
    
    methods
        
        function this = percent_bar(varargin)
            
            this.parse_input(varargin);
            
            this.reset_percent_bar();
            
            if this.CMDLINE_ONLY
                this.MODE = @ this.iteration_finished_CMD_ONLY;
            else
                this.MODE = @ this.iteration_finished_WAITBAR;
            end
            
        end
        
        function init_loop(this)
            
            fprintf('Start ...\n');
            
            this.start();
            
            this.iteration_finished(0);
            
        end
        
        function reset_percent_bar(this)
            
            this.N_msg_characters = 0;
            this.msg_old = '\';
            this.percent_done_old = -Inf;
            this.blink_ON = 0;
            
            this.t_tot = [];
            this.t_self = [];
            
            this.time_start = [];
            this.time_end = [];
            
            close(this.WB);
            this.WB = [];
            
        end
        
        function iteration_finished(this,percent_done)
            
            t0 = tic;
            
            if isempty(this.time_start)
                warning('percent_bar: Not proberly initialized. Time estimates may be wrong. Use init_loop.');
                this.start();
            end
            
            this.MODE(percent_done);
            
            this.t_self = this.t_self + toc(t0);
            
            if percent_done == 1
                this.finish();
            end
            
        end
	
    end
    
    methods (Access = private)
        
        function parse_input(this,Hvarargin)
            
            p = inputParser;
            
            addParameter(p,'char_bar',       '=', @(x) ischar(x) && isscalar(x) && ~ismember(x,this.bar_characters_not_allowed));
            addParameter(p,'char_side',      '|', @(x) ischar(x) && ~ismember(x,this.bar_characters_not_allowed));
            addParameter(p,'char_empty',     ' ', @(x) ischar(x) && isscalar(x) && ~ismember(x,this.bar_characters_not_allowed));
            addParameter(p,'char_blink',     '.', @(x) ischar(x) && isscalar(x) && ~ismember(x,this.bar_characters_not_allowed));
            addParameter(p,'bar_length',     100, @(x) isnumeric(x) && isscalar(x));
            addParameter(p,'blink_interval', 0,   @(x) isnumeric(x) && isscalar(x));
            
            addParameter(p,'selftime_show',   0, @(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
            addParameter(p,'CMDLINE_ONLY',  0, @(x) validateattributes(boolean(x),{'logical'},{'scalar'}));
            addParameter(p,'datestr_format','dd.mm.yyyy HH:MM', @(x) all(boolean(datestr(now,x))));
            addParameter(p,'warn_high_selftime',0.1, @(x) validateattributes(x,{'numeric'},{'scalar','>=',0,'<=',1}));
            
            parse(p,Hvarargin{:});
            
            this.bar_character = p.Results.char_bar;
            this.side_character = p.Results.char_side;
            this.empty_character = p.Results.char_empty;
            this.blink_character = p.Results.char_blink;
            this.bar_length = max(this.bar_length_min,p.Results.bar_length);
            this.blink_interval = p.Results.blink_interval;
            
            this.CMDLINE_ONLY = boolean(p.Results.CMDLINE_ONLY);
            this.SHOW_SELFTIME = boolean(p.Results.selftime_show);
            this.datestr_format = p.Results.datestr_format;
            this.self_time_warn_percent = p.Results.warn_high_selftime;
            
        end
        
        function start(this)
            
            this.reset_percent_bar();
            
            this.time_start = now;
            this.tic_start = tic;
            this.t_self = 0;
            
        end
        
        function finish(this)
            
            fprintf('End time: %s\n' , datestr(now,this.datestr_format));
            
            if ~isempty(this.tic_start)
                
                toc(this.tic_start);
                
                this.time_end = now;
                this.t_tot = toc(this.tic_start);
                
                if this.SHOW_SELFTIME
                    fprintf('Self time percent_bar: %.2f %%\n',100*this.t_self/this.t_tot);
                end
                
                if this.t_self/this.t_tot > this.self_time_warn_percent
                    warning('percent_bar: self time > %.1f %%',100*this.self_time_warn_percent);
                end
                
            end
            
        end
        
    	function iteration_finished_WAITBAR(this,percent_done)
            
            [ ~ , time_end_est_string ] = this.get_estimated_endtime(percent_done);
            msg = time_end_est_string;
            
            this.waitbar_update(percent_done,msg);
            
            if percent_done == 1
                close(this.WB);
            end
            
        end
        
        function iteration_finished_CMD_ONLY(this,percent_done)
            
            Hpercent_done = percent_done * 100;
            
            Hpercent_done = round(Hpercent_done,0);
            
            if this.percent_done_old ~= Hpercent_done
                
                if this.blink_interval > 0
                    if isempty(this.blink_start)
                        this.blink_start = tic;
                    end
                    
                    if toc(this.blink_start) > abs(this.blink_interval)
                        this.blink_start = tic;
                        this.blink_ON = ~this.blink_ON;
                    end
                    
                    if this.blink_ON
                        Hempty_character = this.blink_character;
                    else
                        Hempty_character = this.empty_character;
                    end
                else
                    Hempty_character = this.empty_character;
                end
                
                if this.blink_interval < 0
                    if isempty(this.blink_start)
                        this.blink_start = tic;
                    end
                    
                    if toc(this.blink_start) > abs(this.blink_interval)
                        this.blink_start = tic;
                        this.blink_ON = ~this.blink_ON;
                    end
                    
                    if this.blink_ON
                        Hside_character = this.empty_character;
                    else
                        Hside_character = this.side_character;
                    end
                else
                    Hside_character = this.side_character;
                end
                
                this.percent_done_old = Hpercent_done;
                if Hpercent_done < 100*(1/2-1/this.bar_length)
                    str_pad_with = Hempty_character;
                    msg = [repmat(this.bar_character,1,floor(Hpercent_done/100*this.bar_length)) , repmat(Hempty_character,1,1 + this.bar_length - floor(Hpercent_done/100*this.bar_length))];
                else
                    str_pad_with = this.bar_character;
                    msg = [repmat(this.bar_character,1,1 +floor(Hpercent_done/100*this.bar_length)) , repmat(Hempty_character,1,this.bar_length - floor(Hpercent_done/100*this.bar_length))];
                end
                msg_percent = pad(sprintf('%.0f%%%%',Hpercent_done),5,'left',str_pad_with);
                msg(round(this.bar_length/2)-1:round(this.bar_length/2)+3) = msg_percent;
                msg = [Hside_character , msg , Hside_character , '\n'];
                
                [ ~ , time_end_est_string ] = this.get_estimated_endtime(Hpercent_done/100);
                msg = [msg , time_end_est_string , '\n'];
                
                % Delete and print
                fprintf(repmat('\b',1,this.N_msg_characters-this.count_forbidden_characters(this.msg_old)+1));
                fprintf(msg);
                this.N_msg_characters = numel(msg);
                this.msg_old = msg;
                
            end
            
        end
        
        function [ time_end_est , time_end_est_string ] = get_estimated_endtime(this,percent_done)
            
            validateattributes(percent_done,{'numeric'},{'scalar','>=',0,'<=',1});
            
            if isempty(this.tic_start) || percent_done == 0
                time_end_est = [];
            else
                t_elapsed = toc(this.tic_start);
                t_overall_est = t_elapsed/percent_done;
                time_end_est = now + (t_overall_est - t_elapsed)/60/60/24;
            end
            
            if ~isempty(time_end_est)
                time_end_est_string = ['Estimated end time: ' , datestr(time_end_est,this.datestr_format)];
            else
                time_end_est_string = 'Estimated end time: --:--';
            end
            
        end
        
        function cnt = count_forbidden_characters(this,msg)
            
            cnt = 0;
            for ii = 1:numel(this.bar_characters_not_allowed)
                cnt = cnt + length(strfind(msg,this.bar_characters_not_allowed(ii)));
            end
            
        end
        
        function waitbar_update(this,percent_done,msg)
            
            if isempty(this.WB)
                this.WB = waitbar(percent_done,msg,'name',this.NAME);
            else
                if ~isvalid(this.WB)
                    this.WB = waitbar(percent_done,msg,'name',this.NAME);
                else
                    waitbar(percent_done,this.WB,msg);
                end
            end
            
        end
        
    end
    
end