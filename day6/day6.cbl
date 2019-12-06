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
      *        + `01` means "Record description entry"
      *        + `pic X(3)` is a "Picture clause" specifying a type
      *        + Keywords like NUMBER and DATA are not allowed as field.
               01 orbit-file.
                   05 orbit-file-center  pic X(3).
                   05 orbit-file-R       pic X(1) value '('.
                   05 orbit-file-object  pic X(3).

           working-storage section.
      *        I hardcoded the number of objects to make it easier.
               01 object-count      pic 9(9) value 1656 usage is binary.
               01 eof-reached       pic 9(1) value 0 usage is binary.
               01 counter           pic 9(9) value 0 usage is binary.
               01 i                 pic 9(9) value 0 usage is binary.
               01 j                 pic 9(9) value 0 usage is binary.
               01 center-ptr        pic X(3).
               01 center-ptr-2      pic X(3).

               01 orbit             occurs 1656 times
                                    indexed by orbit-i.
                   05 orbit-center  pic X(3).
                   05 orbit-object  pic X(3).

       procedure division.
      *    COBOL programs contain paragraphs like read-input and part-1.
      *    Paragraphs contain sentences that are terminated by a period.
      *    A sentence may contain multiple statements. A statement
      *    contains verbs like add, subtract, search, etc. 
       read-input.
      *    Read input file.
           open input input-fd.
           perform until eof-reached = 1
               read input-fd
                   at end
                       set eof-reached to 1
                   not at end
                       add 1 to i
                       move orbit-file-center to orbit-center(i)
                       move orbit-file-object to orbit-object(i)
               end-read
           end-perform.
           close input-fd.
      
       part-1.
      *    Count total number of orbits using a linear search.
      *    We iterate through all objects and follow all parents.
           set i to 0.
           perform until i = object-count
               add 1 to i
               add 1 to counter
               set eof-reached to 0
               move orbit-center(i) to center-ptr
      *        Iterate parent orbits until there are no more.
               perform until eof-reached = 1
                   set orbit-i to 1
                   search orbit
                       at end
      *                    There is no parent orbit.
                           set eof-reached to 1
                       when orbit-object(orbit-i) = center-ptr
      *                    We found a parent orbit.
                           add 1 to counter
                           move orbit-center(orbit-i) to center-ptr
                   end-search
               end-perform
           end-perform.

      *    Total number of orbits and pseudo-orbits.
           display "Orbit count: " counter.

       part-2.
      *    Count number of hops from YOU to SAN.
           move "SAN" to center-ptr
           set counter to 0
           set eof-reached to 0.
           perform until eof-reached = 2
      *        Let Santa make one hop.
               set orbit-i to 1
               search orbit
                   at end
      *                Santa is at the root. We cannot reach Santa.
                       set eof-reached to 2
                       go to part-2-display
                   when orbit-object(orbit-i) = center-ptr
      *                Move Santa to parent orbit.
                       add 1 to counter
                       move orbit-center(orbit-i) to center-ptr
               end-search

      *        Travel from YOU to root and see if we meet Santa.
               move "YOU" to center-ptr-2
               set eof-reached to 0
               set i to 0
               perform until eof-reached = 1
                   set orbit-i to 1
                   search orbit
                       at end
      *                    We reached the root and did not find Santa.
                           set eof-reached to 1
                       when orbit-object(orbit-i) = center-ptr-2
      *                    We found a parent orbit.
                           add 1 to i
                           move orbit-center(orbit-i) to center-ptr-2
      *                    Check if Santa is here.
                           if center-ptr-2 = center-ptr
      *                        We found Santa!
                               go to part-2-display
                           end-if
                   end-search
               end-perform
           end-perform.

       part-2-display.
           if eof-reached = 2 then
              display "Unable to reach Santa!"
           else
      *        Total number of *orbit transfers*
               add i to counter
               subtract 2 from counter
               display "Orbit transfers to Santa: " counter
           end-if.

      *    Terminate.
           stop run.
       end program day6.
