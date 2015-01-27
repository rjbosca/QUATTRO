function s = combine_structs(s1,s2,repTag)
%combine_structs  Combines to structures into a single array
%
%   S = combine_structs(S1,S2) combines the structures S1 and S2 into a single
%   array of structures, S. S1 and/or S2 can be arrays of structures of any
%   size.
%
%   S = combine_structs(...,REPTYPE) performs the above operation using the
%   replication type specified by REPTYPE. Valid type strings are:
%
%       Rep. String         Operation
%       -----------------------------
%       'copy'              Copies missing field information from the more
%                           complete strucure
%
%       'fill' (default)    Null-fills the missing field information with
%                           appropriate data type

    % Validate the optional input
    if (nargin<3)
        repTag = 'fill';
    end

    % Determine the current fields (from S1) and the new fields (to be added)
    % from S2
    newFlds = fieldnames(s2);
    oldFlds = fieldnames(s1);

    % At this point, there are two cases to consider: (1) the "new" structure,
    % S2, has fields that are not in the "old" strucutre (S1), and (2) the "old"
    % structure, S1, has fields that are not present in the "new" structure.
    if any( ~isfield(s1,newFlds) )

        % Determine which fields must be created from S2
        newFlds = newFlds( ~isfield(s1,newFlds) );

        % Either null-fill the missing fields or copy those fields from the
        % second input structure
        if strcmpi(repTag,'fill')

            % Loop through each of the fields that need to be added,
            % null-filling the "old" structure
            for fldIdx = 1:length(newFlds)

                % Determine the class of the new field. Because s1 and/or s2 can
                % be an array of strcutres, cell fun must be used to deteremine
                % what class the data are
                isChar = all( cellfun(@ischar,   {s2.(newFlds{fldIdx})}) );
                isNum  = all( cellfun(@isnumeric,{s2.(newFlds{fldIdx})}) );
                if isChar
                    [s1(:).(newFlds{fldIdx})] = deal('');
                elseif isNum
                    [s1(:).(newFlds{fldIdx})] = deal([]);
                else
                    error(['QUATTRO:' mfilename ':invalidDataClass'],...
                           'An unknown or invalid data class was detected.');
                end

            end

        else

            % Loop through each of the fields that need to be added, and copy
            % the data from the previous structure.
            for fldIdx = 1:length(newFlds)
                [s1(:).(newFlds{fldIdx})] = deal( s2.(newFlds{fldIdx}) );
            end
            
            %TODO: the above loop assumes that the "new" structure is a scalar.
            %Update the code sometime to handle the case of a non-scalar array
            %of structures (or at least warn the user...).

        end

    elseif any( ~isfield(s2,oldFlds) )

        % Since this case handles the event that the "old" and "new" structures
        % are switched, simply flip the inputs, call the function, and return
        % the results
        s = combine_structs(s2,s1);
        return

    end

    % Combine the headers by first ordering the fields according to the "old"
    % structure
    s2 = orderfields(s2,s1);
    s  = [s1 s2];
    
end %combine_structs