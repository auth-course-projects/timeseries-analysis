function column_letters = column_index_to_letters(column_index)
%COLUMN_INDEX_TO_LETTERS Returns the column characters of Excel given a 
%certain column number.
%Source: https://www.mathworks.com/matlabcentral/answers/248797-i-need-to-convert-a-number-into-its-column-name-equivalent#comment_830969\
%Author: Remco Hamoen
%INPUTS:
%   column_index        : index of column
%OUTPUTS:
%   column_letters      : character combination in Excel
if column_index <= 26              % [A..Z]
    column_letters = char(mod(column_index-1,26)+1+64);
elseif column_index <= 702                   % [AA..ZZ]
    column_index = column_index-26;    
    char1 = char(floor((column_index-1)/26)+1+64);
    char0 = char(mod(column_index-1,26)+1+64);
    column_letters = [char1 char0];
elseif column_index <= 16384                 % [AAA..XFD]
    column_index = column_index-702; 
    char2 = char(floor((column_index-1)/676)+1+64);
    column_index=column_index-(floor((column_index-1)/676))*676;
    char1 = char(floor((column_index-1)/26)+1+64);
    char0 = char(mod(column_index-1,26)+1+64);
    column_letters = [char2 char1 char0];
else
    disp('Column does not exist in Excel!');
end
end
