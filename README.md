#################################################################
# This module will create A Public Exposed Fargate Service with Private Networking
#
# This architecture deploys your container into a private subnet. 
# The containers do not have direct internet access, or a public IP address.
# Their outbound traffic must go out via a NAT gateway, and receipients of 
# requests from the containers will just see the request orginating from 
# the IP address of the NAT gateway. However, inbound traffic from the public
# can still reach the containers because there is a public facing load balancer
# that can proxy traffic from the public to the containers in the private subnet.
#################################################################


![private subnet public load balancer](images/private-task-public-loadbalancer.png)