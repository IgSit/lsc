curl --silent --location "https://github.com/weaveworks/eksctl/releases/download/0.135.0/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin

aws configure

eksctl create cluster --name my-cluster \
  --region us-east-1 \
  --nodegroup-name my-nodes \
  --node-type t2.micro \
  --nodes 3 \
  --nodes-min 1 \
  --nodes-max 4 \
  --managed \
  --role-arn arn:aws:iam::143928431044:role/LabRole \
  --resources-vpc-config subnetIds=subnet-08da675de240116da,subnet-08add95be444ad43d,securityGroupIds=sg-03457e24b8931c70e

aws eks create-nodegroup --cluster-name my-cluster \
  --nodegroup-name my-nodes \
  --node-role arn:aws:iam::143928431044:role/LabRole \
  --subnet subnet-08da675de240116da subnet-08add95be444ad43d \
  --instance-types t3.medium \
  --scaling-config minSize=1,maxSize=2,desiredSize=1 \
  --disk-size 20 \
  --ami-type AL2_x86_64

aws eks --region us-east-1 update-kubeconfig --name my-cluster

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm repo add nfs-ganesha-server-and-external-provisioner https://kubernetes-sigs.github.io/nfs-ganesha-server-and-external-provisioner/
helm install my-release nfs-ganesha-server-and-external-provisioner/nfs-server-provisioner \
  --set storageClass.defaultClass=true \
  --set storageClass.name=nfs \

kubectl apply -f pvc.yaml
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl apply -f job.yaml
