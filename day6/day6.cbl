      * Comment lines must start with an asterisk in the 7th column.
      * In older COBOL most statements should start in the 12th column.
       identification division.
           program-id. day6.

       environment division.
           input-output section.
               file-control.
               select input-fd assign to 'input.txt'
               organization is line sequential.

       data division.
           file section.
           fd input-fd.
      *    + `01` means "Record description entry"
      *    + `pic 9(3)` is a "Picture clause" specifying a type
      *    + Keywords like NUMBER and DATA are not allowed as field.
           01 input-data.
           05 input-number  pic 9(3).
           05 input-space   pic X(1).
           05 input-text    pic A(5).

       working-storage section.
           01 eof-reached  pic 9.

       procedure division.
          open input input-fd.
             perform until eof-reached=1
                read input-fd
                   at end
                      move 1 to eof-reached
                   not at end
                      display input-number " => " input-text
                end-read
             end-perform
          close input-fd.
          goback.

       end program day6.
