function status = challenge_me(level)
%status = misc.challenge_me(level)
    if nargin < 1
        level = 1;
    else
        level = max(1,level);
    end
    challenge_letter = char(96+randi(26,1,level));
    status = strcmp(challenge_letter,input(sprintf('For security reasons, please enter the letter(s) ''%s'': ',challenge_letter),'s'));
    assert(status,'Consider being more careful next time!');
end