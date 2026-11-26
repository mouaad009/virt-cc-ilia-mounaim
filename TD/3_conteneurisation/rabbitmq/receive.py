import pika


def callback(channel, method, properties, body):
    print(f" [x] Received {body!r}", flush=True)


connection = pika.BlockingConnection(pika.ConnectionParameters(host="localhost"))
try:
    channel = connection.channel()
    channel.queue_declare(queue="hello")
    channel.basic_consume(queue="hello", on_message_callback=callback, auto_ack=True)
    print(" [*] Waiting for messages. To exit press CTRL+C", flush=True)
    channel.start_consuming()
except KeyboardInterrupt:
    pass
finally:
    if connection.is_open:
        connection.close()
