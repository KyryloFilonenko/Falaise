#!/bin/sh

FAL_DIR=/sps/nemo/scratch/kfilonen/Falaise

if [ ! -d ${FAL_DIR}/DATA ]; then
    mkdir ${FAL_DIR}/DATA
fi

# echo "Choose the name for your run:"
# read RUN_NAME
# echo "                                          " 
RUN_NAME=Dataset_mf_2

if [ ! -d $FAL_DIR/DATA/$RUN_NAME ]; then
    mkdir $FAL_DIR/DATA/$RUN_NAME
    RUN_DIR=$FAL_DIR/DATA/$RUN_NAME
    START_FOL=0
else
    RUN_DIR=$FAL_DIR/DATA/$RUN_NAME
#     echo "This run exists. Do you want to modify this run(y) or make new one(n)?"
#     read CHOISE
#     if [CHOISE == n]; then
#         echo "Choose the name for your run:"
#         read RUN_NAME
#         echo "                                          "
#         mkdir $FAL_DIR/DATA/$RUN_NAME
#         RUN_DIR=$TEST_FOLD/DATA/$RUN_NAME  
#         START_FOL = 0
#     fi
#     if [CHOISE == y]; then
#         RUN_DIR=$TEST_FOLD/DATA/$RUN_NAME  
#         echo "From what folder you want to add new data?"
#         read START_FOL
#         echo "                                          "
#     fi
fi


#пам'ятати про обмеження на час для різних кількостей івентів

TIME=10:00 # time limit

# echo "How many type of simulations you want to do?"
# read NUM_SIM
# echo "                                          "

SIMU_NAME=("mf_0nu_Se82_flat" "mf_2nu_Se82_flat" "mf_Bi214_flat" "mf_Tl208_flat" "mf_0nu_Se82_bent" "mf_2nu_Se82_bent" "mf_Bi214_bent" "mf_Tl208_bent")

num_fol=99 # folders per simulation (+1)

NUM_EV=100000  # events per folder

# скільки івентів, скільки івентів на файл
# зміна і для "продовження", типу з 101 до 200

# 10 по 1000 для тесту
# перевіряти чи існуєть файли на кожному кроці

# FINAL_FOL=$START_FOL+$NUM_FOL

simu_names=$(printf "\"%s\", " "${SIMU_NAME[@]}" | sed 's/, $//')

cp $FAL_DIR/TEMP_analyze_all.cpp $RUN_DIR/analyze_$RUN_NAME.cpp
    MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule
    sed "s|\$1|$MI_DIR|g; s|\$2|$MI_DIR|g; s|\$3|$num_fol|g; s|\$4|$NUM_EV|g; s|\$5|$RUN_NAME|g; s|\$6|${#SIMU_NAME[@]}|g; s|\$7|$simu_names|g" "$FAL_DIR/TEMP_analyze_all.cpp" > "$RUN_DIR/analyze_$RUN_NAME.cpp"

for simu_name in "${SIMU_NAME[@]}"; do
    
    mkdir $RUN_DIR/$simu_name
    SIMU_DIR=$RUN_DIR/$simu_name

    cp $FAL_DIR/Setup/Setup_$simu_name.conf $SIMU_DIR/Setup_$simu_name.conf
    
    cp $FAL_DIR/TEMP_Simu.conf $SIMU_DIR/Simu_$simu_name.conf # створити темплейт для конфігураційного файла та зміни сід для нього
    sed "s|\$1|$RUN_DIR|g; s|\$2|$simu_name|g; s|\$3|$NUM_EV|g" "$FAL_DIR/TEMP_Simu.conf" > "$SIMU_DIR/Simu_$simu_name.conf"

    cp $FAL_DIR/TEMP_analyze.cpp $SIMU_DIR/analyze_$simu_name.cpp
    MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule
    sed "s|\$1|$MI_DIR|g; s|\$2|$MI_DIR|g; s|\$3|$num_fol|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_analyze.cpp" > "$SIMU_DIR/analyze_$simu_name.cpp"

    for i in $(seq 0 $num_fol); do
        mkdir $SIMU_DIR/$i
        
        cp $FAL_DIR/TEMP_send.sh $SIMU_DIR/$i/send_$simu_name.sh
        sed "s|\$1|$TIME|g; s|\$2|$SIMU_DIR|g; s|\$3|$i|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_send.sh" > "$SIMU_DIR/$i/send_$simu_name.sh"
        chmod 755 $SIMU_DIR/$i/send_$simu_name.sh
        sbatch --job-name=simu_$simu_name_${i} --output=$SIMU_DIR/${i}/OUT_%j.log $SIMU_DIR/$i/send_$simu_name.sh
        
        echo $simu_name "   " $i
#         sbatch --job-name=simu_$simu_name_${i} --output=$SIMU_DIR/${i}/OUT_%j.log TEMP_send.sh $TIME $SIMU_DIR $SIMU_DIR/$i $simu_name $NUM_EV
#         sbatch --job-name=simu_${i} \ # назва яка показується в squeue (ні на що не впливає по суті)
#                --output=${TFAL_DIR}/DATA/${RUN_NAME}/${i}/OUT_%j.log \ # names of slurm files
#                simulate.sh $i $RUN_NAME #назва надсилаємого файлу і змінні
               # не треба переписувати файл, можна використовувати це кожен раз використовуючи темп файл

    # видаляти перший бріофайл в темплейті
    done
done