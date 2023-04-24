% Generate orthogonal Latin squares using Prolog clp(FD).
% Copyright 2022 Jan Plaza

% Version of 2022/03/17

% https://github.com/plazajan
                    
% Copyright 2022, Jan A. Plaza

% This file is part of Prolog-CLP-FD-Orthogonal-Latin-Squares. It is free software: 
% you can redistribute it and/or modify it under the terms 
% of the GNU General Public License as published by the Free Software Foundation, 
% either version 3 of the License, or (at your option) any later version. 
% It is distributed in the hope that it will be useful, 
% but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
% or FITNESS FOR A PARTICULAR PURPOSE. 
% See the GNU General Public License for more details. 
% You should have received a copy of the GNU General Public License 
% along with Prolog-CLP-FD-Orthogonal-Latin-Squares. 
% If not, see https://www.gnu.org/licenses/.

/*
What are they?
NxN squares, with each item being a pair of numbers 0..N-1.
Every possible pair (0,0), (0,1), ... ,(N-1,N-1) occurs in the square.
In every row, the first components are 0..N-1, in some order.
In every column, the first components are 0..N-1, in some order.
In every row, the second components are 0..N-1, in some order.
In every column, the second components are 0..N-1, in some order.
To disregard symmetric solutions (permutations of X and permutations of Y,
where X is the domain from which first components are taken, and Y - second)
one can assume that the first row is (0,0), (1,1), ... , (N-1,N-1).
Additionally, to disregard solutions differing only in the order of the rows,
one can assume that the first components in the first column are 1,2,...,N.
No such squares exist for N=2 and for N=6, but they exist for all other N's.

We generate such squares using a finite domain arithmetical logic programming
constraint solver clp(FD). 

The program runs in Gnu Prolog (gprolog).

The main idea in the program is this.
The clp(FD) we are using is not capable of directly expressing a constraint 
that all the pairs in the square are distinct.
So, we equivalently represent each pair (X,Y) as a number N*X+Y,
and we formulate a constraint that all such numbers are distinct.

The problem of generating orthogonal squares is difficult/expensive for any 
general purpose search algorithm, clp(FD) being one of them.
The preprocessing using arc consistency, etc., does not reduce the domains
of the variables -- see that by commenting out the line "fd_labeling(Vars)".
*/

c :- consult(squares).

%--------------------------------------------------------
% varList(+N, -List) 
% List is a list of N different variables.
% E.g. varList(3,[_,_,_]).
varList(0, []).
varList(N, [_|Aux]) :-
    N1 is N-1,
    varList(N1, Aux), !.
    
%--------------------------------------------------------    
% constList(+N, +Const, -List)
% List is a list of N values Const.
% E.g. constList(3,0,[0,0,0]).
constList(0, _, []).
constList(N, Const, [Const|Aux]) :-
    N1 is N-1,
    constList(N1, Const, Aux),!.
    
%--------------------------------------------------------    
% stepList(+N, -List)
% List is a list of N values: 0..N-1.
% E.g. stepList(3,[0,1,2]).

stepList(N, L):-
    stepListAux(N,N,L), !.
    
stepListAux(0, _, []).
stepListAux(N, Length, [First|Aux]) :-
    N1 is N-1,
    First is Length-N,
    stepListAux(N1, Length, Aux).
    
%--------------------------------------------------------    
constraintPNXY(P, N, X, Y) :-
    P #=# N*X+Y.
    
%--------------------------------------------------------    
constraintVI(V, I) :-
    V #= I.
    
%--------------------------------------------------------
% row(+List, +Counter, +Length, -Row, -ShorterList)
% Split List into Length items followed by the ShorterList,
% and put these Length items into a list Row,
% (Length is the length of Row.)
% E.g. row([1,2,3,4,5,6,7,8,9], 3, 3, [1,2,3], [4,5,6,7,8,9]).
row(Vs, 0, _, [], Vs).
row([V|Vs], Counter, Length, [V|Row], Ws) :-
    Counter1 is Counter-1,
    row(Vs, Counter1, Length, Row, Ws).

% rows(+List, +Length, -Rows)
% List contains all items from an MxLength matrix,
% Rows is a list of row-lists, each of length Length.
% E.g. rows([1,2,3,4,5,6,7,8,9], 3, [[1,2,3],[4,5,6],[7,8,9]]).
rows([], _, []).
rows(Vs, Length, [Row|Rows]) :-
    row(Vs, Length, Length, Row, NewVs),
    rows(NewVs, Length, Rows), !.
 
%--------------------------------------------------------
% transpose(+Rows, -Columns).
% Transpose the matrix given as a list of row lists: 
% produce a list of column lists.
transpose([[]|_],[]).
transpose(Rows, [Column|Columns]) :-
    column(Rows, Column, ShorterRows),
    transpose(ShorterRows, Columns).
    
% column(+Rows, -Column, -ShorterRows).
% Extract one column from rows and shorten rows.
column([], [], []).
column([[E|ShorterRow]|Rows], [E|Column], [ShorterRow|ShorterRows]) :- 
    column(Rows, Column, ShorterRows).
    
%--------------------------------------------------------
% writePairRows(+Counter, +Length, +List1, +List2)
% Write pairs of corresponding items from List1, List2 in rows of length Length.
% In the initial call use Counter == Length.
% A pair (4,7) is written as 4-7.
writePairRows(_,_,[],[]).
writePairRows(0, Length, List1, List2):-
     nl,
     writePairRows(Length, Length, List1, List2).
writePairRows(N, Length, [First1|Rest1], [First2|Rest2]) :-
     write(First1-First2), write(' '),
     N1 is N-1,
     writePairRows(N1, Length, Rest1, Rest2), !.
     
%--------------------------------------------------------

squares(N) :-

    % try N = 1,2,3,...
    
    N1 is N-1,
    NN is N*N,
    NN1 is NN-1,
    
    constList(NN, N, Ns), % Ns is a list of N*N N's 
    stepList(N, StepList), % StepList is [0,1,2,...,N-1]
    
    varList(NN, Xs), % first components in the entire square
    varList(NN, Ys), % second components in the entire square
    varList(NN, Pairs), % P from Pairs will be constrained to =N*X+Y
    
    append(Xs, Ys, Vars),
    
    rows(Xs, N, RowsX),
    rows(Ys, N, RowsY),
    
    transpose(RowsX, ColumnsX),
    transpose(RowsY, ColumnsY),

    RowsX = [FirstRowX|_],
    RowsY = [FirstRowY|_],
    ColumnsX = [FirstColumnX|_],
        
    fd_domain(Xs,0,N1),
    fd_domain(Ys,0,N1),
    fd_domain(Pairs, 0, NN1),
    
    maplist(constraintVI, FirstRowX, StepList), % disregard permutations of X
    maplist(constraintVI, FirstRowY, StepList), % disregard permutations of Y
    maplist(constraintVI, FirstColumnX, StepList), % disregard row order
    
    fd_all_different(Pairs),
    
    maplist(constraintPNXY, Pairs, Ns, Xs, Ys),
    
    maplist(fd_all_different, RowsX),
    maplist(fd_all_different, RowsY),
    maplist(fd_all_different, ColumnsX),
    maplist(fd_all_different, ColumnsY),

    fd_labeling(Vars), % Also, run the program with this commented out.

    writePairRows(N, N, Xs, Ys).
