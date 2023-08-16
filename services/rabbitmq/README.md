# Rabbit MQ

Message query server for cluster

## Install

Install from helm chart

## Optimization

To reduce CPU usage when idle:

```sh
RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="+sbwt very_short +sbwtdcpu very_short +sbwtdio very_short"
#or 
RABBITMQ_SERVER_ADDITIONAL_ERL_ARGS="+sbwt none +sbwtdcpu none +sbwtdio none" 
```