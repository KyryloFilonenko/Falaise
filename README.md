# README - Simulation Run Management Script

## Overview
This script automates the creation and management of simulation runs for the Falaise framework. It allows users to create new runs, update existing runs, and manage simulation data efficiently using Slurm workload manager.

## Features
- Create a new simulation run with user-defined parameters
- Update an existing run by adding new folders or correcting data
- Automatically generate and configure simulation scripts
- Submit batch jobs using Slurm

## Prerequisites
- A working Slurm environment
- Required configuration and template files in the Falaise directory
- Appropriate permissions for creating and managing directories

## Script Usage
### Running the Script
Execute the script using the following command:
```sh
./manager.sh
```
You will be prompted to choose between creating a new run or updating an existing one.

### Creating a New Run
1. Choose `new` when prompted.
2. Provide a unique name for the run.
3. Specify the number of folders and events per folder.
4. Define the control time (hh:mm format).
5. Verify the provided parameters.
6. If everything is correct, the script will generate necessary directories, configure scripts, and submit batch jobs.

### Updating an Existing Run
1. Choose `old` when prompted.
2. Select whether you want to `add` new data or `cor`rect existing data.
3. Provide the run name.
4. Specify the range of folders and event count.
5. Define the control time.
6. If adding data, the script will create and configure new folders within the existing run.
7. If correcting data, specific folders will be replaced with new configurations.

## Directory Structure
```
FAL_DIR
├── DATA
│   ├── <RUN_NAME>
│   │   ├── <Setup name 1>
│   │   │   ├── Setup_<Setup name 1>.conf
│   │   │   ├── Simu_<Setup name 1>.conf
│   │   │   ├── analyze_<Setup name 1>.cpp
│   │   │   ├── <FOLDER_NUMBER>
│   │   │   │   ├── send_<Setup name 1>.sh
│   │   │   │   ├── OUT_<job_id>.log
│   │   │   │   ├── root_<Setup name 1>.root
│   │   ├── <Setup name 2>
│   │   │   ├── Setup_<Setup name 2>.conf
│   │   │   ├── Simu_<Setup name 2>.conf
│   │   │   ├── analyze_<Setup name 2>.cpp
│   │   │   ├── <FOLDER_NUMBER>
│   │   │   │   ├── send_<Setup name 2>.sh
│   │   │   │   ├── OUT_<job_id>.log
│   │   │   │   ├── root_<Setup name 2>.root
```

## Configuration Files
- `TEMP_analyze_all.cpp` - Template for the general analysis script
- `TEMP_Simu.conf` - Template for simulation configuration files
- `TEMP_analyze.cpp` - Template for individual simulation analysis
- `TEMP_send.sh` - Template for Slurm submission scripts

## Notes
- Ensure the `FAL_DIR` variable points to the correct location.
- The script assumes predefined simulation setups (`0nu_Se82_flat`, `0nu_Se82_bent`). Modify as needed.
- Review the generated scripts before execution for accuracy.

## Troubleshooting
- If the script does not execute, ensure it has the proper execution permissions:
  ```sh
  chmod 755 manager.sh
  ```
- If jobs do not appear in Slurm, check the logs in the `OUT_<job_id>.log` files.
- If a run with the same name exists, choose a different name or update the existing one.
