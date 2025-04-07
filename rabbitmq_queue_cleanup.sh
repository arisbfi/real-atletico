
#!/bin/bash

# Set RabbitMQ connection details
RABBITMQ_HOST="localhost"
RABBITMQ_PORT="15672"
RABBITMQ_USER="guest"
RABBITMQ_PASS="guest"
RABBITMQ_VHOST="%2F"  # Default vhost (/) URL-encoded

# Auth string for basic authentication
AUTH="-u $RABBITMQ_USER:$RABBITMQ_PASS"

# Define prefixes to match
QUEUE_PREFIX="q.lgs."
EXCHANGE_PREFIX="x.lgs."

# Step 1: Get and parse queues with the prefix q.lgs.* without using jq
echo "Listing queues with prefix $QUEUE_PREFIX..."
QUEUES_JSON=$(curl -s $AUTH -X GET "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/queues/$RABBITMQ_VHOST")

# Save the JSON to a temporary file for processing
echo "$QUEUES_JSON" > /tmp/rabbitmq_queues.json

# Use grep and sed to extract queue names (simplified parsing)
QUEUES=$(grep -o "\"name\":\"$QUEUE_PREFIX[^\"]*\"" /tmp/rabbitmq_queues.json | sed 's/"name":"//g' | sed 's/"//g')

# Step 2: Delete each matching queue
if [ -z "$QUEUES" ]; then
    echo "No queues found with prefix $QUEUE_PREFIX"
else
    echo "Deleting the following queues:"
    echo "$QUEUES"

    for QUEUE in $QUEUES; do
        echo "Deleting queue: $QUEUE"
        ENCODED_QUEUE=$(echo "$QUEUE" | sed 's/\//\%2F/g')
        curl -s $AUTH -X DELETE "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/queues/$RABBITMQ_VHOST/$ENCODED_QUEUE"
        echo ""
    done
fi

# Step 3: Get and parse exchanges with the prefix x.lgs.* without using jq
echo -e "\nListing exchanges with prefix $EXCHANGE_PREFIX..."
EXCHANGES_JSON=$(curl -s $AUTH -X GET "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/exchanges/$RABBITMQ_VHOST")

# Save the JSON to a temporary file for processing
echo "$EXCHANGES_JSON" > /tmp/rabbitmq_exchanges.json

# Use grep and sed to extract exchange names (simplified parsing)
EXCHANGES=$(grep -o "\"name\":\"$EXCHANGE_PREFIX[^\"]*\"" /tmp/rabbitmq_exchanges.json | sed 's/"name":"//g' | sed 's/"//g')

# Step 4: Delete each matching exchange
if [ -z "$EXCHANGES" ]; then
    echo "No exchanges found with prefix $EXCHANGE_PREFIX"
else
    echo "Deleting the following exchanges:"
    echo "$EXCHANGES"

    for EXCHANGE in $EXCHANGES; do
        echo "Deleting exchange: $EXCHANGE"
        ENCODED_EXCHANGE=$(echo "$EXCHANGE" | sed 's/\//\%2F/g')
        curl -s $AUTH -X DELETE "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/exchanges/$RABBITMQ_VHOST/$ENCODED_EXCHANGE"
        echo ""
    done
fi

# Clean up temporary files
rm -f /tmp/rabbitmq_queues.json /tmp/rabbitmq_exchanges.json

echo "Cleanup complete!"
