import os
import subprocess

# enable reporting of the result
REPORT_MODE = 0

#print everything in the console
PRINT_MODE = 0

# enable log file to print all exception
DEBUG_MODE = 0

# check false positive in concurrency
CHECK_CONCURRENCY_FP = 0

# Timeout for z3 in ms
TIMEOUT = 100

# Set this flag to 2 if we want to do evm real value unit test
# Set this flag to 3 if we want to do evm symbolic unit test
UNIT_TEST = 0

# timeout to run symbolic execution (in secs)
GLOBAL_TIMEOUT = 50

# timeout to run symbolic execution (in secs) for testing
GLOBAL_TIMEOUT_TEST = 2

# print path conditions
PRINT_PATHS = 0

# WEB = 1 means that we are using Oyente for web service
WEB = 0

# Redirect results to a json file.
STORE_RESULT = 0

# depth limit for DFS
DEPTH_LIMIT = 50

GAS_LIMIT = 4000000

LOOP_LIMIT = 10

# Use a public blockchain to speed up the symbolic execution
USE_GLOBAL_BLOCKCHAIN = 0

USE_GLOBAL_STORAGE = 0

# Take state data from state.json to speed up the symbolic execution
INPUT_STATE = 0

# Check assertions
CHECK_ASSERTIONS = 0

GENERATE_TEST_CASES = 0

# Run Oyente in parallel
PARALLEL = 0

# Output lines of code that contain untested bytecode
UNCOVERED_BYTE_CODE_LINES = 0

# an array of all supported solc versions in the container
AVAILABLE_SOLC_VERSIONS = ['0.4.21','0.4.20','0.4.19','0.4.18','0.4.17','0.4.16','0.4.15','0.4.14','0.4.13','0.4.12','0.4.11','0.4.10']

if "SOLC_CUSTOM_PATH" in os.environ:
    SOLC_CUSTOM_PATH = os.environ['SOLC_CUSTOM_PATH']
else:
    SOLC_CUSTOM_PATH = "/oyente/solc"

SOLC_PATH = subprocess.check_output(['which', 'solc'], universal_newlines=True).rstrip()
