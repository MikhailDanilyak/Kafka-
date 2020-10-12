#!/bin/bash
source Config.txt
while [[ $1 != "" ]]; do
    case $1 in
    # Блок для запуска выбранного сервера
    "--start")
        shift #Для получения имени запускаемого процесса
        if [[ $2 != "" ]] || [[ $4 !=  "" ]]; then
          echo "Too many input arguments. Use --help for list of commands."
        else
          if [[ $1 != "kafka" ]] && [[ $1 != "zookeeper" ]]; then
            echo "Error in second parameter. It should be kafka or zookeper. You can also use --help for information."
          else
            if  (([[ $2 = "--config" ]] && ([[ $3 =~ .*zookeeper.* ]] || [[ $3 =~ .*server.* ]]) && [ -f $3 ]) || [ -f $CONFIG_FILES_LOCAL_PATH/server.properties ] || [ -f $CONFIG_FILES_LOCAL_PATH/zookeeper.properties ] ); then
              # Запуск zookeeper
              if [[ $1 = "zookeeper" ]]; then
                if ssh -i $KEY_FILEPATH $ADDRESS ps ax | grep zookeeper.properties > $LOG_PATH/zookeeper_status_log.txt; then
                  echo "Zookeeper already running"
                else
                  if [[ $2 = "" ]]; then
                    echo "You choose start server with --config path as default. You can change this path in config.txt."
                    #Копируем полученные настройки на сервер
                    scp -i $KEY_FILEPATH $CONFIG_FILES_LOCAL_PATH/zookeeper.properties $ADDRESS:$CONFIG_FILES_PATH
                    #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
                    ssh -i $KEY_FILEPATH $ADDRESS "
                    $SCRIPTS_PATH/zookeeper-server-start $CONFIG_FILES_PATH/zookeeper.properties" > $LOG_PATH/zookeeper_log.txt
                    echo "You can check log information in zookeeper_log.txt file at $LOG_PATH"
                  else
                    #Копируем полученные настройки на сервер
                    scp -i $KEY_FILEPATH $3 $ADDRESS:$CONFIG_FILES_PATH
                    #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
                    ssh -i $KEY_FILEPATH $ADDRESS "
                    $SCRIPTS_PATH/zookeeper-server-start $CONFIG_FILES_PATH/zookeeper.properties" > $LOG_PATH/zookeeper_log.txt
                    echo "You can check log information in zookeeper_log.txt file at $LOG_PATH"
                  fi
                fi
              elif [[ $1 = "kafka" ]]; then
                if ssh -i $KEY_FILEPATH $ADDRESS ps ax | grep server.properties > $LOG_PATH/kafka_status_log.txt; then
                  echo "Kafka already running"
                else
                    if [[ $2 = "" ]]; then
                      echo "You choose start server with --config path as default. You can change this path in config.txt."
                      #Копируем полученные настройки на сервер
                      scp -i $KEY_FILEPATH $CONFIG_FILES_LOCAL_PATH/server.properties $ADDRESS:$CONFIG_FILES_PATH
                      #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
                      ssh -i $KEY_FILEPATH $ADDRESS "
                      $SCRIPTS_PATH/kafka-server-start $CONFIG_FILES_PATH/server.properties" > $LOG_PATH/server_log.txt
                      echo "You can check log information in server_log.txt file at $LOG_PATH"
                    else
                      #Копируем полученные настройки на сервер
                      scp -i $KEY_FILEPATH $3 $ADDRESS:$CONFIG_FILES_PATH
                      #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска kafka
                      ssh -i $KEY_FILEPATH $ADDRESS "
                      $SCRIPTS_PATH/kafka-server-start $CONFIG_FILES_PATH/server.properties" > $LOG_PATH/server_log.txt
                      echo "You can check log information in server_log.txt file at $LOG_PATH"
                    fi
                fi
              else
                echo "No zookeeper.properties or server.properties file in your config directory or local config directory (Check CONFIG_FILES_LOCAL_PATH in config.txt). Or Error in word --config. Write --help for information."
              fi
            fi
          fi
        fi
        break
    ;;

    # Блок для проверки статуса сервера
    "--status")
        shift #Для получения имени проверяемого процесса
        if [[ $2 != "" ]]; then
          echo "Too many input arguments. Use --help for list of commands."
        else
          if [[ $1 != "kafka" ]] && [[ $1 != "zookeeper" ]]; then
            echo "Error in 2 parameter. It should be kafka or zookeeper. More information at --help."
          else
            if [[ $1 = "zookeeper" ]]; then
              if ssh -i $KEY_FILEPATH $ADDRESS ps ax | grep zookeeper.properties > $LOG_PATH/zookeeper_status_log.txt; then
                echo "Zookeeper: Running"
                echo "PID and other information you can check in file zookeeper_status_log.txt in $LOG_PATH."
              else
                echo "Zookeeper: Not Running"
              fi
            elif [[ $1 = "kafka" ]]; then
              if ssh -i $KEY_FILEPATH $ADDRESS ps ax | grep server.properties > $LOG_PATH/kafka_status_log.txt; then
                echo "Kafka: Running"
                echo "PID and other information you can check in file kafka_status_log.txt in $LOG_PATH."
              else
                echo "Kafka: Not Running"
              fi
            fi
          fi
        fi
        break
    ;;

    # Блок для остановки выбранного сервера
    "--stop")
        shift #Для получения имени запускаемого процесса
        if [[ $2 != "" ]]; then
          echo "Too many input arguments. Use --help for list of commands."
        else
          if [[ $1 != "kafka" ]] && [[ $1 != "zookeeper" ]]; then
            echo "Error in 2 parameter. It should be kafka or zookeeper. More information at --help."
          else
            if [[ $1 = "zookeeper" ]]; then
              #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска zookeeper
              ssh -i $KEY_FILEPATH $ADDRESS "
              $SCRIPTS_PATH/zookeeper-server-stop "
            else
              #Подключаемся к серверу по ключу KeyName2.pem и выполняем комнаду для запуска kafka
              ssh -i $KEY_FILEPATH $ADDRESS "
              $SCRIPTS_PATH/kafka-server-stop "
            fi
          fi
        fi
        break
    ;;

    #Блок для запуска Java Producer
    "--producer")
      shift # Для получения названия топика
      if [[ $2 != "" ]]; then
        echo "Too many input arguments. Use --help for list of commands."
      else
        if [ -f $EXAMPLES_JAVA_PATH/pom.xml ]; then
          mvn -e  exec > $LOG_PATH/producer_log.txt :java -Dexec.mainClass="io.confluent.examples.clients.cloud.ProducerExample" -f $EXAMPLES_JAVA_PATH -Dexec.args="$JAVA_CONFIG_PATH/java.config $1" > $LOG_PATH/producer.txt
          echo "For log files check producer_log.txt file in $LOG_PATH directory. For results of production check producer.txt file in the same directory."
        else
          echo "Wrong EXAMPLES_JAVA_PATH in config.txt. You should change it to directory with pom.xml file."
        fi
      fi
      break
    ;;

    #Блок для запуска Java Consumer
    "--consumer")
      shift # Для получения названия топика
      if [[ $2 != "" ]]; then
        echo "Too many input arguments. Use --help for list of commands."
      else
        if [ -f $EXAMPLES_JAVA_PATH/pom.xml ]; then
          mvn -e  exec > $LOG_PATH/consumer_log.txt :java -Dexec.mainClass="io.confluent.examples.clients.cloud.ConsumerExample" -f $EXAMPLES_JAVA_PATH -Dexec.args="$JAVA_CONFIG_PATH/java.config $1" > $LOG_PATH/consumer.txt
          echo "For log files check consumer_log.txt file in $LOG_PATH directory. For results of production check consumer.txt file in the same directory."
        else
          echo "Wrong EXAMPLES_JAVA_PATH in config.txt. You should change it to directory with pom.xml file."
        fi
      fi
      break
    ;;

    "--help")
    echo "List of commands structure:"
    echo "1) Start server: --start zookeeper or kafka --config /path_to_your_directory_with_property_files"
    echo "2) Start server with default config: --start zookeeper or kafka (you can change defaut --config directory by changing CONFIG_FILES_LOCAL_PATH in config.txt)."
    echo "3) Stop server: --stop zookeeper or kafka"
    echo "4) Status of the server: --status zookeeper or kafka"
    echo "5) Java Producer: --producer name_of_topic"
    echo "6) Java Consumer: --consumer name_of_topic"
    break
    ;;

    *)
    echo "Such command is undefined. Use --help for information."
    break
    ;;
    esac
    shift
done
