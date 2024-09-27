import { TerraformStack } from "cdktf";
import { SecurityGroup } from "@cdktf/provider-aws/lib/security-group";

export const getSshSecurityGroup = ({ stack, port = 1337 }: { stack: TerraformStack; port?: number; }) => {
  const securityGroup = new SecurityGroup(stack, "security-group", {
    name: `dtksi-ssh-${port}`,
    description: `Allow SSH on port ${port}`,
    ingress: [
      {
        fromPort: port,
        toPort: port,
        protocol: "tcp",
        cidrBlocks: ["0.0.0.0/0"],
      },
    ],
    egress: [
      {
        fromPort: 0,
        toPort: 0,
        protocol: "-1", // Allows all outbound traffic
        cidrBlocks: ["0.0.0.0/0"],
      },
    ],
  });
  return securityGroup
} 