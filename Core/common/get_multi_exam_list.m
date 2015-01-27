function s = get_multi_exam_list(headers,e_type)
%get_multi_exam_list  Generates a list of multiple exam names.
%   S = get_multi_exam_list(H) generates a cell array of strings from the
%   array of header information supplied by the user. Only eDWI exams are
%   currently supported.

switch lower(e_type)
    case 'edwi'
        dir_tag = dicomlookup('0043','1030');
        for i = 1:length(headers)
            s{i} = get_edwi_dir(headers(i).(dir_tag));
        end
    otherwise
        s = cell(size(headers)); [s{:}] = deal(e_type);
end