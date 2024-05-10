
import sys
import os
import csv
import pandas as pd
import numpy as np
import json
import ast


def find_all_files(dir:str,extension:str):
    """
    Given a parent directory, find all files with extension of extension
    Args:
        dir: parent directory, e.g. "/usr/admin/HoloToken/"

    Returns:
        list of file directories. e.g. ["/usr/admin/HoloToken/user0001.extension"......]
    """
    res = []
    for file in os.listdir(dir):
        if file.endswith(extension):
            res.append(os.path.join(dir, file))
    return res



def random_select(data: list, seed: int, num: int):
    if len(data) < num:
        return data
    np.random.seed(seed)
    selected = np.random.choice(data, size=num, replace=False)
    return list(selected)


def remove_B_from_A(A: list, B: list):
    """
    remove the elements in B from A
    """
    for b in B:
        if b in A:
            A.remove(b)
    return A




def get_num_vul(data: str):
    if isinstance(data, float):
        return data
    if isinstance(data,int):
        return data
    res = ast.literal_eval(data)
    if isinstance(res, dict):
        return len(res.keys())
    else:
        return 0


def count_bugs(data: str) -> list:
    if str(data) in ['{}']:
        data_dict = {}
    else:
        try:
            data_dict = ast.literal_eval(data)
        except Exception as e:
            print(f'has exception when evaluate bug data: {e}')
            print(data)
    count_dict = {}
    if len(data_dict) > 0:
        for bug_detail in data_dict.values():
            if bug_detail['name'] in count_dict.keys():
                count_dict[bug_detail['name']] += 1
            else:
                count_dict[bug_detail['name']] = 1

    return count_dict
    # return ast.literal_eval(data)
    # return json.loads(data)


def get_covered_instructions(data: str):
    if isinstance(data, int):
        return int(data)
    elif isinstance(data, str):
        if data in ['-']:
            return 0
        else:
            return int(data)


def get_coverage(data: str):
    if isinstance(data,str):
        if data.__eq__('-'):
           
            return 0
        else:
            if '%' in data:
               
                return float(str(data).strip('%'))
            else:
                
                return float(data)
    else:
        return data


def get_integer_value(data: str):
    if isinstance(data, int):
        return data
    if isinstance(data, float):
        return data
    if data.isnumeric():
        return int(data)
    else:
        return '-'


def get_time(data):
    if isinstance(data, float):
        return data
    if str(data) in ['-']:
        return 0
    else:
        return float(data)


def count_deep_functions(data: str):
    count = 0
    data = str(data)
    if '[]' in data: return 0
    mylist = ast.literal_eval(data)
    for item in mylist:
        cov = str(item[0]).strip('%')
        if float(cov) < 100:
            if not str(item[1]) in ['name', 'symbol', 'safeSub', 'safeMul',
                                    'safeAdd', 'safeDiv']:
                count += 1
    return count


def function_coverage_difference(dataA: str, dataB: str):
    results = []
    if '[]' in dataA or '[]' in dataB: return []
    a = ast.literal_eval(dataA)
    a_dict = {}
    b = ast.literal_eval(dataB)
    b_dict = {}
    for item in a:
        cov = float(str(item[0]).strip('%'))
        ftn = str(item[1]).strip()
        a_dict[ftn] = cov
    for item in b:
        cov = float(str(item[0]).strip('%'))
        ftn = str(item[1]).strip()
        b_dict[ftn] = cov
    assert len(a_dict) == len(b_dict)
    for ftn, cov_a in a_dict.items():
        cov_b = b_dict[ftn]
        # print(f'ftn:{ftn} ')
        # print(f'cov_x:{cov_x} ')
        # print(f'cov_y:{cov_y} ')
        # assert cov_x>=cov_y
        if cov_a > cov_b:
            cov_diff = cov_a - cov_b
            results.append([ftn, cov_diff])
    return results


def average(data: list):
    valid_items = []
    sum = 0
    for item in data:
        if item != 0:
            valid_items.append(item)
    length = len(valid_items)
    if len(valid_items) == 0.0:
        return 0

    for item in valid_items:
        sum += item
    return sum / length


def get_average(data_list: list):
    sum = 0
    for item in data_list:
        if not str(item) in ['-']:
            sum += float(item)
    return sum / len(data_list)


def get_average_0(data_list: list):
    sum = 0
    item_len = 0
    for item in data_list:
        if not str(item) in ['-']:
            item_len += 1
            sum += float(item)
    if sum > 0:
        return sum / item_len
    else:
        return 0
