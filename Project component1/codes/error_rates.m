x = 'HI I AM VARSHA FROM TELANGANA 508001';
y = 'HI E KM VARSHA FRRM TELANAGANA';
w = word_error(x,y)
c = char_error(x,y)
%x_words = strsplit(x,'')
function w = word_error(x,y)
x_words = strsplit(x,' ');
y_words = strsplit(y,' ');
mini =min(numel(x_words),numel(y_words));
x_words = x_words(1:mini);
y_words = y_words(1:mini);
cmp = strcmp(x_words,y_words);
cmp = sum(cmp);
w = length(x_words)- cmp;
w = w/length(x_words);
end 

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

