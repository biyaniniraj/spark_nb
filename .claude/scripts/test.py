#just write a test script
#!/usr/bin/env python3
import os
import sys
import subprocess
def main():
    # Run the test script and capture output
    result = subprocess.run(
        [sys.executable, "backend/scripts/import_excel.py", "test_data.xlsx"],
        capture_output=True,
        text=True
    )
    # Print the output for debugging
    print("STDOUT:")
    print(result.stdout)
    print("STDERR:")
    print(result.stderr)
    # Check if the script ran successfully
    if result.returncode != 0:
        print(f"Test failed with return code {result.returncode}")
        sys.exit(1)
    else:
        print("Test passed successfully.")
if __name__ == "__main__":    main()