# Prolog-CLP-FD-Orthogonal-Squares
A program in GNU Prolog with Constraint Logic Programming over finite arithmetical domain to find orthogonal Latin squares of a given size.

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

