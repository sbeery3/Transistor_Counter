import queue, math, time, argparse
from collections import Counter
"""
Class representing a single verilog module with interior attributes representing:
name, transistor count, inputs, outputs, wires, inner modules, and assign statements
"""
class module: 
    
    """
    Constructor
    """
    def __init__(self, text):
        mod_text = combine_lines(text)
        self.name = getParseModName(mod_text[0])
        self.inputs, self.outputs, self.wires, self.modules, self.assigns = getModParts(mod_text)
        self.trans_count = -1

    """
    Calculates transistor count based on interior characteristics
    """
    def findTransCount(self):
        current_count = 0
        error_count = 0
        module_count = 1

        #
        for module in self.modules:
            if module[0] in known_input_independent.keys():
                current_count += known_input_independent.get(module[0])
            #
            elif module[0] in known_input_dependent.keys():
                current_count += known_input_dependent.get(module[0])[0] + known_input_dependent.get(module[0])[1]*module[1]
            #
            elif module[0] in known_modules.keys():
                current_count += known_modules.get(module[0])
            #
            else:
                error_count += 1
            module_count += 1

        for assign in self.assigns:
            current_count += assign[1]
        self.trans_count = current_count
        known_modules.update({self.name : current_count})
        
    """
    Shows a formatted version of inner attributes
    """
    def __str__(self):
        input_string = "\n"
        for i in self.inputs:
            input_string += i[0] + " : width " + str(i[1]) + "\n"
  
        output_string = "\n"
        for o in self.outputs:
            output_string += o[0] + " : width " + str(o[1]) + "\n"

        wire_string = "\n"
        for w in self.wires:
            wire_string += w[0] + " : width " + str(w[1]) + "\n"

        assign_string = "\n"
        for a in self.assigns:
            assign_string += a[0] + " : " + str(a[1]) + " transistors\n"

        module_string = "\n"
        for val, count in dict(Counter(self.modules)).items():

            module_string += str(count) + "x " + val[0] +" - " + str(val[1]) + " input\n"

        string = "\n//////////////////////\nModule name: " + self.name + "\nTransistor count: " + str(self.trans_count)
        string = string + "\n\n-----------------\n\nInputs:\n" + input_string + "\nOutputs:\n" + output_string
        string = string + "\nWires:\n" + wire_string + "\nAssigns:\n" + assign_string + "\nModules:\n" + module_string
        
        return string

    """
    Getter: 
    Return string representing name
    """
    def getName(self):
        return self.name

    """
    Getter:
    Return list of inputs with widths
    """
    def getInputs(self):
        return self.inputs

    """
    Getter:
    Return list of outputs with widths
    """
    def getOutputs(self):
        return self.outputs

    """
    Getter:
    Return list of wires with widths
    """
    def getWires(self):
        return self.outputs

    """
    Getter:
    Return list of tuples in the format:
    (module, input_count)
    representing the interior modules of this module
    """
    def getModules(self):
        return self.modules

    """
    Getter:
    Return list of tuples in the format:
    (assign, transistor count)
    representing the interior modules of this module
    """
    def getAssigns(self):
        return self.assigns
    
    def getTransistors(self):
        return self.trans_count

#
known_input_dependent = {
        'and' : (1,1), 
        'or' : (1,1), 
        'nand' : (0,1),
        'nor' : (0,1),
        'xor' : (0,4)
    }

#
known_input_independent = {
        'not' : 1,
        'bufif1' : 6
    }
    
#
known_modules = {}

    
"""
Method that combines and formats the lines of a verilog file, which 
is syntactically separated by semicolons(';'). Right now,
the formatting only removes newline characters
"""
def combine_lines(text):
    combined_lines = []
    current = ''
    setPass = False
    for i in text:
        if (i == "\n"):
            setPass = False
        if (i == "/"):
            setPass = True
        if (setPass):
            continue
        current += i
        if (i == ';'):
            combined_lines.append(current.strip().replace('\n', ' '))
            current = ''
    return combined_lines

"""
Gets lines with declared inner modules from a module string
"""
def getModParts(text):
    inputs = []
    outputs = [] 
    wires = []
    modules = []
    assigns = []
    for line in text[1:]:
        if (line[0:5] == 'input'):
            inputs.append(line)
        elif (line[0:6] == 'output'):
            outputs.append(line)
        elif (line[0:4] == 'wire'):
            wires.append(line)
        elif (line[0:6] == 'assign'):
            assigns.append(line)
        else: 
            modules.append(line.strip())
    result = (parseModInputs(inputs), parseModOutputs(outputs), parseModWires(wires), parseModInnerModules(modules), parseModAssigns(assigns))
    return result

"""
Gets and parses for the module name given a preformatted list of strings
"""
def getParseModName(first_line):
    split_line = first_line.split('(')
    first_split = split_line[0]
    space_split = first_split.split(' ')
    return space_split[1].strip()

"""
Parses inputs
"""
def parseModInputs(text):
    inputs = []
    for input in text:
        if ('[' and ']' in input):
            range = input.split('[')[1].split(']')[0]
            length = int(range.split(':')[0]) - int(range.split(':')[1]) + 1
            names = input.split(']')[1].split(', ')
        else: 
            length = 1
            names = input.split('input ')[1].split(',')
        for name in names:
            parsed = (format(name),length)
            inputs.append(parsed)
    return inputs


"""
Parses outputs
"""
def parseModOutputs(text):
    outputs = []
    for output in text:
        if ('[' and ']' in output):
            range = output.split('[')[1].split(']')[0]
            length = int(range.split(':')[0]) - int(range.split(':')[1]) + 1
            names = output.split(']')[1].split(',' )
        else: 
            length = 1
            names = output.split('output ')[1].split(',')
        for name in names:
            parsed = (format(name),length)
            outputs.append(parsed)
    return outputs




"""
Parses wires
"""
def parseModWires(text):
    wires = []
    for wire in text:
        if ('[' and ']' in wire):
            range = wire.split('[')[1].split(']')[0]
            length = int(range.split(':')[0]) - int(range.split(':')[1]) + 1
            names = wire.split(']')[1].split(',')
        else: 
            length = 1
            names = wire.split('wire ')[1]
            names = names.split(',')
        for name in names:
            parsed = (format(name),length)
            wires.append(parsed)
    return wires


"""
Parses assign statements 
"""
def parseModAssigns(text):
    assigns = []
    for line in text:
        
        left = line.split(' = ')[0]
        right = line.split(' = ')[1]
        individual_parts = right.split(': ')
        if (len(individual_parts) == 1):
            assigns.append((left, 0))
            continue
        default = individual_parts[-1]
        statement_total = 0
        for part in individual_parts[:-1]:
            parts = part.split(' ? ')
            result = convert(parts[1].strip())
            condition = convert(parts[0].split("== ")[1].split(")")[0].strip())
            condition_trans_count = known_input_dependent.get("and")[1] * len(condition) + known_input_dependent.get("and")[0]
            result_trans_count = known_input_independent.get("bufif1") * len(result)
            statement_total += condition_trans_count + result_trans_count
        assigns.append((left, statement_total))
    return assigns


"""
Parses inner modules
"""
def parseModInnerModules(text):
    modules = []
    for module in text:
        count = module.count(',')
        name = module.split('(')[0].strip()
        if (len(name.split(' ')) == 2):
            name = name.split(' ')[0]
        modules.append((name, count))
    return modules
    

"""
Removes extra ';' and ',' characters
"""
def format(text):
    new = text.replace(';','').replace(',','').strip()
    return new


"""
Converts hexadecimal/octal/binary to binary 
"""
def convert(line):
    radix = line.split("'")[1][0]
    original_value = line.split("'")[1][1:]
    binary_length = line.split("'")[0][0]
    
    if (radix == "h"):
        new_value = "{0:0{len}b}".format(int(original_value,16), len=binary_length)
        return new_value
    elif (radix == "o"):
        new_value = "{0:0{len}b}".format(int(original_value,8), len=binary_length)
        return new_value
    elif (radix == "b"):
        return original_value
    else:
        pass




"""
Extract a list of individual modules from a verilog file.
"""
def parseInputFile(filename):
    
    file = open(filename, "r")

    line = file.readline().strip()
    modules = set()
        
    # This is looped until the end of the file is reached. 
    while (line is not "") : 

        line = line.strip()

        # Skip lines with comments only 
        if (not line or not line[1]):
            pass
        elif (line[0] == "/" and line[1] == "/"): 
            line = file.readline()
        
        # Identify modules
        if (line[0:6] == "module"):
            current_mod = line + "\n"
            line = file.readline().strip().split('/')[0]
            # Until module ends
            while (line[0:9] != "endmodule"):
                if not line: 
                    pass
                elif (line[0] == "/" and line[1] == "/"):
                    pass
                else:
                    current_mod = current_mod + line + "\n"

                line = file.readline().strip().split('/')[0]
            current_mod = current_mod + "endmodule\n"
            modules.add(current_mod)

        line = file.readline()
    return modules
        

"""
Main function
"""
def __main__(filename):

    modules = parseInputFile(filename)
   # Get all of the modules into a set
    parsed_modules = set()
    for mod in modules:
        current_mod = module(mod)
        parsed_modules.add(current_mod)


    analyzed_modules = []

    #
    while (not len(parsed_modules) == 0):
        current = parsed_modules.pop()
        current_inner_modules = current.getModules()
        
        known = list(known_input_dependent.keys())
        known += list(known_input_independent.keys())
        known += list(known_modules.keys())
        ready = True
        
        #
        for (name, _) in current_inner_modules:
            if name.strip() not in known:
                ready = False
                break
        #
        if ready: 
            current.findTransCount()
            analyzed_modules.append(current)
        #
        else: 
            parsed_modules.add(current)
    
    for mod in analyzed_modules:
        print(mod)

    
    print("Top level module:", analyzed_modules[-1].getName(), "with", analyzed_modules[-1].getTransistors(), "transistors.")
    
    
"""
    Runs main function
"""
if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--f', default='function_unit.v',type=str,help='This is the file to be parsed')
    args = parser.parse_args()

    filename = str(args.f)  
    start_time = time.time()
    __main__(filename)
    print("Runtime: %s seconds " % (time.time() - start_time))
