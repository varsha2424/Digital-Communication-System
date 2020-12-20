% Tar's message(Input) 
text = input ('Enter input \n','s');
%text = fileread('sample_data.m');
text = upper(text);
text = strjoin(strsplit(text));% avoiding multi spaces etc
disp('Transmitted Text:');
disp(text);

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
                  text_bits = [text_bits,1];%appending 1 for '.'
                elseif t(k)=='-'
                  text_bits = [text_bits,1,1,1];%appending 1,1,1 for '-'
                end
                text_bits = [text_bits,0];%appending 0 after char in morse
            end
            text_bits = text_bits(1:end-1);
            text_bits = [text_bits, 0,0,0];%appending 0,0,0 after each char
        else 
            text_bits = [text_bits,0,0,0,0,0,0,0]; % appending 7 0's for spaces
            text_bits = text_bits(1:end-3);%removing last 3 unnecessary 0's
        end
    end
end
text_bits = text_bits(1:end-3);%removing last 3 unnecessary 0's
fprintf('\n');
disp("Encoded Input :");
disp(text_encoded);
disp("Digital Signal :");
disp(mat2str(text_bits));

% plotting Input signal as digital signal
x_bit=[]; 
nb=100; % bbit/bit
Tb=0.0001;
N = length(text_bits);
for n=1:1:N   % 
    if text_bits(n)==1 
       x_bitt=ones(1,nb);
    elseif text_bits(n)==0
        x_bitt=zeros(1,nb);
    end
     x_bit=[x_bit x_bitt];
end

t1=Tb/nb:Tb/nb:nb*N*(Tb/nb); % time of the signal 
f1 = figure(1);
set(f1,'color',[1 1 1]);
subplot(3,1,1);
plot(t1,x_bit,'lineWidth',2);grid on;
axis([ 0 Tb*N -0.5 1.5]);
ylabel('Amplitude(volt)');
xlabel(' Time(sec)');
title('Input signal as digital signal');


% BPSK modulation
text_modulated = [];
for n = 1:length(text_bits)
    if text_bits(n) == 1 
        text_modulated = [text_modulated,1];% appending 1 if bit is 1
    else
        text_modulated = [text_modulated,-1];%appending -1 if bit is 0
    end
end
disp("Modulated signal :");
disp(mat2str(text_modulated));%converting to string

% plotting modulated signal
xmod_bit=[]; 
N = length(text_modulated);
for n=1:1:N   
    if text_modulated(n)== 1 
       xmod_bitt=ones(1,nb);
    elseif text_modulated(n)== -1
        xmod_bitt= -ones(1,nb);
    end
     xmod_bit = [xmod_bit xmod_bitt];
end

subplot(3,1,2);
plot(t1,xmod_bit,'lineWidth',2);grid on;
axis([ 0 Tb*N -1.5 1.5]);
ylabel('Amplitude(volt)');
xlabel(' Time(sec)');
title('Modulated signal');


% adding AWGN noise
snr =10;
text_corrupted = awgn(text_modulated,snr);
disp("corrupted signal:");
disp(mat2str(text_corrupted));

% plotting corrupted signal :
xcor_bit=[]; 
N = length(text_corrupted);
for n=1:1:N   
     xcor_bitt= text_corrupted(n)*ones(1,nb);
     xcor_bit = [xcor_bit xcor_bitt];
end

subplot(3,1,3);
plot(t1,xcor_bit,'lineWidth',2);grid on;
axis([ 0 Tb*N -3 3]);
ylabel('Amplitude(volt)');
xlabel(' Time(sec)');
title('Corrupted signal');

% Threshold (which is found by MAL method)
 v= -0.0338;
 
 
 % BPSK demodulation 
 text_demodulated = [];
 for n = 1:length(text_corrupted)
    if text_corrupted(n) >= v 
        text_demodulated = [text_demodulated,1];%appending 1 if corrupted bit>=threshold
    elseif text_corrupted(n) < v
        text_demodulated = [text_demodulated,-1];%appending -1 if corrupted bit<threshold
    end
 end
disp("Demodulated Signal");
disp(mat2str(text_demodulated));%converting to string

% plotting demodulated signal
xdem_bit=[]; 
N = length(text_demodulated);
for n=1:1:N   
     xdem_bitt= text_demodulated(n).*ones(1,nb);
     xdem_bit = [xdem_bit xdem_bitt];
end
t2=Tb/nb:Tb/nb:nb*N*(Tb/nb);
f2 = figure(2);
set(f2,'color',[1 1 1]);
subplot(3,1,1);
plot(t2,xdem_bit,'lineWidth',2);grid on;
axis([ 0 Tb*N -1.5 1.5]);
ylabel('Amplitude(volt)');
xlabel(' Time(sec)');
title('Demodulated signal');
%check= isequal(text_modulated,text_demodulated)

%Converting demodulated signal into 0's and 1's
text_output = "";
text_output_bits = [];
for n = 1:length(text_demodulated)
    if text_demodulated(n) == 1
        text_output = text_output + '1';
        text_output_bits = [text_output_bits,1];%appending 1 if demodulated bit is 1
    else
        text_output = text_output + '0';
        text_output_bits = [text_output_bits,0];%appending 0 if demodulated bit is -1
    end
end

% Decoding th signal
words_bits = strsplit(text_output,'0000000');%splitting string to words at that pattern
disp("Recieved Digital signal")
disp(text_output)
words = [];
for i = 1:length(words_bits)
    char_bits = strsplit(words_bits(i),'000'); %splitting word to characters
    char_text = "";
    for n = 1:length(char_bits)
        sub_bits = strsplit(char_bits(n),'0'); %splitting chars to get morse codes
        letter_morse = "";
        %disp(sub_bits);
        for m = 1:length(sub_bits)
            if sub_bits(m) == '111'
                letter_morse = letter_morse + '-'; % adding '-' if '111'
            elseif sub_bits(m)=='1'
                letter_morse = letter_morse + '.'; % adding '.' if '1'
            else 
                choices = {'.', '-'};
                r = randi([1, 2], 1); % Get a 1 or 2 randomly, it is like tossing coin
                c = choices(r) ;
                letter_morse = letter_morse + c;
            end   
        end
        if ismember(letter_morse, morse_code)
            [~, index] = ismember(letter_morse, morse_code);% if the code found is member index is index of code 
        else
            index = randi([1,length(Numbers_Or_Letters)-1],1);% if it is not member I am taking some random index in that range
        end
        char_text = char_text + Numbers_Or_Letters{index};
    end
    words = [words,char_text];
end

%plotting output signal as digital signal
y_bit=[]; 
N = length(text_output_bits);
for n=1:1:N   
    if text_bits(n)==1 
       y_bitt=ones(1,nb);
    elseif text_bits(n)==0
        y_bitt=zeros(1,nb);
    end
     y_bit=[y_bit y_bitt];
end
subplot(3,1,2);
plot(t1,y_bit,'lineWidth',2);grid on;
axis([ 0 Tb*N -0.5 1.5]);
ylabel('Amplitude(volt)');
xlabel(' Time(sec)');
title('Output signal as digital signal');


text_recieved = strjoin(words,' ');
disp("Recieved text :");
disp(text_recieved);
disp('Final msg:');
w = word_error(text,text_recieved);
c = char_error(text,text_recieved);
check= isequal(text,text_recieved);
if check
    disp('Great! we recived the exact msg');
else
    msg = 'Sry.. we recieved msg with word error rate %f and letter error rate %f';
    fprintf(msg,w,c);
    fprintf('\n');
end

% function predicting word error 
function w = word_error(x,y)
x_words = strsplit(x,' ');%splitting input words
y_words = strsplit(y,' ');%splitting output words
mini =min(numel(x_words),numel(y_words));%finding min no of words
x_words = x_words(1:mini);%changing length to min no of words
y_words = y_words(1:mini);
cmp = strcmp(x_words,y_words);%comparing words
cmp = sum(cmp);
w = length(x_words)- cmp;%getting sum of not equal words
w = w/length(x_words);
end 

% function predicting letter error
function c = char_error(x,y)
c = 0;
x_chars = split(x);%splitting input words
y_chars = split(y);%splitting output words

mini =min(numel(x_chars),numel(y_chars));%finding min no of words
x_chars = x_chars(1:mini);%changing length to min no of words
y_chars = y_chars(1:mini);
for i = 1: length(x_chars)
    x_char = x_chars{i}
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