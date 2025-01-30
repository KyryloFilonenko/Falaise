#!/bin/sh

# 1) Run name +
# 2) Time +
# 3) simu names +-
# 4) Num fold +
# 5) Num ev +
# 6) Rm Reco (TEMP_send) -
# 7) rm brio (TEMP_send) -

FAL_DIR=/sps/nemo/scratch/kfilonen/Falaise

if [ ! -d ${FAL_DIR}/DATA ]; then
    mkdir ${FAL_DIR}/DATA
fi

echo "******************************************" 
echo "Do you want to create new run(new) or update old one(old)?"
read CHOISE
echo "******************************************" 

if [ "$CHOISE" = "new" ]; then
    echo "Choose the name for your run:"
    read RUN_NAME
    echo "******************************************" 
    if [ ! -d $FAL_DIR/DATA/$RUN_NAME ]; then
        SIMU_NAME=("0nu_Se82_flat" "0nu_Se82_bent")
        SIMU_ARRAY=$(printf "\"%s\", " "${SIMU_NAME[@]}" | sed 's/, $//')
        echo "How many folders do you want to create?"
        read NUM_FOL
        echo "******************************************"
        echo "How many events per folder do you want to create?"
        read NUM_EV
        echo "******************************************"
        echo "What is control time? (hh:mm)"
        read TIME
        echo "******************************************"
        echo "Please, carefully check your simulation setups and correctness of their format:"
        echo "Simulation setups: $SIMU_ARRAY"
        echo "Number of folders: $NUM_FOL"
        echo "Number of events per folder: $NUM_EV"
        echo "General number of events: $((NUM_FOL * NUM_EV))"
        echo "Control time: $TIME (should be in hh:mm format)"
        echo "******************************************"
        echo "Are you agree with it? (yes/no)"
        read SIMU_AGREEMENT
        if [ "$SIMU_AGREEMENT" = "yes" ]; then
            mkdir -p $FAL_DIR/DATA/$RUN_NAME
            RUN_DIR=$FAL_DIR/DATA/$RUN_NAME
            NUM_FOL=$((NUM_FOL - 1))

            cp $FAL_DIR/TEMP_analyze_all.cpp $RUN_DIR/analyze_$RUN_NAME.cpp
            MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule
            sed "s|\$1|$MI_DIR|g; s|\$2|$MI_DIR|g; s|\$3|$NUM_FOL|g; s|\$4|$NUM_EV|g; s|\$5|$RUN_NAME|g; s|\$6|${#SIMU_NAME[@]}|g; s|\$7|$SIMU_ARRAY|g" "$FAL_DIR/TEMP_analyze_all.cpp" > "$RUN_DIR/analyze_$RUN_NAME.cpp"
        
            for simu_name in "${SIMU_NAME[@]}"; do
                
                mkdir $RUN_DIR/$simu_name
                SIMU_DIR=$RUN_DIR/$simu_name
            
                cp $FAL_DIR/Setup/Setup_$simu_name.conf $SIMU_DIR/Setup_$simu_name.conf
                
                cp $FAL_DIR/TEMP_Simu.conf $SIMU_DIR/Simu_$simu_name.conf # створити темплейт для конфігураційного файла та зміни сід для нього
                sed "s|\$1|$RUN_DIR|g; s|\$2|$simu_name|g; s|\$3|$NUM_EV|g" "$FAL_DIR/TEMP_Simu.conf" > "$SIMU_DIR/Simu_$simu_name.conf"
            
                cp $FAL_DIR/TEMP_analyze.cpp $SIMU_DIR/analyze_$simu_name.cpp
                MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule
                sed "s|\$1|$MI_DIR|g; s|\$2|$MI_DIR|g; s|\$3|$NUM_FOL|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_analyze.cpp" > "$SIMU_DIR/analyze_$simu_name.cpp"
            
                for i in $(seq 0 $NUM_FOL); do
                    mkdir $SIMU_DIR/$i
                    
                    cp $FAL_DIR/TEMP_send.sh $SIMU_DIR/$i/send_$simu_name.sh
                    sed "s|\$1|$TIME|g; s|\$2|$SIMU_DIR|g; s|\$3|$i|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_send.sh" > "$SIMU_DIR/$i/send_$simu_name.sh"
                    chmod 755 $SIMU_DIR/$i/send_$simu_name.sh
                    sbatch --job-name=simu_$simu_name_${i} --output=$SIMU_DIR/${i}/OUT_%j.log $SIMU_DIR/$i/send_$simu_name.sh
                    
                    echo $simu_name "   " $i
                    # sbatch --job-name=simu_$simu_name_${i} --output=$SIMU_DIR/${i}/OUT_%j.log TEMP_send.sh $TIME $SIMU_DIR $SIMU_DIR/$i $simu_name $NUM_EV
                    # sbatch --job-name=simu_${i} \ # назва яка показується в squeue (ні на що не впливає по суті)
                    #        --output=${TFAL_DIR}/DATA/${RUN_NAME}/${i}/OUT_%j.log \ # names of slurm files
                    #        simulate.sh $i $RUN_NAME #назва надсилаємого файлу і змінні
                    #        не треба переписувати файл, можна використовувати це кожен раз використовуючи темп файл
            
                # видаляти перший бріофайл в темплейті
                done
            done
        else
            echo "Please choose correct simulation setups and restart script."
        fi
    else
        echo "Run with this name already exists. Please restart the script and choose correct option."
    fi
fi




if [ "$CHOISE" = "old" ]; then
    echo "Choose the name of existing run:"
    read RUN_NAME
    echo "******************************************" 
    if [ ! -d $FAL_DIR/DATA/$RUN_NAME ]; then
        echo "Run with this name don't exists. Please restart the script and choose correct option."
    else
        echo "Do you want to add or correct data? (add/cor)"
        read CHECKPOINT
        echo "******************************************"
        if [ "$CHECKPOINT" = "add" ]; then
            SIMU_NAME=("0nu_Se82_flat" "0nu_Se82_bent")
            SIMU_ARRAY=$(printf "\"%s\", " "${SIMU_NAME[@]}" | sed 's/, $//')
            echo "Write start folder:"
            read START_FOL
            echo "Write final folder?"
            read FINAL_FOL
            NUM_FOL=$((FINAL_FOL - START_FOL + 1))            
            echo "******************************************"
            echo "How many events per folder do you want to create? It should be the same as in old folders."
            read NUM_EV
            echo "******************************************"
            echo "What is control time? (hh:mm)"
            read TIME
            echo "******************************************"
            echo "Please, carefully check your simulation setups and correctness of their format:"
            echo "Simulation setups: $SIMU_ARRAY"
            echo "Start folder: $START_FOL"
            echo "Final folder: $FINAL_FOL"
            echo "Number of events per folder: $NUM_EV"
            echo "General number of added events: $((NUM_FOL * NUM_EV))"
            echo "General number of events: $(((FINAL_FOL + 1) * NUM_EV))"
            echo "Control time: $TIME (should be in hh:mm format)"
            echo "You should change analyze_all script after changing range of data."
            echo "******************************************"
            echo "Are you agree with it? (yes/no)"
            read SIMU_AGREEMENT
            if [ "$SIMU_AGREEMENT" = "yes" ]; then
                RUN_DIR=$FAL_DIR/DATA/$RUN_NAME
                MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule            
                for simu_name in "${SIMU_NAME[@]}"; do
                    SIMU_DIR=$RUN_DIR/$simu_name
                    
                    cp $FAL_DIR/TEMP_analyze.cpp $SIMU_DIR/analyze_$simu_name.cpp
                    MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule
                    sed "s|\$1|$MI_DIR|g; s|\$2|$MI_DIR|g; s|\$3|$FINAL_FOL|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_analyze.cpp" > "$SIMU_DIR/analyze_$simu_name.cpp"
                
                    for i in $(seq $START_FOL $FINAL_FOL); do
                        mkdir $SIMU_DIR/$i
                        
                        cp $FAL_DIR/TEMP_send.sh $SIMU_DIR/$i/send_$simu_name.sh
                        sed "s|\$1|$TIME|g; s|\$2|$SIMU_DIR|g; s|\$3|$i|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_send.sh" > "$SIMU_DIR/$i/send_$simu_name.sh"
                        chmod 755 $SIMU_DIR/$i/send_$simu_name.sh
                        sbatch --job-name=simu_$simu_name_${i} --output=$SIMU_DIR/${i}/OUT_%j.log $SIMU_DIR/$i/send_$simu_name.sh
                        echo $simu_name "   " $i
                    done
                done  
            else
                echo "Please choose correct simulation setups and restart script."
            fi
        fi
            

        if [ "$CHECKPOINT" = "cor" ]; then
            SIMU_NAME=("0nu_Se82_flat")
            SIMU_ARRAY=$(printf "\"%s\", " "${SIMU_NAME[@]}" | sed 's/, $//')
            echo "Write start folder:"
            read START_FOL
            echo "Write final folder?"
            read FINAL_FOL
            NUM_FOL=$((FINAL_FOL - START_FOL + 1))            
            echo "******************************************"
            echo "How many events per folder do you want to create? It should be the same as in old folders."
            read NUM_EV
            echo "******************************************"
            echo "What is control time? (hh:mm)"
            read TIME
            echo "******************************************"
            echo "Please, carefully check your simulation setups and correctness of their format:"
            echo "Simulation setups: $SIMU_ARRAY (should be 1 simulation setup)"
            echo "Start folder: $START_FOL"
            echo "Final folder: $FINAL_FOL"
            echo "Number of events per folder: $NUM_EV"
            echo "General number of added events: $((NUM_FOL * NUM_EV))"
            echo "Control time: $TIME (should be in hh:mm format)"
            echo "******************************************"
            echo "Are you agree with it? (yes/no)"
            read SIMU_AGREEMENT
            if [ "$SIMU_AGREEMENT" = "yes" ]; then
                RUN_DIR=$FAL_DIR/DATA/$RUN_NAME
                MI_DIR=/sps/nemo/scratch/kfilonen/Falaise/MiModule            
                for simu_name in "${SIMU_NAME[@]}"; do
                    SIMU_DIR=$RUN_DIR/$simu_name
                    for i in $(seq $START_FOL $FINAL_FOL); do
                        # rm -rf $SIMU_DIR/$i
                        mkdir $SIMU_DIR/$i
                        cp $FAL_DIR/TEMP_send.sh $SIMU_DIR/$i/send_$simu_name.sh
                        sed "s|\$1|$TIME|g; s|\$2|$SIMU_DIR|g; s|\$3|$i|g; s|\$4|$simu_name|g; s|\$5|$NUM_EV|g" "$FAL_DIR/TEMP_send.sh" > "$SIMU_DIR/$i/send_$simu_name.sh"
                        chmod 755 $SIMU_DIR/$i/send_$simu_name.sh
                        sbatch --job-name=simu_$simu_name_${i} --output=$SIMU_DIR/${i}/OUT_%j.log $SIMU_DIR/$i/send_$simu_name.sh
                        echo $simu_name "   " $i
                    done
                done 
            else
                echo "Please choose correct simulation setups and restart script."
            fi
        fi
    fi
fi