import { TerraformStack } from "cdktf";
import { DataAwsAmi } from "@cdktf/provider-aws/lib/data-aws-ami";

export const getAmi = ({
  stack,
  name = "dtksi-debian-12-amd64",
  deviceType = "ebs",
  virtualType = "hvm"
}: {
  stack: TerraformStack;
  name?: string;
  deviceType?: string;
  virtualType?: string;
}) => {
  const dtksiOwnerAccount = process.env.AWS_OWNER_ID;
  if (!dtksiOwnerAccount) {
    throw new Error("AWS_OWNER_ID is not set");
  }
  return new DataAwsAmi(stack, "ami", {
    mostRecent: true,
    filter: [
      {
        name: "name",
        values: [name],
      },
      {
        name: "root-device-type",
        values: [deviceType],
      },
      {
        name: "virtualization-type",
        values: [virtualType],
      }
    ],
    owners: [dtksiOwnerAccount]
  });
} 