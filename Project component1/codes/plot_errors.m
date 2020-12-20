word_errors = [];
letter_errors = [];
snr_vals = [];
for s = 3:0.1:18
% Tar's message(Input) 
text = 'HI I AM VARSHA FROM TELANGANA 508002';
%text = fileread('sample_data.m');
text = upper(text);
text = strjoin(strsplit(text));% avoiding multi spaces etc

% Encoding Tars msg to morse codes and converting message to digital
morse_code={'.----','..---','...--','....-','.....','-....','--...','---..','----.','-----','.-','-...','-.-.','-..','.','..-.','--.','....','..','.---','-.-','.-..','--','-.','---','.--.','--.-','.-.','...','-','..-','...-','.--','-..-','-.--','--..',' ','\n'}; 
Numbers_Or_Letters={'1','2','3','4','5','6','7','8','9','0','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z',' ','\n'};
text_encoded = [];
text_bits = [];
for i=1:length(text)
    [~, index] = ismember(text(i), Numbers_Or_Letters);
    if index > 0
        text_encoded = [text_encoded,morse_code{index}];
        t = morse_code{index};
        if t ~= ' '
            for k = 1:length(t)
                if t(k)=='.'
                  text_bits = [text_bits,1];
                elseif t(k)=='-'
                  text_bits = [text_bits,1,1,1];
                end
                text_bits = [text_bits,0];
            end
            text_bits = text_bits(1:end-1);
            text_bits = [text_bits, 0,0,0];
        else 
            text_bits = [text_bits,0,0,0,0,0,0,0];
            text_bits = text_bits(1:end-3);
        end
    end
end
text_bits = text_bits(1:end-3);

% BPSK modulation
text_modulated = [];
for n = 1:length(text_bits)
    if text_bits(n) == 1 
        text_modulated = [text_modulated,1];
    else
        text_modulated = [text_modulated,-1];
    end
end

% adding AWGN noise
%snr = s;
S = RandStream('mt19937ar','Seed',5489);  
text_corrupted = awgn(text_modulated,s,0,S);

% Threshold (which is found by MAL method)
 v= 0.2;
 
 
 % BPSK demodulation 
 text_demodulated = [];
 for n = 1:length(text_corrupted)
    if text_corrupted(n) >= v 
        text_demodulated = [text_demodulated,1];
    elseif text_corrupted(n) < v
        text_demodulated = [text_demodulated,-1];
    end
 end

%Converting demodulated signal into 0's and 1's
text_output = "";
text_output_bits = [];
for n = 1:length(text_demodulated)
    if text_demodulated(n) == 1
        text_output = text_output + '1';
        text_output_bits = [text_output_bits,1];
    else
        text_output = text_output + '0';
        text_output_bits = [text_output_bits,0];
    end
end

% Decoding th signal
words_bits = strsplit(text_output,'0000000');
words = [];
for i = 1:length(words_bits)
    char_bits = strsplit(words_bits(i),'000');
    char_text = "";
    for n = 1:length(char_bits)
        sub_bits = strsplit(char_bits(n),'0');
        letter_morse = "";
        %disp(sub_bits);
        for m = 1:length(sub_bits)
            if sub_bits(m) == '111'
                letter_morse = letter_morse + '-';
            elseif sub_bits(m)=='1'
                letter_morse = letter_morse + '.';
            else 
                choices = {'.', '-'};
                r = randi([1, 2], 1); % Get a 1 or 2 randomly, it is like tossing coin
                c = choices(r) ;
                letter_morse = letter_morse + c;
            end   
        end
        if ismember(letter_morse, morse_code)
            [~, index] = ismember(letter_morse, morse_code);
        else
            index = randi([1,length(Numbers_Or_Letters)-1],1);
        end
        char_text = char_text + Numbers_Or_Letters{index};
    end
    words = [words,char_text];
end

text_recieved = strjoin(words,' ');
w = word_error(text,text_recieved);
c = char_error(text,text_recieved);
snr_vals = [snr_vals,s];
word_errors = [word_errors,w];
letter_errors = [letter_errors,c];
end

%plotting letter error rate vs snr
%x=linspace(0,18,length(letter_errors));
f3 = figure(3);
set(f3,'color',[1 1 1]);
subplot(3,1,1);
plot(snr_vals,letter_errors);
ylabel('Letter error');
xlabel(' SNR(db)');
title('Letter error rate vs snr');

%plotting word error rate vs snr
x=linspace(0,18,length(word_errors));
subplot(3,1,2);
plot(x,word_errors);
ylabel('word error');
xlabel(' SNR(db)');
title('word error rate vs snr');

% function predicting word error 
function w = word_error(x,y)
x_words = strsplit(x,' ');
y_words = strsplit(y,' ');
mini =min(numel(x_words),numel(y_words));
x_words = x_words(1:mini);
y_words = y_words(1:mini);
cmp = strcmp(x_words,y_words);
cmp = sum(cmp);
w = length(x_words) - cmp;
w = w/length(x_words);
end 


% function predicting letter error
function c = char_error(x,y)
c = 0;
x_chars = split(x);
y_chars = split(y);
%x_chars = (x_chars)
mini =min(numel(x_chars),numel(y_chars));
x_chars = x_chars(1:mini);
y_chars = y_chars(1:mini);
for i = 1: length(x_chars)
    x_char = x_chars{i};
    y_char = y_chars{i};
    minis = min(length(x_char),length(y_char));
    x_char = x_char(1:minis);
    y_char = y_char(1:minis);
    for j = 1:length(x_char)
           if x_char(j) ~= y_char(j)%comparing message and recovered text characterwise
           c = c+1;
           
        end
    end
end
c = c/length(x);
end