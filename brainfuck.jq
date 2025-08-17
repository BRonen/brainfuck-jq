def assert(cond; msg):
  if   cond
  then .
  else error(msg)
  end;

def match_brackets:
  def match(index; stack; record):
    . as $source
    | $source[index] as $op
    | if   (index <= ($source | length))
      then ( if   $op == "[" then match(index + 1; stack + [index]; record)
             elif $op == "]" then ( stack[-1] as $opening_bracket
                                  | { ($opening_bracket | tostring): index,
                                      (index | tostring): $opening_bracket} as $new_entries
                                  | match(index + 1; stack[0:-1]; record + $new_entries) )
             else match(index + 1; stack; record)
             end)
      else ( if   (stack | length) > 0
             then error("unmatched bracket(s) at \(stack)")
             else record
             end )
      end;
  match(0; []; {});

def evaluate:
  def eval:
    if   (.program_counter >= (.tokens | length))
    then .
    else .tokens[.program_counter] as $op
         | if   $op == "<" then ( .data_pointer -= 1
                                | assert(.data_pointer >= 0; "trying to access memory[-1]: \(.)") )
           elif $op == ">" then .data_pointer += 1
           elif $op == "+" then .memory[.data_pointer] += 1
           elif $op == "-" then .memory[.data_pointer] -= 1
           elif $op == "[" then ( if   .memory[.data_pointer] == 0
                                  then ( .program_counter | tostring ) as $current_address
                                       | .program_counter = .brackets[$current_address]
                                  else .
                                  end )
           elif $op == "]" then ( if   .memory[.data_pointer] != 0
                                  then ( .program_counter | tostring ) as $current_address
                                       | .program_counter = .brackets[$current_address]
                                  else .
                                  end )
           elif $op == "." then .output += [ .memory[.data_pointer] ]
           elif $op == "," then .memory[.data_pointer] = .input[0]
                              | .input = .input[1:]
           else .
           end
         | .program_counter += 1
         | eval
      end;
  (. | split("")) as $tokens
  | { "data_pointer": 0,
      "program_counter": 0,
      "memory": [],
      "brackets": ($tokens | match_brackets),
      "tokens": $tokens,

      # I did not implemented any way to receive the input from outside of here,
      # but you can just statically define the inputs that your program need.
      "input": [25, 25],
      "output": [] }
  | eval
  | .output
  | implode;

evaluate
