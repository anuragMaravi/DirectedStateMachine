import com.rabbitmq.client.*;
import java.io.IOException;
import java.util.concurrent.TimeoutException;

//RabbitMQ Configuration
String EXCHANGE_NAME = "master_exchange";
String userName = "test";
String password = "TeSt";
String virtualHost = "/";
String hostName = "128.237.158.26";
String sensorId = "80ee9a0e-e420-4263-9629-46ce4c3f7ae4";
int port = 5672;

String message = "";

/**
    Stream from the broker 
    When a new message arrives, the message object gets updated
*/
void initializeDataStream() {
  try{
   ConnectionFactory factory = new ConnectionFactory();
   factory.setUsername(userName);
   factory.setPassword(password);
   factory.setVirtualHost(virtualHost);
   factory.setHost(hostName);
   factory.setPort(port);
   Connection connection = factory.newConnection();
   Channel channel = connection.createChannel();
   channel.exchangeDeclare(EXCHANGE_NAME, BuiltinExchangeType.DIRECT);
   String queueName = channel.queueDeclare().getQueue();
   channel.queueBind(queueName, EXCHANGE_NAME, sensorId);

   System.out.println(" [*] Waiting for messages. To exit press CTRL+C");

   Consumer consumer = new DefaultConsumer(channel) {
     @Override
     public void handleDelivery(String consumerTag, Envelope envelope, AMQP.BasicProperties properties, byte[] body) throws IOException {
       message = new String(body, "UTF-8");                      // Message in unicode format
       message = message.replace('\'','\"');                     // Convert the unicode string to java compatible string
       message = message.replace("u\"","\"");                    // This message updates when a new message arrives
       redraw();
       
     }
   };
   channel.basicConsume(queueName, true, consumer);

  } catch(IOException i) {
    println(i);
  } catch(TimeoutException i) {
    println(i);
  }  
  
}
