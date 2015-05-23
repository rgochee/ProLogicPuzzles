:- use_module(library(apply)).
:- use_module(library(lists)).
:- use_module(library(clpfd)).

% skyscrapers(Rows, Rules, Size)
% Rows is a list of length Size: [[Top row], ..., [bottom row]]
% Rules is a list of length 4: [[Top], [Bottom], [Left], [Right]]
% Length of each sublist is equal to the specified Size
% Rows and any sublist (individual row, any rule) is optional.
% Prints out the list of rows.
%
% Examples queries:
%
% All rules specified:
% skyscrapers(Rows,
%             [[2,3,2,1],
%              [2,1,2,3],
%              [4,1,2,2],
%              [1,4,2,2]],
%             4).
% --> [1,2,3,4]
%     [4,3,2,1]
%     [2,1,4,3]
%     [3,4,1,2]
%     true.
%
% Rules and rows partially specified:
% skyscrapers([
%              _,
%              [_,2,_,_,_],
%              _,
%              _,
%              _
%             ],
%             [
%              [_,4,3,_,_],
%              [_,_,1,2,2],
%              _,
%              [_,_,_,2,_]
%             ],
%             5).
% --> [2,1,3,4,5]
%     [5,2,4,3,1]
%     [3,4,1,5,2]
%     [4,5,2,1,3]
%     [1,3,5,2,4]
%     true.
%
% More about skyscrapers:
% http://wiki.logic-masters.de/index.php?title=Skyscrapers/en


skyscrapers(Rows, [RTop, RBot, RLef, RRig], N) :-
  % First, we set up our matrix of data
  unique_matrix(N, Rows, Cols),
  maplist(reverse,Rows,RowsRev),
  maplist(reverse,Cols,ColsRev),
  % We have the grid, use label to start attempting solutions
  % This must be done here because check_view_counts has some arithmetic
  % operation which would fail as not sufficiently instantiated
  maplist(label,Rows),
  % Now we check correctness
  check_view_counts( Rows, RLef ),
  check_view_counts( RowsRev, RRig ),
  check_view_counts( Cols, RTop ),
  check_view_counts( ColsRev, RBot ),
  % Found something, cut!
  % If multiple solutions possible/desired, this can be removed
  !,
  % Print out the data
  maplist(writeln,Rows).


% Creates an NxN matrix with the property that values of each row and
% col are distinct elements of the integral range [1,N]
unique_matrix(N, Rows, Cols) :-
  matrix(N, Rows, Cols),
  append(Rows, Vs), Vs ins 1..N,
  maplist(all_distinct, Rows),
  maplist(all_distinct, Cols).

% Creates an NxN matrix, accessible via both Rows and Cols
matrix(N, Rows, Cols) :-
  length(Rows, N),
  maplist(length_list(N),Rows),
  transpose(Rows, Cols).

% Helper function to switch length\2 parameter order.
% Could be replaced by lambda.
length_list(N,L) :-
  length(L,N).


% check_view_counts(Rows, Counts)
% Rows is a list of rows (or cols) whose view count correspond
% to the entry in the Counts list
% See tower_view_count
check_view_counts([], _).
check_view_counts([Row|Rows], [C|Cs]) :-
  tower_view_count(Row, C),
  check_view_counts(Rows, Cs).

% List L, C is the "view" from the front
% View is defined as the number of skyscrapers one can see,
% assuming taller skyscrapers obscure shorter ones behind it
% e.g. [2, 1, 4, 5, 3] is 3 -- the view is 2-4-5
% tower_view_count( List, Count {, CurrentMax} )
tower_view_count(L, C) :-
  tower_view_count(L, C, 0).

tower_view_count([], 0, _).

tower_view_count([X|Tail], C, Max) :-
  X =< Max,
  tower_view_count(Tail, C, Max).

% Can this be made tail-recursive? We don't know what C is yet.
tower_view_count([X|Tail], C, Max) :-
  X > Max,
  tower_view_count(Tail, C1, X),
  C is C1+1.

/*
% alternate version using if/else branching
tower_view_count([X|Tail], C, Max) :-
  ( X > Max
  ->
    tower_view_count(Tail, C1, X),
    C is C1+1
  ;
    tower_view_count(Tail, C, Max)
  ).
*/
