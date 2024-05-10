import argparse

from result_collection.result_data_extraction.result_for_24_exp_sGuard import \
    obtain_results_for_24_exp_sGuard
from result_collection.result_data_extraction.result_for_24_exp_tie_breaking_rules import \
    obtain_results_for_24_exp_tie_breaking_rules
from result_collection.result_data_extraction.result_for_24_impact_of_depth_limit_in_phase1 import \
    obtain_results_for_24_impact_of_depth_limit_in_phase1
from result_collection.result_data_extraction.result_for_case_studies import \
    obtain_results_for_case_studies


def main():
    parser = argparse.ArgumentParser(description='Description of your program')
    # Add options
    parser.add_argument('--experiment', type=str, default='24_exp_sGuard',
                        help='the name of the experiment')
    # parser.add_argument('--option3', choices=['A', 'B', 'C'],
    #                     help='Description of option 3')
    # parser.add_argument('--p1-depth-limit', default=1,type=int,
    #                     help='the depth limit of Phase 1')
    # parser.add_argument('--timeout', default=900,type=int,
    #                     help='the time the tool is set to execute a contract')
    # parser.add_argument('--execution-times', type=int, default=3,
    #                     help='the number of times the tool is run on a contract')

    # Parse arguments
    args = parser.parse_args()

    # # Accessing options
    # print('p1-depth-limit:', args.p1_depth_limit)
    # print('timeout:', args.timeout)
    # print('execution-times:', args.execution_times)

    if args.experiment in ['24_exp_sGuard']:
        obtain_results_for_24_exp_sGuard(args=args)
    elif args.experiment in ['24_impact_of_depth_limit_in_phase1']:
        obtain_results_for_24_impact_of_depth_limit_in_phase1(args=args)
    elif args.experiment in ['24_exp_tie_breaking_rules']:
        obtain_results_for_24_exp_tie_breaking_rules(args=args)
    elif args.experiment in ['case_studies']:
        obtain_results_for_case_studies(args=args)
    else:
        print(f'the given experiment name is not correct:{args.dataset}')
        exit()



if __name__ == "__main__":
    main()
