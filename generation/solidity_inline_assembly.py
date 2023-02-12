from utils import Constants
import json
import os
target='json2_top_10000'
target='json1_top_10000'
contract_path=Constants.solidity_inline_assembly+target

results=[]
for file in os.listdir(contract_path):
    file_path=os.path.join(contract_path,file)
    f=open(file_path)
    re=json.load(f)
    if len(re['SourceCode'])>0:
        file_name=file.split('.')[0]+".sol"
        with open(Constants.solidity_inline_assembly+"solidity_files/"+file_name,'w') as ff:
            ff.write(re['SourceCode'])
            ff.close()
        results.append([file_name,re['CompilerVersion'],re['ContractName']])
        print(re)

