from result_collection.result_data_extraction.file_data_extraction.utils_file import \
    collect_data


def extract_a_result_file_from_manticore(file_path:str,data_to_be_collected:list)->dict:


    output = {}
    for data_name in data_to_be_collected:
        if data_name in ['vulnerability','statistics']:
            output[data_name] = {}
        else:
            output[data_name] = '-'


    flag_coverage='[++@$++]current_coverage:'
    flag_info_mark = "#@contract_info_time"
    flag_info=False
    read_file = open(file_path, 'r', encoding='utf8')
    for line in read_file.readlines():
        line = line.strip('\n').strip()
        if len(line) == 0: continue


        if line.startswith(flag_coverage):
            output['coverage']=line.split(flag_coverage)[-1]
            continue
        elif line.startswith(flag_info_mark):
            flag_info = True
            continue


        if flag_info:
            flag_info = False
            contract_info = line.split(':')
            assert len(contract_info) >= 4
            output['solidity'] = contract_info[0]
            output['solc'] = contract_info[1]
            output['contract'] = contract_info[2]
            output['time'] = contract_info[3]

    return collect_data(output, data_to_be_collected)
