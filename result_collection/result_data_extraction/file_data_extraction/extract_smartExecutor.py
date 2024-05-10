from result_collection.result_data_extraction.file_data_extraction.utils_file import \
    collect_data


def extract_a_result_file_from_smartExecutor(file_path:str,data_to_be_collected:list)->dict:

    output = {}
    for data_name in data_to_be_collected:
        if data_name in ['vulnerability', 'statistics']:
            output[data_name] = {}
        else:
            output[data_name] = '-'


    pre_exception_mark='have exceptions in preprocessing'
    pre_cov_mark='preprocessing: Achieved'
    pre_time_mark='preprocessing time(s):'
    reach_max_cov_mark='Reach the maximum coverage'
    no_state_at_depth_1_mark='No states are generated at depth 1'

    flag_state = False
    flag_state_mark = '#@statespace'

    flag_cov = False
    flag_cov_mark = "#@coverage"
    contract_coverage=0

    bugs = {}
    flag_bug = False
    flag_bug_mark = '===='

    flag_info = False
    flag_info_mark = "#@contract_info_time"

    bug_name = ''
    bug_index = 0

    flag_total_instr_mark = "total instructions:"

    read_file = open(file_path, 'r', encoding='utf8')
    for line in read_file.readlines():
        line = line.strip('\n').strip()
        if len(line) == 0: continue

        if line.startswith(reach_max_cov_mark):
            output['max_cov']=1
            continue
        if line.startswith(no_state_at_depth_1_mark):
            output['no_state_at_d1']=1
            continue
        if line.startswith(pre_exception_mark):
            output['pre_exception'] = 1
            continue
        if line.startswith(pre_time_mark):
            output['pre_time'] = line.split(pre_time_mark)[-1]
            continue
        if line.startswith(pre_cov_mark):
            output['pre_cov'] = line.split(pre_cov_mark)[-1].strip().split(' ')[0]
            continue
        if line.startswith("contract coverage:"):
            contract_coverage=line.split(":")[-1]
            continue

        if line.startswith(flag_state_mark):
            flag_state = True
            continue
        elif line.startswith(flag_cov_mark):
            flag_cov = True
            continue
        elif line.startswith(flag_total_instr_mark):
            output['total_runtime_instructions'] = line.split(flag_total_instr_mark)[-1]
            continue

        elif line.startswith(flag_bug_mark):
            if line[0:5] == "=====": continue
            bug_index += 1
            bugs['bug' + str(bug_index)] = {}
            bug_name = line.split('====')[1]
            bugs['bug' + str(bug_index)]['name'] = bug_name
            flag_bug = True
            continue

        elif line.startswith(flag_info_mark):
            flag_bug = False  # if contract_info_time is reached, definitely flag_bug should  be false
            flag_info = True
            continue



        if flag_bug:
            line_eles = line.split(":")
            if line_eles[0].strip() == "SWC ID":
                bugs['bug' + str(bug_index)]['SWC_ID'] = line_eles[1].strip()
            elif line_eles[0].strip() == 'Severity':
                bugs['bug' + str(bug_index)]['Severity'] = line_eles[1].strip()
            elif line_eles[0].strip() == 'Contract':
                bugs['bug' + str(bug_index)]['Contract'] = line_eles[1].strip()
            elif line_eles[0].strip() == 'Function name':
                bugs['bug' + str(bug_index)]['Function_name'] = line_eles[1].strip()
            elif line_eles[0].strip() == 'PC address':
                bugs['bug' + str(bug_index)]['PC_address'] = line_eles[1].strip()
            elif line_eles[0].strip() == 'Estimated Gas Usage':
                bugs['bug' + str(bug_index)]['Estimated_Gas_Usage'] = line_eles[1].strip()
            # elif line_eles[0].strip() == 'In file':
            #     bugs['bug' + str(bug_index)]['file_point'] = line_eles[-1]



        elif flag_state:
            flag_state = False
            # line format: 25 nodes, 24 edges, 363 total states
            line_eles = line.split(',')
            for ele in line_eles:
                items = ele.strip().split(' ')
                if len(items) == 2:
                    output[items[1]] = items[0]
                elif len(items) == 3:
                    output[items[1].strip() + "_" + items[2].strip()] = items[0]

        elif flag_cov:
            flag_cov = False
            # line format:Achieved 5.50% coverage for code: 6060604052341561000f576
            # in case of timeout, no coverage is obtained
            if "coverage" in line:
                items = line.split(' ')
                if 'coverage' in output.keys():
                    output['coverage'] += [items[1]]
                else:
                    output['coverage'] = [items[1]]

        elif flag_info:
            flag_info = False
            contract_info = line.split(':')
            assert len(contract_info) >= 4
            output['solidity'] = contract_info[0].strip()
            output['solc'] = contract_info[1].strip()
            output['contract'] = contract_info[2].strip()
            output['time'] = contract_info[3].strip()

        else:
            pass
    if 'coverage' in output.keys():
        coverage_data=output['coverage']
        if len(coverage_data)==1:
            output['cov_1']=coverage_data[0]
        elif len(coverage_data)==2:
            output['cov_1'] = coverage_data[0]
            output['cov_2'] = coverage_data[1]
        elif len(coverage_data)>=3:
            output['cov_1'] = coverage_data[0]
            output['cov_2'] = coverage_data[1]
            output['cov_3']=-1
    else:
        output['coverage']=contract_coverage
        output['cov_1'] = 0
        output['cov_2'] = contract_coverage

    # add bugs:
    output['vulnerability'] = bugs
    return collect_data(output, data_to_be_collected)
