require "spec"

# Tape adaptation
def adapt_tape(tape, t1, t2)
  tape[1] = t1
  tape[2] = t2
  tape
end

# Walk forward through opcodes until halting code (99)
def process_tape(tape : Array(Int))
  ptr = 0
  until tape[ptr] == 99
    begin
      opcode = tape[ptr]
      a = tape[tape[ptr + 1]]
      b = tape[tape[ptr + 2]]
      c = tape[ptr + 3]
      ptr += 4

      case opcode
      when 1
        tape[c] = a + b
      when 2
        tape[c] = a * b
      else
        raise "Invalid opcode #{opcode}"
      end
    rescue IndexError
      raise "Invalid pointer"
    end
  end
  return tape
end

# Spec
describe "#process_tape" do
  it "Passes example 3" do
    input = [2, 4, 4, 5, 99, 0]
    expect = [2, 4, 4, 5, 99, 9801]
    output = process_tape input
    (output <=> expect).should eq 0
  end

  it "Passes example 4" do
    input = [1, 1, 1, 4, 99, 5, 6, 0, 99]
    expect = [30, 1, 1, 4, 2, 5, 6, 0, 99]
    output = process_tape input
    (output <=> expect).should eq 0
  end
end

# Read input.
tape = (File.read "input.txt")
  .split(',', remove_empty: true)
  .map { |str| str.to_i }

# Evaluate tape.
tape1 = adapt_tape tape.clone, 12, 2
process_tape tape1
puts "Answer part one: #{tape1.first}"

# Brute force search.
target = 19690720
solution = ((0..99).to_a.product (0..99).to_a).find do |(noun, verb)|
  tape_n = adapt_tape tape.clone, noun, verb
  process_tape tape_n
  tape_n.first == target
end

case solution
when Nil
  puts "Part two: no solution was found."
else
  puts "Part two: #{100 * solution[0] + solution[1]}"
end
