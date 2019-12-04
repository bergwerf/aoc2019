# HTML documentation for easier searching: #
# https://jmvdveer.home.xs4all.nl/en.post.algol-68-revised-report.html #

# Classic ALGOL 68 thinks of files as pages with lines of characters: #
# MODE BOOK = FLEX[0]FLEX[0]FLEX[0]CHAR #
# (MODE defines a new data type) #

# Read input file (ALGOL allows whitespaces in variable names) #
# Fun fact, ALGOL is defined using a vW-grammar. #
STRING data;
FILE file handle;
open(file handle, "input.txt", stand in channel);
INT password start, password end;
getf(file handle, ($6z"-",6z$, password start, password end));
close(file handle);

# + A format string is enclosed with dollar signs. #
# + `{n}a` means take the *n* next characters of a string. #
# + `l` inserts a newline. #
printf(($"Input: "6z", ",6zl$, password start, password end));

# Solve using a brute-force search. #
INT n;
n := 0;

# Genie runs out of memory here #
FOR i FROM password start TO password end
DO
  printf(($6zl$, i))
OD