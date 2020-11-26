function status = challenge_me(level)
%status = misc.challenge_me(level)
% status true if passed, false otherwise.
% level is number of letters to be asked
    if nargin < 1
        level = 1;
    else
        level = max(1,level);
    end
    text = 'For security reasons, please enter the letter';
    if level > 1
        text = [text,'s'];
    end
    challenge_letter = char(96+randi(26,1,level));
    status = strcmp(challenge_letter,input(sprintf('%s ''%s'': ',text,challenge_letter),'s'));
    if ~status
        warning('Consider being more careful next time!');
    end
end