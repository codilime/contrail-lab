# contrail-lab

This project helps to create virtual machine with Juniper Contrail controller
on private OpenStack instance within CodiLime.

Notice: a lot of stuff is in just in todo stage.

## Project leaders

Current project leader is Michał Kostrzewa, so ask him anything :)

# Known limitations

- currently project is strictly tied to the OpenStack instance in CodiLime
  due hard-coded variables
- private key and access credentials to OpenStack in jenkins job is a security issue.
- certain fields in jenkins jobs should not be modified.
- there is a limit of instances on OpenStack (project constraint)

# Requirements

- have access to OpenStack project named 'contrail-lab',
  more on [wiki](https://codilime.atlassian.net/wiki/spaces/COD/pages/12877953/OpenStack)
- your credentials to OpenStack.
- OpenStack project must have enough resources to create new instance,
  for now ask on [rocket chat channel](https://codilime.rocket.chat/channel/juniper-contrail-lab)
- private+public ssh keys generated for this project only,
  private key cannot be password protected, and is used by jenkins to provision
  virtual machine
- optional - access to jenkins instance to run job to create virtual machine on
  OpenStack, ask for access on chat

# Contributing

- create GitHub issues.
- create pull requests with optional issue reference from GitHub.
