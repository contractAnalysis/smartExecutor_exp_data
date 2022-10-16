import numpy as np
import os
def random_select(data:list, seed:int, num:int):
    if len(data)<num:
        return data
    np.random.seed(seed)
    selected = np.random.choice(data, size=num, replace=False)
    return list(selected)

def remove_B_from_A(A:list, B:list):
    re=[]
    for a in A:
        if a not in B:
            re.append(a)
    return re
def find_all_file(dir,extension:str):
    """
    Given a parent directory, find all files with extension of extension
    Args:
        dir: parent directory, e.g. "/usr/admin/HoloToken/"

    Returns:
        list of file directories. e.g. ["/usr/admin/HoloToken/user0001.extension"......]
    """
    res = []
    for file in os.listdir(dir):
        if file.endswith("."+extension):
            res.append(os.path.join(dir, file))
    return res

def find_all_folders(dir):
    """
    Given a parent directory, find all folders within it
    Args:
        dir: parent directory, e.g. "/usr/admin/HoloToken/"

    Returns:
    """
    res = []
    for name in os.listdir(dir):
        path=os.path.join(dir, name)
        if os.path.isdir(path):
            res.append(path)
    return res

if __name__=="__main__":
    print(find_all_folders('/media/sf___share_vms/2022_exp_data_preparation/exp_benchmark/SB/SB_curated/'))
    print(random_select([1],20,2))