import string

import pandas as pd

from result_collection.result_data_extraction.utils import get_num_vul, \
    get_coverage, get_integer_value, get_time, get_average_0, \
    get_covered_instructions

key_columns=['solidity','solc' ,'contract']

contracts_total_runtime_instructions={

}



def collect_and_format_csv_data(base_dir: str, csv_file_path: str,data_to_be_collected:list) -> pd.DataFrame:
    df_result = pd.read_csv(base_dir + csv_file_path)
    if len(data_to_be_collected)>0:
        existent_columns = [column for column in data_to_be_collected if
                            column in df_result.columns]
    else:
        existent_columns=df_result.columns
    # get the required data and put them in proper types
    df_result_target = df_result[existent_columns]

    # format the data
    # make sure the folowing columns exist
    if 'time' in df_result_target.columns:
        df_result_target['time'] = df_result_target['time'].map(
            lambda x: get_time(x))
    if 'total_states' in df_result_target.columns:
        df_result_target['total_states'] = df_result_target['total_states'].map(
            lambda x: get_integer_value(x))
    if 'cov_1' in df_result_target.columns:
        df_result_target['cov_1'] = df_result_target['cov_1'].map(
            lambda x: get_coverage(x))
    if 'cov_2' in df_result_target.columns:
        df_result_target['cov_2'] = df_result_target['cov_2'].map(
            lambda x: get_coverage(x))
    if 'cov_3' in df_result_target.columns:
        df_result_target['cov_3'] = df_result_target['cov_3'].map(
            lambda x: get_coverage(x))
    if 'cov' in df_result_target.columns:
        df_result_target['cov'] = df_result_target['cov'].map(
            lambda x: get_coverage(x))
    if 'coverage' in df_result_target.columns:
        df_result_target['coverage'] = df_result_target['coverage'].map(
            lambda x: get_coverage(x))
    if 'vul' in df_result_target.columns:
        df_result_target['vul'] = df_result_target[
            'vul'].map(
            lambda x: get_num_vul(x))
    if 'vulnerability' in df_result_target.columns:
        # df_result_target['bugs'] = df_result_target['bugs'].map(lambda x: get_num_vul(x))
        df_result_target['vulnerability'] = df_result_target[
            'vulnerability'].map(
            lambda x: get_num_vul(x))


    return df_result_target

def collect_csv_data_in_dict(base_dir: str, csv_file_path: str,data_to_be_collected:list) -> dict:
    df_data=collect_and_format_csv_data(base_dir,csv_file_path,data_to_be_collected)
    if len(data_to_be_collected)>0:
        existent_columns = [column for column in data_to_be_collected if
                            column in df_data.columns]
    else:
        existent_columns=df_data.columns

    # organize data in dict
    results = {}
    for idx, row in df_data.iterrows():
        key = row['solidity'] +"#"+row["solc"]+ "#" + row["contract"]
        results[key]={}
        for col_name in existent_columns:
            if col_name in ['solidity','solc','contract']:continue
            if str(col_name)=='cov_2':
                results[key][f'cov']=row[col_name]
            elif str(col_name)=='vulnerability':
                results[key][f'vul'] = row[col_name]
            else:
                try:
                    results[key][f'{col_name}'] = row[col_name]
                except KeyError as e:
                    print(f'KeyError:{e}')

    return results


def combine_multiple_iteration_results_of_the_same_tool(base_dir:str,tool_or_result_identifier:str,result_file_paths:list,data_to_be_collected:list):
    dict_result=[]
    for csv_file in result_file_paths:
        dict_result.append(collect_csv_data_in_dict(base_dir,csv_file,data_to_be_collected))

    results=[]
    average_results=[]
    for key,value in dict_result[0].items():
        key_items=str(key).split('#')

        if 'time' in value.keys():
            time_all=[value['time']]
            for item_dict in dict_result[1:]:
                if key in item_dict.keys():
                    time_all.append(item_dict[key]['time'])
                else:
                    time_all.append(0)
        else:
            time_all=[0,0,0]

        if 'cov' in value.keys():
            cov_all = [value['cov']]
            for item_dict in dict_result[1:]:
                if key in item_dict.keys():
                    cov_all.append(item_dict[key]['cov'])
                else:
                    cov_all.append(0)
        else:
            cov_all=[0,0,0]

        if 'vul' in value.keys():
            vul_all = [value['vul']]
            for item_dict in dict_result[1:]:
                if key in item_dict.keys():
                    vul_all.append(item_dict[key]['vul'])
                else:
                    vul_all.append(0)
        else:
            vul_all=[0,0,0]

        if 'total_states' in value.keys():
            total_states_all = [value['total_states']]
            for item_dict in dict_result[1:]:
                if key in item_dict.keys():
                    total_states_all.append(item_dict[key]['total_states'])
                else:
                    total_states_all.append(0)
        else:
            total_states_all=[0,0,0]


        if 'total_runtime_instructions' in value.keys():
            new_columns=['solidity','solc','contract','states1','states2','states3','time1','time2','time3','cov1','cov2','cov3','vul1','vul2','vul3','total_runtime_instructions']
            new_columns_avg=['solidity','solc', 'contract', 'total_states', 'time', 'cov', 'vul',
                         'total_runtime_instructions']
            results.append(key_items+total_states_all+time_all+cov_all+vul_all+[value['total_runtime_instructions']])

            average_results.append(
                key_items + [get_average_0(total_states_all),get_average_0(time_all),get_average_0(cov_all),get_average_0(vul_all)] + [value['total_runtime_instructions']]
            )
        elif 'covered_runtime_instructions' in value.keys():
            new_columns = ['solidity', 'solc', 'contract', 'states1', 'states2',
                           'states3', 'time1', 'time2', 'time3', 'cov1', 'cov2',
                           'cov3', 'vul1', 'vul2', 'vul3',
                           'covered_runtime_instructions']
            new_columns_avg = ['solidity', 'solc', 'contract', 'total_states',
                               'time', 'cov', 'vul',
                               'covered_runtime_instructions']
            results.append(
                key_items + total_states_all + time_all + cov_all + vul_all + [
                    value['covered_runtime_instructions']])

            average_results.append(
                key_items + [get_average_0(total_states_all),
                             get_average_0(time_all), get_average_0(cov_all),
                             get_average_0(vul_all)] + [
                    value['covered_runtime_instructions']]
            )
        else:
            new_columns = ['solidity', 'solc', 'contract', 'states1', 'states2',
                           'states3', 'time1', 'time2', 'time3', 'cov1', 'cov2',
                           'cov3', 'vul1', 'vul2', 'vul3']
            new_columns_avg = ['solidity', 'solc', 'contract', 'total_states',
                               'time', 'cov', 'vul']
            results.append(
                key_items + total_states_all + time_all + cov_all + vul_all)

            average_results.append(
                key_items + [get_average_0(total_states_all),
                             get_average_0(time_all), get_average_0(cov_all),
                             get_average_0(vul_all)]
            )


    output_csv_path = f'{base_dir}{tool_or_result_identifier}_combined_{len(result_file_paths)}_instances_results.csv'
    df_result=pd.DataFrame(results)
    df_result.columns=new_columns
    df_result.to_csv( output_csv_path, index=False,sep=',',lineterminator='\n')

    output_csv_path = f'{base_dir}{tool_or_result_identifier}_average_of_{len(result_file_paths)}_instances_results.csv'
    df_result_average = pd.DataFrame(average_results)
    df_result_average.columns = new_columns_avg
    df_result_average.to_csv(output_csv_path, index=False,sep=',',lineterminator='\n')


def combine_multiple_csv_files(base_dir:str, csv_file_path_and_names:list, data_to_be_collected:list=[], merge_on_columns:list=[], result_file_name_identifier:str= ''):
    if len(merge_on_columns)==0:
        merge_on_columns=key_columns
    assert len(csv_file_path_and_names)>=2

    # prepare identifiers
    alphabet = list(string.ascii_lowercase)

    assert len(csv_file_path_and_names) < len(alphabet)
    identifiers=["_" + alphabet[idx] for idx in range(len(csv_file_path_and_names))]

    # merge data
    df_combined=None
    for index, csv_path in enumerate(csv_file_path_and_names):
        df_data=collect_and_format_csv_data(base_dir,csv_path,data_to_be_collected)

        # rename columns
        rename_columns = [name if name in merge_on_columns else name + identifiers[index] for name in
                          df_data.columns]
        df_data.columns = rename_columns

        # merge
        if df_combined is None:
            df_combined=df_data
        else:
            df_combined=df_combined.merge(df_data,on=merge_on_columns)

    # prepare output name
    if len(result_file_name_identifier)==0:
        mid_name= f'{len(csv_file_path_and_names)}_csv_files'
    else:
        mid_name=result_file_name_identifier

    df_combined.to_csv(base_dir + f'combined_{mid_name}_results.csv', index=False,sep=',',lineterminator="\n")

