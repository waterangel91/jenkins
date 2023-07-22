#Ref: https://medium.com/swlh/quick-and-simple-how-to-setup-jenkins-distributed-master-slave-build-on-kubernetes-37f3d76aae7d

minikube --memory 65536 --cpus 16 start
kubectl create namespace jenkins
kubectl config set-context --current --namespace=jenkins
kubectl create serviceaccount jenkins-master -n jenkins
minikube mount /home/remichu/Kubernetes/persistent_volume/jenkins/jenkins_home:/pv

#Deploy
cd /home/remichu/Kubernetes/Github/jenkins/Kubernetes_yml
kubectl apply -f jenkins_pv.yml
kubectl apply -f jenkins_pv_claim.yml
kubectl apply -f jenkins_service.yml
kubectl apply -f jenkins_master_role.yml
kubectl apply -f jenkins_deploy.yml
#kubectl apply -f secret.yml

#kubectl port-forward -n jenkins service/jenkins-master 80:80

#sonar
#https://docs.sonarsource.com/sonarqube/9.6/setup-and-upgrade/deploy-on-kubernetes/deploy-sonarqube-on-kubernetes/?gads_campaign=SQ-Hroi-PMax&gads_ad_group=Global&gads_keyword=&gclid=Cj0KCQjwk96lBhDHARIsAEKO4xadwOIPgF_yZaNckQG2CXmvaOREpL-ztcrh2HAWxrxRDPXBGiEEuv4aAuK2EALw_wcB
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube
helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube
kubectl port-forward sonarqube-sonarqube-0 9000:9000 -n sonarqube

#Access the pod via nodeport
kubectl port-forward -n jenkins pod/jenkins-master-679b4ff58b-xqg6f 8080:8080
kubectl exec --stdin --tty pod/jenkins-master-679b4ff58b-xqg6f -- /bin/bash

#Access the pod via cluster IP Load Balancer
minikube tunnel
kubectl get service jenkins-master
#use the external IP to access


#get jenkins-master secret token for kubernetes
kubectl get secret $(kubectl get sa jenkins-master -n jenkins -o jsonpath={.secrets[0].name}) -n jenkins -o jsonpath={.data.token} | base64 --decode

#helm chart
helm install my-jenkins jenkinsci/jenkins --version 4.4.1
