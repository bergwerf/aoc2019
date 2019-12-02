-- Day 1 in Ada

with Ada.strings, Ada.text_io;
use Ada.strings, Ada.text_io;

procedure Day1 is
   file : File_Type;
   mass, fuel : Float;
   sum : Integer;
begin
   -- Open input.txt
   open(file=>file, mode=>In_File, name=>"input.txt");

   -- Part 1
   sum := 0;
   while not end_of_file(file) loop
      mass := Float'value(get_line(file));
      fuel := Float'floor(mass / 3.0 - 2.0);
      sum := sum + Integer(fuel);
   end loop;
   put_line("Fuel part 1:" & Integer'image(sum));

   -- Part 2
   sum := 0;
   reset(file);
   while not end_of_file(file) loop
      mass := Float'value(get_line(file));
      loop
         fuel := Float'floor(mass / 3.0 - 2.0);
         mass := fuel;
         if fuel > 0.0 then
            sum := sum + Integer(fuel);
         else
            exit;
         end if;
      end loop;
   end loop;
   put_line("Fuel part 2:" & Integer'image(sum));

   close(file);
end Day1;