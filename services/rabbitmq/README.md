# Rabbit MQ

Message query server for cluster

## Optimization

To reduce CPU usage when idle:

```
RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="+sbwt very_short +sbwtdcpu very_short +sbwtdio very_short"
#or 
RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="+sbwt none +sbwtdcpu none +sbwtdio none" 
```