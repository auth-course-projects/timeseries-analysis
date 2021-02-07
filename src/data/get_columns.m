function [varargout] = get_columns(column_indices)
%GET_COLUMNS Fetches columns at `column_indices` indices from the
%VideoViews.xlsx file.
%
%INPUTS:
%   column_indices      : the indices as a matlab array
%
%OUPUTS:
%   y{i}                : variable number of output columns - timeseries
%
excel_file = 'VideoViews.xlsx';
argout_counter = 1;
varargout = cell(1199, length(column_indices));
for i = column_indices
    col_letters = column_index_to_letters(i);
    varargout{argout_counter} = ...
        xlsread(excel_file, 1, [col_letters '1:' col_letters '1199']);
    argout_counter = argout_counter + 1;
end
end