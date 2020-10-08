#Команды для запуска Java Cosumer/Producer на локальной машине
cd /home/misha/examples/clients/cloud/java  (Вместо /home/misha/ нужно поставить путь до директории с файлами examples java кода)
#Команда для запуска Consumer
mvn -e  exec:java -Dexec.mainClass="io.confluent.examples.clients.cloud.ConsumerExample" -Dexec.args="/home/misha/examples/java.config test1"
#Команда для запуска Producer
mvn -e  exec:java -Dexec.mainClass="io.confluent.examples.clients.cloud.ProducerExample" -Dexec.args="/home/misha/examples/java.config test1"

java.config нужно положить в корень examples, взятую по этой ссылке: https://github.com/confluentinc/examples
