function sharedRFs = getLFPSharedRFs()
% load shared RFs -- 55 sessions included
% column 1: session name
% column 2: RF location (1-6). -1 = exclude the session
sharedRFs = {...
        'C110524',1;
        'C110527',1;
        'C110531',1; % or P2
        'C110601',1;
        'C110602',-1; % drop -- tentatively drop -- 22 trials, but evoked potentials in TEO, LIP
        'C110603',1; %%% compare with P3; P1 is good for V4 and LIP, but not so much for Pul
        'C110607',-1; % drop -- 10 trials
        'C110608',1;
        'C110609',-1; % drop -- tentatively drop -- 30 trials, but evoked potentials in TEO
        'C110610',1; %%% compare with P2; P1 is good for V4 and LIP, but not as much for Pul
        'C110613',1; %%% compare with P3 (noisy for P3 in LIP and V4)
        'C110614',1; %%% compare with P2
        'C110615',1; %%% compare with P2
        'C110616',1; 
        'C110617',2;
        'C110622',-1; % drop -- tentatively drop -- 30 trials, but evoked potentials in PUL, TEO, V4
        'C110623',3;
        'C110624',3;
        'C110629',-1; % drop -- tentatively drop -- 29 trials, but evoked potentials in PUL, TEO, V4
        'C110630',2; %%% compare with P1, which is a little better for LIP % conflictig RF for LIP -- leave out for LIP-network analysis?
        'C110701',3; %%%%% agreed %%% Ryan had P1, I think P3 is better; % or P2, P3
        'C110708',1; %%%%% agreed %%% Ryan had P2, I think P1 is better; % or P3. weak RF for PUL
        'C110712',-1; % drop -- 15 trials
        'C110713',2; %%% compare with P1
        'C110720',3; 
        'C110721',-1; % drop -- 13 trials
        'C110722',1; % or P2
        'C110726',-1; % drop -- 5 trials
        'C110727',-1; % drop -- 9 trials
        'C110728',1; %%%%% noise at 60, 80, 100, 120 Hz %%% 120Hz noise? harmonic of line noise?
        'C110803',-1; % drop -- 19 trials
        'C110804',3;
        'C110809',4;
        'C110811',3; %%%%% agreed %%% Ryan had P1, I think P3 is better; P1 evoked poential a bit odd for V4; % LIP needs filtering
        'C110812',-1; % drop -- 21 trials
%         'L100913',-1; % drop -- bad data -- not enough trials?
        'L100927',-1; %%% don't use Pul - noisy; % no LIP, V4
        'L100928',-1; %%% drop -- don't use as common signal in all AD; previously P2 was designated here
        'L101001',-1; % drop -- all AD variables identical
        'L101007',3; %%% compare with P6; % or P1
        'L101008',1;
        'L101011',1;
        'L101012',1; %%% compare with P2 
        'L101013',1;
        'L101014',3; %%%%% agreed %%% Ryan had P1, I think P3 is better; P3 is best for Pul and V4, and still generates response from LIP 
        'L101018',-1; %%% P6 works for both Pul and LIP; % no TEO or V4
        'L101019',2; %%% compare with P6
        'L101020',2;
        'L101021',1;
        'L101022',3; %%% compare with P1
        'L101025',1;
        'L101027',3;
        'L101029',-1; %%%%% I disagree b/c P6 is the best position for LIP and P3 generates only a weak response for LIP %%% Ryan had no good match, but I think P3 is best for Pul and V4, and still generates response from LIP; % no good match
        'L101102',1;
        'L101103',3; %%% compare with P2; although LIP response shown in bars is reasonable for P3, evoked waveform for P3 differs from others
        'L101105',6; %%%%% This is ok but I'm on the fence %%% Ryan had no good match, but I think P6 is best for Pul, and still generates response from LIP and V4 (clearer when looking at evoked waveforms rather than bar graph); % no good match
        'L101119',-1; %%% for Pul-V4 coherence use P3, or even P2; % no LIP
        'L101123',-1; %%% for Pul-V4 coherence use P3, or even P2; % no LIP
        'L101124',-1; %%%%% don't use Pul - noisy %%% for Pul-V4 coherence use P1 (although Pul LFP noisy?), or even P2; % no LIP
        'L101208',3; % or P1
        'L101209',1;
        'L101214',3; %%% compare with P1
        'L101215',1;
        'L101216',3; %%% compare with P1
        'L101221',2; %%% there seems to be a P2-evoked, although small, response in Pul % conflicting RF for PUL -- leave out for PUL-network analysis?
        'L101222',3; %%% P3 gives clear early latency response in PUL (but P1 shown as best position in bar graph); % possibly conflicting RF for PUL -- leave out for PUL-network analysis?
        'L110411',-1; %%% P4? early response; % no LIP, TEO, V4
        'L110412',-1; %%% P2?; % no LIP, TEO, V4
        'L110413',-1; %%% P1; % no LIP, TEO, V4
        'L110414',-1; % drop -- 36 trials, PUL only but no clear evoked potential
        'L110419',-1; %%% no clear evoked response % no LIP, TEO, V4
        'L110420',-1; %%% P6; % no LIP, TEO, V4
        'L110421',-1; %%% P3; % no LIP, TEO, V4
        'L110422',-1; %%% P3; % no LIP, TEO, V4
        'L110426',1;
        'L110429',2;
        'L110502',3; %%% compare with P2
        'L110503',3;
        'L110504',-1; %%% P2; % no PUL, LIP, V4
        'L110519',2;
        'L110523',3;
        'L110524',3;
        'L110531',3; %%% compare with P2
        'L110711',-1; %%% P2; % no V4
        % 'L110810',-1; %%% no LFP
        'L110811',-1; %%% P3; % no LIP, TEO, V4
        'L110812',1; % conflicting RF for V4 -- leave out for V4-network analysis?
        };