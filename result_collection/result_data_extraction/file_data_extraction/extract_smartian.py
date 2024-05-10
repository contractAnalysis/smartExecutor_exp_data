import re

from result_collection.result_data_extraction.file_data_extraction.utils_file import \
    collect_data


def extract_a_result_file_from_smartian(file_path:str,data_to_be_collected:list)->dict:

    def get_statistics(line:str):
        # Define a regular expression pattern to match the required data
        pattern = r'\[.*\] (.*): (\d+)'
        # Use re.search to find the pattern in the input string
        match = re.search(pattern, line)
        if match:
            bug_type = match.group(
                1)  # Get the text "Assertion Failure"
            number = int(match.group(2))  # Get the integer value
            return bug_type,number
        else:
            return None,None

    output = {}
    for data_name in data_to_be_collected:
        if data_name in ['vulnerability','statistics']:
            output[data_name] = {}
        else:
            output[data_name] = '-'

    flag_fuzzing_statistics=False
    fuzzing_statistics_mark='===== Statistics ====='
    fuzzing_statistics_end_mark='Done, clean up and exit'

    num_bugs_mark='number_of_bugs:'

    flag_info = False
    flag_info_mark = "#@contract_info_time"

    read_file = open(file_path, 'r', encoding='utf8')
    for line in read_file.readlines():
        line = line.strip('\n').strip()
        if len(line) == 0: continue
        if fuzzing_statistics_mark in line:
            flag_fuzzing_statistics=True
            continue
        elif line.startswith(flag_info_mark):
            flag_info = True
            continue
        elif fuzzing_statistics_end_mark in line:
            flag_fuzzing_statistics=False
            continue
        elif line.startswith(num_bugs_mark):
            output['vulnerability']=line.split(num_bugs_mark)[-1]
            continue

        if flag_fuzzing_statistics:
            type,num=get_statistics(line)
            if type is not None:
                if type not in output['statistics'].keys():
                    output['statistics'][type]=num
                else:
                    output['statistics']={type:num}
                if type=='Covered Instructions':
                    output['covered_runtime_instructions']=num

        elif flag_info:
            flag_info = False
            contract_info = line.split(':')
            assert len(contract_info) >= 4
            output['solidity'] = contract_info[0]
            output['solc'] = contract_info[1]
            output['contract'] = contract_info[2]
            output['time'] = contract_info[3]


    return collect_data(output, data_to_be_collected)

