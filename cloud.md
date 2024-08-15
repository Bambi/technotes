# Cloud
## Definitions
Cloud: on demand and scalable access to servers, data and network resources.
MaaS: Metal as a service, provides physical servers where you can install OS or hypervisor of your choice.
IaaS: Infrastructure as a service, provides VM. Ex: Azure, Amazon EC2, GCE
PaaS: Platform as a service, provides a developer platform for Python, Ruby, Node.js, MySQL, RabbitMQ, etc. Ex: Salesforce, AWS Elastic.
SaaS: Software as a service, provides application access. Ex: Office365, salesforces.com, Gmail, Google drive.

## Technologies
[ONOS](https://opennetworking.org/onos/): SDN controller / orchestrator
[Floodlight](https://github.com/floodlight): SDN controller
[OpenDaylight](https://www.opendaylight.org/about/platform-overview):  SDN controller
[Open Compute Project](https://github.com/opencomputeproject): software for managing switches
[ONIE](https://github.com/opencomputeproject/onie): operating system, for bare metal switches, that provides automated provisioning.
[ONAP](https://www.onap.org/about): NFV orchestrator
[OSM](https://osm.etsi.org/): ONAP alternative

## Other Technologies
KVM: linux kernel modules to run a VM.
Qemu: linux command line tools to drive KVM.
OCI (Open Container Initiative): file format specification to describe a container.
[runV](https://github.com/hyperhq): hypervisor to run an OCI file in a VM. The kernel and rootfs are fixed (stored in /usr/lib/hyper).
[Firecracker](https://firecracker-microvm.github.io/): Minimal VM manager (replaces Qemu) to run a container inside a VM. IOW runs a VM with minimal functionality (virtio-net, virtio-block, serial console, and a 1-button keyboard controller used only to stop the microVM).
[runc](https://github.com/opencontainers/runc): lightweight universal run-time container. Required by OCI.
[containerd](https://containerd.io/): daemon runtime which can manage a complete container lifecycle - from image transfer/storage to container execution, supervision and networking. Compatible with OCI. Can run also under Windows. Does not build container images ; this is done by [img](https://github.com/genuinetools/img), [buildah](https://github.com/containers/buildah) or [kaniko](https://github.com/GoogleContainerTools/kaniko).
docker engine: handles docker user interaction. Communicates with containerd.
cri-o:
Kata containers: Wrapper around containers that executes a container inside a lightweight VM. => feels like a container but with increased isolation.
