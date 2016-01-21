% When defining abstract super-classes that require an event listener to be
% created for a private method during constrction, place those classes outside
% of the qt_models package. It appears that MATLAB changes the behavior of
% constructing function handles from private methods of a class when that class
% is encapsulated in a package.
%
% For example, the private method, "checkCalcReady_event", that is defined for
% most abstract modeling super-classes (i.e., pk, fspgrvfa, etc.) is added to
% the object during construction. In doing so, MATLAB recognizes (errantly?)
% that the class under construction (not the class of the object) should be used
% to find the appropriate private method. When the super-class is encapsulated
% in a package, MATLAB looks for a method from the sub-class (e.g., GKM or
% SEMIQDCE). However, the private method is defined for the super-class and
% can't be found, causing an error