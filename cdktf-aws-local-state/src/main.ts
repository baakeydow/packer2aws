
import { App, TerraformStack, TerraformOutput } from "cdktf";
import { Construct } from "constructs";
import { AwsProvider } from "@cdktf/provider-aws/lib/provider";
import { Instance } from "@cdktf/provider-aws/lib/instance";
import { getSshSecurityGroup } from "./ssh-sg";
import { getAmi } from "./ami";

class DtksiStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);

    new AwsProvider(this, "AWS", {
      region: process.env.AWS_REGION || "eu-west-2",
    });

    const ami = getAmi({ stack: this })

    if (!ami?.id) {
      throw new Error(`Failed to retrieve AMI => ${ami.name}`);
    }

    const securityGroup = getSshSecurityGroup({ stack: this })

    if (!securityGroup?.id) {
      throw new Error("Failed to retrieve security group");
    }

    const ec2Instance = new Instance(this, "compute", {
      ami: ami.id,
      instanceType: process.env.EC2_INSTANCE_TYPE || "t2.micro",
      vpcSecurityGroupIds: [securityGroup.id],
    });

    if (!ec2Instance?.publicIp) {
      throw new Error("Failed to retrieve public IP");
    }

    new TerraformOutput(this, "public_ip", {
      value: ec2Instance.publicIp,
    });
  }
}

const app = new App();
new DtksiStack(app, "dtksi-stack");

app.synth();

