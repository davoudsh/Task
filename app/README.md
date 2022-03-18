# Assessment - Application

This is an assessment pertaining to a simple HTTP app in Bash that upon query returns the
contents of the S3 bucket in JSON format.

## How it works:

This applicaion is written in Bash and works as a `CGI` (Common Gateway Interface) script in parellel with Apache2 Web server and processes data on the Web server. It is commonly used to process a query from the user that was entered on an HTML page (Web page) and returned as an HTML page. 
The default location for CGI scripts is at `/usr/lib/cgi-bin`. While the Web server is up and running, Upon placing a CGI script in that directory, it can be easily queried via 
`curl http://localhost/cgi-bin/<script_file>` which triggers the script.

In this project, respectively a bash script, a `Dockerfile`, an `ubuntu/apache2` docker image pushed to docker hub, and a helm chart were created which was then installed on `Minikube`.

### Bash CGI Script

In creation of this script, I made use of AWS CLI commands which facilitates the job of listing the contents of Helm Repo Bucket that was created through the Terraform section of this project. AWS credentionals Variables are passed to the command to make the connection feasible:

```
AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY aws s3api list-objects --bucket helmrepo-bucket --output json
```

### Dockerfile

In the Dockerfile, `ubuntu:bionic` was used as the Base Image, and on top of that multiple instructions were added to meet the expectation. Installing, configuring, and starting `Apache2` upon the container start, installing `awscli` and `curl` which is used for health check, adding the CGI Bash script to the default CGI alias directory, exposing the container, and adding a health check for the app are the main instructions added to the Dockerfile.
This images was then built and pushed to my public Docker Registry.

### Helm Chart

A Helm chart was created from scratch and the following modifications were applied to it:

- `Chart.yaml` was modified to match the aplication's properties
- `templates/deployment.yaml` was modified to include environment variables for AWS Key Credentials so that they could be added as environment variales to the pod(s):

```
env:
  - name: "AWS_ACCESS_KEY_ID"
    valueFrom:
      secretKeyRef:
        key:  AWS_ACCESS_KEY_ID
        name: {{ .Release.Name }}-auth
  - name: "AWS_SECRET_ACCESS_KEY"
    valueFrom:
      secretKeyRef:
        key:  AWS_SECRET_ACCESS_KEY
        name: {{ .Release.Name }}-auth          
```

- `templates/secret.yaml` file was added to handle the sensetive AWS Key Credentials:

```
apiVersion: v1
kind: Secret
metadata:
  name: {{ .Release.Name }}-auth
data:
  AWS_ACCESS_KEY_ID: {{ .Values.AWS_ACCESS_KEY_ID | b64enc }}
  AWS_SECRET_ACCESS_KEY: {{ .Values.AWS_SECRET_ACCESS_KEY | b64enc }}
```

- `templates/service.yaml` was modified to include a `nodePort` so that comunication with the app would be possible from ouside the cluster (from a Vagrant Ubuntu box in our case):

```
nodePort: 30007
```

- In `values.yaml` the `replicaCount` was increased from 1 to 3 so that more pods can be added in case the traffic is high and accordingly `autoscaling` was enabled and the `maxReplicas` was reduced to 3:

```
autoscaling:
  enabled: true
  minReplicas: 1
  maxReplicas: 3
  targetCPUUtilizationPercentage: 80
```
The image repository was set to my docker repository where the build Docker image was push to:

```
image:
  repository: docker.io/davoudsh/apache2-s3
  pullPolicy: IfNotPresent
  # Overrides the image tag whose default is the chart appVersion.
  tag: ""
```

The service type was modified from `ClusterIP` to `NodePort` as discussed above:

```
service:
  type: NodePort
```
The AWS Key Credentials' names were also added to this file for reference for `secret.yaml`:

```
AWS_ACCESS_KEY_ID: AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY: AWS_SECRET_ACCESS_KEY
```
- The Helm chart was then installed on `Minikube` which ran on a Vagrant `buntu/bionic` box. Following is the command for helm installation which contains the AWS Key Crendentials' variables. These keys were exported in the Vagrant box before.

```
helm install  apache2-s3 ./apache-s3-chart/ -n myapp --set AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID --set AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
```

- When the pod gets ready, using the following curl command, you can query the app to get a list objects in the helmrepo bucket:

```
curl http://minikube_ip:30007/cgi-bin/list_s3_contents.sh
```
