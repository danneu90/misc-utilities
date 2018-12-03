function status = challenge_me()
    challenge_letter = char(96+randi(26));
    status = all(challenge_letter == input(sprintf('For security reasons, please enter the letter ''%s'': ',challenge_letter),'s'));
end