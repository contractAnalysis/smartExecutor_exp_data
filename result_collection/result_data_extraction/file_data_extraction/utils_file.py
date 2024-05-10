def collect_data(file_results:dict,data_to_be_collected:list)->list:
    output = []
    for data_name in data_to_be_collected:
        if data_name in file_results.keys():
            output.append(file_results[data_name])
        else:
            if str(data_name).startswith('cov_'):
                if str(data_name) == 'cov_1':
                    output.append(file_results['coverage'][0])
                elif str(data_name) == 'cov_2':
                    output.append(file_results['coverage'][1])
                elif str(data_name) == 'cov_3':
                    output.append(file_results['coverage'][2])
                else:
                    print(f'{data_name} is not collected.')

            else:
                print(f'{data_name} is not collected.')
                output.append('-')

    assert(len(output)==len(data_to_be_collected))
    return output
