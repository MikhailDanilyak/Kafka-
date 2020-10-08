#!/bin/bash
source Config.txt
Address=$AddressFirstPart$IP$AddressSecondPart
while [[ $1 != "" ]]; do
    case $1 in
    # Блок для запуска выбранного сервера
    "--start")
        shift #Для получения имени запускаемого процесса
        # Запуск zookeeper
        if [[ $1 = "zookeeper" ]] && [[ $2 =~ .*zookeeper.* ]] && [[ $3 = "" ]]; then
            #Копируем полученные настройки на сервер
            scp -i $Filepath$KeyName $2 $Address:$PathToConfigFiles
            #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
            ssh -i $Filepath$KeyName $Address "
            $PathToStartScripts/zookeeper-server-start $PathToConfigFiles/zookeeper.properties"
            shift
            shift
        # Запуск kafka
        elif [[ $1 = "kafka" ]]  && [[ $2 =~ .*server.* ]] && [[ $3 = "" ]]; then
            #Копируем полученные настройки на сервер
            scp -i $Filepath$KeyName $2 $Address:$PathToConfigFiles
            #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска kafka
            ssh -i $Filepath$KeyName $Address "
            $PathToStartScripts/kafka-server-start $PathToConfigFiles/server.properties"
            shift
            shift
        else
            echo "Команда содержит ошибку или не определена"
        fi
    ;;

    # Блок для проверки статуса сервера
    "--status")
        shift #Для получения имени проверяемого процесса
        if [[ $1 = "zookeeper" && -n "$(ssh -i $Filepath$KeyName $Address pgrep -f zookeeper)" ]]  && [[ $2 = "" ]]; then
            ssh -i $Filepath$KeyName $Address pgrep -f zookeeper | awk '{printf "Zookeeper:Running, pid = %d\n", $1}'
        elif [[ $1 = "zookeeper" ]] && [[ $2 = "" ]]; then
            echo "Zookeeper: Not Running"
        elif [[ $1 = "kafka" && -n "$(ssh -i $Filepath$KeyName $Address pgrep -f zookeeper)" ]]  && [[ $2 = "" ]]; then
            ssh -i $Filepath$KeyName $Address pgrep -f kafka | awk '{printf "Kafka:Running, pid = %d\n", $1}'
        elif [[ $1 = "kafka" ]]  && [[ $2 = "" ]]; then
            echo "Kafka: Not Running"
        else
            echo "Команда содержит ошибку или не определена"
        fi
        shift
    ;;
    # Блок для остановки выбранного сервера
    "--stop")
        shift #Для получения имени запускаемого процесса
        # Запуск zookeeper
        if [[ $1 = "zookeeper" ]] && [[ $2 = "" ]]; then
            #Копируем полученные настройки на сервер
            scp -i $Filepath$KeyName $2 $Address:$PathToConfigFiles
            #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
            ssh -i $Filepath$KeyName $Address "
            $PathToStartScripts/zookeeper-server-stop "
            shift
            shift
        # Запуск kafka
        elif [[ $1 = "kafka" ]] && [[ $2 = "" ]]; then
            #Копируем полученные настройки на сервер
            scp -i $Filepath$KeyName $2 $Address:$PathToConfigFiles
            #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска kafka
            ssh -i $Filepath$KeyName $Address "
            $PathToStartScripts/kafka-server-stop "
            shift
            shift
        else
            echo "Команда содержит ошибку или не определена"
        fi
    ;;
    *)
    echo "Команда содержит ошибку или не определена"
    ;;
    esac
    shift
done
