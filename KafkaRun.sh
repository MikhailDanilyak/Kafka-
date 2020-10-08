#!/bin/bash
source Config.txt


# Предполагается, что $1=--start; $2=zookeper или kafka; $3=path до config файлов zookeeper и kafka
if [ $1 = "--start" ]; then
    settingspath=$3
elif [ $2 = "--start" ]; then
    settingspath=$1
fi
if [[ $2 = zookeeper || $3 = zookeeper ]] && [[ "$settingspath" =~ .*zookeeper.* ]]; then 
    if [[ $1 = "--start" || $2 = "--start" ]]; then
    #Копируем полученные настройки на сервер
    scp -i $Filepath$KeyName $settingspath $Address:$PathToConfigFiles
    if [ $3 = "zookeeper" ] || [ $2 = "zookeeper" ]; then 
        #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
        ssh -i $Filepath$KeyName $Address '
        $PathToStartScripts/zookeeper-server-start $PathToConfigFiles/zookeeper.properties'
    elif [ $3 = "kafka" ] || [ $2 = "kafka" ]; then
        #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска kafka
        ssh -i $Filepath$KeyName $Address '
        $PathToStartScripts/kafka-server-start $PathToConfigFiles/server.properties'
    else 
        echo "Команда не определена"
    fi
    else
        echo "Команда содержит ошибку"
    fi
elif [[ $2 = kafka || $3 = kafka ]] && [[ "$settingspath" =~ .*server.* ]]; then 
    if [[ $1 = "--start" || $2 = "--start" ]]; then
    #Копируем полученные настройки на сервер
    scp -i $Filepath$KeyName $settingspath $Address:$PathToConfigFiles
    if [ $3 = "zookeeper" ] || [ $2 = "zookeeper" ]; then 
        #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
        ssh -i $Filepath$KeyName $Address '
        $PathToStartScripts/zookeeper-server-start $PathToConfigFiles/zookeeper.properties'
    elif [ $3 = "kafka" ] || [ $2 = "kafka" ]; then
        #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска kafka
        ssh -i $Filepath$KeyName $Address '
        $PathToStartScripts/kafka-server-start $PathToConfigFiles/server.properties'
    else 
        echo "Команда не определена"
    fi
    else
        echo "Команда содержит ошибку"
    fi
elif [[ $1 = "status" || $2 = "status" ]]; then
    if [[ $2 = "zookeeper" || $1 = "zookeeper" && -n "$(ssh -i $Filepath$KeyName $Address pgrep -f zookeeper)" ]];then
        ssh -i $Filepath$KeyName $Address pgrep -f zookeeper | awk '{printf "Zookeeper:Running, pid = %d\n", $1}'
    elif [[ $2 = "kafka" || $1 = "kafka" && -n "$(ssh -i $Filepath$KeyName $Address pgrep -f zookeeper)" ]];then
        ssh -i $Filepath$KeyName $Address pgrep -f kafka | awk '{printf "Kafka:Running, pid = %d\n", $1}'
    elif [[ $2 = "zookeeper" || $1 = "zookeeper" ]]; then
        echo "Zookeeper: Not Running"
    elif [[ $2 = "Kafka" || $1 = "Kafka" ]]; then
        echo "Kafka: Not Running"
    fi
else
    echo "Команда неверная"
fi
