#Ref: https://medium.com/swlh/quick-and-simple-how-to-setup-jenkins-distributed-master-slave-build-on-kubernetes-37f3d76aae7d

minikube --memory 65536 --cpus 16 start
kubectl create namespace jenkins
kubectl config set-context --current --namespace=jenkins
kubectl create serviceaccount jenkins-master -n jenkins
minikube mount /home/remichu/Kubernetes/persistent_volume/jenkins/jenkins_home:/pv

#Deploy
cd /home/remichu/Kubernetes/Kubernetes_yml
kubectl apply -f jenkins_pv.yml
kubectl apply -f jenkins_pv_claim.yml
kubectl apply -f jenkins_deploy.yml
kubectl apply -f jenkins_service.yml
kubectl apply -f jenkins_master_role.yml
kubectl apply -f secret.yml

#sonar
#https://docs.sonarsource.com/sonarqube/9.6/setup-and-upgrade/deploy-on-kubernetes/deploy-sonarqube-on-kubernetes/?gads_campaign=SQ-Hroi-PMax&gads_ad_group=Global&gads_keyword=&gclid=Cj0KCQjwk96lBhDHARIsAEKO4xadwOIPgF_yZaNckQG2CXmvaOREpL-ztcrh2HAWxrxRDPXBGiEEuv4aAuK2EALw_wcB
helm repo add sonarqube https://SonarSource.github.io/helm-chart-sonarqube
helm repo update
kubectl create namespace sonarqube
helm upgrade --install -n sonarqube sonarqube sonarqube/sonarqube
kubectl port-forward sonarqube-sonarqube-0 9000:9000 -n sonarqube

#Access the pod
kubectl port-forward -n jenkins jenkins-master-679b4ff58b-hh6l5 8080:8080
kubectl exec --stdin --tty jenkins-master-679b4ff58b-hh6l5 -- /bin/bash


#get jenkins-master secret token for kubernetes
kubectl get secret $(kubectl get sa jenkins-master -n jenkins -o jsonpath={.secrets[0].name}) -n jenkins -o jsonpath={.data.token} | base64 --decode