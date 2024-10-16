These are the scripts to prepare a receptor with probes for DOCK3.8
To use you must have DiffDOCK-L installed and working on the umich cluster
my conda enviorment for this under enviorment.yml.
Although this environment does not contain the prereq for DiffDOCK

to use you must go to /bin/probe_wizard.sh and change the three following variables:
WIZARD_PATH=(whereever you have DiffDockProbe installed)
PROJ_PATH=(where you want the files and probes to be stored)
DIFFDOCK_PATH=(path where you have diffdock installed)

after that activate the wizard via the command:

source ./probe_wizard.sh

and follow the steps sequentially. step 2 creates a sbatch file that you need to run after:

sbatch ${PROJ_PATH}/bin/diffdock_probe.sbatch

after running the clusting step your desired probes will be located in:

${PROJ_PATH}/docked_probes as "prepared_structure.pdb"