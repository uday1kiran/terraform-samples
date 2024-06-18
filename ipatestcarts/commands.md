- Open a terminal or command prompt.
- Navigate to the project directory where the `helmfile.yaml` file is located.
- Run the following command to deploy the applications:

```
helmfile sync
```

Helmfile will read the `helmfile.yaml` file, fetch the specified Helm charts from the repositories, and deploy the applications to your Kubernetes cluster.

Step 8: Verify the deployment
- Run the following command to check the status of the deployed applications:

```
kubectl get pods
```
