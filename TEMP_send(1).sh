#!/bin/sh
#SBATCH -t 0-$1
#SBATCH -n 1
#SBATCH --mem 8192M
#SBATCH --licenses sps

TUTO_FOLD=$2
FAL_FOLD=/sps/nemo/sw/Falaise/install_develop/
CONF_FAL=$FAL_FOLD/share/Falaise-4.1.0/resources/snemo/demonstrator/reconstruction/
CONF_SEN=/sps/nemo/scratch/kfilonen/Falaise/MiModule/testing_products/

if [ -f ${THRONG_DIR}/config/supernemo_profile.bash ]; then
	source ${THRONG_DIR}/config/supernemo_profile.bash
fi
snswmgr_load_stack base@2024-09-04
snswmgr_load_setup falaise@5.1.2
           
flsimulate -c $TUTO_FOLD/Simu_$4.conf \
           -o $TUTO_FOLD/$3/Simu_$4.brio

flreconstruct -i $TUTO_FOLD/$3/Simu_$4.brio \
              -p $CONF_FAL/official-2.0.0.conf \
              -o $TUTO_FOLD/$3/Reco_$4.brio

rm $TUTO_FOLD/$3/Simu_$4.brio
              
cd $TUTO_FOLD/$3/

#########
flreconstruct -i $TUTO_FOLD/$3/Reco_$4.brio -p /sps/nemo/scratch/kfilonen/SNCuts/build/SNCutsPipeline.conf -o CUT.brio
###########
            
flreconstruct -i $TUTO_FOLD/$3/Reco_$4.brio \
              -p $CONF_SEN/p_MiModule_v00.conf
            
mv Default.root $4_$5.root

# rm $TUTO_FOLD/$3/Reco_$4.brio