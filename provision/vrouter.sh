#!/bin/bash
docker restart vrouter_vrouter-kernel-init_1
sleep 40
docker restart vrouter_vrouter-agent_1
